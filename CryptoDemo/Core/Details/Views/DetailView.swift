//
//  DetailView.swift
//  CryptoDemo
//
//  Created by Philophobic on 14/11/24.
//

import SwiftUI

struct DetailLoadingView : View {
    @Binding var  coin : CoinModel?
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(coin: coin)
            }
        }
    }
}

struct DetailView: View {
    
   @StateObject var vm : DetailViewModel
    private let colums : [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing : CGFloat = 30
    init(coin: CoinModel) {
        _vm = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView {
            
            VStack(spacing:20) {
                Text("")
                    .frame(height:150)
                overViewTitle
                Divider()
                overViewGrid
                additionalTitle
                Divider()
                additionalGrid
            }
            .padding()
        }
        
        .navigationTitle(vm.coin.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                navigationBarTrailingItems
            }
        }
    }
}

#Preview {
    NavigationView {
        DetailView(coin: DeveloperPreview.instance.coin)
    }
}

extension DetailView  {
    
    private var navigationBarTrailingItems : some View {
        HStack {
            Text(vm.coin.symbol.uppercased())
                .font(.headline)
                .foregroundStyle(Color.theme.accent)
            CoinImageView(coin: vm.coin)
                .frame(width: 25,height: 25)
        }
       
    }
    private var overViewTitle : some View {
        Text("Overview")
            .font(.title)
            .bold()
            .foregroundStyle(Color.theme.accent)
            .frame(maxWidth:.infinity,alignment: .leading)
    }
    
    private var additionalTitle : some View {
        Text("Additinal Details")
            .font(.title)
            .bold()
            .foregroundStyle(Color.theme.accent)
            .frame(maxWidth:.infinity,alignment: .leading)
    }
    
    private var overViewGrid : some  View {
        LazyVGrid(columns: colums,alignment: .leading,spacing: spacing,content: {
            ForEach(vm.overViewStatics) { stat in
                StatisticView(stat: stat)
            }
        })
    }
    
    private var additionalGrid : some View {
        LazyVGrid(columns: colums,alignment: .leading,spacing: spacing,content: {
            ForEach(vm.additionalStatics) { stat in
                StatisticView(stat: stat)
            }
        })
    }
}
