//
//  HomeViewModel.swift
//  CryptoDemo
//
//  Created by Philophobic on 08/11/24.
//

import Foundation
import Combine

class HomeViewModel : ObservableObject {
    
    @Published var statics : [StatisticModel] = []
    @Published var allCoins : [CoinModel] = []
    @Published var portfolioCoins : [CoinModel] = []
    @Published var searchText : String = ""
    private let dataService = CoinDataServices()
    private let marketDataService = MarketDataService()
    private var cancelables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    
    func addSubscribers(){
        
//        dataService.$allCoins
//            .sink { [weak self] returedCoins in
//                self?.allCoins = returedCoins
//            }
//            .store(in: &cancelables)
        
        $searchText
            .combineLatest(dataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] returnedCoin in
                self?.allCoins = returnedCoin
            }
            .store(in: &cancelables)
        
        marketDataService.$marketData
            .map(mapGlobalMarketData(marketDataModel:))
            .sink { returnStats in
                self.statics = returnStats
            }
            .store(in: &cancelables)
        
    }
    
    
    private func filterCoins(text:String,coins:[CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else  {
            return coins
        }
        let lowerCaseText = text.lowercased()
        return coins.filter({ (coin) -> Bool in
            return coin.name.lowercased().contains(lowerCaseText) || coin.id.lowercased().contains(lowerCaseText) || coin.symbol.lowercased().contains(lowerCaseText)
        })
    }
    
    private func mapGlobalMarketData(marketDataModel:MarketDataModel?) -> [StatisticModel] {
        var stats : [StatisticModel] = []
        guard let data = marketDataModel  else {
            return stats
        }
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        let portfolio = StatisticModel(title: "Portfolio Value", value: "$0.00", percentageChange: 0)
        
        stats.append(contentsOf: [marketCap,volume,btcDominance,portfolio])
        return stats
    }
}
