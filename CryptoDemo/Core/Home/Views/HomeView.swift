//
//  HomeView.swift
//  CryptoDemo
//
//  Created by Philophobic on 30/10/24.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showPortfolio = false
    @EnvironmentObject var vm : HomeViewModel
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            VStack {
                homeHeaderView
                HomeStatsView(showPortfolio: $showPortfolio)
                SearchBarView(searchText: $vm.searchText)
                columTitle
                if !showPortfolio {
                    allListCoins
                    .transition(.move(edge: .leading))
                }
                if showPortfolio {
                    portfolioListCoins
                        .transition(.move(edge: .trailing))
                }
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    NavigationView {
        HomeView()
            .navigationBarHidden(true)
    }
    .environmentObject(DeveloperPreview.instance.homeVM)
}

extension HomeView {
    
    private var homeHeaderView : some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none, value: 0)
                .background(
                    CircleButtonAnimationView(animate: $showPortfolio)
                    )
            Spacer()
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(Color.theme.accent)
                .animation(.none, value: 0)

            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .onTapGesture {
                    withAnimation(.spring) {
                        showPortfolio.toggle()
                    }
                }
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))

        }
        .padding(.horizontal)

    }
    
    private var allListCoins : some View {
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowViews(coin: coin, showHoldingColum: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                
            }
        }
        .listStyle(.plain)
    }
    
    private var portfolioListCoins : some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowViews(coin: coin, showHoldingColum: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                
            }
        }
        .listStyle(.plain)
    }
    
    private var columTitle : some View {
        HStack {
            Text("Coin")
            Spacer()
            if showPortfolio {
                Text("Holdings")
            }
            Text("Price")
                .frame(width: UIScreen.main.bounds.width / 3.5,alignment: .trailing)
        }
        .padding(.horizontal)
        .font(.caption)
        .foregroundStyle(Color.theme.secondaryText)
    }
}