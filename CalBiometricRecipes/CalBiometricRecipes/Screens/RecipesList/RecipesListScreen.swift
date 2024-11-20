//
//  RecipesListScreen.swift
//  CalBiometricRecipes
//
//  Created by Jonathan Hoch on 18/11/2024.
//

import SwiftUI

struct RecipesListScreen: View {
    
    @StateObject private var screenModel = RecipesListScreenModel()
    
    var body: some View {
        
        NavigationStack {
            Group {
                if !screenModel.recipes.isEmpty {
                    List(screenModel.recipes) { recipe in
                        VStack {
                            Text(recipe.name)
                                .font(.headline)
                                .lineLimit(1)
                            HStack {
                                VStack(alignment: .leading){
                                    Text(recipe.fats ?? "")
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    
                                    Text(recipe.calories ?? "")
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    
                                    Text(recipe.carbos ?? "")
                                        .font(.subheadline)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                AsyncImage(url: URL(string: recipe.image ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 50)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        .overlay {
                            Color.clear
                                .contentShape(Rectangle()) // Makes the clear background tappable
                                .onTapGesture {
                                    screenModel.tapped(recipe: recipe)
                                }
                        }
                    }
                } else if screenModel.failedFetch {
                    VStack {
                        Text("Something went wrong with fetching recipes.\nCheck your internet!")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 32)
                        Button {
                            screenModel.fetch()
                        } label: {
                            Text("Try fetching again")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.top, 16)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(isPresented: Binding(
                get: {
                    screenModel.selectedRecipeId != nil },
                set: { isPresented in
                    if !isPresented { screenModel.selectedRecipeId = nil }
                }
            )) {
                if let recipeID = screenModel.selectedRecipeId {
                    RecipeDetailsScreen(screenModel: .init(biometricKey: recipeID))
                }
            }
        }
    }
}

#Preview {
    RecipesListScreen()
}
