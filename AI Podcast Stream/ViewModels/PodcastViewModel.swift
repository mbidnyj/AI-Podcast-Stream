//
//  PodcastViewModel.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import Foundation
import AVFoundation

class AudioStreamer {
    private var player: AVPlayer?

    func playStream(from url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
    }
}
