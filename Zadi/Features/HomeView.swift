
import SwiftUI
import AVFoundation

struct HomeView: View {
    @State private var showCharacterSelection = false

    // MARK: - Audio
    @State private var narrator = AVSpeechSynthesizer()
    
    
    @State private var selectedCharacter: String? = nil
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in

                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {

                
                    // MARK: - Background
                    Image("HomeBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()

                    // MARK: - Characters
                    Image("HomeCharacters")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.40)
                        .position(
                            x: width * 0.48,
                            y: height * 0.63
                        )

                    // MARK: - Foreground
                    Image("HomeForeground")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 1.02)
                        .position(
                            x: width * 0.50,
                            y: height * 0.98
                        )

                    // MARK: - Decorations
                    Image("HomeDecorations")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()

                    // MARK: - Happy Cloud
                    Image("HomeHappyCloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.25)
                        .position(
                            x: width * 0.16,
                            y: height * 0.18
                        )

                    // MARK: - Welcome Title
                    Text("أهلًا يا أبطال!")
                        .font(.system(
                            size: height * 0.06,
                            weight: .bold
                        ))
                        .foregroundStyle(
                            Color(red: 0.31, green: 0.37, blue: 0.71)
                        )
                        .position(
                            x: width * 0.51,
                            y: height * 0.19
                        )

                    // MARK: - Subtitle
                    Text("هيا نُحضّر وجبة لذيذة معًا!")
                        .font(.system(
                            size: height * 0.041,
                            weight: .semibold
                        ))
                        .foregroundStyle(.black.opacity(0.75))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(width: width * 0.65)
                        .position(
                            x: width * 0.51,
                            y: height * 0.30
                        )

                    // MARK: - Sound Button
                    Button {
                        playWelcomeVoice()
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.black.opacity(0.7))
                            .padding(15)
                            .background(
                                .white.opacity(0.5),
                                in: Circle()
                            )
                    }
                    .position(
                        x: width * 0.095,
                        y: height * 0.10
                    )

                
                    Button {
                        showCharacterSelection = true
                    } label: {
                        Text("ابدأ المغامرة")
                            .font(.system(
                                size: height * 0.045,
                                weight: .bold
                            ))
                            .foregroundStyle(.white)
                            .frame(
                                width: width * 0.34,
                                height: height * 0.11
                            )
                            .background(
                                Color(red: 0.0, green: 0.70, blue: 0.28),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    .zIndex(10)
                    .position(
                        x: width * 0.50,
                        y: height * 0.82
                    )


                }
                .navigationDestination(
                    isPresented: $showCharacterSelection
                ) {
                    CharacterSelectionView()
                }
                .frame(width: width, height: height)
                .clipped()
            }
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Welcome Audio
    private func playWelcomeVoice() {
        if narrator.isSpeaking {
            narrator.stopSpeaking(at: .immediate)
        } else {
            let message = AVSpeechUtterance(
                string: "أهلًا يا أبطال! هيا نُحضّر وجبة لذيذة معًا!"
            )
            message.voice = AVSpeechSynthesisVoice(language: "ar-SA")
            message.rate = 0.48
            narrator.speak(message)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    HomeView()
}
