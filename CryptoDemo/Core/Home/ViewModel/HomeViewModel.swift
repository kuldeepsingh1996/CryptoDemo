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
    @Published var isLoading : Bool = false
    @Published var sortOptions : SortOptions = .holdings
    private let dataService = CoinDataServices()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    
    private var cancelables = Set<AnyCancellable>()
    
    
    enum SortOptions  {
        case rank,rankReversed,holdings,holdingReversed, price , priceReversed
        
    }
    
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
        
        $allCoins
            .combineLatest(portfolioDataService.$savedEntity)
            .map{(coinModel,portfolioEnities) -> [CoinModel] in
                coinModel
                    .compactMap { (coin) -> CoinModel? in
                        guard let entity = portfolioEnities.first(where: {$0.coidId == coin.id}) else {
                            return nil
                        }
                        return coin.updateHoldings(amount: entity.amount)
                    }
            }
            .sink { [weak self] returnedCoins in
                self?.portfolioCoins = returnedCoins
            }
            .store(in: &cancelables)
        
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink {  [weak self] returnStats in
                self?.statics = returnStats
                self?.isLoading = false
            }
            .store(in: &cancelables)
    }
    
    func reloadData() {
        isLoading = true
        dataService.getAllCoins()
        marketDataService.getGlobalMarketData()
        HapticManager.notification(type: .success)
    }
    
    func updatePortfolio(coin:CoinModel,amount:Double) {
        portfolioDataService.updatePortfoilo(coin: coin, amount: amount)
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
    
    private func mapGlobalMarketData(marketDataModel:MarketDataModel?,portfolioCoins:[CoinModel]) -> [StatisticModel] {
        var stats : [StatisticModel] = []
        guard let data = marketDataModel  else {
            return stats
        }
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        let portfoiloValue = portfolioCoins
            .map({$0.currentHoldingsValue})
            .reduce(0, +)
        
        let previousValue = portfolioCoins.map { coin -> Double in
            let currentValue = coin.currentHoldingsValue
            let percentChange = coin.priceChangePercentage24H ?? 0 / 100
            let previousValue = currentValue / (1+percentChange)
            return previousValue
        }
            .reduce(0, +)
        
        let percantChange = ((portfoiloValue - previousValue) / previousValue) * 100
        
        let portfolio = StatisticModel(title: "Portfolio Value", value: portfoiloValue.asCurrencyWith2Decimals(), percentageChange: percantChange)
        
        stats.append(contentsOf: [marketCap,volume,btcDominance,portfolio])
        return stats
    }
}
