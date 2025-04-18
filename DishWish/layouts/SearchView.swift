//
//  SearchView.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 14/4/2025.
//

import SwiftUI
import Combine

import Foundation

struct Recipe: Decodable, Hashable {
    let id: Int
    let image: String
    let imageType: String
    let title: String
    let readyInMinutes: Int
    let servings: Int
    let sourceUrl: String
    let vegetarian: Bool
    let vegan: Bool
    let glutenFree: Bool
    let dairyFree: Bool
    let veryHealthy: Bool
    let cheap: Bool
    let veryPopular: Bool
    let sustainable: Bool
    let lowFodmap: Bool
    let weightWatcherSmartPoints: Int
    let gaps: String
    let preparationMinutes: Int?
    let cookingMinutes: Int?
    let aggregateLikes: Int
    let healthScore: Double
    let creditsText: String?
    let license: String?
    let sourceName: String?
    let pricePerServing: Double
//    let extendedIngredients: [ExtendedIngredient]
    let nutrition: Nutrition
    let summary: String
    let cuisines: [String]
    let dishTypes: [String]
    let diets: [String]
    let occasions: [String]
    let analyzedInstructions: [AnalyzedInstruction]
    let spoonacularScore: Double
    let spoonacularSourceUrl: String?
    let usedIngredientCount: Int
    let missedIngredientCount: Int
    let likes: Int
//    let missedIngredients: [Ingredient]
    let usedIngredients: [Ingredient]
//    let unusedIngredients: [Ingredient]
}

struct ExtendedIngredient: Decodable, Hashable {
    let id: Int
    let aisle: String?
    let image: String?
    let consistency: String?
    let name: String
    let original: String
    let originalString: String?
    let originalName: String?
    let amount: Double?
    let unit: String?
    // Add more fields if available
}

struct Nutrition: Decodable, Hashable {
    let nutrients: [Nutrient]
    let properties: [Nutrient]?
    let flavonoids: [Nutrient]?
    let caloricBreakdown: CaloricBreakdown
    let weightPerServing: WeightPerServing
}

struct CaloricBreakdown: Decodable, Hashable {
    let percentProtein: Double
    let percentFat: Double
    let percentCarbs: Double
}

struct WeightPerServing: Decodable, Hashable {
    let amount: Double
    let unit: String
}

struct Nutrient: Decodable, Hashable {
    let name: String
    let amount: Double
    let unit: String
    let percentOfDailyNeeds: Double?
}

struct AnalyzedInstruction: Decodable, Hashable {
    let name: String
    let steps: [InstructionStep]
}

struct InstructionStep: Decodable, Hashable {
    let number: Int
    let step: String
    let ingredients: [Ingredient]
    let equipment: [Equipment]
    let length: StepLength?
}

struct Ingredient: Decodable, Hashable {
    let id: Int?
    let amount: Double?
    let unit: String?
    let unitLong: String?
    let unitShort: String?
    let aisle: String?
    let name: String?
    let original: String?
    let originalName: String?
    let meta: [String]?
    let image: String?
}


struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: recipe.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)

                if let cooking = recipe.cookingMinutes, cooking > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(cooking) min")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                if let prep = recipe.preparationMinutes, prep > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                        Text("\(prep) min")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    if recipe.vegan {
                        Label("Vegan", systemImage: "leaf")
                    }
                    if recipe.cheap {
                        Label("Cheap", systemImage: "dollarsign.circle")
                    }
                    if recipe.veryPopular {
                        Label("Popular", systemImage: "star.fill")
                    }
                    if recipe.sustainable {
                        Label("Sustainable", systemImage: "globe")
                    }
                }
                .font(.caption)
                .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

class SearchViewModel: ObservableObject {
    @Published var suggestions: [String] = []
    @Published var recipes: [Recipe] = []
    @Published var nlpFoodItems: [NLPFoodItem] = []
    private var cancellables = Set<AnyCancellable>()
    private var cache = [String: [String]]()

    func fetchSuggestions(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }

        if let cached = cache[query] {
            suggestions = cached
            return
        }

        APIProxy.shared.autoCompleteFood(expression: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    struct AutoCompleteResponse: Decodable {
                        let suggestions: [String]
                    }

                    if let result = try? JSONDecoder().decode(AutoCompleteResponse.self, from: data) {
                        self?.cache[query] = result.suggestions
                        self?.suggestions = result.suggestions
                        print(result.suggestions)
                    } else {
                        self?.suggestions = []
                    }
                case .failure:
                    self?.suggestions = []
                }
            }
        }
    }

    func fetchNLPNutrition(for query: String) {
        guard !query.isEmpty else { return }

        APIProxy.shared.fetchNutritionInfo(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    struct NLPResponse: Decodable {
                        let foods: [NLPFoodItem]
                    }

                    if let result = try? JSONDecoder().decode(NLPResponse.self, from: data) {
                        self?.nlpFoodItems = result.foods
                    } else {
                        self?.nlpFoodItems = []
                    }
                case .failure:
                    self?.nlpFoodItems = []
                }
            }
        }
    }

    func fetchRecipeSuggestions(
        ingredients: [String],
        mealType: String?,
        maxTime: Int?,
        cuisine: String?,
        diet: String?,
        allergens: String?,
        number: Int = 7
    ) {
        let request = RecipeRequestModel(
            ingredients: ingredients,
            mealType: mealType,
            maxTime: maxTime,
            cuisine: cuisine,
            diet: diet,
            allergens: allergens,
            number: number
        )

        APIProxy.shared.fetchRecipes(request: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    struct RecipeResult: Decodable {
                        let results: [Recipe]
                    }

                    if let decoded = try? JSONDecoder().decode(RecipeResult.self, from: data) {
                        self?.recipes = decoded.results
                    } else {
                        self?.recipes = []
                    }
                case .failure:
                    self?.recipes = []
                }
            }
        }
    }
}

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var showSearchBar = false
    @FocusState private var isSearchFocused: Bool
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedMealType: String = ""
    @State private var selectedMaxTime: Int = 60
    @State private var selectedCuisine: String = ""
    @State private var selectedDiet: String = ""
    @State private var selectedAllergens: String = ""
    @State private var numberOfResults: Int = 7
    @State private var searchMode: String = "food"
    private let searchModeOptions = ["food", "recipe"]
    private let cuisineOptions = ["", "Italian", "Chinese", "Mexican", "Indian", "French", "Japanese"]
    private let dietOptions = ["", "vegetarian", "vegan", "pescetarian", "ketogenic", "gluten free"]
    private let allergenOptions = ["", "dairy", "egg", "gluten", "peanut", "seafood", "sesame", "soy", "sulfite", "tree nut", "wheat"]
    @State private var suppressAutoTrigger = false
    @State private var hasSearched = false
    @Binding var predictedObjects: String
    
    
    var shouldShowFilters: Bool {
        return searchMode == "recipe" && searchText.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Search Mode", selection: $searchMode) {
                    ForEach(searchModeOptions, id: \.self) {
                        Text($0.capitalized).tag($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)

                if shouldShowFilters {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Picker("Meal Type", selection: $selectedMealType) {
                                Text("Any").tag("")
                                Text("Main Course").tag("main course")
                                Text("Side Dish").tag("side dish")
                                Text("Dessert").tag("dessert")
                                Text("Snack").tag("snack")
                                Text("Breakfast").tag("breakfast")
                            }
                            .pickerStyle(MenuPickerStyle())

                            Text("Max Time:")
                            TextField("min", value: $selectedMaxTime, formatter: NumberFormatter())
                                .frame(width: 50)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        HStack {
                            Text("Cuisine:")
                            Picker("Cuisine", selection: $selectedCuisine) {
                                ForEach(cuisineOptions, id: \.self) { Text($0.isEmpty ? "Any" : $0.capitalized).tag($0) }
                            }
                            .pickerStyle(MenuPickerStyle())

                            Text("Diet:")
                            Picker("Diet", selection: $selectedDiet) {
                                ForEach(dietOptions, id: \.self) { Text($0.isEmpty ? "Any" : $0.capitalized).tag($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }

                        HStack {
                            Text("Allergens:")
                            Picker("Allergens", selection: $selectedAllergens) {
                                ForEach(allergenOptions, id: \.self) { Text($0.isEmpty ? "None" : $0.capitalized).tag($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }

                TextField("Search for recipes...", text: $searchText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                    .focused($isSearchFocused)
                
                if hasSearched && searchMode == "food" && !viewModel.suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.suggestions, id: \.self) { suggestion in
                            Button(action: {
                                suppressAutoTrigger = true
                                searchText = suggestion
                                viewModel.fetchNLPNutrition(for: suggestion)
                                viewModel.suggestions = []
                                isSearchFocused = false
                                hasSearched = false
                            }) {
                                Text(suggestion)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .shadow(radius: 2)
                }
                
                Button(action: {
                    if searchMode == "food" {
                        viewModel.fetchNLPNutrition(for: searchText)
                    } else if searchMode == "recipe" {
                        let ingredients = searchText
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
 
                        viewModel.fetchRecipeSuggestions(
                            ingredients: ingredients,
                            mealType: selectedMealType.isEmpty ? nil : selectedMealType,
                            maxTime: selectedMaxTime,
                            cuisine: selectedCuisine.isEmpty ? nil : selectedCuisine,
                            diet: selectedDiet.isEmpty ? nil : selectedDiet,
                            allergens: selectedAllergens.isEmpty ? nil : selectedAllergens,
                            number: numberOfResults
                        )
                    }
                    UserDefaults.standard.set(searchText, forKey: "searchHistory")
                }) {
                    Text("Search")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                if searchText.isEmpty {
                    Text("Type something to search")
                        .foregroundColor(.gray)
                        .padding()
                        .onTapGesture {
                            isSearchFocused = false
                        }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if searchMode == "recipe" {
                                ForEach(viewModel.recipes, id: \.self) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCardView(recipe: recipe)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            } else {
                                ForEach(viewModel.nlpFoodItems, id: \.self) { item in
                                    NavigationLink(destination: FoodDetailView(foodItem: item)) {
                                        HStack(spacing: 12) {
                                            AsyncImage(url: URL(string: item.photo.thumb)) { image in
                                                image.resizable()
                                                     .aspectRatio(contentMode: .fill)
                                                     .frame(width: 60, height: 60)
                                                     .clipShape(RoundedRectangle(cornerRadius: 8))
                                            } placeholder: {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 60, height: 60)
                                            }
 
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.foodName.capitalized)
                                                    .font(.headline)
                                                Text("Tap for details")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                }
                            }
                        }
                        .padding()
                        .onTapGesture {
                            isSearchFocused = false
                        }
                    }
                }
            }.onChange(of: searchText) { newValue in
                if suppressAutoTrigger {
                    suppressAutoTrigger = false
                    return
                }

                if newValue.isEmpty {
                    hasSearched = false
                    viewModel.recipes = []
                    viewModel.nlpFoodItems = []
                } else {
                    viewModel.fetchSuggestions(for: searchText)
                    hasSearched = true
                }
            }
            .navigationTitle("Search")
            .onAppear {
                showSearchBar = true
                suppressAutoTrigger = true
                hasSearched = false
                if !predictedObjects.isEmpty {
                    searchText = predictedObjects
                    if searchMode == "food" {
                        viewModel.fetchNLPNutrition(for: predictedObjects)
                    } else if searchMode == "recipe" {
                        let ingredients = predictedObjects
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        viewModel.fetchRecipeSuggestions(
                            ingredients: ingredients,
                            mealType: selectedMealType.isEmpty ? nil : selectedMealType,
                            maxTime: selectedMaxTime,
                            cuisine: selectedCuisine.isEmpty ? nil : selectedCuisine,
                            diet: selectedDiet.isEmpty ? nil : selectedDiet,
                            allergens: selectedAllergens.isEmpty ? nil : selectedAllergens,
                            number: numberOfResults
                        )
                    }
                }
            }
        }
    }


struct Equipment: Decodable, Hashable {
    let id: Int
    let name: String
    let image: String?
}

struct StepLength: Decodable, Hashable {
    let number: Int
    let unit: String
}
struct NLPFoodItem: Decodable, Hashable {
    let foodName: String
    let servingQty: Double
    let servingUnit: String
    let servingWeightGrams: Double
    let nfCalories: Double
    let nfTotalFat: Double
    let nfSaturatedFat: Double
    let nfCholesterol: Double
    let nfSodium: Double
    let nfTotalCarbohydrate: Double
    let nfDietaryFiber: Double
    let nfSugars: Double
    let nfProtein: Double
    let nfPotassium: Double
    let nfP: Double
    let photo: NLPPhoto

    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case servingQty = "serving_qty"
        case servingUnit = "serving_unit"
        case servingWeightGrams = "serving_weight_grams"
        case nfCalories = "nf_calories"
        case nfTotalFat = "nf_total_fat"
        case nfSaturatedFat = "nf_saturated_fat"
        case nfCholesterol = "nf_cholesterol"
        case nfSodium = "nf_sodium"
        case nfTotalCarbohydrate = "nf_total_carbohydrate"
        case nfDietaryFiber = "nf_dietary_fiber"
        case nfSugars = "nf_sugars"
        case nfProtein = "nf_protein"
        case nfPotassium = "nf_potassium"
        case nfP = "nf_p"
        case photo
    }
}

struct NLPPhoto: Decodable, Hashable {
    let thumb: String
}
