//
//  SessionHelper.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 13/4/2025.
//

import Foundation
import Supabase
import Combine

class SessionHelper: ObservableObject {
    static let shared = SessionHelper()

    private let accessTokenKey = "ACCESSTOKENKEY_NOTLOADED"
    private let refreshTokenKey = "REFRESHTOKENKEY_NOTLOADED"
    private let encryptionKeyDefaultsKey = "ENCRYPTION_KEY"

    @Published var currentUser: UserData?

    private init() {}

    private func getEncryptionKey() -> String {
        if let key = UserDefaults.standard.string(forKey: encryptionKeyDefaultsKey) {
            return key
        } else {
            let newKey = UUID().uuidString
            UserDefaults.standard.set(newKey, forKey: encryptionKeyDefaultsKey)
            return newKey
        }
    }

    func saveSession(refreshToken: String) {
        let encryptionKey = getEncryptionKey()
        let encrypted = "\(refreshToken).\(encryptionKey)".data(using: .utf8)?.base64EncodedString() ?? refreshToken
        KeychainHelper.shared.save(encrypted, forKey: refreshTokenKey)
    }

    func loadSession() async -> Session? {
        guard let stored = KeychainHelper.shared.load(forKey: refreshTokenKey),
              let data = Data(base64Encoded: stored),
              let combined = String(data: data, encoding: .utf8) else {
            return nil
        }

        let encryptionKey = getEncryptionKey()
        guard combined.hasSuffix(encryptionKey) else {
            print("Encryption key mismatch — likely a reinstall")
            return nil
        }

        let refreshToken = String(combined.dropLast(encryptionKey.count + 1)) // remove ".encryption_key"
        print("refreshToken", refreshToken)
        do {
            let session = try await Supabase.shared.client.auth.refreshSession(refreshToken: refreshToken)
            saveSession(refreshToken: session.refreshToken)
            let user = session.user
            self.currentUser = UserData(id: user.id, email: user.email)
            return session
        } catch {
            print("Failed to refresh session: \(error)")
            return nil
        }
    }

    func getUser() async -> UserData? {
        do {
            let user = try await Supabase.shared.client.auth.user()
            let userData = UserData(id: user.id, email: user.email)
            self.currentUser = userData
            return userData
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }
    
    func clearSession() {
        KeychainHelper.shared.delete(forKey: accessTokenKey)
        KeychainHelper.shared.delete(forKey: refreshTokenKey)
    }

}

struct UserData {
    let id: UUID
    let email: String?
}
