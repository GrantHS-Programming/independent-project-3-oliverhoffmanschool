import SwiftUI

struct RootView: View {
    @AppStorage("theme") private var storedTheme = "System"
    @AppStorage("accentColor") private var accentColorHex = "#007AFF"
    @State private var currentTheme = "System"

    var colorScheme: ColorScheme? {
        switch currentTheme {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        ContentView()
            .tint(Color(hex: accentColorHex) ?? .blue)
            .preferredColorScheme(colorScheme)
            .onAppear {
                currentTheme = storedTheme
            }
            .onChange(of: storedTheme) { _, newTheme in
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentTheme = newTheme
                }
            }
    }
}
#Preview {
    RootView()
}
