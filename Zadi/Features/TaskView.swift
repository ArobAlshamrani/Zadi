
import SwiftUI
import AVFoundation

struct TaskView: View {

    // MARK: - Properties
    let character: String
    let meal: MealOption
    let onReturnHome: () -> Void

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var isTrying = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()

    // MARK: - Character
    private var isGirl: Bool {
        character == "girl"
    }

    private var characterImage: String {
        isGirl ? "TaskGirl" : "TaskBoy"
    }

    // MARK: - Task Title
    private var taskTitle: String {
        switch meal {

        case .pancake, .cereal:
            return "🍓 مهمة الفواكه!"

        case .bread:
            return "🥪 ساندويتش الأبطال!"

        case .rice:
            return "🌈 تحدي الألوان!"

        case .pasta:
            return "🥕 مغامرة الخضار!"
        }
    }

    // MARK: - Task Description
    private var taskDescription: String {
        switch meal {

        case .pancake, .cereal:
            return isGirl
                ? "حوّلي فطورك إلى لوحة جميلة!\nزيّنيه بفاكهة تحبينها"
                : "حوّل فطورك إلى لوحة جميلة!\nزيّنه بفاكهة تحبها"

        case .bread:
            return isGirl
                ? "حضّري ساندويتشًا بمكوّنين\nمغذّيين تحبينهما!"
                : "حضّر ساندويتشًا بمكوّنين\nمغذّيين تحبهما!"

        case .rice:
            return isGirl
                ? "اجعلي طبقك مليئًا بالألوان!\nاختاري ثلاثة ألوان من الأطعمة"
                : "اجعل طبقك مليئًا بالألوان!\nاختر ثلاثة ألوان من الأطعمة"

        case .pasta:
            return isGirl
                ? "مغامرة جديدة بانتظارك!\nجرّبي إضافة خضار تحبينها"
                : "مغامرة جديدة بانتظارك!\nجرّب إضافة خضار تحبها"
        }
    }

    // MARK: - Body
    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {

                // MARK: - Background
                Image("Taskbackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()

                // MARK: - Character
                Image(characterImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width * 0.29,
                        height: height * 0.52
                    )
                    .position(
                        x: width * 0.22,
                        y: height * 0.73
                    )

                // MARK: - Notebook
                ZStack {

                    Image("TaskNotebook")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.62,
                            height: height * 0.70
                        )

                    // MARK: - Notebook Content
                    VStack(spacing: height * 0.018) {

                        if isTrying {

                            // MARK: - Encouragement
                            Text(
                                isGirl
                                ? "يا بطلة! 🌟"
                                : "يا بطل! 🌟"
                            )
                            .font(.system(
                                size: height * 0.05,
                                weight: .bold
                            ))
                            .foregroundStyle(.green)

                            Text(
                                isGirl
                                ? "مغامرتك مستمرة!\nجرّبي مهمتك مع عائلتك."
                                : "مغامرتك مستمرة!\nجرّب مهمتك مع عائلتك."
                            )
                            .font(.system(
                                size: height * 0.035,
                                weight: .semibold
                            ))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)

                        } else {

                            // MARK: - Task Title
                            Text(taskTitle)
                                .font(.system(
                                    size: height * 0.045,
                                    weight: .bold
                                ))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)

                            // MARK: - Task Description
                            Text(taskDescription)
                                .font(.system(
                                    size: height * 0.032,
                                    weight: .semibold
                                ))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .lineLimit(3)
                                .minimumScaleFactor(0.8)

                            // MARK: - Buttons
                            HStack(spacing: width * 0.012) {

                                // Return Home Button
                                Button {
                                    speechSynthesizer.stopSpeaking(
                                        at: .immediate
                                    )
                                    onReturnHome()
                                } label: {

                                    HStack(spacing: 5) {

                                        Image(systemName: "house.fill")

                                        Text("العودة للواجهة")
                                    }
                                    .font(.system(
                                        size: height * 0.026,
                                        weight: .bold
                                    ))
                                    .foregroundStyle(.black)
                                    .frame(
                                        width: width * 0.19,
                                        height: height * 0.075
                                    )
                                    .background(
                                        Color(
                                            red: 1.0,
                                            green: 0.86,
                                            blue: 0.15
                                        ),
                                        in: Capsule()
                                    )
                                }
                                .buttonStyle(.plain)

                                // Try Button
                                Button {
                                    startTask()
                                } label: {

                                    Text("سأجرب! ⭐")
                                        .font(.system(
                                            size: height * 0.029,
                                            weight: .bold
                                        ))
                                        .foregroundStyle(.white)
                                        .frame(
                                            width: width * 0.19,
                                            height: height * 0.075
                                        )
                                        .background(
                                            Color(
                                                red: 0.24,
                                                green: 0.69,
                                                blue: 0.32
                                            ),
                                            in: Capsule()
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, height * 0.02)
                        }
                    }
                    .frame(
                        width: width * 0.43,
                        height: height * 0.28
                    )
                    .offset(y: height * 0.04)
                    .animation(
                        .easeInOut(duration: 0.25),
                        value: isTrying
                    )
                }
                .frame(
                    width: width * 0.62,
                    height: height * 0.70
                )
                .position(
                    x: width * 0.65,
                    y: height * 0.53
                )

                // MARK: - Back Button
                Button {
                    speechSynthesizer.stopSpeaking(at: .immediate)
                    dismiss()
                } label: {

                    Image(systemName: "arrow.left")
                        .font(.system(
                            size: height * 0.035,
                            weight: .bold
                        ))
                        .foregroundStyle(
                            Color(
                                red: 0.20,
                                green: 0.30,
                                blue: 0.45
                            )
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
                    playTaskAudio()
                } label: {

                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(
                            size: height * 0.035,
                            weight: .bold
                        ))
                        .foregroundStyle(
                            Color(
                                red: 0.20,
                                green: 0.30,
                                blue: 0.45
                            )
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
                .accessibilityLabel("استمع إلى المهمة")
                .position(
                    x: width * 0.93,
                    y: height * 0.10
                )
                .zIndex(10)

            } // End ZStack
            .frame(width: width, height: height)

        } // End GeometryReader
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Task Action
    private func startTask() {

        guard !isTrying else { return }

        speechSynthesizer.stopSpeaking(at: .immediate)

        withAnimation(.easeInOut(duration: 0.25)) {
            isTrying = true
        }

        Task {
            try? await Task.sleep(for: .seconds(3))

            guard !Task.isCancelled else { return }

            onReturnHome()
        }
    }

    // MARK: - Play Task Audio
    private func playTaskAudio() {

        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            return
        }

        let message = "مهمتك اليوم. \(taskTitle). \(taskDescription)"
            .replacingOccurrences(of: "\n", with: " ")

        let utterance = AVSpeechUtterance(string: message)

        utterance.voice =
            AVSpeechSynthesisVoice(language: "ar-SA")
            ?? AVSpeechSynthesisVoice(language: "ar")

        utterance.rate = 0.45

        speechSynthesizer.speak(utterance)
    }

} // End TaskView

// MARK: - Preview
#Preview(traits: .landscapeLeft) {
    NavigationStack {
        TaskView(
            character: "girl",
            meal: .rice,
            onReturnHome: {}
        )
    }
}
