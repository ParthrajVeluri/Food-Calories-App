//  Login.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 11/4/2025.
//

import SwiftUI
import AuthenticationServices
import Supabase
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    //used to render the app again
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Image("login_thumb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 360, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(spacing: 8) {
                    Text("Smarter meals start here")
                        .font(.custom("Georgia", size: 22))
                        .multilineTextAlignment(.center)
                        .fontWeight(.semibold)

                    Text("Discover recipes that match your cravings and goals")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        Task {
                            do {
                                guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else {
                                    print("Failed to get AppleIDCredential")
                                    return
                                }

                                guard let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
                                    print("Failed to extract idToken")
                                    return
                                }


                                let session = try await Supabase.shared.client.auth.signInWithIdToken(
                                    credentials: .init(provider: .apple, idToken: idToken)
                                )
                                SessionHelper.shared.saveSession(refreshToken: session.refreshToken)
                                print("Supabase login success: \(session.user.email ?? "No email")")
                                isLoggedIn = true
                                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            } catch {
                                print("Supabase login failed:")
                                dump(error)
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(.black) // Adjust style if needed
                    .frame(height: 50)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }
}

//#Preview {
//    LoginView(isLoggedIn: .constant(false)
//}
