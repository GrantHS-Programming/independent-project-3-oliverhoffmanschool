import SwiftUI

struct ContentView: View {
    @StateObject private var portfolio = UserPortfolio()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            TradeView()
                .tabItem {
                    Label("Trade", systemImage: "chart.line.uptrend.xyaxis")
                }

            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "briefcase.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(portfolio)
    }
}
