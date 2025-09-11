import Foundation
import AVFoundation

final class AudioEngine: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioEngine()
    private var player: AVAudioPlayer?

    private override init() {
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
    }

    func play(url: URL) {
        stop()
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
        } catch {
            player = nil
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    // Locate bundled audio: Resources/audio/<lessonID>/seg-<index>.m4a
    func findAudio(lessonID: String, index: Int) -> URL? {
        let path = "audio/\(lessonID)/seg-\(index).m4a"
        return Bundle.main.url(forResource: path, withExtension: nil)
    }
}
