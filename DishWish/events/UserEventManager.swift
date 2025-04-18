//
//  UserEvent.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 13/4/2025.
//

import Foundation
import SwiftUI




struct UserEvent: Codable {
    let userId: UUID
    let eventId: UUID
    let isCompleted: Bool
    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case eventId = "event_id"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
    }
}

struct Event: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let isRequired: Bool
    let priority: Int
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case isRequired = "is_required"
        case priority
        case createdAt = "created_at"
    }
}

struct UserEventWithEvent: Identifiable {
    let id: UUID
    let userId: UUID
    let event: Event
    let isCompleted: Bool
    let completedAt: Date?
}

class UserEventManager {
    static let shared = UserEventManager()
    
    private init() {
        Task {
            guard let user = await SessionHelper.shared.getUser() else { return }

            do {
                let userId = user.id
                let existingUserEvents: [UserEvent] = try await Supabase.shared.client
                    .from("user_events")
                    .select()
                    .eq("user_id", value: userId)
                    .execute()
                    .value

                let allEvents: [Event] = try await Supabase.shared.client
                    .from("events")
                    .select()
                    .execute()
                    .value

                let existingEventIds = Set(existingUserEvents.map { $0.eventId })
                let missingEvents = allEvents.filter { !existingEventIds.contains($0.id) }

                for event in missingEvents {
                    _ = try await Supabase.shared.client
                        .from("user_events")
                        .insert([
                            [
                                "user_id": userId.uuidString,
                                "event_id": event.id.uuidString,
                                "is_completed": "false",
                                "completed_at": nil
                            ]
                        ])
                        .execute()
                }
            } catch {
                print("Failed to initialize user_events: \(error)")
            }
        }
    }

    var eventViewFactoryMap: [String: (Binding<Bool>) -> AnyView] = [
        "Event_Guidance": { showEvent in AnyView(Event_Guidance(showEvent: showEvent)) }
    ]

    @MainActor
    func nextPendingEventView(for userId: UUID, showEvent: Binding<Bool>) async -> AnyView? {
        do {
            let userEvents = try await fetchUserEventWithEvents(for: userId)
            if let nextPending = userEvents
                .filter({ !$0.isCompleted })
                .sorted(by: { $0.event.priority < $1.event.priority })
                .first {
                if let factory = eventViewFactoryMap[nextPending.event.name] {
                    return factory(showEvent)
                }
            }
        } catch {
            print("Failed to fetch events: \(error)")
        }
        return nil
    }

    func fetchUserEventWithEvents(for userId: UUID) async throws -> [UserEventWithEvent] {
        let userEvents: [UserEvent] = try await Supabase.shared.client
            .from("user_events")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        let events: [Event] = try await Supabase.shared.client
            .from("events")
            .select()
            .execute()
            .value
        
        let eventDict = Dictionary(uniqueKeysWithValues: events.map { ($0.id, $0) })

        return userEvents.compactMap { ue in
            guard let event = eventDict[ue.eventId] else { return nil }
            return UserEventWithEvent(
                id: UUID(),
                userId: ue.userId,
                event: event,
                isCompleted: ue.isCompleted,
                completedAt: ue.completedAt
            )
        }
    }
    
    func fetchEventIdByName(_ name: String) async throws -> UUID? {
        let events: [Event] = try await Supabase.shared.client
            .from("events")
            .select()
            .eq("name", value: name)
            .limit(1)
            .execute()
            .value

        return events.first?.id
    }

    func markEventCompleted(userId: UUID, eventId: UUID) async {
        do {
            let _ = try await Supabase.shared.client
                .from("user_events")
                .update([
                    [
                        "is_completed": "true",
                        "completed_at": ISO8601DateFormatter().string(from: Date())
                    ]
                ])
                .eq("user_id", value: userId)
                .eq("event_id", value: eventId)
                .execute()
        } catch {
            print("Failed to mark event as completed: \(error)")
        }
    }
}
