import SwiftUI

// MARK: - Shared Page Layout
// Sandwich and Content are view types supplied by the caller, so every page can share this layout.
struct ToastPageLayout<Sandwich: View, Content: View>: View {
    let showsBackButton: Bool
    let backLabel: String
    let goBack: () -> Void
    let sandwich: (CGFloat) -> Sandwich
    let content: (CGFloat) -> Content

    // MARK: - Setup
    // @ViewBuilder lets each closure combine several views.
    // @escaping allows the layout to store these closures and call them later.
    init(
        showsBackButton: Bool,
        backLabel: String,
        goBack: @escaping () -> Void,
        @ViewBuilder sandwich: @escaping (CGFloat) -> Sandwich,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self.showsBackButton = showsBackButton
        self.backLabel = backLabel
        self.goBack = goBack
        self.sandwich = sandwich
        self.content = content
    }

    // MARK: - UI
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let isPortrait = height > width
            // Scale the bread and toppings together to keep their proportions consistent.
            let sandwichSize = (isPortrait
                ? min(width * 0.75, height * 0.40)
                : min(width * 0.34, height * 0.52)) * 0.75
            let cardStyle = FoodLayoutStyle.responsive(to: geometry.size)
            let cardWorkspaceWidth = FoodLayoutStyle.workspaceWidth(for: geometry.size)
            let buttonWidth = cardStyle.cardWidth
            // I previously used let buttonWidth = min(140, max(44, (width - 68) / 3)).
            // The plate center is at y = 250 in the 1194 x 834 background.
            // Match the background's fill scale so the toast stays on the plate when cropped.
            let backgroundScale = max(width / 1194, height / 834)
            let plateY = height / 2 + (250 - 834 / 2) * backgroundScale

            ZStack {
                Image("Plate Background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()

                sandwich(sandwichSize)
                    .position(x: width * 0.5, y: plateY)
                    // The toast is only a preview, so it should not intercept taps.
                    .allowsHitTesting(false)

                // I give every step the same workspace and shared card sizes.
                // I size the cards once, rather than scaling the entire row a second time.
                content(buttonWidth)
                    .environment(\.foodLayoutStyle, cardStyle)
                    .environment(\.layoutDirection, .rightToLeft)
                    .frame(width: cardWorkspaceWidth)
                    .position(x: width * 0.5, y: height * FoodLayoutStyle.rowCenterFraction)
                // I keep my previous scaling here for reference.
    //                 // I place every ingredient row at Pancake's height, independently of Next or Finish.
    //                 // I scale the cards for larger iPads without shrinking them on the mini.
    //                 content(buttonWidth)
    //                     .environment(\.layoutDirection, .rightToLeft)
    //                     .scaleEffect(max(1, min(width / 1194, height / 834)))
    //                     .position(x: width * 0.5, y: height * 0.75)
                // I keep my previous row layout here for reference.
                // VStack(spacing: 12) {
                // Spacer()
                // content(buttonWidth)
                // .environment(\.layoutDirection, .rightToLeft)
                // Spacer()
                // .frame(height: height * 0.075)
                // }
                // .frame(width: width, height: height)
                // .position(x: width * 0.5, y: height * 0.5)

                // ToastView supplies ZadiTopControls and always disabled this older Back button.
                // Previous unused Back-button branch:
//                 if showsBackButton {
//                     CircleBackButton(label: Text(backLabel), action: goBack)
//                         .position(
//                             x: max(geometry.safeAreaInsets.leading + 34, width * 0.055),
//                             y: max(geometry.safeAreaInsets.top + 34, height * 0.09)
//                         )
//                         .zIndex(100)
//                 }
            }
            .frame(width: width, height: height)
        }
        .ignoresSafeArea()
        // Physical positions stay fixed; Arabic direction is scoped to the controls above.
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - Sandwich Layers
struct SandwichView: View {
    let size: CGFloat
    let selectedBase: ToastBase?
    let selectedProtein: ToastProtein?
    let selectedVegetables: Set<ToastVegetable>
    let selectedFruits: Set<ToastFruit>

    // MARK: - UI
    var body: some View {
        ZStack {

            // Keep the same bread underneath every recipe step.
            // Layer the spread and protein above it, then the fruit or vegetables.
            centeredArtwork("toast", canvas: ToastArtwork.breadCanvas, bounds: ToastArtwork.breadBounds,
                            scale: size / ToastArtwork.breadBounds.width)
                .zIndex(0)

            // if let unwraps the optional, so the spread is drawn only when one is selected.
            if let base = selectedBase {
                centeredArtwork(base.toppingImage, canvas: base.canvasSize, bounds: base.artworkBounds,
                                scale: size * base.spreadScale
                                    / max(base.artworkBounds.width, base.artworkBounds.height))
                    .offset(y: base == .chocolate ? size * ToastArtwork.sweetLayerOffsetY : 0)
                    .id(base)
                    .zIndex(1)
                    .transition(.opacity)
            }

            if let protein = selectedProtein {
                topping(protein.toppingImage, size: size * ToastArtwork.proteinScale)
                    .id(protein)
                    .zIndex(2)
                    .transition(.opacity)
            }

            // Sets have no fixed order; filtering allCases keeps the drawing order predictable.
            if !selectedVegetables.isEmpty {
                ForEach(ToastVegetable.allCases.filter { selectedVegetables.contains($0) }) { vegetable in
                    topping(vegetable.toppingImage, size: size * vegetable.scale)
                        .zIndex(vegetable.layer)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
            }

            if !selectedFruits.isEmpty {
                ForEach(ToastFruit.allCases.filter { selectedFruits.contains($0) }) { fruit in
                    topping(fruit.piecesImage, size: size * fruit.scale)
                        .rotationEffect(.degrees(fruit.rotation))
                        .offset(
                            x: size * fruit.offset.width,
                            y: size * (fruit.offset.height + ToastArtwork.sweetLayerOffsetY)
                        )
                        .zIndex(fruit.layer)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: - Artwork Helpers
    // Center the visible artwork rather than the PNG canvas, which includes uneven transparent margins.
    private func centeredArtwork(_ imageName: String, canvas: CGSize, bounds: CGRect,
                                 scale: CGFloat) -> some View {
        Image(imageName)
            .resizable()
            .frame(width: canvas.width * scale, height: canvas.height * scale)
            .offset(
                x: (canvas.width / 2 - bounds.midX) * scale,
                y: (canvas.height / 2 - bounds.midY) * scale
            )
            .frame(width: size, height: size)
    }

    private func topping(_ imageName: String, size: CGFloat) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }

}

// MARK: - Preview
#Preview("Layered fruit", traits: .landscapeLeft) {
    SandwichView(
        size: 360,
        selectedBase: .chocolate,
        selectedProtein: nil,
        selectedVegetables: [],
        selectedFruits: Set(ToastFruit.allCases)
    )
}

#Preview("Bread layout — Arabic", traits: .landscapeLeft) {
    ToastView(character: "boy")
        .environment(\.layoutDirection, .rightToLeft)
}

// MARK: - Removed Back Button Helper (Reference Only)
// Bread uses ZadiTopControls for its visible Back and Listen buttons.
// struct CircleBackButton: View {
//     let label: Text
//     let action: () -> Void
//     
//     var body: some View {
//         Button(action: action) {
//             Image(systemName: "chevron.left")
//                 .font(.system(size: 22, weight: .bold))
//                 .foregroundStyle(Color(red: 0.30, green: 0.40, blue: 0.55))
//                 .frame(width: 52, height: 52)
//                 .background(.white.opacity(0.85), in: Circle())
//                 .shadow(color: .black.opacity(0.12), radius: 5, y: 3)
//         }
//         .buttonStyle(.plain)
//         .accessibilityLabel(label)
//     }
// }
