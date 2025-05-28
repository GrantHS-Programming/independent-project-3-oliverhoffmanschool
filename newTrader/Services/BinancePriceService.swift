import Foundation

class BinancePriceService: ObservableObject {
    @Published var currentPrice: Double = 0
    private var webSocketTask: URLSessionWebSocketTask?
    
    func connect(symbol: String) {
        let wsSymbol = symbol.lowercased() + "usdt"
        guard let url = URL(string: "wss://stream.binance.com:9443/ws/\(wsSymbol)@trade") else { return }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let trade = try? JSONDecoder().decode(BinanceTrade.self, from: data) {
                        DispatchQueue.main.async {
                            self?.currentPrice = trade.price
                        }
                    }
                default:
                    break
                }
                
                // Continue receiving messages
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket error: \(error)")
                // Attempt to reconnect after failure
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.connect(symbol: "BTC")
                }
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel()
    }
}

struct BinanceTrade: Codable {
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case price = "p"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let priceString = try container.decode(String.self, forKey: .price)
        price = Double(priceString) ?? 0
    }
} 