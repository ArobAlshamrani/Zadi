
import SwiftUI
// MARK: - Meal Options
enum MealOption: String, Hashable {
    case pancake, bread, rice, cereal, pasta

    var title: String {
        switch self {
        case .pancake: return "بانكيك"
        case .bread: return "خبز"
        case .rice: return "أرز"
        case .cereal: return "كورن فليكس"
        case .pasta: return "مكرونة"
        }
    }

    var image: String {
        switch self {
        case .pancake: return "MealPancake"
        case .bread: return "MealBread"
        case .rice: return "MealRice"
        case .cereal: return "MealCereal"
        case .pasta: return "MealPasta"
        }
    }
}

// MARK: - Meal Selection
struct MealSelectionView: View {

    let character: String
    
    // MARK: - Audio

    @Environment(\.dismiss) private var dismiss
    @Environment(\.returnToHome) private var returnToHome

    // MARK: - Navigation & Feedback
    @State private var pressedMeal: MealOption?
    @State private var selectedMeal: MealOption?
    @State private var showDestination = false
    @State private var isTransitioning = false

    private var isGirl: Bool {
        character == "girl"
    }

    private var characterImage: String {
        isGirl ? "MealSelectionGirl" : "MealSelectionBoy"
    }

    private var instruction: String {
        isGirl ? "اختاري وجبتك لليوم!" : "اختر وجبتك لليوم!"
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let cardWidth = width * 0.108
            let cardHeight = height * 0.145

            ZStack {

                // MARK: - Background
                Image("MealBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()

                // MARK: - Character
                CharacterPresentation(character: character, imageName: characterImage)

                // MARK: - Instruction
                Text(instruction)
                    .font(.system(
                        size: height * 0.055,
                        weight: .bold
                    ))
                    .foregroundStyle(
                        Color(red: 0.17, green: 0.29, blue: 0.70)
                    )
                    .position(
                        x: width * 0.50,
                        y: height * 0.60
                    )

                // MARK: - First Row (3 Meals)
                HStack(spacing: width * 0.028) {

                    mealButton(.pancake,
                        width: cardWidth,
                        height: cardHeight)

                    mealButton(.bread,
                        width: cardWidth,
                        height: cardHeight)

                    mealButton(.rice,
                        width: cardWidth,
                        height: cardHeight)
                }
                .position(
                    x: width * 0.50,
                    y: height * 0.715
                )

                // MARK: - Second Row (2 Meals)
                HStack(spacing: width * 0.028) {

                    mealButton(.cereal,
                        width: cardWidth,
                        height: cardHeight)

                    mealButton(.pasta,
                        width: cardWidth,
                        height: cardHeight)
                }
                .position(
                    x: width * 0.50,
                    y: height * 0.895
                )

            
                // MARK: - Back Button
                Button {
                    Coach.stopVoice()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(
                            size: height * 0.035,
                            weight: .bold
                        ))
                        .foregroundStyle(
                            Color(red: 0.20, green: 0.30, blue: 0.45)
                        )
                        .frame(
                            width: height * 0.10,
                            height: height * 0.10
                        )
                        .background(
                            Color.white.opacity(0.35),
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("رجوع")
                .position(
                    x: width * 0.07,
                    y: height * 0.10
                )
                .zIndex(10)

                // MARK: - Sound Button
                Button {
                    playMealAudio()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(
                            size: height * 0.035,
                            weight: .bold
                        ))
                        .foregroundStyle(
                            Color(red: 0.20, green: 0.30, blue: 0.45)
                        )
                        .frame(
                            width: height * 0.10,
                            height: height * 0.10
                        )
                        .background(
                            Color.white.opacity(0.35),
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("إعادة تشغيل آخر تسجيل")
                .position(
                    x: width * 0.93,
                    y: height * 0.10
                )
                .zIndex(10)


            }
            .frame(width: width, height: height)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            Coach.stopVoice()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showDestination) {
            if let selectedMeal {
                destination(for: selectedMeal)
            }
        }
    }
    
    // MARK: - Meal Selection Audio
    private func playMealAudio() {
        IngredientVoice.shared.replayLast()
    }


    // MARK: - Food Card
    private func mealButton(
        _ meal: MealOption,
        width: CGFloat,
        height: CGFloat
    ) -> some View {

        let isPressed = pressedMeal == meal

        return Button {
            selectMeal(meal)
        } label: {

            VStack(spacing: 5) {

                Image(meal.image)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width * 0.85,
                        height: height * 0.65
                    )

                Text(meal.title)
                    .font(.system(
                        size: height * 0.17,
                        weight: .bold
                    ))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .shadow(
                        color: .black.opacity(0.35),
                        radius: 2,
                        y: 2
                    )
            }
            .frame(width: width, height: height)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.78, green: 0.80, blue: 0.82),
                                Color(red: 0.66, green: 0.69, blue: 0.72)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            // Darken on tap
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        .black.opacity(isPressed ? 0.15 : 0)
                    )
            }
            .shadow(
                color: .black.opacity(
                    isPressed ? 0.10 : 0.22
                ),
                radius: isPressed ? 3 : 7,
                y: isPressed ? 2 : 5
            )
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(.plain)
        .animation(
            .easeOut(duration: 0.12),
            value: isPressed
        )
        .disabled(isTransitioning)
        .accessibilityLabel(meal.title)
    }

    // MARK: - Select & Navigate
    private func selectMeal(_ meal: MealOption) {

        guard !isTransitioning else { return }

        isTransitioning = true
        pressedMeal = meal

        Task {
            // Brief visual feedback
            try? await Task.sleep(
                for: .milliseconds(200)
            )

            selectedMeal = meal
            showDestination = true
            pressedMeal = nil
            isTransitioning = false
        }
    }

    // MARK: - Meal Destinations
    @ViewBuilder
    private func destination(
        for meal: MealOption
    ) -> some View {

        TaskView(
            character: character,
            meal: meal,
            onReturnHome: returnToHome
        )
    }
}

// MARK: - Preview
#Preview(traits: .landscapeLeft) {
    NavigationStack {
        MealSelectionView(character: "girl")
    }
}
