//
//  ImageFetcher.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import Foundation
import SwiftUI


class ImageFetcher: ObservableObject {
    private var apiService = APIService()
    
    @Published var coverImage: UIImage?
    @Published var isLoadingImage = false
    
    // getCover
    func loadCoverImage(topic: String) {
        isLoadingImage = true
        apiService.getCoverImageURL(topic: topic) { [weak self] result in
            switch result {
            case .success(let imageURL):
                self?.downloadImage(from: imageURL)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoadingImage = false
                    print("Error fetching image URL: \(error)")
                    // Handle the error appropriately
                }
            }
        }
    }
        
        
        
    // getCover
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoadingImage = false
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                    // Handle the error
                    return
                }
                self?.coverImage = image
            }
        }.resume()
    }
}
