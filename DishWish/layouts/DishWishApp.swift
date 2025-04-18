//  DishWishApp.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 11/4/2025.
//

import SwiftUI

@main
struct DishWishApp: App {
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

    var body: some Scene {
        WindowGroup {
            AppStartupView(isLoggedIn: $isLoggedIn)
        }
    }
}


// handle event pop up and login session retrieve logic
struct AppStartupView: View {
    @Binding var isLoggedIn: Bool
    @State private var didLoadSession = false

    var body: some View {
        ZStack {
            if !didLoadSession {
                ZStack {
                    LoadingView()
                }
                .transition(.opacity)
            } else {
                MainView(isLoggedIn: $isLoggedIn)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: didLoadSession)
        .task(id: didLoadSession) {
            if didLoadSession { return }
            
            print("ContentViewWrapper: Starting session load")

            await loadSessionAndSetLogin()

            didLoadSession = true
        }
    }

    private func loadSessionAndSetLogin() async {
        print("loadSession")
        if await SessionHelper.shared.loadSession() != nil {
            isLoggedIn = true
            print("Session found")
        } else {
            isLoggedIn = false
            print("No session found")
        }
    }
}
