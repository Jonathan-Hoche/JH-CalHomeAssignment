//
//  RecipesListScreenModel.swift
//  CalBiometricRecipes
//
//  Created by Jonathan Hoch on 19/11/2024.
//

import Foundation
import Combine

class RecipesListScreenModel: ObservableObject {
    
    @Published private(set) var recipes = [Recipe]()
    
    @Published private(set) var failedFetch = false
    @Published private(set) var failedSecuringData = false
    
    @Published var selectedRecipeId: String? // Used as Binding
    
    private let recipesProvider = RecipesProvider()
    
    private let secureDataProvider = SecureDataProvider()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getRecipes()
    }
    
    private func getRecipes() {
        recipesProvider.fetch().receive(on: RunLoop.main).sink { [weak self] recipesFetchError in
            switch recipesFetchError {
            case .finished: break
            case .failure(_):
                self?.failedFetch = true
            }
        } receiveValue: { [weak self] recipes in
            self?.recipes = recipes
        }.store(in: &cancellables)
    }
}

extension RecipesListScreenModel {
    
    func tapped(recipe: Recipe) {
        secureDataProvider.encrypt(with: recipe.id, object: recipe).receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished: break
            case .failure(_):
                self?.failedSecuringData = true
            }
        }, receiveValue: { [weak self] _ in
            self?.selectedRecipeId = recipe.id
            self?.failedSecuringData = false
        }).store(in: &cancellables)
    }
    
    func fetch() {
        if recipes.isEmpty {
            failedFetch = false
            getRecipes()
        }
    }
}
