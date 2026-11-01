
import SwiftUI

struct CharacterSelectionView: View {

    // MARK: - States
    @State private var selectedCharacter: String?
    @State private var animateStar = false
    @AppStorage("chosenCharacter") private var chosenCharacter = "girl"

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {

                // MARK: - Background
                LinearGradient(
                    colors: [
                        Color(red: 0.70, green: 0.89, blue: 1.0),
                        Color(red: 1.0, green: 0.96, blue: 0.86)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // MARK: - Happy Cloud
                Image("HomeHappyCloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.18)
                    .position(
                        x: width * 0.12,
                        y: height * 0.19
                    )

                // MARK: - Animated Star
                Image("CharacterStar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.14)
                    .offset(y: animateStar ? -8 : 8)
                    .position(
                        x: width * 0.85,
                        y: height * 0.19
                    )
                    .animation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: animateStar
                    )

                // MARK: - Header
                VStack(spacing: height * 0.025) {

                    Text("من سيشاركك المغامرة؟")
                        .font(.system(
                            size: height * 0.065,
                            weight: .bold
                        ))
                        .foregroundStyle(
                            Color(red: 0.34, green: 0.32, blue: 0.85)
                        )

                    Text("اختر شخصيتك المفضلة!")
                        .font(.system(
                            size: height * 0.045,
                            weight: .semibold
                        ))
                        .foregroundStyle(
                            Color(red: 0.28, green: 0.32, blue: 0.40)
                        )
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .position(
                    x: width * 0.50,
                    y: height * 0.19
                )

                // MARK: - Character Selection
                HStack(spacing: width * 0.04) {

                    // Girl Card
                    Button {
                        selectedCharacter = "girl"
                        chosenCharacter = "girl"
                    } label: {
                        characterCard(
                            image: "CharacterGirl",
                            name: "البنت",
                            color: Color(
                                red: 1.0,
                                green: 0.76,
                                blue: 0.88
                            ),
                            width: width * 0.25,
                            height: height * 0.52,
                            isSelected: selectedCharacter == "girl"
                        )
                    }
                    .accessibilityLabel("اختيار البنت")

                    // Boy Card
                    Button {
                        selectedCharacter = "boy"
                        chosenCharacter = "boy"
                    } label: {
                        characterCard(
                            image: "CharacterBoy",
                            name: "الولد",
                            color: Color(
                                red: 0.64,
                                green: 0.84,
                                blue: 1.0
                            ),
                            width: width * 0.25,
                            height: height * 0.52,
                            isSelected: selectedCharacter == "boy"
                        )
                    }
                    .accessibilityLabel("اختيار الولد")
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.50,
                    y: height * 0.59
                )

                // MARK: - Continue Button
                if let selectedCharacter {

                    NavigationLink {
                        MissionView(character: selectedCharacter)
                    } label: {
                        Text("يلا نبدأ!")
                            .font(.system(
                                size: height * 0.04,
                                weight: .bold
                            ))
                            .foregroundStyle(.white)
                            .frame(
                                width: width * 0.25,
                                height: height * 0.09
                            )
                            .background(
                                Color.green,
                                in: Capsule()
                            )
                            .shadow(radius: 5, y: 3)
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: width * 0.50,
                        y: height * 0.92
                    )
                }
            }
            .frame(width: width, height: height)
        }
        .onAppear {
            animateStar = true
        }
    }

    // MARK: - Character Card
    private func characterCard(
        image: String,
        name: String,
        color: Color,
        width: CGFloat,
        height: CGFloat,
        isSelected: Bool
    ) -> some View {

        Image(image)
            .resizable()
            .scaledToFit()
            .frame(
                width: width * 0.92,
                height: height * 0.90
            )
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(color)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        isSelected ? Color.green : Color.white,
                        lineWidth: isSelected ? 5 : 3
                    )
            }
            .overlay(alignment: .bottomTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.green)
                        .background(.white, in: Circle())
                        .padding(12)
                }
            }
            .shadow(
                color: .black.opacity(0.13),
                radius: 12,
                y: 6
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 30)
            )
            .animation(
                .spring(response: 0.3),
                value: isSelected
            )
            .accessibilityLabel(name)
    }
}

// MARK: - Preview
#Preview(traits: .landscapeLeft) {
    NavigationStack {
        CharacterSelectionView()
    }
}
