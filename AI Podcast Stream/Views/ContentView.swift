//
//  ContentView.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var streamer = AudioStreamer()
    @StateObject var imageFetcher = ImageFetcher()
    @State private var isPlaying = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Button(action: startPodastButton) {
                    Text("Start Podcast")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: handleAudioButton) {
                    Text(isPlaying ? "Pause" : "Play")
                        .foregroundColor(.white)
                        .padding()
                        .background(isPlaying ? Color.red : Color.green)
                        .cornerRadius(10)
                }

                // Image display
                HStack{
                    Spacer()
                    if imageFetcher.isLoadingImage {
                        ProgressView()
                            .frame(width: geometry.size.width * 0.8)
                    } else if let image = imageFetcher.coverImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8)
                            .onAppear{
                                streamer.updateNowPlayingInfo(with: image, title: "Whats is Artificial Intelligence?", podcastTitle: "AI Podcast")
                            }
                    }
                    Spacer()
                }
            }
            .onAppear {
                imageFetcher.loadCoverImage(topic: "some topic")
                streamer.setupRemoteTransportControls()
            }
        }
    }

    // play/pause button
    private func handleAudioButton() {
        if self.isPlaying {
            self.streamer.pause()
        } else {
            self.streamer.play()
        }
        self.isPlaying.toggle()
    }
    
    private func startPodastButton() {
//        self.streamer.playStream(from: "https://wpr-ice.streamguys1.com/wpr-music-mp3-96")
        self.streamer.playStream(from: "http://localhost:8080/api/getAudioStream?userId=123&topic=AI")
    }
}


#Preview {
    ContentView()
}
