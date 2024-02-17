//
//  ContentView.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import SwiftUI

struct ContentView: View {
    var uuid: String

    init() {
        if let savedUUID = UserDefaults.standard.string(forKey: "appUUID") {
            // Use the saved UUID
            uuid = savedUUID
        } else {
            // Generate a new UUID and save it
            uuid = UUID().uuidString
            UserDefaults.standard.set(uuid, forKey: "appUUID")
        }
    }
        
    @State private var inputTopic: String = ""
    @State private var textHeight: CGFloat = 35 // Initial height
    @State private var showPodcastView: Bool = false
    @State private var temporaryTopic: String = ""
    @State private var selectedTopic: String?
    @State private var buttonHeight: CGFloat = 0

    let allTopics = [
        Topic(title: "The art of conversation", icon: "💬"),
        Topic(title: "Exploring the universe", icon: "⭐️"),
        Topic(title: "The history of technology", icon: "⚙️"),
        Topic(title: "Future of transportation", icon: "🚗"),
        Topic(title: "Deep sea mysteries", icon: "🌊"),
        Topic(title: "Space travel: myths and facts", icon: "🚀"),
        Topic(title: "Ancient civilizations", icon: "🔺"),
        Topic(title: "The science of happiness", icon: "😊"),
        Topic(title: "World's greatest mysteries", icon: "🔍"),
        Topic(title: "Artificial Intelligence & us", icon: "🖥"),
        Topic(title: "Sustainable living", icon: "🍃"),
        Topic(title: "The power of meditation", icon: "🚶‍♂️"),
        Topic(title: "Understanding blockchain", icon: "🔗"),
        Topic(title: "The evolution of music", icon: "🎵"),
        Topic(title: "Photography techniques", icon: "📷"),
        Topic(title: "Urban gardening and sustainability", icon: "🍃"),
        Topic(title: "The future of work and digital nomadism", icon: "💻"),
        Topic(title: "Mindfulness and productivity", icon: "⏳"),
        Topic(title: "Cultural impacts of cinema", icon: "🎞"),
        Topic(title: "Advancements in renewable energy", icon: "⚡️"),
        Topic(title: "The psychology of social media", icon: "👥"),
        Topic(title: "Exploring minimalist living", icon: "🏠"),
        Topic(title: "The art of storytelling", icon: "📖"),
        Topic(title: "Innovations in healthcare", icon: "❌"),
        Topic(title: "The impact of fashion on society", icon: "👓"),
        Topic(title: "Understanding the stock market", icon: "📊"),
        Topic(title: "The role of AI in education", icon: "🎓"),
        Topic(title: "Exploring virtual reality", icon: "🌐"),
        Topic(title: "The history of video games", icon: "🎮"),
        Topic(title: "The importance of cybersecurity", icon: "🔒"),
        Topic(title: "The evolution of social networks", icon: "👥"),
        Topic(title: "The future of space exploration", icon: "🔭"),
        Topic(title: "Understanding climate change", icon: "☁️"),
        Topic(title: "The world of cryptocurrencies", icon: "💰"),
        Topic(title: "The science behind nutrition", icon: "🍃")
    ]
    
    @State private var topics: [Topic] = []
    @State private var isLoading = true
        
    var body: some View {
        NavigationStack {
            VStack {
                Text("Podcaster")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // topics to get started
                NavigationView {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(topics) { topic in
                                NavigationLink(destination: PodcastView(receivedTopic: topic.title, uuid: uuid)) {
                                    TopicRow(topic: topic)
                                        .frame(width: UIScreen.main.bounds.width * 0.85)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Topics to get started")
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        topics = allTopics.shuffled().prefix(8).map { $0 }
                    }
                }.navigationViewStyle(StackNavigationViewStyle())
                
                // text input field with placeholder
                HStack {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $inputTopic)
                            .frame(height: max(textHeight, buttonHeight))
                            .background(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 0.5)
                            )
                            .onChange(of: inputTopic) {
                                let textView = UITextView()
                                textView.text = inputTopic
                                textView.font = UIFont.systemFont(ofSize: 18)
                                let size = CGSize(width: UIScreen.main.bounds.width - 90, height: .infinity)
                                let estimatedSize = textView.sizeThatFits(size)
                                textHeight = estimatedSize.height
                            }
                        
                        if inputTopic.isEmpty {
                            Text("Podcast anything 🎤")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 7) // Adjust to match TextEditor's text padding
                                .padding(.vertical, 8) // Adjust to match TextEditor's text padding
                        }
                    }
                    .padding() // Apply padding to the ZStack for outer spacing
                    
                    // button to send the text
                    Button(action: {
                        if !inputTopic.isEmpty {
                            temporaryTopic = inputTopic
                            inputTopic = ""
                            self.showPodcastView = true
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
                    .navigationDestination(isPresented: $showPodcastView) {
                        PodcastView(receivedTopic: temporaryTopic, uuid: uuid)
                    }
                }
            }
            .padding(.bottom)
            .navigationDestination(isPresented: .constant(selectedTopic != nil), destination: {
                if let selectedTopic = selectedTopic {
                    PodcastView(receivedTopic: selectedTopic, uuid: uuid)
                } else {
                    EmptyView()
                }
            })
        }
    }
}


struct Topic: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}


struct TopicRow: View {
    var topic: Topic
    
    var body: some View {
        HStack {
            Text(topic.icon)
                .font(.system(size: 24)) // Adjusted for emoji display
                .frame(width: 36, height: 36)
                .padding(.leading, 8) // Added small margin from the left side of the emoji
            Text(topic.title)
                .foregroundColor(.black) // Ensure text color is black
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.body)
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 3)
    }
}

//func fetchTopics() {
//    guard let url = URL(string: "https://api.example.com/topics") else { return }
//    URLSession.shared.dataTask(with: url) { data, response, error in
//        if let data = data {
//            if let decodedResponse = try? JSONDecoder().decode([Topic].self, from: data) {
//                DispatchQueue.main.async {
//                    self.topics = decodedResponse
//                    self.isLoading = false
//                }
//                return
//            }
//        }
//        // Handle error/failure or use default topics
//        DispatchQueue.main.async {
//            self.topics = allTopics.shuffled().prefix(8).map { $0 }
//            self.isLoading = false
//        }
//    }.resume()
//}

#Preview {
    ContentView()
}
