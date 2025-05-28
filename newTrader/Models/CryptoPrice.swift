import Foundation

struct CryptoPrice: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
    let symbol: String
    
    static func mockData(for symbol: String) -> [CryptoPrice] {
        let calendar = Calendar.current
        let now = Date()
        
        let basePrice: Double = switch symbol {
        case "BTC": 45000.0
        case "ETH": 2300.0
        case "SOL": 98.0
        case "XRP": 0.57
        case "ADA": 0.51
        default: 0.0
        }
        
        return [
            CryptoPrice(date: calendar.date(byAdding: .hour, value: -24, to: now)!, price: basePrice * 0.98, symbol: symbol),
            CryptoPrice(date: calendar.date(byAdding: .hour, value: -20, to: now)!, price: basePrice * 1.01, symbol: symbol),
            CryptoPrice(date: calendar.date(byAdding: .hour, value: -16, to: now)!, price: basePrice * 0.99, symbol: symbol),
            CryptoPrice(date: calendar.date(byAdding: .hour, value: -12, to: now)!, price: basePrice * 1.02, symbol: symbol),
            CryptoPrice(date: calendar.date(byAdding: .hour, value: -8, to: now)!, price: basePrice * 1.03, symbol: symbol),
            CryptoPrice(date: calendar.date(byAdding: .hour, value: -4, to: now)!, price: basePrice * 0.99, symbol: symbol),
            CryptoPrice(date: now, price: basePrice, symbol: symbol)
        ]
    }
} 