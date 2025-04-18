//
//  HomeView.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 16/4/2025.
//
import SwiftUI
import Shimmer
import UIKit
import PhotosUI

struct RecipeResult: Decodable {
    let results: [Recipe]
}

struct HomeView: View {
    @State private var selectedCategory: String = "Breakfast"
    @State private var isLoading = true
    @State private var userName: String = "Place Holder"
    @State private var featuredVideos: [YoutubeVideo] = []
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @Binding var predictedObjects: String
    @StateObject private var searchViewModel = SearchViewModel()
    let categories = ["Breakfast", "Lunch", "Dinner"]
    @State private var categoryRecipes: [String: [Recipe]] = [:]
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "🌤 Good Morning"
        case 12..<18: return "☀️ Good Afternoon"
        case 18..<22: return "🌆 Good Evening"
        default: return "🌙 Good Night"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greetingText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .redacted(reason: isLoading ? .placeholder : [])
                            .shimmering(active: isLoading)
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .redacted(reason: isLoading ? .placeholder : [])
                            .shimmering(active: isLoading)
                    }
                    .padding(.horizontal)

                    // Featured Recipes
                    VStack(alignment: .leading) {
                        Text("Featured")
                            .font(.headline)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(featuredVideos, id: \.videoId) { video in
                                    FeaturedCardView(video: video)
                                        .redacted(reason: isLoading ? .placeholder : [])
                                        .shimmering(active: isLoading)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Categories
                    VStack(alignment: .leading) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.teal.opacity(0.2) : Color(.systemGray6))
                                        .cornerRadius(20)
                                        .foregroundColor(.primary)
                                        .redacted(reason: isLoading ? .placeholder : [])
                                        .shimmering(active: isLoading)
                                }
                            }
                        }
                        .padding(.horizontal)

                        Text(selectedCategory)
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators:     false) {
                            HStack(spacing: 16) {
                                ForEach(categoryRecipes[selectedCategory] ?? [], id: \.id) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCardView(recipe: recipe)
                                            .redacted(reason: isLoading ? .placeholder : [])
                                            .shimmering(active: isLoading)
                                    }
                                    
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Popular Recipes
//                    VStack(alignment: .leading) {
//                        HStack {
//                            Text("Popular Recipes")
//                                .font(.headline)
//                            Spacer()
//                            Button("See All") {}
//                                .font(.subheadline)
//                                .foregroundColor(.blue)
//                        }
//                        .padding(.horizontal)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 16) {
//                                ForEach(0..<5) { _ in
//                                    PopularRecipeCardView()
//                                        .redacted(reason: isLoading ? .placeholder : [])
//                                        .shimmering(active: isLoading)
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                    }
                }
                .padding(.vertical)
            }
            .overlay(
                // Center Camera Button
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.teal)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.bottom, 24),
                alignment: .bottom
            )
            .task {
                predictedObjects = ""
                isLoading = true

                if let user = await SessionHelper.shared.getUser() {
                    await UserDataManager.shared.loadUserInfoIfNeeded(userId: user.id)
                    if let info = await UserDataManager.shared.getUserInfo(userId: user.id) {
                        userName = info.name
                        do {
                            featuredVideos = try await YoutubeApiHelper.fetchTrendingFoodVideos()
                        } catch {
                            print("Failed to fetch featured videos:", error)
                        }
                    }
                    
                    if let history = UserDefaults.standard.string(forKey: "searchHistory"), !history.isEmpty {
                        let ingredients = history
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

                        let dispatchGroup = DispatchGroup()

                        for category in categories {
                            dispatchGroup.enter()
                            let request = RecipeRequestModel(
                                ingredients: ingredients,
                                mealType: category.lowercased(),
                                maxTime: nil,
                                cuisine: nil,
                                diet: nil,
                                allergens: nil,
                                number: 5
                            )
                            APIProxy.shared.fetchRecipes(request: request) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let data):
                                        if let decoded = try? JSONDecoder().decode(RecipeResult.self, from: data),
                                           decoded.results.count >= 3 {
                                            categoryRecipes[category] = decoded.results
                                        }
                                    default: break
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                        }

                        dispatchGroup.notify(queue: .main) {
                            for category in categories where (categoryRecipes[category]?.count ?? 0) < 3 {
                                var attempts = 0
                                func tryFetchFallbackRecipes(for category: String) {
                                    guard attempts < 5 else { return }
                                    let randomOffset = Int.random(in: 0..<20)
                                    let fallbackRequest = RecipeRequestModel(
                                        ingredients: [],
                                        mealType: category.lowercased(),
                                        maxTime: nil,
                                        cuisine: nil,
                                        diet: nil,
                                        allergens: nil,
                                        number: 5
                                    )
                                    APIProxy.shared.fetchRecipes(request: fallbackRequest) { result in
                                        DispatchQueue.main.async {
                                            switch result {
                                            case .success(let data):
                                                if let decoded = try? JSONDecoder().decode(RecipeResult.self, from: data) {
                                                    var current = categoryRecipes[category] ?? []
                                                    current.append(contentsOf: decoded.results)
                                                    categoryRecipes[category] = Array(current.prefix(5))
                                                }
                                            default: break
                                            }
                                            if (categoryRecipes[category]?.count ?? 0) < 3 {
                                                attempts += 1
                                                tryFetchFallbackRecipes(for: category)
                                            }
                                        }
                                    }
                                }
                                tryFetchFallbackRecipes(for: category)
                            }
                        }
                    }
                    
                    for category in categories {
                        let request = RecipeRequestModel(
                            ingredients: [category],
                            mealType: nil,
                            maxTime: nil,
                            cuisine: nil,
                            diet: nil,
                            allergens: nil,
                            number: 5
                        )
                        APIProxy.shared.fetchRecipes(request: request) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let data):
                                    if let decoded = try? JSONDecoder().decode(RecipeResult.self, from: data) {
                                        categoryRecipes[category] = decoded.results
                                    }
                                case .failure:
                                    break
                                }
                            }
                        }
                        print(categoryRecipes)
                    }
                }

                await MainActor.run {
                    isLoading = false
                }
            }
            .sheet(isPresented: $showImagePicker) {
                VStack {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Select a photo", systemImage: "photo")
                            .font(.headline)
                            .padding()
                            .background(Color.teal.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }

                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .padding()

                        HStack {
                            Button("Cancel") {
                                selectedItem = nil
                                selectedImageData = nil
                                showImagePicker = false
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)

                            Button("OK") {
                                showImagePicker = false
                                predictFood(from: imageData)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.teal.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    func predictFood(from imageData: Data) {
        let base64String = imageData.base64EncodedString()
        print(base64String)
        APIProxy.shared.predict(base64Image: base64String) { result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let uniqueFoods = json["unique_foods"] as? [String] {
                        let foodQuery = uniqueFoods.joined(separator: ", ")
                        DispatchQueue.main.async {
                            if self.predictedObjects != foodQuery {
                                self.predictedObjects = foodQuery
                            }
                        }
                    }
                } catch {
                    print("Failed to decode prediction response:", error)
                }
            case .failure(let error):
                print("Prediction request failed:", error)
            }
        }
    }
}

struct FeaturedCardView: View {
    let video: YoutubeVideo

    var body: some View {
        let cardWidth: CGFloat = 200
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: video.thumbnailURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.2))
            }
            .frame(width: cardWidth, height: 120)
            .clipped()
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .frame(width: cardWidth, alignment: .leading)
                HStack {
                    Label(formatYouTubeDuration(video.duration), systemImage: "clock")
                }
                .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
            .frame(width: cardWidth, alignment: .leading)
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(16)
        }
    }
    
    private func formatYouTubeDuration(_ duration: String) -> String {
        var hours = 0, minutes = 0, seconds = 0
        let pattern = #"PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?"#

        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: duration, range: NSRange(duration.startIndex..., in: duration)) {
            if let hRange = Range(match.range(at: 1), in: duration), let h = Int(duration[hRange]) {
                hours = h
            }
            if let mRange = Range(match.range(at: 2), in: duration), let m = Int(duration[mRange]) {
                minutes = m
            }
            if let sRange = Range(match.range(at: 3), in: duration), let s = Int(duration[sRange]) {
                seconds = s
            }
        }

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct PopularRecipeCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray)
                .frame(width: 140, height: 100)
                .overlay(
                    Image(systemName: "heart")
                        .padding(8),
                    alignment: .topTrailing
                )
            Text("Taco Salad")
                .font(.subheadline)
                .fontWeight(.semibold)
            HStack {
                Label("120 Kcal", systemImage: "flame")
                Label("20 min", systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .frame(width: 140)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}
