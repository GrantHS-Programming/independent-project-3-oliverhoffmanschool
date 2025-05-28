import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var portfolio: UserPortfolio
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Balance Card
                    VStack(spacing: 8) {
                        Text("$\(portfolio.balance, specifier: "%.2f")")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: portfolio.balanceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("$\(portfolio.balanceChange, specifier: "%.2f")")
                            Text("(24h)")
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                        .foregroundColor(portfolio.balanceChange >= 0 ? .green : .red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Holdings List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Holdings")
                            .font(.headline)
                        
                        if portfolio.positions.isEmpty {
                            Text("No active positions")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(portfolio.positions.sorted { $0.value > $1.value }) { position in
                                HoldingCard(position: position)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct HoldingCard: View {
    let position: Position
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(position.symbol)
                    .font(.headline)
                Text("\(position.amount, specifier: "%.4f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(position.value, specifier: "%.2f")")
                    .font(.headline)
                Text("\(position.leverage, specifier: "%.1f")x")
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
#Preview {
    ContentView()
}
 
