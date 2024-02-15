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

    let allTopics = [
        Topic(title: "The art of conversation", icon: "message.fill"),
        Topic(title: "Exploring the universe", icon: "star.fill"),
        Topic(title: "The history of technology", icon: "gear"),
        Topic(title: "Future of transportation", icon: "car.fill"),
        Topic(title: "Deep sea mysteries", icon: "waveform.path.ecg"),
        Topic(title: "Space travel: myths and facts", icon: "star.fill"),
        Topic(title: "Ancient civilizations", icon: "pyramid.fill"),
        Topic(title: "The science of happiness", icon: "smiley.fill"),
        Topic(title: "World's greatest mysteries", icon: "magnifyingglass.circle.fill"),
        Topic(title: "Artificial Intelligence & us", icon: "cpu.fill"),
        Topic(title: "Sustainable living", icon: "leaf.fill"),
        Topic(title: "The power of meditation", icon: "figure.walk"),
        Topic(title: "Understanding blockchain", icon: "link"),
        Topic(title: "The evolution of music", icon: "music.note"),
        Topic(title: "Photography techniques", icon: "camera.fill"),
        Topic(title: "Urban gardening and sustainability", icon: "leaf.arrow.circlepath"),
        Topic(title: "The future of work and digital nomadism", icon: "laptopcomputer"),
        Topic(title: "Mindfulness and productivity", icon: "hourglass"),
        Topic(title: "Cultural impacts of cinema", icon: "film"),
        Topic(title: "Advancements in renewable energy", icon: "bolt.horizontal"),
        Topic(title: "The psychology of social media", icon: "person.3.fill"),
        Topic(title: "Exploring minimalist living", icon: "house.fill"),
        Topic(title: "The art of storytelling", icon: "book.closed.fill"),
        Topic(title: "Innovations in healthcare", icon: "cross.fill"),
        Topic(title: "The impact of fashion on society", icon: "eyeglasses"),
        Topic(title: "Understanding the stock market", icon: "chart.bar.fill"),
        Topic(title: "The role of AI in education", icon: "graduationcap.fill"),
        Topic(title: "Exploring virtual reality", icon: "globe"),
        Topic(title: "The history of video games", icon: "gamecontroller.fill"),
        Topic(title: "The importance of cybersecurity", icon: "lock.fill"),
        Topic(title: "The evolution of social networks", icon: "person.2.square.stack.fill"),
        Topic(title: "The future of space exploration", icon: "star.fill"),
        Topic(title: "Understanding climate change", icon: "cloud.sun.fill"),
        Topic(title: "The world of cryptocurrencies", icon: "bitcoinsign.circle.fill"),
        Topic(title: "The science behind nutrition", icon: "leaf.fill")
    ]
    
    @State private var topics: [Topic] = []
        
    var body: some View {
        NavigationStack {
            VStack {
                Text("Podcaster")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                NavigationView {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(topics) { topic in
//                                NavigationLink(destination: DetailView(topic: topic)) {
//                                    TopicRow(topic: topic)
//                                        .frame(width: UIScreen.main.bounds.width * 0.85)
//                                }
//                                .buttonStyle(.plain)
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
                }
                
                HStack {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $inputTopic)
                            .frame(height: max(35, textHeight))
                            .border(Color.gray, width: 1)
                            .cornerRadius(5)
                            .onChange(of: inputTopic) {
                                let textView = UITextView()
                                textView.text = inputTopic
                                textView.font = UIFont.systemFont(ofSize: 18)
                                let size = CGSize(width: UIScreen.main.bounds.width - 90, height: .infinity)
                                let estimatedSize = textView.sizeThatFits(size)
                                textHeight = estimatedSize.height
                            }
                        
                        if inputTopic.isEmpty {
                            Text("Podcast anything")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 7) // Adjust to match TextEditor's text padding
                                .padding(.vertical, 7) // Adjust to match TextEditor's text padding
                        }
                    }
                    .padding() // Apply padding to the ZStack for outer spacing
                    
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
                            .cornerRadius(10)
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
            Image(systemName: topic.icon)
                .foregroundColor(.accentColor)
                .imageScale(.medium)
                .frame(width: 36, height: 36)
            Text(topic.title)
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

struct DetailView: View {
    var topic: Topic
    
    var body: some View {
        Text("Details for \(topic.title)")
            .navigationTitle(topic.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
