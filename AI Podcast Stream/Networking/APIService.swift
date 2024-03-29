//
//  APIService.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 10.01.2024.
//

import Foundation

struct APIService{
    func getCoverImageURL(topic: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let urlString = Constants.getCover + "?topic=\(topic)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            guard let imageURL = URL(string: String(decoding: data, as: UTF8.self)) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            completion(.success(imageURL))
        }
        task.resume()
    }
    
    
    
    func fetchAuthToken(completion: @escaping (Result<String, Error>) -> Void) {
            let url = URL(string: Constants.getAuth)!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to String"])))
                    return
                }

                completion(.success(responseString))
            }

            task.resume()
        }
}
