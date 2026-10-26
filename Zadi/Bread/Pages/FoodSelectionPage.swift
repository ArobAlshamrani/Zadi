import SwiftUI

// The entry screen owns navigation into a fresh toast recipe.
struct FoodSelectionPage: View {
    @State private var showsToast = false
    @State private var showsComingSoon = false

    var body: some View {
        if showsToast {
            ToastView(returnToFoodSelection: { showsToast = false })
        } else {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let spacing: CGFloat = 18

                ZStack(alignment: .bottomLeading) {
                    Image("Plate Background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                        .accessibilityHidden(true)

                    Image("girl select page")
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
                                    showsComingSoon = true
                                }
                                MealSelectionButton(title: "وجبات خفيفة", image: "popcorn") {
                                    showsComingSoon = true
                                }
                                MealSelectionButton(title: "أرز", image: "Rice") {
                                    showsComingSoon = true
                                }
                            }
                            .padding(12)
                        }
                        .frame(width: min(width - 32, 598), height: 159)
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .frame(width: width - 32)
                    .position(x: width * 0.5, y: height * 0.785)
                }
                .frame(width: width, height: height)
            }
            .ignoresSafeArea()
            .alert("قريبًا", isPresented: $showsComingSoon) {
                Button("حسنًا", role: .cancel) {}
            } message: {
                Text("هذه الوجبة غير متاحة بعد. يمكنك اختيار الخبز لتحضير شطيرتك!")
            }
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
    FoodSelectionPage()
}
