//
//  StatisticView.swift
//  CryptoDemo
//
//  Created by Philophobic on 09/11/24.
//

import SwiftUI

struct StatisticView: View {
    let stat : StatisticModel
    
    var body: some View {
        VStack(alignment: .leading,spacing: 4) {
            Text(stat.title)
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
            Text(stat.value)
                .font(.headline)
                .foregroundStyle(Color.theme.accent)
            HStack {
                Image(systemName: "triangle.fill")
                    .font(.caption2)
                    .rotationEffect(Angle(degrees: (stat.percentageChange ?? 0 >= 0 ? 0 : 180)))
                Text(stat.percentageChange?.asPercentString() ?? "")
            }
            
            .foregroundStyle((stat.percentageChange ?? 0) >= 0 ? Color.theme.green :  Color.theme.red)
            .opacity(stat.percentageChange == nil ? 0 : 1.0)
            
        }
    }
}


struct Statics_Preview : PreviewProvider {
    static var previews: some View {
        Group {
            StatisticView(stat:DeveloperPreview.instance.stat3)
                .previewLayout(.sizeThatFits)
            StatisticView(stat:DeveloperPreview.instance.stat2)
                .previewLayout(.sizeThatFits)


        }
    }
    
    
}
