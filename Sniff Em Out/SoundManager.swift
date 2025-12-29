import AVFoundation

class SoundManager {
    static let instance = SoundManager()
    
    // For basic playback
    var stereo: AVAudioPlayer?
    
    // For pitch/advanced playback
    var backgroundMusicPlayer: AVAudioPlayer?
    var audioEngine: AVAudioEngine?
    var playerNode: AVAudioPlayerNode?
    var timePitch: AVAudioUnitTimePitch?
    
    enum SoundOption: String {
        case evil_trumpet
        case fail
        case jazz_opening
        case music
        case paper_moving
        case quick_trumpet
        case short_trumpet
        case vibraphone
    }
    
    // Background Music Control
    func playBackgroundMusic(volume: Float = 0.5) {
            guard let url = Bundle.main.url(forResource: "music", withExtension: ".mp3") else { return }
            
            // Stop existing background music if any
            stopBackgroundMusic()
            
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1  // -1 = infinite loop
                backgroundMusicPlayer?.volume = volume
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("Error starting background music: \(error)")
            }
        }
        
        func stopBackgroundMusic() {
            backgroundMusicPlayer?.stop()
            backgroundMusicPlayer = nil
        }
    
    // Basic playback with volume control
    func playSound(sound: SoundOption, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        
        do {
            stereo = try AVAudioPlayer(contentsOf: url)
            stereo?.volume = volume
            stereo?.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
    }
    
    // Advanced playback with pitch and volume control
    func playSound(sound: SoundOption, pitch: Float? = nil, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        
        // If no pitch adjustment needed, use simpler AVAudioPlayer
        guard let pitch = pitch else {
            playSound(sound: sound, volume: volume)
            return
        }
        
        // Cleanup previous engine
        resetAudioEngine()
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            timePitch = AVAudioUnitTimePitch()
            
            guard let engine = audioEngine,
                  let player = playerNode,
                  let pitchEffect = timePitch else { return }
            
            // Pitch adjustment (1200 cents = 1 octave up, -1200 = 1 octave down)
            pitchEffect.pitch = pitch
            
            engine.attach(player)
            engine.attach(pitchEffect)
            
            // Connect nodes: player -> pitchEffect -> output
            engine.connect(player, to: pitchEffect, format: audioFile.processingFormat)
            engine.connect(pitchEffect, to: engine.mainMixerNode, format: audioFile.processingFormat)
            
            // Set volume
            player.volume = volume
            
            // Schedule and start playback
            engine.prepare()
            try engine.start()
            
            player.scheduleFile(audioFile, at: nil) { [weak self] in
                self?.resetAudioEngine()
            }
            
            player.play()
        } catch let error {
            print("Error playing pitched sound: \(error.localizedDescription)")
            resetAudioEngine()
        }
    }
    
    private func resetAudioEngine() {
        playerNode?.stop()
        audioEngine?.stop()
        audioEngine?.reset()
        playerNode = nil
        timePitch = nil
        audioEngine = nil
    }
}
