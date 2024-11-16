//
//  CoinRowViews.swift
//  CryptoDemo
//
//  Created by Philophobic on 31/10/24.
//

import SwiftUI

struct CoinRowViews: View {
    
    let coin : CoinModel
    let showHoldingColum : Bool
    var body: some View {
        HStack(spacing:0) {
            leftColum
            Spacer()
            if showHoldingColum {
                centerColum
            }
            rightColum
        }
        .font(.subheadline)
        .background(Color.theme.background.opacity(0.001))
    }
}

#Preview {
    CoinRowViews(coin: DeveloperPreview.instance.coin, showHoldingColum: true)
}


extension CoinRowViews {
    
    private var leftColum : some View {
        HStack(spacing:0) {
            Text("\(coin.rank)")
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
                .frame(minWidth: 30)
            CoinImageView(coin: coin)
                .frame(width: 30,height: 30)
            Text(coin.symbol.uppercased())
                .font(.headline)
                .padding(.leading,6)
                .foregroundStyle(Color.theme.accent)
        }
    }
    
    
    private var centerColum : some View {
        VStack(alignment:.trailing) {
            Text(coin.currentHoldingsValue.asCurrencyWith6Decimals())
                .bold()
            Text((coin.currentHoldings ?? 0).asPercentString())
        }
        .foregroundStyle(Color.theme.accent)
    }

    private var rightColum : some View {
        VStack(alignment:.trailing) {
            Text("\(coin.currentPrice.asCurrencyWith2Decimals())")
                .bold()
                .foregroundStyle(Color.theme.accent)
            Text(coin.priceChangePercentage24H?.asPercentString() ?? "")
                .foregroundStyle(
                    (coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.green : Color.theme.red
                )
        }
        .frame(width: UIScreen.main.bounds.width / 3.5,alignment: .trailing)

    }
    
}
