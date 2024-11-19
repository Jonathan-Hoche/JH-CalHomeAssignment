//
//  RestAPIRequest.swift
//  CalBiometricRecipes
//
//  Created by Jonathan Hoch on 18/11/2024.
//

import Foundation

struct RestAPIRequest<T: Decodable> {
    
    let requestUrl: String
    
    func fetch() async throws -> [T] {
        // Ensure the URL is valid
        guard let url = URL(string: requestUrl) else {
            throw URLError(.badURL)
        }
        
        // Create a URL session with a default configuration
        let urlSession = URLSession.shared
        
        // Perform network request asynchronously
        let (data, response) = try await urlSession.data(from: url)
        
        // Check if the response is valid (HTTP status 200)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode data
        let decoder = JSONDecoder()
        do {
            let recipes = try decoder.decode([T].self, from: data)
            return recipes
        } catch {
            throw error
        }
    }
}
