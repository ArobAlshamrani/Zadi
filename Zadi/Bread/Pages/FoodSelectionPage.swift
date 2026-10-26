import SwiftUI

// The entry screen owns navigation into a fresh toast recipe.
struct FoodSelectionPage: View {
    let character: String
    @Environment(\.dismiss) private var dismiss
    @State private var showsToast = false
    @State private var showsRice = false
    @State private var showsPancake = false

    var body: some View {
        page
            .navigationBarBackButtonHidden(true)
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
    }

    @ViewBuilder
    private var page: some View {
        if showsToast {
            ToastView(character: character, returnToFoodSelection: { showsToast = false })
        } else if showsPancake {
            PancakePlateView()
                .overlay(alignment: .topLeading) {
                    Button {
                        showsPancake = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 52, height: 52)
                            .background(.white.opacity(0.85), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(24)
                    .accessibilityLabel("الرجوع لاختيار الوجبة")
                }
        } else if showsRice {
            GeometryReader { geometry in
                let canvas = CGSize(width: 1366, height: 1100)
                let scale = min(geometry.size.width / canvas.width, geometry.size.height / canvas.height)
                RiceMealView(character: character)
                    .frame(width: canvas.width, height: canvas.height)
                    .scaleEffect(scale)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(alignment: .topLeading) {
                        Button {
                            showsRice = false
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .bold))
                                .frame(width: 52, height: 52)
                                .background(.white.opacity(0.85), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(24)
                        .accessibilityLabel("الرجوع لاختيار الوجبة")
                    }
            }
            .ignoresSafeArea()
        } else {
            GeometryReader { geometry in
                // Keep geometry-derived frames valid even during transient layout changes.
                let width = geometry.size.width.isFinite ? max(0, geometry.size.width) : 0
                let height = geometry.size.height.isFinite ? max(0, geometry.size.height) : 0
                let contentWidth = max(0, width - 32)
                let spacing: CGFloat = 18

                ZStack(alignment: .bottomLeading) {
                    Image("Plate Background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                        .accessibilityHidden(true)

                    Image("\(character) select page")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.22, height: height * 0.28)
                        .padding(.leading, width * 0.015)
                        .accessibilityHidden(true)

                    VStack(spacing: spacing * 0.5) {
                        Text("اختار وجبتك لليوم !")
                            .font(.title.bold())
                            .foregroundStyle(Color(red: 0.20, green: 0.27, blue: 0.65))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)

                        ScrollView(.horizontal) {
                            HStack(spacing: spacing) {
                                MealSelectionButton(title: "خبز", image: "Bread") {
                                    showsToast = true
                                }
                                MealSelectionButton(title: "بانكيك", image: "Pancake") {
                                    showsPancake = true
                                }
                                MealSelectionButton(title: "وجبات خفيفة", image: "popcorn") {
                                    // This meal will be connected when its screen is available.
                                }
                                MealSelectionButton(title: "أرز", image: "RiceBowl") {
                                    showsRice = true
                                }
                            }
                            .padding(12)
                        }
                        .frame(width: min(contentWidth, 598), height: 159)
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .frame(width: contentWidth)
                    .position(x: width * 0.5, y: height * 0.785)
                }
                .frame(width: width, height: height)
                .overlay(alignment: .topLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(red: 0.30, green: 0.40, blue: 0.55))
                            .frame(width: 52, height: 52)
                            .background(.white.opacity(0.85), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, max(geometry.safeAreaInsets.leading + 8, width * 0.055 - 26))
                    .padding(.top, max(geometry.safeAreaInsets.top + 8, height * 0.09 - 26))
                    .accessibilityLabel("الرجوع لنبدأ")
                }
            }
            .ignoresSafeArea()

        }
    }
}

private struct MealSelectionButton: View {
    let title: LocalizedStringResource
    let image: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FoodCardLabel(title: Text(title), image: image)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}

#Preview(traits: .landscapeLeft) {
    FoodSelectionPage(character: "girl")
}
