
import SwiftUI

struct HomeView: View {
    @State private var resetNavigation = false
    private enum HomeRoute: Hashable {
        case characters
        case mission(String)
            }

            @AppStorage("chosenCharacter") private var chosenCharacter = "girl"

    @State private var navigationPath: [HomeRoute] = []

    // MARK: - Audio
    @Environment(\.scenePhase) private var scenePhase
    
    
    @State private var selectedCharacter: String? = nil
    var body: some View {
        NavigationStack(path: $navigationPath) {            GeometryReader { geometry in

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

                
                    NavigationLink(value: HomeRoute.characters) {
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
            
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                                       case .characters:
                                           CharacterSelectionView()
                                       case .mission(let character):
                                           MissionView(character: character)
                                       }
                }
                .frame(width: width, height: height)
                .clipped()
            }
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
            // Attach playback to the Home content, which disappears when another page opens.
            .onAppear { playWelcomeVoice() }
            .onDisappear { Coach.stopVoice() }
            .onChange(of: scenePhase) {
                if scenePhase != .active { Coach.stopVoice() }
            }
        }
        .id(resetNavigation)
        .environment(\.returnToHome) {
            navigationPath = [.characters, .mission(chosenCharacter)]
            resetNavigation.toggle()
        }
    }

    // MARK: - Welcome Audio
    private func playWelcomeVoice() {
        // The welcome filename is shared, so this character value does not change its voice.
        IngredientVoice.shared.play(.homeWelcome, character: .girl)
        // Previous speaker behavior:
        // IngredientVoice.shared.replayLast()
    }
}

#Preview(traits: .landscapeLeft) {
    HomeView()
}
