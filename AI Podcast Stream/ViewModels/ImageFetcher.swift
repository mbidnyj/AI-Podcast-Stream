//
//  ImageFetcher.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import Foundation
import SwiftUI

class ImageFetcher: ObservableObject {
    @Published var image: Image? = nil
    @Published var isLoading = false

    // Function to fetch the image URL
    func fetchImageUrl(from endpoint: String) {
        isLoading = true

        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching image URL: \(error)")
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                return
            }

            if let data = data, let imageUrlString = String(data: data, encoding: .utf8), let imageUrl = URL(string: imageUrlString) {
                self?.downloadImage(from: imageUrl)
            } else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                print("Invalid response data")
            }
        }.resume()
    }

    // Function to download the image
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = data, error == nil, let uiImage = UIImage(data: data) {
                    self?.image = Image(uiImage: uiImage)
                } else {
                    print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }
}
