import Foundation

class UserPortfolio: ObservableObject {
    @Published var balance: Double = 100000.0
    @Published var previousDayBalance: Double = 100000.0
    @Published var positions: [Position] = []
    
    var balanceChange: Double {
        balance - previousDayBalance
    }
    
    var balanceChangePercentage: Double {
        (balanceChange / previousDayBalance) * 100
    }
}

struct Position: Identifiable {
    let id = UUID()
    let symbol: String
    var amount: Double
    var entryPrice: Double
    var leverage: Double
    var stopLoss: Double?
    var takeProfit: Double?
    
    var value: Double {
        amount * entryPrice * leverage
    }
} 