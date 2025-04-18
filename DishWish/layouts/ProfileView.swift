//
//  ProfileView.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 15/4/2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Image and Info
                VStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding(.top)

                    Text("Alan Choi")
                        .font(.title2)
                        .bold()

                    Text("@alanchoi")
                        .foregroundColor(.secondary)

                    Button("Edit Profile") {
                        isEditing.toggle()
                    }
                    .padding(.top, 8)
                }

                Divider()

                // Stats Section
                HStack(spacing: 40) {
                    VStack {
                        Text("18")
                            .font(.title2)
                            .bold()
                        Text("Dishes Tried")
                            .font(.caption)
                    }

                    VStack {
                        Text("12")
                            .font(.title2)
                            .bold()
                        Text("Favorites")
                            .font(.caption)
                    }

                    VStack {
                        Text("5")
                            .font(.title2)
                            .bold()
                        Text("Uploaded")
                            .font(.caption)
                    }
                }

                Divider()

                // Activity Section
                List {
                    NavigationLink(destination: ProfileMyRecipeView()) {
                        Label("My Recipes", systemImage: "book")
                    }
                    NavigationLink(destination: Text("Liked Recipes")) {
                        Label("Liked Recipes", systemImage: "heart")
                    }
                    NavigationLink(destination: Text("Saved Recipes")) {
                        Label("Saved Recipes", systemImage: "bookmark")
                    }
                    NavigationLink(destination: Text("My Reviews")) {
                        Label("My Reviews", systemImage: "pencil")
                    }

                    Section {
                        NavigationLink(destination: Text("Language")) {
                            Label("Language", systemImage: "globe")
                        }
                        NavigationLink(destination: Text("Theme")) {
                            Label("Theme", systemImage: "paintbrush")
                        }
                        NavigationLink(destination: Text("Privacy")) {
                            Label("Privacy", systemImage: "lock")
                        }

                        Button(role: .destructive) {
                            print("Logging out")
                        } label: {
                            Label("Log Out", systemImage: "arrow.backward.circle")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Profile")
        }
    }
}
