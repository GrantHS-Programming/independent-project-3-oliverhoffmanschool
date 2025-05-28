import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject private var portfolio: UserPortfolio
    @State private var showingPositionDetails: Position?
    @AppStorage("accentColorHex") private var accentColorHex = "#007AFF"

    var totalPositionValue: Double {
        portfolio.positions.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // Portfolio Stats
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Value")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(String(format: "$%.2f", portfolio.balance + totalPositionValue))
                                    .font(.system(size: 32, weight: .bold))
                            }
                            Spacer()
                        }

                        // Portfolio Distribution
                        HStack(spacing: 12) {
                            StatCard(title: "Available", value: portfolio.balance)
                            StatCard(title: "In Positions", value: totalPositionValue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Active Positions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Active Positions")
                            .font(.headline)

                        if portfolio.positions.isEmpty {
                            Text("No active positions")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(portfolio.positions) { position in
                                Button {
                                    showingPositionDetails = position
                                } label: {
                                    PositionListItem(position: position)
                                }
                                .tint(Color(hex: accentColorHex) ?? .blue)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Portfolio")
            .tint(Color(hex: accentColorHex) ?? .blue)
            .sheet(item: $showingPositionDetails) { position in
                PositionDetailView(position: position)
                    .tint(Color(hex: accentColorHex) ?? .blue)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "$%.2f", value))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

struct PositionListItem: View {
    let position: Position

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(position.symbol)
                    .font(.headline)
                Text(String(format: "%.4f", position.amount))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", position.value))
                    .font(.headline)
                Text(String(format: "%.1fx", position.leverage))
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PositionDetailView: View {
    let position: Position
    @Environment(\.dismiss) private var dismiss
    @AppStorage("accentColorHex") private var accentColorHex = "#007AFF"

    var body: some View {
        NavigationView {
            List {
                Section("Position Details") {
                    DetailRow(title: "Symbol", value: position.symbol)
                    DetailRow(title: "Amount", value: String(format: "%.4f", position.amount))
                    DetailRow(title: "Entry Price", value: String(format: "$%.2f", position.entryPrice))
                    DetailRow(title: "Current Value", value: String(format: "$%.2f", position.value))
                    DetailRow(title: "Leverage", value: String(format: "%.1fx", position.leverage))
                }

                if let stopLoss = position.stopLoss {
                    Section("Risk Management") {
                        DetailRow(title: "Stop Loss", value: String(format: "$%.2f", stopLoss))
                        if let takeProfit = position.takeProfit {
                            DetailRow(title: "Take Profit", value: String(format: "$%.2f", takeProfit))
                        }
                    }
                }
            }
            .navigationTitle("Position Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .tint(Color(hex: accentColorHex) ?? .blue)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview{
    PortfolioView()
        .environmentObject(UserPortfolio())
}
