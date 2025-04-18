//
//  SupabaseHelper.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 13/4/2025.
//

import Supabase
import Foundation

public class Supabase {
    static let shared = Supabase()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://irozqukgtfegmbwikvbd.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlyb3pxdWtndGZlZ21id2lrdmJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ0OTkyOTMsImV4cCI6MjA2MDA3NTI5M30.2YsUYtDEUfM_dane0LibneFZz3g-ightQj11nJ6hwII"
        )
    }

    func fetchTable<T: Decodable>(from table: String) async throws -> [T] {
        try await client
            .from(table)
            .select()
            .execute()
            .value
    }
}

