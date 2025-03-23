import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedTab = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Property Tab - Always accessible
            NavigationView {
                PropertyDetailsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Property", systemImage: "house.fill")
            }
            .tag(0)
            
            // Expenses Tab - May show paywall overlay
            NavigationView {
                ExpensesView(viewModel: viewModel)
            }
            .tabItem {
                Label("Expenses", systemImage: "dollarsign.circle.fill")
            }
            .tag(1)

            
            // Results Tab - May show paywall overlay
            NavigationView {
                ResultsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Results", systemImage: "chart.pie.fill")
            }
            .tag(2)

        }
        .accentColor(Color("AppTeal"))
        .onAppear {
            // Apply custom styling to tab bar based on color scheme
            let appearance = UITabBarAppearance()
            
            // Use CardBackground color asset for tab bar background
            appearance.backgroundColor = UIColor(Color("CardBackground"))
            
            // Use NavyBlue for shadows with appropriate opacity
            appearance.shadowColor = UIColor(Color("NavyBlue").opacity(0.1))
            
            // Style the selected item
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .medium)
            ]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            
            // Apply to both normal and scrolling edge cases
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
        .onChange(of: selectedTab) { newValue in
            // Add subtle haptic feedback when changing tabs
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        // Add sheet presentations for paywalls
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $viewModel.showMaxReachedPaywall) {
            PaywallMaxView()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainTabView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            MainTabView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
