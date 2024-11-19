//
//  Recipe.swift
//  CalBiometricRecipes
//
//  Created by Jonathan Hoch on 18/11/2024.
//

import Foundation

struct Recipe: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
    let calories: String?
    let carbos: String?
    let fats: String?
    let image: String?
    let thumb: String?
    
    // Unused:
    /*
    let difficulty: Int?
    let headline: String?
    let proteins: String?
    let time: String
    let country: String?
     */
}
