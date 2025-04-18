import SwiftUI
import SwiftSoup
import Charts

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showSummary = false
    @State private var showNutrition = false
    @State private var showCalories = false
    @State private var showInstructions = false
    @State private var showIngredients = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header: Recipe image banner
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable()
                         .aspectRatio(contentMode: .fill)
                         .frame(height: 250)
                         .clipped()
                } placeholder: {
                    Color.gray.frame(height: 250)
                }

                // Title and Basic Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 4)
                    
                    HStack(spacing: 12) {
                        if let prep = recipe.preparationMinutes {
                            Label("\(prep) min", systemImage: "timer")
                        }
                        if let cook = recipe.cookingMinutes {
                            Label("\(cook) min", systemImage: "flame.fill")
                        }
                        Label("\(recipe.readyInMinutes) min", systemImage: "clock")
                        Label("Serves \(recipe.servings)", systemImage: "person.2.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)

                // Dietary Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if recipe.vegetarian { TagView(text: "Vegetarian") }
                        if recipe.vegan { TagView(text: "Vegan") }
                        if recipe.glutenFree { TagView(text: "Gluten Free") }
                        if recipe.dairyFree { TagView(text: "Dairy Free") }
                        if recipe.cheap { TagView(text: "Cheap") }
                        if recipe.veryPopular { TagView(text: "Popular") }
                        if recipe.sustainable { TagView(text: "Sustainable") }
                        if recipe.veryHealthy { TagView(text: "Healthy") }
                    }
                    .padding(.horizontal)
                }
                
                // Stats: Likes, Health Score, WW Smart Points, Price per Serving
                HStack(spacing: 16) {
                    StatView(label: "Likes", value: "\(recipe.aggregateLikes)")
                    StatView(label: "Health", value: "\(Int(recipe.healthScore))")
                    StatView(label: "WW Points", value: "\(recipe.weightWatcherSmartPoints)")
                    StatView(label: "Price", value: String(format: "$%.2f", recipe.pricePerServing))
                }
                .padding(.horizontal)
                
                // Summary Section
                let parsedSummary: String = {
                    do {
                        let doc = try SwiftSoup.parse(recipe.summary)
                        return try doc.text()
                    } catch {
                        return recipe.summary
                    }
                }()
                
                DisclosureGroup("Summary", isExpanded: $showSummary) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(parsedSummary)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Nutrition Facts Summary Section
                DisclosureGroup("Nutrition Facts", isExpanded: $showNutrition) {
                    VStack(alignment: .leading, spacing: 8) {
                        let keyNames = ["Calories", "Fat", "Sugar", "Carbohydrates", "Protein"]
                        let keyNutrients = recipe.nutrition.nutrients.filter { keyNames.contains($0.name) }
                        
                        ForEach(keyNutrients, id: \.name) { nutrient in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(nutrient.name)
                                    Spacer()
                                    Text(String(format: "%.1f %@", nutrient.amount, nutrient.unit))
                                }
                                ProgressView(value: (nutrient.percentOfDailyNeeds ?? 0 ) / 100)
                                    .accentColor(.green)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Caloric Breakdown Pie Chart
                DisclosureGroup("Caloric Breakdown", isExpanded: $showCalories) {
                    Chart {
                        SectorMark(
                            angle: .value("Protein", recipe.nutrition.caloricBreakdown.percentProtein),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(.blue)
                        .annotation(position: .overlay, alignment: .center) {
                            Text("Protein")
                                .font(.caption)
                                .foregroundColor(.white)
                        }

                        SectorMark(
                            angle: .value("Fat", recipe.nutrition.caloricBreakdown.percentFat),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(.red)
                        .annotation(position: .overlay, alignment: .center) {
                            Text("Fat")
                                .font(.caption)
                                .foregroundColor(.white)
                        }

                        SectorMark(
                            angle: .value("Carbs", recipe.nutrition.caloricBreakdown.percentCarbs),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(.green)
                        .annotation(position: .overlay, alignment: .center) {
                            Text("Carbs")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 150)
                }
                .padding(.horizontal)

                // Instructions Section
                DisclosureGroup("Instructions", isExpanded: $showInstructions) {
                    VStack(alignment: .leading, spacing: 8) {
                        if !recipe.analyzedInstructions.isEmpty {
                            ForEach(recipe.analyzedInstructions, id: \.name) { instruction in
                                ForEach(instruction.steps, id: \.number) { step in
                                    Text("\(step.number). \(step.step)")
                                        .padding(.vertical, 2)
                                }
                            }
                        } else {
                            Text("No instructions available.")
                        }
                    }
                }
                .padding(.horizontal)

                // Ingredients Section
                ingredientsSection

                // Source Link
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source")
                        .font(.headline)
                    if let url = URL(string: recipe.sourceUrl) {
                        Link("View Full Recipe", destination: url)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var ingredientsSection: some View {
        DisclosureGroup("Ingredients", isExpanded: $showIngredients) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(recipe.usedIngredients, id: \.id) { ingredient in
                    HStack(alignment: .top, spacing: 8) {
                        if let imageUrl = ingredient.image,
                           let url = URL(string: "\(imageUrl)") {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                     .frame(width: 44, height: 44)
                                     .clipShape(RoundedRectangle(cornerRadius: 6))
                            } placeholder: {
                                Color.gray.frame(width: 44, height: 44)
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            if let original = ingredient.original {
                                Text(original)
                                    .font(.body)
                            }
                            if let unit = ingredient.unitShort {
                                Text("\(ingredient.amount) \(unit)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal)
    }
}

// Helper view for displaying tags
struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
    }
}

// Helper view for displaying stats
struct StatView: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

extension Double {
    var clean: String {
        self == floor(self) ? String(Int(self)) : String(format: "%.2f", self)
    }
}
