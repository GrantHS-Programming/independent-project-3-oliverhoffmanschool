import SwiftUI

/// Button Style for Pressable Effects
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
            .cornerRadius(10)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// Reusable Row for Account Settings
struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.horizontal)
    }
}

/// Styled container for trading settings
struct SettingsCard<Content: View>: View {
    let label: String
    let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            content
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct SettingsView: View {
    @State private var username = "Username"

    @AppStorage("defaultLeverage") private var defaultLeverage = 1.0
    @AppStorage("showPriceAlerts") private var showPriceAlerts = true
    @AppStorage("maxLeverageAllowed") private var maxLeverageAllowed = 10.0
    @AppStorage("theme") private var theme = "System"
    @AppStorage("accentColor") public var accentColorHex: String = "#007AFF"

    private let themeOptions = ["System", "Light", "Dark"]
    private let defaultAccentColor = Color.blue

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {

                    // Profile Section
                    VStack {
                        HStack {
                            Image("exampleProfilePic")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 85, height: 85)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .padding(.leading)

                            Spacer()

                            Text(username)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer().frame(width: 30)
                        }
                        .padding()
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Account Setting Rows
                    VStack(spacing: 15) {
                        SettingsRow(title: "Email", icon: "envelope") {
                            print("Email row clicked!")
                        }
                        SettingsRow(title: "Password", icon: "lock") {
                            print("Password row clicked!")
                        }
                        SettingsRow(title: "Notification Settings", icon: "bell") {
                            print("Notification settings clicked!")
                        }
                        SettingsRow(title: "Log Out", icon: "arrow.right.square") {
                            print("Log Out clicked!")
                        }
                    }

                    // Trading Preferences Styled
                    VStack(spacing: 15) {
                        SettingsCard(label: "Default Leverage") {
                            Slider(value: $defaultLeverage, in: 1...20, step: 1)
                            Text("\(Int(defaultLeverage))x")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }.tint(Color(hex: accentColorHex))

                        SettingsCard(label: "Maximum Leverage") {
                            Slider(value: $maxLeverageAllowed, in: defaultLeverage...100, step: 1)
                            Text("\(Int(maxLeverageAllowed))x")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }.tint(Color(hex: accentColorHex))

                        SettingsCard(label: "Price Alerts") {
                            Toggle("Enable Price Alerts", isOn: $showPriceAlerts)
                                .toggleStyle(SwitchToggleStyle())
                                .tint(Color(hex: accentColorHex))
                        }
                    }

                    // Appearance Settings
                    VStack(spacing: 15) {

                        SettingsCard(label: "Accent Color") {
                            ColorPicker("Pick Accent Color", selection: Binding(
                                get: { Color(hex: accentColorHex) ?? defaultAccentColor },
                                set: { newColor in accentColorHex = newColor.toHex() ?? "#007AFF" }
                            ))
                        }
                    }

                    // About Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                            .padding(.horizontal)
                            .tint(Color(hex: accentColorHex))
                        Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                            .padding(.horizontal)
                            .tint(Color(hex: accentColorHex))

                    }

                    Spacer().frame(height: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
extension Color {
    init?(hex: String) {
        let r, g, b, a: Double

        var hexColor = hex
        if hexColor.hasPrefix("#") {
            hexColor = String(hexColor.dropFirst())
        }

        guard hexColor.count == 6 || hexColor.count == 8 else { return nil }

        var hexNumber: UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&hexNumber)

        if hexColor.count == 6 {
            r = Double((hexNumber & 0xFF0000) >> 16) / 255
            g = Double((hexNumber & 0x00FF00) >> 8) / 255
            b = Double(hexNumber & 0x0000FF) / 255
            a = 1.0
        } else {
            r = Double((hexNumber & 0xFF000000) >> 24) / 255
            g = Double((hexNumber & 0x00FF0000) >> 16) / 255
            b = Double((hexNumber & 0x0000FF00) >> 8) / 255
            a = Double(hexNumber & 0x000000FF) / 255
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    func toHex() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }

        let rgba = (Int(r * 255) << 16) + (Int(g * 255) << 8) + Int(b * 255)
        return String(format: "#%06x", rgba)
    }
}
