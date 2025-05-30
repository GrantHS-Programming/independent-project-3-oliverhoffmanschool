import SwiftUI
import Charts

struct TradeView: View {
    @EnvironmentObject private var portfolio: UserPortfolio
    @State private var searchText = ""
    @State private var selectedAsset: CryptoAsset = CryptoAsset.placeholder
    @State private var amount = ""
    @State private var leverage: Double = 1.0
    @State private var stopLoss = ""
    @State private var takeProfit = ""
    @State private var selectedTimeframe = TimeFrame.day
    @State private var priceData: [CryptoPrice] = []
    @State private var coinSuggestions: [CryptoAsset] = []
    @StateObject private var cryptoService = CryptoService()
    @StateObject private var binanceService = BinancePriceService()
    @AppStorage("accentColor") private var accentColorHex = "#007AFF"

    var accentColor: Color {
        Color(hex: accentColorHex) ?? .blue
    }

    enum TimeFrame: String, CaseIterable {
        case hour = "1H"
        case day = "1D"
        case week = "1W"
        case month = "1M"

        var days: Int {
            switch self {
            case .hour: return 1
            case .day: return 1
            case .week: return 7
            case .month: return 30
            }
        }
    }

    var currentPrice: Double {
        binanceService.currentPrice > 0 ? binanceService.currentPrice : selectedAsset.price
    }

    var maxAmount: Double {
        portfolio.balance / currentPrice / leverage
    }

    var orderValue: Double {
        (Double(amount) ?? 0) * currentPrice * leverage
    }

    var priceChange24h: Double {
        guard let firstPrice = priceData.first?.price else { return 0 }
        return ((currentPrice - firstPrice) / firstPrice) * 100
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Search Bar
                VStack(spacing: 10) {
                    TextField("Search cryptocurrency", text: $searchText)
                        .padding(.horizontal)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray3), lineWidth: 1)
                        )
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .onChange(of: searchText) {
                            filterAssets()
                        }

                    if !coinSuggestions.isEmpty {
                        VStack(spacing: 6) {
                            ForEach(coinSuggestions.prefix(4)) { asset in
                                Button {
                                    selectedAsset = asset
                                    searchText = ""
                                    coinSuggestions = []
                                    updatePriceData()
                                } label: {
                                    HStack {
                                        Text("\(asset.symbol) - \(asset.name)")
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }

                // Price Card
                VStack(spacing: 8) {
                    HStack {
                        Text(selectedAsset.symbol)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(accentColor)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(String(format: "$%.2f", currentPrice))
                                .font(.system(size: 30, weight: .bold))
                                .fontWeight(.semibold)
                                .foregroundColor(accentColor)
                            Text(String(format: "%+.2f%%", priceChange24h))
                                .font(.subheadline)
                                .foregroundColor(priceChange24h >= 0 ? .green : .red)
                        }
                    }

                    HStack {
                        MarketStatView(title: "24h High", value: String(format: "$%.2f", currentPrice * 1.05))
                        MarketStatView(title: "24h Low", value: String(format: "$%.2f", currentPrice * 0.95))
                        MarketStatView(title: "Volume", value: String(format: "$%.1fM", 234.5))
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Price Chart
                PriceChartView(
                    priceData: priceData,
                    priceChange: priceChange24h,
                    selectedTimeframe: $selectedTimeframe
                )
                .tint(accentColor)

                // Trading Controls
                VStack(spacing: 16) {
                    HStack {
                        Text("Amount:")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack {
                        Text("Leverage: \(String(format: "%.1fx", leverage))")
                        Slider(value: $leverage, in: 1...10, step: 0.1)
                    }

                    HStack {
                        Text("Stop Loss:")
                        TextField("Stop Loss", text: $stopLoss)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack {
                        Text("Take Profit:")
                        TextField("Take Profit", text: $takeProfit)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack(spacing: 24) {
                        Button {
                            placeTrade(isBuy: true)
                        } label: {
                            Text("Buy")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }

                        Button {
                            placeTrade(isBuy: false)
                        } label: {
                            Text("Sell")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .tint(accentColor)
        .task {
            await cryptoService.fetchTopCryptos()
        }
        .onChange(of: selectedAsset) { _, newAsset in
            binanceService.disconnect()
            binanceService.connect(symbol: newAsset.symbol)
            updatePriceData()
        }
        .onAppear {
            binanceService.connect(symbol: selectedAsset.symbol)
            updatePriceData()
        }
        .onDisappear {
            binanceService.disconnect()
        }
    }

    private func placeTrade(isBuy: Bool) {
        guard let amountValue = Double(amount),
              amountValue > 0,
              orderValue <= portfolio.balance else { return }

        let position = Position(
            symbol: selectedAsset.symbol,
            amount: amountValue,
            entryPrice: currentPrice,
            leverage: leverage,
            stopLoss: Double(stopLoss),
            takeProfit: Double(takeProfit)
        )

        portfolio.positions.append(position)
        portfolio.balance -= orderValue

        amount = ""
        leverage = 1.0
        stopLoss = ""
        takeProfit = ""
    }

    private func updatePriceData() {
        Task {
            priceData = await cryptoService.fetchPriceHistory(
                for: selectedAsset.id,
                days: selectedTimeframe.days
            ).map { CryptoPrice(date: $0.date, price: $0.price, symbol: selectedAsset.symbol) }
        }
    }

    private func filterAssets() {
        if searchText.isEmpty {
            coinSuggestions = []
        } else {
            coinSuggestions = cryptoService.assets.filter {
                $0.symbol.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct MarketStatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TradeView()
        .environmentObject(UserPortfolio())
}
