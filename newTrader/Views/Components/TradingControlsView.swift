import SwiftUI

struct TradingControlsView: View {
    @Binding var amount: String
    @Binding var leverage: Double
    @Binding var showingAdvancedOptions: Bool
    @Binding var stopLoss: String
    @Binding var takeProfit: String
    let maxAmount: Double
    let orderValue: Double
    let selectedSymbol: String
    let onBuy: () -> Void
    let onSell: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Amount Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text(String(format: "Max: %.4f %@", maxAmount, selectedSymbol))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Leverage Slider
            VStack(alignment: .leading, spacing: 8) {
                Text(String(format: "Leverage: %.1fx", leverage))
                    .font(.subheadline)
                
                Slider(value: $leverage, in: 1...10, step: 1)
            }
            
            // Advanced Options
            DisclosureGroup("Advanced Options", isExpanded: $showingAdvancedOptions) {
                VStack(spacing: 16) {
                    // Stop Loss
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stop Loss ($)")
                            .font(.subheadline)
                        TextField("Optional", text: $stopLoss)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Take Profit
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Take Profit ($)")
                            .font(.subheadline)
                        TextField("Optional", text: $takeProfit)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.top, 8)
            }
            
            // Order Value
            VStack(spacing: 4) {
                Text("Order Value")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(String(format: "$%.2f", orderValue))
                    .font(.title2.bold())
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: onBuy) {
                    Text("Buy")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: onSell) {
                    Text("Sell")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 