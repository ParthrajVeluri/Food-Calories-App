import SwiftUI


struct NavView: View {
    @State var objectDetected:String = ""
    @State var selectedTab = 0
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                HomeView(predictedObjects: $objectDetected)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)

                SearchView(predictedObjects: $objectDetected)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(1)

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }
            .onChange(of: objectDetected) { newValue in
                if !newValue.isEmpty {
                    selectedTab = 1
                }
            }
        }
    }
}
