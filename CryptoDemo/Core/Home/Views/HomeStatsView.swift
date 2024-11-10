//
//  HomeStatsView.swift
//  CryptoDemo
//
//  Created by Philophobic on 10/11/24.
//

import SwiftUI

struct HomeStatsView: View {
    
  
    @EnvironmentObject var vm : HomeViewModel
    @Binding var showPortfolio : Bool
    var body: some View {
        HStack {
            ForEach(vm.statics) { stat in
                StatisticView(stat: stat)
                    .frame(width:UIScreen.main.bounds.width / 3)
            }
        }
        .frame(width:UIScreen.main.bounds.width,alignment: showPortfolio ? .trailing : .leading)
    }
}

#Preview {
    HomeStatsView(showPortfolio: .constant(false))
        .environmentObject(DeveloperPreview.instance.homeVM)
}
