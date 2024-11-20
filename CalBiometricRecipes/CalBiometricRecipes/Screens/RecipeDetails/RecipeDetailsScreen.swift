//
//  RecipeDetailsScreen.swift
//  CalBiometricRecipes
//
//  Created by Jonathan Hoch on 19/11/2024.
//

import SwiftUI

struct RecipeDetailsScreen: View {
    
    @StateObject var screenModel: RecipeDetailsScreenModel
    
    var body: some View {
        ScrollView {
            VStack {
                if let recipe = screenModel.recipe {
                    AsyncImage(url: URL(string: recipe.image ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    HStack {
                        Text(recipe.fats ?? "")
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Text(recipe.calories ?? "")
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    Text(recipe.description ?? "")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                } else if screenModel.failedAuthentication {
                    VStack {
                        Text("Something went wrong with your authentication.")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 32)
                        
                        Text("Pull to refresh")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .refreshable {
            screenModel.refresh()
        }
        .navigationTitle(screenModel.recipe?.name ?? "")
    }
}

#Preview {
    RecipeDetailsScreen(screenModel: .init(biometricKey: ""))
}
