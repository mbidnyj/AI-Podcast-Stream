//
//  PodcastView.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import SwiftUI

struct PodcastView: View {
    // received parameters
    var receivedTopic: String
    var uuid: String
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
    // loading states signs
    @State private var currentStateIndex = 0
    @State private var isCycling = true
    let states = ["Creating", "Recording", "Editing", "Loading"]
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    
    

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
                            streamer.updateNowPlayingInfo(with: image, title: receivedTopic, podcastTitle: "AI Podcast")
                        }
                }
                
                
                
                VStack{
                    Spacer()
                    Spacer()
                    
                    // Play/Pause button
                    if streamer.isLoading {
                        // loading status animation
                        if isCycling {
                            Text(states[currentStateIndex])
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .onAppear {
                                    cycleStates()
                                }
                        }
                        
                        Spacer()
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.bottom, 35)
                    } else {
                        // Play/Pause button
                        Button(action: handleAudioButton) {
                            Image(systemName: streamer.isPlaying ? "pause.circle" : "play.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 35)
                        }
                    }
                                    
                    Spacer()
                    
                    // Podcast question
                    HStack {
                        TextField("Podcast qeustion...", text: $podcastTopic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                                     
                        Button(action: {
                            if !podcastTopic.isEmpty {
                                startPodastButton()
                                podcastTopic = ""
                            }
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
                isCycling = true
            }
        }
    }

    // play/pause button
    private func handleAudioButton() {
        streamer.togglePlayPause()
        isCycling = false
    }
    
    private func startPodastButton() {
        self.isPlaying = true
        let url = URL(string: Constants.getAudioStream + "?userId=" + (authToken ?? "12345") + "&topic=" + podcastTopic)!
        self.streamer.playStream(from: url)
//        let url = URL(string: "https://wpr-ice.streamguys1.com/wpr-music-mp3-96")!
//        self.streamer.playStream(from: url)
    }
    
    private func fetchAuthToken() {
        apiService.fetchAuthToken { result in
            switch result {
            case .success(let responseString):
                print("API Response: \(responseString)")
//                self.authToken = responseString
//                self.isPlaying = true
//                let url = URL(string: Constants.getAudioStream + "?userId=" + uuid + "&podcastId=" + (authToken ?? uuid) + "&topic=" + receivedTopic)!
//                self.streamer.playStream(from: url)
                let url = URL(string: "https://wpr-ice.streamguys1.com/wpr-music-mp3-96")!
                self.streamer.playStream(from: url)
            case .failure(let error):
                print("Error fetching API data: \(error.localizedDescription)")
            }
        }
    }
    
    private func cycleStates() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            if !isCycling {
                timer.invalidate()
            } else {
                withAnimation(.easeInOut(duration: 1.0)) {
                    scale = 0.5
                    opacity = 0.0
                }
                    
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    currentStateIndex = (currentStateIndex + 1) % states.count
                        
                    withAnimation(.easeInOut(duration: 1.0)) {
                        scale = 1
                        opacity = 1
                    }
                }
            }
        }
    }
}

#Preview {
    PodcastView(receivedTopic: "What is API?", uuid: "1234567890")
}
