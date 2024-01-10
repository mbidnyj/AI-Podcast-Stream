//
//  AudioStreamer.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import AVFoundation

class AudioStreamer: ObservableObject {
    private var player: AVPlayer?

    init() {
        configureAudioSession()
    }

    func playStream(from url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        play()
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
}

