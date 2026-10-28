
import SwiftUI
import AVFoundation

struct TaskView: View {

    // MARK: - Properties

    let character: String
    let meal: MealOption
    let onReturnHome: () -> Void

    // MARK: - Audio

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

    // MARK: - Main Screen

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

                        // Task Title

                        Text(taskTitle)
                            .font(.system(
                                size: height * 0.045,
                                weight: .bold
                            ))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)

                        // Task Description

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

                        // MARK: - Return to Main Page

                        Button {

                            speechSynthesizer.stopSpeaking(
                                at: .immediate
                            )

                            onReturnHome()

                        } label: {

                            Label(
                                "العودة للواجهة",
                                systemImage: "house.fill"
                            )
                            .font(.system(
                                size: height * 0.026,
                                weight: .bold
                            ))
                            .foregroundStyle(.black)
                            .frame(
                                width: width * 0.24,
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
                        .padding(.top, height * 0.02)

                    }
                    .frame(
                        width: width * 0.43,
                        height: height * 0.28
                    )
                    .offset(y: height * 0.04)

                }
                .frame(
                    width: width * 0.62,
                    height: height * 0.70
                )
                .position(
                    x: width * 0.65,
                    y: height * 0.53
                )

                // MARK: - Shared Sound Button

                ZadiTopControls(
                    onBack: {},
                    onSound: playTaskAudio,
                    showsBackButton: false
                )
                .zIndex(10)

            }
            .frame(
                width: width,
                height: height
            )

        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            speechSynthesizer.stopSpeaking(at: .immediate)
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
}

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
