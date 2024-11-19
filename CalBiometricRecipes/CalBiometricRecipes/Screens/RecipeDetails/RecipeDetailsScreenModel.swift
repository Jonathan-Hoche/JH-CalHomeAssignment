//
//  RecipeDetailsScreenModel.swift
//  CalBiometricRecipes
//
//  Created by Jonathan Hoch on 19/11/2024.
//

import Foundation
import Combine

class RecipeDetailsScreenModel: ObservableObject {
    
    @Published private(set) var recipe: Recipe?
    @Published private(set) var failedAuthentication = false
    
    private let secureDataProvider = SecureDataProvider()
    private let biometricKey: String
    
    private var cancellable: AnyCancellable?
    
    init(biometricKey: String) {
        self.biometricKey = biometricKey
        
        getRecipe()
    }
    
    private func getRecipe() {
        cancellable = secureDataProvider.getDecryptedObject(with: biometricKey)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(_):
                    self?.failedAuthentication = true
                }
            }, receiveValue: { [weak self] (recipe: Recipe) in
                self?.recipe = recipe
                self?.failedAuthentication = false
            })
    }
}

extension RecipeDetailsScreenModel {
    
    func refresh() {
        if recipe == nil {
            failedAuthentication = false
            getRecipe()
        }
    }
}
