//
//  PodcastView.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import SwiftUI

struct PodcastView: View {
    // podcast topic
    var receivedTopic: String
    // playing audio stream
    @ObservedObject var streamer = AudioStreamer()
    @State private var isPlaying = false
    // fetching cover image
    @StateObject var imageFetcher = ImageFetcher()
    // fetching auth token
    let apiService = APIService()
    @State private var authToken: String? = nil
    // podcast topic
    @State private var podcastTopic = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // show auth token
                Text(receivedTopic)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .top)
                
                
                
                // Image display
                Spacer().frame(height: 50)
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
                
                
                
                VStack{
                    Spacer()
                    
                    // Play/Pause button
                    Button(action: handleAudioButton) {
                        Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.bottom, 35)
                    }
                    
                    // Podcast question
                    HStack {
                        TextField("Podcast qeustion...", text: $podcastTopic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                                            
                        Button(action: {
                            startPodastButton()
                            podcastTopic = ""
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                        .padding(.trailing)
                    }

                }
            }
            .onAppear {
                fetchAuthToken()
                imageFetcher.loadCoverImage(topic: receivedTopic)
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
        self.isPlaying = true
        let url = URL(string: Constants.getAudioStream + "?userId=" + (authToken ?? "12345") + "&topic=" + podcastTopic)!
        self.streamer.playStream(from: url)
//        self.streamer.playStream(from: "https://wpr-ice.streamguys1.com/wpr-music-mp3-96")
    }
    
    private func fetchAuthToken() {
        apiService.fetchAuthToken { result in
            switch result {
            case .success(let responseString):
                print("API Response: \(responseString)")
                self.authToken = responseString
                self.isPlaying = true
                let url = URL(string: Constants.getAudioStream + "?userId=" + (authToken ?? "12345") + "&topic=" + receivedTopic)!
                self.streamer.playStream(from: url)
            case .failure(let error):
                print("Error fetching API data: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    PodcastView(receivedTopic: "What is API?")
}
