//
//  TopicRow.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 18.02.2024.
//

import SwiftUI

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

#Preview {
    TopicRow(topic: Topics.allTopics[0])
}
