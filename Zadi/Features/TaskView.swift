
import SwiftUI
import AVFoundation

struct TaskView: View {
    
    // MARK: - Properties
    
    let character: String
    let meal: MealOption
    let onReturnHome: () -> Void
    @Environment(\.returnToHome) private var returnToHome
    
    // MARK: - Audio
    
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Character
    
    private var isGirl: Bool {
        character == "girl"
    }
    
    private var characterImage: String {
        isGirl ? "TaskGirl" : "TaskBoy"
    }
    
    //Task Recording
    
    private var taskRecording: IngredientVoice.Recording {
        switch meal {
        case .pancake, .cereal: return .taskBreakfast
        case .bread:            return .taskBread
        case .rice:             return .taskRice
        case .pasta:            return .taskPasta
        }
    }
    
    private var voiceCharacter: IngredientVoice.Character {
        isGirl ? .girl : .boy
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
                        x: width * 0.17,
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
                        
                        Text("⭐ تحدّي اليوم ⭐")
                            .font(.system(
                                size: height * 0.027,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundStyle(
                                Color(red: 0.85, green: 0.44, blue: 0.04)
                            )
                        
                        Text(taskTitle)
                            .font(.system(
                                size: height * 0.047,
                                weight: .heavy,
                                design: .rounded
                            ))
                            .foregroundStyle(
                                Color(red: 0.15, green: 0.22, blue: 0.37)
                            )
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.85)
                        
                        
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
                            IngredientVoice.shared.stop()
                            returnToHome()
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
        .task {
            // wait until the ending screen has fully closed (it stops all voices when it closes)
            try? await Task.sleep(for: .seconds(0.8))
            IngredientVoice.shared.play(taskRecording, character: voiceCharacter)
        }
        .onDisappear {
            IngredientVoice.shared.stop()
        }
    }
    
    // MARK: - Play Task Audio
    
    private func playTaskAudio() {
        
        if IngredientVoice.shared.isPlaying {
            IngredientVoice.shared.stop()
            return
        }
        IngredientVoice.shared.play(taskRecording, character: voiceCharacter)
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

