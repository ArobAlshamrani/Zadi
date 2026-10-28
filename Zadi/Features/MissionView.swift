
import SwiftUI
import AVFoundation

struct MissionView: View {

    // MARK: - Properties
    let character: String

    @Environment(\.dismiss) private var dismiss
    @State private var speechSynthesizer = AVSpeechSynthesizer()

    // MARK: - Selected Character
    private var isGirl: Bool {
        character == "girl"
    }

    // MARK: - Character Image
    private var characterImage: String {
        isGirl ? "MissionGirl" : "MissionBoy"
    }

    // MARK: - Mission Text
    private var missionText: String {
        isGirl
        ? "جاهزة نجهّز وجبتنا؟ اختاري أكلة تحبينها!"
        : "جاهز نجهّز وجبتنا؟ اختر أكلة تحبها!"
    }
    // MARK: - Body
    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {

                // MARK: - Kitchen Background
                Image("MissionKitchen")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .ignoresSafeArea()
                    .clipped()

                // MARK: - Character
                Image(characterImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width * 0.35,
                        height: height * 0.72
                    )
                    .position(
                        x: width * 0.25,
                        y: height * 0.65
                    )

                // MARK: - Speech Bubble Tail
                Circle()
                    .fill(.white)
                    .frame(width: width * 0.025)
                    .position(
                        x: width * 0.48,
                        y: height * 0.48
                    )

                Circle()
                    .fill(.white)
                    .frame(width: width * 0.038)
                    .position(
                        x: width * 0.51,
                        y: height * 0.43
                    )

             
                // MARK: - Speech Bubble
                ZStack {

                    Ellipse()
                        .fill(.white)
                        .overlay {
                            Ellipse()
                                .stroke(
                                    Color.brown.opacity(0.45),
                                    lineWidth: 2
                                )
                        }
                        .shadow(
                            color: .black.opacity(0.12),
                            radius: 6,
                            y: 3
                        )

                    VStack(spacing: height * 0.035) {

                        Text(
                            isGirl
                            ? "جاهزة نجهّز وجبتنا؟"
                            : "جاهز نجهّز وجبتنا؟"
                        )
                        .font(.system(
                            size: height * 0.044,
                            weight: .bold
                        ))

                        Text(
                            isGirl
                            ? "اختاري أكلة تحبينها!"
                            : "اختر أكلة تحبها!"
                        )
                        .font(.system(
                            size: height * 0.039,
                            weight: .semibold
                        ))
                    }
                    .foregroundStyle(
                        Color(red: 0.65, green: 0.39, blue: 0.11)
                    )
                    .multilineTextAlignment(.center)
                    .frame(width: width * 0.42)
                }
                .frame(
                    width: width * 0.50,
                    height: height * 0.33
                )
                .position(
                    x: width * 0.70,
                    y: height * 0.28
                )

                // MARK: - Start Mission Button
                NavigationLink {
                    FoodSelectionPage(character: character)
                } label: {
                    HStack(spacing: 10) {

                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: height * 0.032))
                            .foregroundStyle(
                                Color(red: 0.32, green: 0.39, blue: 0.70)
                            )

                        Text("لنبدأ")
                            .font(.system(
                                size: height * 0.045,
                                weight: .bold
                            ))
                            .foregroundStyle(
                                Color(red: 0.32, green: 0.39, blue: 0.70)
                            )
                    }
                    .frame(
                        width: width * 0.22,
                        height: height * 0.12
                    )
                    .background(
                        Color(red: 1.0, green: 0.77, blue: 0.86),
                        in: Capsule()
                    )
                    .overlay {
                        Capsule()
                            .stroke(
                                Color.brown.opacity(0.35),
                                lineWidth: 2
                            )
                    }
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 8,
                        y: 5
                    )
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.81,
                    y: height * 0.83
                )

               

            
                // MARK: - Shared Back & Sound Buttons

                ZadiTopControls(
                    onBack: {},
                    onSound: playMissionAudio,
                    showsBackButton: false
                )
                .zIndex(100)
                
                // MARK: - Change Character Button
                Button {
                    speechSynthesizer.stopSpeaking(at: .immediate)
                    dismiss()
                } label: {

                    HStack(spacing: 10) {

                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(
                                size: height * 0.032,
                                weight: .bold
                            ))

                        Text("تغيير الشخصية")
                            .font(.system(
                                size: height * 0.036,
                                weight: .bold
                            ))
                    }
                    .foregroundStyle(
                        Color(
                            red: 0.58,
                            green: 0.37,
                            blue: 0.18
                        )
                    )
                    .frame(
                        width: width * 0.25,
                        height: height * 0.12
                    )
                    .background(
                        Color(
                            red: 1.0,
                            green: 0.97,
                            blue: 0.89
                        ),
                        in: Capsule()
                    )
                    .overlay {
                        Capsule()
                            .stroke(
                                Color.brown.opacity(0.35),
                                lineWidth: 2
                            )
                    }
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 8,
                        y: 5
                    )
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.55,
                    y: height * 0.83
                )

            } // End ZStack
            .frame(width: width, height: height)
            .clipped()

        } // End GeometryReader
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

    } // End body

    // MARK: - Mission Audio
    private func playMissionAudio() {

        // Stop previous speech
        speechSynthesizer.stopSpeaking(at: .immediate)

        // Use the current character's mission text
        let message = missionText.replacingOccurrences(
            of: "\n",
            with: " "
        )

        let utterance = AVSpeechUtterance(string: message)

        // Arabic voice
        utterance.voice =
            AVSpeechSynthesisVoice(language: "ar-SA")
            ?? AVSpeechSynthesisVoice(language: "ar")

        // Speaking speed
        utterance.rate = 0.45

        // Start speaking
        speechSynthesizer.speak(utterance)
    }

} // End MissionView

// MARK: - Preview
#Preview(traits: .landscapeLeft) {
    NavigationStack {
        MissionView(character: "girl")
    }
}
