import AVFoundation

// Shared recordings for meal pages. Screens choose when to play or stop a voice.
@MainActor
final class IngredientVoice {
    static let shared = IngredientVoice()

    enum Character: String, CaseIterable {
        case boy, girl
    }

    // Keep these names matched to the MP3 files, without the character suffix.
    enum Recording: String, CaseIterable {
        // MARK: - Home and Mission
        case homeWelcome = "home_welcome"
        case mission = "mission"

        // MARK: - Bread
        case breadApple = "bread_apple"
        case breadBanana = "bread_banana"
        case breadCheese = "bread_cheese"
        case breadChicken = "bread_chicken"
        case breadChocolate = "bread_chocolate"
        case breadCucumber = "bread_cucumber"
        case breadEgg = "bread_egg"
        case breadLettuce = "bread_lettuce"
        case breadPlain = "bread_plain"
        case breadStrawberry = "bread_strawberry"
        case breadTomato = "bread_tomato"
        case breadTurkey = "bread_turkey"

        // MARK: - Pancake
        case pancakeApple = "pancake_apple"
        case pancakeBanana = "pancake_banana"
        case pancakeChocolate = "pancake_chocolate"
        case pancakeHoney = "pancake_honey"
        case pancakePlain = "pancake_plain"
        case pancakeStrawberry = "pancake_strawberry"
        case pancakeSauce = "pancake_sauce"

        // MARK: - Rice
        case riceChicken = "rice_chicken"
        case riceFries = "rice_fries"
        case ricePlain = "rice_plain"
        case riceSalad = "rice_salad"
        case riceYogurt = "rice_yogurt"

        // MARK: - Snack
        case snackApple = "snack_apple"
        case snackCandy = "snack_candy"
        case snackChips = "snack_chips"
        case snackChipsYogurt = "snack_chips_yogurt"
        case snackCookies = "snack_cookies"
        case snackMilk = "snack_milk"
        case snackNuts = "snack_nuts"
        case snackPopcorn = "snack_popcorn"
        case snackPopcornOrange = "snack_popcorn_orange"

        // MARK: - Interaction
        case interactionFinished = "interaction_finished"
        case interactionFruit = "interaction_fruit"
        case interactionHealthy = "interaction_healthy"
        case interactionImproved = "interaction_improved"
        case interactionPlain = "interaction_plain"
        case interactionSaltFat = "interaction_salt_fat"
        case interactionSugar = "interaction_sugar"
        case interactionVegetable = "interaction_vegetable"
        
       // Task (end mission)
                case taskBreakfast = "task_breakfast"
                case taskBread = "task_bread"
                case taskRice = "task_rice"
                case taskPasta = "task_pasta"

        func filename(for character: Character) -> String {
            // Home has one shared recording; all other recordings use the chosen character.
            if self == .homeWelcome { return rawValue }
            return "\(rawValue)_\(character.rawValue)"
            // Previous filename rule:
            // "\(rawValue)_\(character.rawValue)"
        }
    }

    private var lastPlayback: (recording: Recording, character: Character)?
    private var player: AVAudioPlayer?
    private var playbackTask: Task<Void, Never>?

    var isPlaying: Bool { player?.isPlaying ?? false }

    private init() {}

    // MARK: - Playback

    // Example: IngredientVoice.shared.play(.breadBanana, character: .girl)
    func play(_ recording: Recording, character: Character) {
        stop()
        let name = recording.filename(for: character)
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("IngredientVoice: missing recording \(name).mp3")
            return
        }

        playbackTask = Task { [weak self] in
            do {
                #if os(iOS) || os(tvOS) || os(visionOS)
                guard try await AVAudioSession.sharedInstance().activate() else {
                    return
                }
                #endif
                // A newer selection or stop request may arrive while activation is waiting.
                try Task.checkCancellation()
                guard let self else { return }
                let nextPlayer = try AVAudioPlayer(contentsOf: url)
                guard nextPlayer.play() else {
                    print("IngredientVoice: could not play \(name).mp3")
                    return
                }
                self.player = nextPlayer
                self.lastPlayback = (recording, character)
            } catch is CancellationError {
                // Changing ingredients or leaving the page cancels queued playback.
            } catch {
                print("IngredientVoice: \(name).mp3 — \(error.localizedDescription)")
            }
        }
    }

    // Keep the last successfully started recording available after navigation or stop.
    func replayLast() {
        guard let lastPlayback else { return }
        play(lastPlayback.recording, character: lastPlayback.character)
    }

    // Screens should call this when leaving, finishing, or becoming inactive.
    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        player?.stop()
        player = nil
    }
}

