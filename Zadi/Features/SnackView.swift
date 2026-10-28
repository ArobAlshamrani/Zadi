
import SwiftUI

// ONE view for the whole snack section.
// Stage 1: choose a snack  ->  Stage 2: snack on the placemat + suggestion card
// ->  Stage 3: combined food on the placemat + finish button.
struct SnackView: View {

    // MARK: - Settings from the rest of the app (both optional)
    var character = "boy"                 // "boy" or "girl" (CharacterCoach images)
    var onFinish: (() -> Void)? = nil     // runs when the child taps "انهاء الوجبة"

    // MARK: - Data (edit pictures and labels here only)
    struct Snack: Identifiable {
        let id: String
        let image: String           // Stage 1 card + Stage 2 placemat picture
        let title: String           // Stage 1 label
        let additionImage: String   // suggestion card picture
        let additionTitle: String   // suggestion card label
        let combinedImage: String   // Stage 3 placemat picture
    }

    static let snacks: [Snack] = [
        Snack(id: "apple", image: "apple_slices", title: "تفاح",
              additionImage: "peanut_butter", additionTitle: "زبدة الفول السوداني",
              combinedImage: "apple_peanut_butter"),

        Snack(id: "candy", image: "candies", title: "حلوى",
              additionImage: "mixed_nuts", additionTitle: "مكسرات",
              combinedImage: "candies_nuts"),

        Snack(id: "chips", image: "chips", title: "بطاطس",
              additionImage: "yogurt_dip", additionTitle: "صوص الزبادي",
              combinedImage: "chips_dip"),

        Snack(id: "cookies", image: "cookies", title: "كوكيز",
              additionImage: "milk_cup", additionTitle: "حليب",
              combinedImage: "cookies_milk"),

        Snack(id: "popcorn", image: "popcorn", title: "فشار",
              additionImage: "orange_juice", additionTitle: "عصير البرتقال",
              combinedImage: "popcorn_orange_juice")
    ]

    // Character speech (same text for every snack, as in your design)
    private let thinkingText = "لذيذ! لكن دعنا نفكر للحظة.. كيف تحسن اختيارنا؟"
    private let praiseText = "أحسنت! هذا رائع!"

    // MARK: - State
    @State private var selected: Snack?        // nil = Stage 1
    @State private var addedAddition = false   // true = Stage 3

    // 1, 2 or 3 (used only to animate between stages)
    private var stage: Int { selected == nil ? 1 : (addedAddition ? 3 : 2) }

    // MARK: - Screen
    var body: some View {
        GeometryReader { geo in
            let size = geo.size

            ZStack {
                // Full-screen background
                Image("BaseBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()

                if let snack = selected {
                    chosenStage(snack, size: size)      // Stages 2 and 3
                } else {
                    choicesGrid(size: size)             // Stage 1
                }
            }
            .frame(width: size.width, height: size.height)
            .animation(.easeInOut(duration: 0.3), value: stage)
        }
        .ignoresSafeArea()
        // Positions stay fixed; Arabic text still reads right-to-left by itself.
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - Stage 1: five cards (3 on top, 2 centered below)
    private func choicesGrid(size: CGSize) -> some View {
        // Sizes are fractions of the screen height, measured from your design.
        let cardWidth = size.height * 0.169
        let cardHeight = size.height * 0.193

        return VStack(spacing: size.height * 0.0195) {
            cardRow(Array(Self.snacks.prefix(3)), gap: size.height * 0.0447,
                    cardWidth: cardWidth, cardHeight: cardHeight)
            cardRow(Array(Self.snacks.suffix(2)), gap: size.height * 0.0725,
                    cardWidth: cardWidth, cardHeight: cardHeight)
        }
        // TUNE: moves the whole grid (fractions of screen width / height)
        .position(x: size.width * 0.5, y: size.height * 0.777)
        .transition(.opacity)
    }

    private func cardRow(_ items: [Snack], gap: CGFloat,
                         cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        HStack(spacing: gap) {
            ForEach(items) { snack in
                Button {
                    addedAddition = false
                    selected = snack            // <- opens Stage 2 for this snack
                } label: {
                    card(image: snack.image, title: snack.title,
                         width: cardWidth, height: cardHeight)
                }
                .buttonStyle(PressStyle(cornerRadius: cardWidth * 0.24))
            }
        }
    }

    // MARK: - Stages 2 and 3: placemat picture, boy, bubble, suggestion card
    private func chosenStage(_ snack: Snack, size: CGSize) -> some View {
        let mood = addedAddition ? "happy" : "thinking"
        let bubbleColor = Color(red: 0.98, green: 0.95, blue: 0.9)

        return ZStack {
            // Picture on the placemat: the snack alone, then the combination
            Image(addedAddition ? snack.combinedImage : snack.image)
                .resizable()
                .scaledToFit()
                .frame(height: size.height * 0.40)
                .id(addedAddition)
                .transition(.opacity)
                .position(x: size.width * 0.5, y: size.height * 0.29)

            // Suggestion card: tapping it adds the food
            Button {
                addedAddition = true
            } label: {
                card(image: snack.additionImage, title: snack.additionTitle,
                     width: size.height * 0.2, height: size.height * 0.228)
            }
            .buttonStyle(PressStyle(cornerRadius: size.height * 0.2 * 0.24))
            .disabled(addedAddition)
            .position(x: size.width * 0.5, y: size.height * 0.79)

            // Boy (thinking, then happy). Uses your CharacterCoach images.
            Image("\(character)_\(mood)")
                .resizable()
                .scaledToFit()
                .frame(height: size.height * 0.30)
                .position(x: size.width * 0.15, y: size.height * 0.85)

            // Speech bubble above the boy
            Text(addedAddition ? praiseText : thinkingText)
                .font(.system(size: size.height * 0.03, weight: .medium, design: .rounded))
                .foregroundStyle(Color(white: 0.3))
                .multilineTextAlignment(.center)
                .padding(.horizontal, size.height * 0.03)
                .padding(.vertical, size.height * 0.015)
                .background(Capsule().fill(bubbleColor))
                .position(x: size.width * 0.28, y: size.height * 0.635)

            // Small circle that points the bubble toward the boy
            Circle()
                .fill(bubbleColor)
                .frame(width: size.height * 0.025, height: size.height * 0.025)
                .position(x: size.width * 0.254, y: size.height * 0.705)

            // Finish button (Stage 3 only)
            if addedAddition {
                Button {
                    onFinish?()
                    selected = nil              // back to Stage 1
                    addedAddition = false
                } label: {
                    Text("إنهاء الوجبة")
                        .font(.system(size: size.height * 0.035, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, size.width * 0.03)
                        .padding(.vertical, size.height * 0.015)
                        .background(Capsule().fill(Color(red: 0.42, green: 0.7, blue: 0.38)))
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .buttonStyle(PressStyle(cornerRadius: size.height * 0.05))
                .position(x: size.width * 0.87, y: size.height * 0.89)
                .transition(.opacity)
            }

            // Back button (not in your design): lets the child change their mind.
            // Delete this whole Button if you don't want it.
            Button {
                selected = nil
                addedAddition = false
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(red: 0.2, green: 0.4, blue: 0.75))
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(.white))
                    .shadow(radius: 3, y: 2)
            }
            .buttonStyle(PressStyle(cornerRadius: 26))
            .accessibilityLabel("رجوع")
            .position(x: size.width * 0.08, y: size.height * 0.27)
        }
        .transition(.opacity)
    }

    // MARK: - One gray card: picture on top, white Arabic label at the bottom
    private func card(image: String, title: String,
                      width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.68, height: height * 0.52)
                .padding(.top, height * 0.09)

            Spacer(minLength: 0)

            Text(title)
                .font(.system(size: width * 0.17, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)      // long names (e.g. peanut butter) shrink to fit
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                .padding(.horizontal, width * 0.06)
                .padding(.bottom, height * 0.10)
        }
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: width * 0.24, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(white: 0.82).opacity(0.92), Color(white: 0.72).opacity(0.92)],
                    startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        )
    }

    // MARK: - Button look: shrinks and glows white while pressed
    private struct PressStyle: ButtonStyle {
        let cornerRadius: CGFloat

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(configuration.isPressed ? 0.9 : 0), lineWidth: 4)
                        .blur(radius: 3)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }
}

#Preview("Snack", traits: .landscapeLeft) {
    SnackView()
}
