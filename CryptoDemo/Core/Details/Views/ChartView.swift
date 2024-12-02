//
//  ChartView.swift
//  CryptoDemo
//
//  Created by Philophobic on 18/11/24.
//

import SwiftUI

struct ChartView: View {
    
    
    var data : [Double]
    let minY : Double
    let maxY : Double
    let lineColor : Color
    let startingDate : Date
    let endingDate : Date
    @State private var percantage : CGFloat = 0
    init(coin:CoinModel){
        data = coin.sparklineIn7D?.price ?? []
        minY = data.min() ?? 0
        maxY = data.max() ?? 0
        
        let priceChange = (data.last ?? 0 - (data.first ?? 0))
        lineColor = priceChange > 0 ? Color.theme.green : Color.theme.red
        endingDate = Date(coinGeckoString: coin.lastUpdated ?? "")
        startingDate = endingDate.addingTimeInterval(-7*24*60*60)
    }
    
    var body: some View {
        chartView
            .frame(height:200)
            .background(
                VStack{
                    Divider()
                    Spacer()
                    Divider()
                    Spacer()
                    Divider()
                }
            )
            .overlay(alignment: .leading) {
                VStack {
                    Text(maxY.formattedWithAbbreviations())
                    Spacer()
                    Text(((minY + maxY)/2).formattedWithAbbreviations())
                    Spacer()
                    Text(minY.formattedWithAbbreviations())
                }
            }
        
        HStack {
            Text(startingDate.asShortDateString())
            Spacer()
            Text(endingDate.asShortDateString())
        }
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 2.0)) {
                    percantage = 1.0
                }
            }
        })
    }
}


extension ChartView {
    
    private var chartView : some View {
        GeometryReader { geo in
            
            Path { path in
                for index in data.indices {
                    let xPosition = geo.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    
                    let yAxis = maxY - minY
                    let yPosition = CGFloat(1-(data[index]-minY) / yAxis) * geo.size.height
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .trim(from: 0,to: percantage)
            .stroke(lineColor,style: StrokeStyle(lineWidth: 2,lineCap: .round,lineJoin: .round))
            .shadow(color: lineColor,radius: 10,x: 0,y: 10)
            .shadow(color: lineColor.opacity(0.4),radius: 10,x: 0,y: 20)
            .shadow(color: lineColor.opacity(0.2),radius: 10,x: 0,y: 30)
            .shadow(color: lineColor.opacity(0.1),radius: 10,x: 0,y: 40)
        }
    }
}
#Preview {
    ChartView(coin: DeveloperPreview.instance.coin)
}
