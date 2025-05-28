import Foundation

struct CryptoAsset: Identifiable, Hashable {
    let id: String
    let symbol: String
    let name: String
    let price: Double
    let priceChange24h: Double
    let marketCap: Double
    let imageUrl: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CryptoAsset, rhs: CryptoAsset) -> Bool {
        lhs.id == rhs.id
    }
}

extension CryptoAsset {
    static let placeholder = CryptoAsset(
        id: "bitcoin",
        symbol: "BTC",
        name: "Bitcoin",
        price: 0.0,
        priceChange24h: 0.0,
        marketCap: 0.0,
        imageUrl: ""
    )
} 