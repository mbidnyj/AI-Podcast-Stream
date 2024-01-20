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
    @State private var showPodcastView: Bool = false
    @State private var temporaryTopic: String = ""
    @State private var selectedTopic: String?
    let topics = [
        "Mastering Money Management?",
        "Navigating Mental Wellness?",
        "Trending in Pop Culture?",
        "Tech's Latest Innovations?",
        "Culinary Cultures Explored?",
        "Mysteries: Solved, Unsolved?"
    ]
        
    var body: some View {
        NavigationStack {
            VStack {
                Text("Al Podcast")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(topics.indices, id: \.self) { index in
                        Button(action: {
                            self.selectedTopic = topics[index]
                        }) {
                            Text(topics[index])
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .frame(maxHeight: .infinity, alignment: .center)
                    
                HStack {
                    TextField("Podcast topic...", text: $inputTopic)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                        
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
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

#Preview {
    ContentView()
}
