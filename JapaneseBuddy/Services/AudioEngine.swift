import Foundation
import AVFoundation

final class AudioEngine: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioEngine()
    private var player: AVAudioPlayer?
    private(set) var isPlaying = false
    @MainActor var onPlaybackEnded: (() -> Void)?
    private var sessionCategory: AVAudioSession.Category {
        let playInSilentMode = (UserDefaults.standard.object(forKey: "playSpeechInSilentMode") as? Bool) ?? true
        return playInSilentMode ? .playback : .soloAmbient
    }

    private override init() {
        super.init()
        configureSessionCategory()
    }

    func play(url: URL) -> Bool {
        configureSessionCategory()
        stop()
        isPlaying = false
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            if player?.play() == true {
                isPlaying = true
                return true
            }
            player = nil
            isPlaying = false
            return false
        } catch {
            player = nil
            isPlaying = false
            return false
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        Task { @MainActor [weak self] in
            self?.onPlaybackEnded?()
        }
    }

    // Locate bundled audio: Resources/audio/<lessonID>/seg-<index>.m4a
    func findAudio(lessonID: String, index: Int) -> URL? {
        let path = "audio/\(lessonID)/seg-\(index).m4a"
        return Bundle.main.url(forResource: path, withExtension: nil)
    }

    private func configureSessionCategory() {
        do {
            try AVAudioSession.sharedInstance().setCategory(sessionCategory)
        } catch {}
    }

    // MARK: - AVAudioPlayerDelegate
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        Task { @MainActor [weak self] in
            self?.onPlaybackEnded?()
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        self.player = nil
        Task { @MainActor [weak self] in
            self?.onPlaybackEnded?()
        }
    }
}
