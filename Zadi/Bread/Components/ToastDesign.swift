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
            let buttonWidth = min(140, max(44, (width - 68) / 3))
            // Follow the plate center even when aspect-fill crops the background.
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
                    .allowsHitTesting(false)

                VStack(spacing: 12) {
                    Spacer()
                    content(buttonWidth)
                        .environment(\.layoutDirection, .rightToLeft)
                    Spacer()
                        .frame(height: height * 0.075)
                }
                .frame(width: width, height: height)
                .position(x: width * 0.5, y: height * 0.5)

                if showsBackButton {
                    Button(action: goBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(red: 0.30, green: 0.40, blue: 0.55))
                            .frame(width: 52, height: 52)
                            .background(.white.opacity(0.85), in: Circle())
                            .shadow(color: .black.opacity(0.12), radius: 5, y: 3)
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: max(geometry.safeAreaInsets.leading + 34, width * 0.055),
                        y: max(geometry.safeAreaInsets.top + 34, height * 0.09)
                    )
                    .zIndex(100)
                    .accessibilityLabel(backLabel)
                }
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
            breadLayer(size: size)
                .zIndex(0)

            // if let unwraps the optional, so the spread is drawn only when one is selected.
            if let base = selectedBase {
                SpreadLayer(base: base, size: size)
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
                    Image(fruit.piecesImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * fruit.scale, height: size * fruit.scale)
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
    // Center the visible bread rather than the PNG canvas, which includes uneven transparent margins.
    private func breadLayer(size: CGFloat) -> some View {
        let canvas = ToastArtwork.breadCanvas
        let bounds = ToastArtwork.breadBounds

        let breadWidth = size
        let breadHeight = size * bounds.height / bounds.width
        let scaleX = breadWidth / bounds.width
        let scaleY = breadHeight / bounds.height

        return Image("toast")
            .resizable()
            .frame(width: canvas.width * scaleX, height: canvas.height * scaleY)
            .offset(
                x: (canvas.width / 2 - bounds.midX) * scaleX,
                y: (canvas.height / 2 - bounds.midY) * scaleY
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

// MARK: - Spread Artwork
// Use visible artwork bounds so transparent margins do not make the spread look off-center.
private struct SpreadLayer: View {
    let base: ToastBase
    let size: CGFloat

    // MARK: - UI
    var body: some View {
        let canvas = base.canvasSize
        let bounds = base.artworkBounds
        let scale = size * base.spreadScale / max(bounds.width, bounds.height)

        Image(base.toppingImage)
            .resizable()
            .frame(width: canvas.width * scale, height: canvas.height * scale)
            .offset(
                x: (canvas.width / 2 - bounds.midX) * scale,
                y: (canvas.height / 2 - bounds.midY) * scale
            )
            .frame(width: size, height: size)
    }
}
