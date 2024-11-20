//
//  RecipesProvider.swift
//  CalBiometricRecipes
//
//  Created by Jonathan Hoch on 18/11/2024.
//

import Foundation
import Combine

class RecipesProvider {
    
    private let restAPIRequest = RestAPIRequest<Recipe>(requestUrl: "https://hf-android-app.s3-eu-west-1.amazonaws.com/android-test/recipes.json")
    
    func fetch() -> Future<[Recipe], RecipesFetchError> {
        return Future { [weak self] promise in
            guard let strongSelf = self else {
                promise(.failure(.failed))
                return
            }
            
            Task {
                do {
                    let recipes = try await strongSelf.restAPIRequest.fetch()
                    promise(.success(recipes))
                } catch {
                    promise(.failure(.failed))
                }
            }
        }
    }
}

enum RecipesFetchError: String, Error {
    case failed
    // Here we could provide more cases detailing why the fetch failed
}
