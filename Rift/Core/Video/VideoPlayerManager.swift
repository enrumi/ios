//
//  VideoPlayerManager.swift
//  Rift
//
//  Manages AVPlayer instances and playback
//

import AVFoundation
import Combine

class VideoPlayerManager: ObservableObject {
    @Published var currentPlayer: AVPlayer?
    @Published var isPlaying = false
    
    private var playerObserver: Any?
    
    // MARK: - Setup Player
    func setupPlayer(for url: URL) {
        // Clean up existing player
        cleanupPlayer()
        
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        
        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        currentPlayer = player
    }
    
    // MARK: - Playback Control
    func play() {
        currentPlayer?.play()
        isPlaying = true
    }
    
    func pause() {
        currentPlayer?.pause()
        isPlaying = false
    }
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    // MARK: - Cleanup
    func cleanupPlayer() {
        currentPlayer?.pause()
        currentPlayer?.replaceCurrentItem(with: nil)
        currentPlayer = nil
        isPlaying = false
        
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        cleanupPlayer()
    }
}
