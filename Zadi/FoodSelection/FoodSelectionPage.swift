import SwiftUI

// Open the chosen meal from this menu; entering Bread starts a fresh recipe.
struct FoodSelectionPage: View {
    // Use the selected boy or girl on this page and pass the choice to Bread and Rice.
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

    // Each meal's back action clears its flag to show the menu again.
    @ViewBuilder
    private var page: some View {
        if showsToast {
            ToastView(character: character, returnToFoodSelection: { showsToast = false })
        } else if showsPancake {
            // The Pancake screen manages its character internally.
            PancakePlateView()
                .overlay(alignment: .topLeading) {
                    CircleBackButton(label: Text("الرجوع لاختيار الوجبة")) {
                        showsPancake = false
                    }
                    .padding(24)
                }
        } else if showsRice {
            GeometryReader { geometry in
                // Scale the Rice screen from its original canvas to fit the available space.
                let canvas = CGSize(width: 1366, height: 1100)
                let scale = min(geometry.size.width / canvas.width, geometry.size.height / canvas.height)
                RiceMealView(character: character)
                    .frame(width: canvas.width, height: canvas.height)
                    .scaleEffect(scale)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(alignment: .topLeading) {
                        CircleBackButton(label: Text("الرجوع لاختيار الوجبة")) {
                            showsRice = false
                        }
                        .padding(24)
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
                                FoodChoiceButton(title: Text("خبز"), image: "Bread") {
                                    showsToast = true
                                }
                                FoodChoiceButton(title: Text("بانكيك"), image: "PancakeSelect") {
                                    showsPancake = true
                                }
                                FoodChoiceButton(title: Text("وجبات خفيفة"), image: "popcorn") {
                                    // This meal will be connected when its screen is available.
                                }
                                FoodChoiceButton(title: Text("أرز"), image: "RiceBowl") {
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
                    CircleBackButton(label: Text("الرجوع لنبدأ")) {
                        // Leave the meal menu and return to the Mission screen.
                        dismiss()
                    }
                    .padding(.leading, max(geometry.safeAreaInsets.leading + 8, width * 0.055 - 26))
                    .padding(.top, max(geometry.safeAreaInsets.top + 8, height * 0.09 - 26))
                }
            }
            .ignoresSafeArea()

        }
    }
}

#Preview(traits: .landscapeLeft) {
    FoodSelectionPage(character: "girl")
}
