//
//  ChartView.swift
//  CryptoDemo
//
//  Created by Philophobic on 18/11/24.
//

import SwiftUI

struct ChartView: View {
    
    
    var data : [Double]
    
    init(coin:CoinModel){
        data = coin.sparklineIn7D?.price ?? []
    }
    
    var body: some View {
        GeometryReader { geo in
            
            Path { path in
                for index in data.indices {
                    let xPosition = geo.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: 0, y: 0))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: 0))
                }
            }
            .stroke(Color.blue,style: StrokeStyle(lineWidth: 10,lineCap: .round,lineJoin: .round))
        }
    }
}

#Preview {
    ChartView(coin: DeveloperPreview.instance.coin)
}
