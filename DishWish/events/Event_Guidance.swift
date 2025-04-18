//
//  ContentView.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 11/4/2025.
//

import SwiftUI

struct Event_Guidance: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var target: String = "Fat Loss"
    @State private var pageIndex = 0
    @Binding var showEvent: Bool
    private let totalPages = 2

    let goals = ["Fat Loss", "Muscle Gain", "Maintenance"]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            TabView(selection: $pageIndex) {
                // Page 1: Goal
                VStack(spacing: 30) {
                    Spacer()
                    Image(systemName: "target") // Built-in SF Symbol for goal
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.accentColor)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's your goal?")
                            .font(.title)
                            .bold()
                        Picker("Select Goal", selection: $target) {
                            ForEach(goals, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            pageIndex = 1
                        }
                    }) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .tag(0)
                .padding()

                // Page 2: Personal Info
                VStack(spacing: 20) {
                    Spacer()
                    Text("Tell us about you")
                        .font(.title2)
                        .bold()
                    Group {
                        TextField("Name", text: $name)
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                        TextField("Weight (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                        TextField("Height (cm)", text: $height)
                            .keyboardType(.decimalPad)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                    Spacer()
                    Button(action: {
                        guard let ageInt = Int(age),
                              let weightDouble = Double(weight),
                              let heightDouble = Double(height),
                              let user = SessionHelper.shared.currentUser else {
                            print("Invalid input or user not available")
                            return
                        }

                        let userInfo = UserInfo(
                            user_id: user.id,
                            name: name,
                            age: ageInt,
                            weight: weightDouble,
                            height: heightDouble,
                            goal: target,
                            created_at: nil
                        )

                        Task {
                            await UserDataManager.shared.upsertUserInfo(userInfo)

                            if let eventId = try? await UserEventManager.shared.fetchEventIdByName("Event_Guidance") {
                                await UserEventManager.shared.markEventCompleted(userId: user.id, eventId: eventId)
                            }

                            showEvent = false
                        }
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .tag(1)
                .padding()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}
