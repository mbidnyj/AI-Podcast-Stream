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
    // loading animation
    @State private var isLoading = true
    // expanding text window
    @State private var textHeight: CGFloat = 35 // Initial height
    @State private var buttonHeight: CGFloat = 0
    
    

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Show title
                Text(receivedTopic)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                        .frame(maxWidth: geometry.size.width * 0.9, alignment: .top)
                        .multilineTextAlignment(.center)
                
                // Display image
                Spacer().frame(height: 50)
                if imageFetcher.isLoadingImage {
                    ProgressView()
                        .frame(width: geometry.size.width * 0.8)
                        .scaleEffect(1.5)
                        .padding(.bottom, 35)
                } else if let image = imageFetcher.coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.8)
                        .onAppear{
                            streamer.updateNowPlayingInfo(with: image, title: receivedTopic, podcastTitle: "Podcaster")
                        }
                }
                
                VStack{
                    Spacer()
                    Spacer()
                    
                    // Play/Pause button
                    if streamer.isLoading {
                        // Loading animation
                        ZStack {
                            if isLoading {
                                LoadingAnimationView()
                            }
                        }
                        .onChange(of: isLoading) {
                            if $isLoading.wrappedValue {
                                withAnimation {
                                    isLoading = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                                    isLoading = true
                                }
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
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $podcastTopic)
                                .frame(height: max(textHeight, buttonHeight))
                                .background(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                                .onChange(of: podcastTopic) {
                                    let textView = UITextView()
                                    textView.text = podcastTopic
                                    textView.font = UIFont.systemFont(ofSize: 18)
                                    let size = CGSize(width: UIScreen.main.bounds.width - 90, height: .infinity)
                                    let estimatedSize = textView.sizeThatFits(size)
                                    textHeight = estimatedSize.height
                                }
                            
                            if podcastTopic.isEmpty {
                                Text("Ask additional question")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 7) // Adjust to match TextEditor's text padding
                                    .padding(.vertical, 8) // Adjust to match TextEditor's text padding
                            }
                        }
                        .padding() // Apply padding to the ZStack for outer spacing
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
                                .cornerRadius(15)
                                .overlay(
                                    GeometryReader { geometry in
                                        Color.clear.onAppear {
                                            buttonHeight = geometry.size.height
                                        }
                                    }
                                )
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
        streamer.togglePlayPause()
    }
    
    private func startPodastButton() {
        self.isPlaying = true
        let url = URL(string: Constants.getAudioStream + "?userId=" + (authToken ?? "12345") + "&topic=" + podcastTopic)!
        self.streamer.playStream(from: url)
        // Public radio url
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
                // Public radio url
                let url = URL(string: "https://wpr-ice.streamguys1.com/wpr-music-mp3-96")!
                self.streamer.playStream(from: url)
            case .failure(let error):
                print("Error fetching API data: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    PodcastView(receivedTopic: "What is API?", uuid: "1234567890")
}
