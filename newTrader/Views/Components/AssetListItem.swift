import SwiftUI

struct AssetListItem: View {
    let asset: CryptoAsset
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: asset.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.headline)
                Text(asset.symbol)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", asset.price))
                    .font(.headline)
                Text(String(format: "%.1f%%", asset.priceChange24h))
                    .font(.caption)
                    .foregroundColor(asset.priceChange24h >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
} 