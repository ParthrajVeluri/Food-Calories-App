//
//  FoodDetailView.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 16/4/2025.
//

import SwiftUI

struct FoodDetailView: View {
    let foodItem: NLPFoodItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: foodItem.photo.thumb)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                } placeholder: {
                    Color.gray
                        .frame(height: 200)
                        .cornerRadius(12)
                }

                Text(foodItem.foodName.capitalized)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Group {
                    Text("Serving: \(foodItem.servingQty.clean) \(foodItem.servingUnit)")
                    Text("Calories: \(foodItem.nfCalories.clean) kcal")
                    Text("Protein: \(foodItem.nfProtein.clean) g")
                    Text("Fat: \(foodItem.nfTotalFat.clean) g")
                    Text("Carbs: \(foodItem.nfTotalCarbohydrate.clean) g")
                    Text("Sugar: \(foodItem.nfSugars.clean) g")
                    Text("Sodium: \(foodItem.nfSodium.clean) mg")
                }
                .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

