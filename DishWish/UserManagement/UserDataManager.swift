//
//  User.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 16/4/2025.
//
import Foundation

struct UserInfo: Codable {
    let user_id: UUID
    let name: String
    let age: Int
    let weight: Double
    let height: Double
    let goal: String
    let created_at: Date?
}

class UserDataManager {
    static let shared = UserDataManager()

    private(set) var cachedUserInfo: UserInfo?

    private init() {}

    func upsertUserInfo(_ userInfo: UserInfo) async {
        do {
            try await Supabase.shared.client
                .from("user_info")
                .upsert(userInfo)
                .execute()
            print("User info upserted successfully")
            self.cachedUserInfo = userInfo
        } catch {
            print("Failed to upsert user info:", error)
        }
    }

    func loadUserInfoIfNeeded(userId: UUID) async {
        if cachedUserInfo == nil {
            do {
                let userInfos: [UserInfo] = try await Supabase.shared.client
                    .from("user_info")
                    .select()
                    .eq("user_id", value: userId)
                    .limit(1)
                    .execute()
                    .value

                if let userInfo = userInfos.first {
                    self.cachedUserInfo = userInfo
                    print("Loaded user info from Supabase")
                }
            } catch {
                print("Failed to load user info from Supabase:", error)
            }
        }
    }

    func getUserInfo(userId: UUID) async -> UserInfo? {
        if cachedUserInfo == nil {
            await loadUserInfoIfNeeded(userId: userId)
        }
        return cachedUserInfo
    }
}
