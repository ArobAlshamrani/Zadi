
import AVFoundation // Apple's framework for playing audio.

// MARK: - Audio Player

// Manages the audio recordings for ingredients.
@MainActor
final class IngredientAudio {

    private let playback = IngredientAudioPlayback()
    private var playbackTask: Task<Void, Never>?

    // MARK: Play Recording

    func play(recording: String?) {

        // Stop the previous recording before starting another.
        stop()

        // Find the MP3 file inside the app.
        // If no recording exists, exit the function.
        guard let recording,
              let url = Bundle.main.url(
                forResource: recording,
                withExtension: "mp3"
              )
        else { return }

        // The new playback request stops the previous player itself.
        playbackTask?.cancel()
        playbackTask = Task { [playback] in
            do {
                try await playback.play(url: url)
            } catch is CancellationError {
                // A stop or a newer recording superseded this request.
            } catch {
                print("Audio error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Stop Recording

    func stop() {
        playbackTask?.cancel()
        playbackTask = Task { [playback] in
            await playback.stop()
        }
    }
}

// Keep synchronous player operations off the main actor and serialize access.
private actor IngredientAudioPlayback {
    private var player: AVAudioPlayer?

    func play(url: URL) async throws {
        try Task.checkCancellation()
        player?.stop()
        player = nil

        guard try await AVAudioSession.sharedInstance().activate() else { return }
        try Task.checkCancellation()

        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
    }

    func stop() {
        // Ignore a queued stop that has been superseded by a newer request.
        guard !Task.isCancelled else { return }
        player?.stop()
        player = nil
    }
}

// MARK: - Ingredient Recordings

// Connects each ingredient to its corresponding audio file.
extension IngredientBenefit {

    var recordingName: String? {
        switch self {

        case .banana:
            return "bananaNoura"

        case .chocolate:
            return "chocolateNoura"

        case .egg:
            return "eggNoura"

        // Ingredients without recordings will remain silent.
        default:
            return nil
        }
    }
}
