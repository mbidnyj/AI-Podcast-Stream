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

    // Topics
    @State private var allTopics: [Topic] = Topics.allTopics
    @State private var topics: [Topic] = []
    @State private var isLoading = true
        
    var body: some View {
        NavigationStack {
            VStack {
                Text("Podcaster")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Topics to get started
                NavigationView {
                    ScrollView {
                        VStack(spacing: 20) {
                            if isLoading {
                                ForEach(allTopics.shuffled().prefix(8)) { topic in
                                TopicRow(topic: topic)
                                    .frame(width: UIScreen.main.bounds.width * 0.85)
                                }
                            } else {
                                ForEach(topics) { topic in
                                    NavigationLink(destination: PodcastView(receivedTopic: topic.title, uuid: uuid)) {
                                        TopicRow(topic: topic)
                                            .frame(width: UIScreen.main.bounds.width * 0.85)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Topics to get started")
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        fetchTopics()
                    }
                }.navigationViewStyle(StackNavigationViewStyle())
                
                // Text input field with placeholder
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
                            Text("Podcast anything")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 7) // Adjust to match TextEditor's text padding
                                .padding(.vertical, 8) // Adjust to match TextEditor's text padding
                        }
                    }
                    .padding() // Apply padding to the ZStack for outer spacing
                    
                    // Button
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
    
    func fetchTopics() {
        guard let url = URL(string: "Constants.getTopics") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Topic].self, from: data) {
                    DispatchQueue.main.async {
                        self.topics = decodedResponse
                        self.isLoading = false
                    }
                    return
                }
            }
            // Handle error/failure or use default topics
            DispatchQueue.main.async {
                self.topics = allTopics.shuffled().prefix(8).map { $0 }
                self.isLoading = false
            }
        }.resume()
    }
}

struct Topic: Identifiable, Codable {
    var id: Int
    let title: String
    let icon: String
}

#Preview {
    ContentView()
}
