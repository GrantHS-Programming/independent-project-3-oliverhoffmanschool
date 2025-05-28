import SwiftUI
import Charts

struct PriceChartView: View {
    let priceData: [CryptoPrice]
    let priceChange: Double
    @Binding var selectedTimeframe: TradeView.TimeFrame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price Chart")
                .font(.headline)
            
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(TradeView.TimeFrame.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            
            Chart {
                ForEach(priceData) { item in
                    LineMark(
                        x: .value("Time", item.date),
                        y: .value("Price", item.price)
                    )
                    .foregroundStyle(priceChange >= 0 ? Color.green : Color.red)
                    
                    AreaMark(
                        x: .value("Time", item.date),
                        y: .value("Price", item.price)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                (priceChange >= 0 ? Color.green : Color.red).opacity(0.2),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 


#Preview {
    TradeView()
        .environmentObject(UserPortfolio())
}
