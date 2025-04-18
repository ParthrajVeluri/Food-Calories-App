import SwiftUI

struct MainView: View {
    @Binding var isLoggedIn: Bool
    @State private var eventView: AnyView?
    @State private var showEvent = false

    var body: some View {
        ZStack {
            if isLoggedIn {
                if showEvent, let view = eventView {
                    view
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(1)
                }
                NavView()
                    .transition(.opacity)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showEvent)
        .task {
            await loadAndShowPendingEvent()
        }
    }

    private func loadAndShowPendingEvent() async {
        guard let user = await SessionHelper.shared.getUser() else { return }

        print("User loaded: \(user.email ?? "unknown email")")
        let view = await UserEventManager.shared.nextPendingEventView(for: user.id, showEvent: $showEvent)

        if !Task.isCancelled {
            print("Event loaded, updating UI")
            await MainActor.run {
                withAnimation {
                    if view != nil{
                        eventView = view
                        showEvent = true
                    }
                }
            }
        } else {
            print("Task was cancelled before assigning eventView")
        }
    }
}
