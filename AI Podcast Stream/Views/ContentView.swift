//
//  ContentView.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import SwiftUI

struct ContentView: View {
    // 1. Define state variables to manage the text input
        @State private var inputTopic: String = ""
        @State private var showTestRequestView: Bool = false
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
                // 2. Use a VStack to layout the elements vertically
                VStack {
                    // 2.1. Title section
                    Text("Al Podcast")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    // 2.2. Buttons grid section
                    // 3. Use a LazyVGrid to create a grid layout for buttons
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        // 3.1. Create 6 buttons in the grid
                        ForEach(topics.indices, id: \.self) { index in
                                        Button(action: {
                                            // When the button is tapped, set the selectedTopic
                                            // This will trigger the navigation
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
                    
                    // 2.3. Text input and send button section
                    HStack {
                        // 4. Text input field
                        TextField("Podcast topic...", text: $inputTopic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                        
                        // 5. Send button
                        Button(action: {
                            // Store the topic in temporary variable
                            temporaryTopic = inputTopic
                            // Clear the TextField
                            inputTopic = ""
                            // This will trigger the navigation
                            self.showTestRequestView = true
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.trailing)
                        .navigationDestination(isPresented: $showTestRequestView) {
                            PodcastView(receivedTopic: temporaryTopic)
                                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
                .padding(.bottom)
                .navigationDestination(isPresented: .constant(selectedTopic != nil), destination: {
                            if let selectedTopic = selectedTopic {
                                PodcastView(receivedTopic: selectedTopic)
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
