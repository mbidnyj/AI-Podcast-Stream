//
//  AudioStreamer.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import AVFoundation
import MediaPlayer


class AudioStreamer: ObservableObject {
    private var player: AVPlayer?
    private var currentAudioURL: String?

    init() {
        configureAudioSession()
    }

    func playStream(from url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
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
    
    
    @objc private func playerItemDidReachEnd(notification: Notification) {
        requestNextAudio()
    }
    
    private func requestNextAudio() {
        // Assuming the server has an endpoint like '/next-audio' that returns the URL of the next audio file
        let nextAudioURL = "http://yourserver.com/next-audio"
        guard let url = URL(string: nextAudioURL) else {
            print("Invalid URL for next audio")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching next audio: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let nextAudioPath = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.playStream(from: nextAudioPath)
                }
            }
        }.resume()
    }
    
    
    func updateNowPlayingInfo(with image: UIImage, title: String, podcastTitle: String) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyPodcastTitle] = podcastTitle

        let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        setupRemoteTransportControls()
    }
    
    
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play command
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.player?.play()
            return .success
        }

        // Pause command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.player?.pause()
            return .success
        }
    }
}

