import Foundation

class CryptoService: ObservableObject {
    @Published var assets: [CryptoAsset] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let baseURL = "https://api.coingecko.com/api/v3"
    private var updateTimer: Timer?
    
    init() {
        // Start polling every 30 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchTopCryptos()
            }
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    func fetchTopCryptos() async {
        isLoading = true
        error = nil
        
        let endpoint = "\(baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false"
        
        guard let url = URL(string: endpoint) else {
            error = URLError(.badURL)
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let coins = try JSONDecoder().decode([CoinGeckoResponse].self, from: data)
            
            DispatchQueue.main.async {
                self.assets = coins.map { coin in
                    CryptoAsset(
                        id: coin.id,
                        symbol: coin.symbol.uppercased(),
                        name: coin.name,
                        price: coin.current_price,
                        priceChange24h: coin.price_change_percentage_24h ?? 0,
                        marketCap: coin.market_cap,
                        imageUrl: coin.image
                    )
                }
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func fetchPriceHistory(for id: String, days: Int) async -> [PriceDataPoint] {
        let endpoint = "\(baseURL)/coins/\(id)/market_chart?vs_currency=usd&days=\(days)"
        
        guard let url = URL(string: endpoint) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PriceHistoryResponse.self, from: data)
            
            return response.prices.map { price in
                PriceDataPoint(
                    date: Date(milliseconds: Int64(price[0])),
                    price: price[1]
                )
            }
        } catch {
            print("Error fetching price history: \(error)")
            return []
        }
    }
}

// Response models for CoinGecko API
struct CoinGeckoResponse: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let market_cap: Double
    let price_change_percentage_24h: Double?
}

struct PriceHistoryResponse: Codable {
    let prices: [[Double]]
}

struct PriceDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

extension Date {
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
} 