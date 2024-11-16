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
        $searchText
            .combineLatest(dataService.$allCoins,$sortOptions)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
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
                guard let self = self else {
                    return
                }
                self.portfolioCoins = sortHoldingCoinIfNeeded(coins: returnedCoins)
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
    
    private func filterAndSortCoins(text:String,coins:[CoinModel],sortOption:SortOptions) -> [CoinModel] {
        
        var updatedCoins = filterCoins(text: text, coins: coins)
        sortCoins(sortOption: sortOption, coins: &updatedCoins)
        return updatedCoins
    }
    
    
    private func sortCoins(sortOption:SortOptions, coins: inout [CoinModel])  {
        switch sortOption {
        case .rank , .holdings:
             coins.sort(by: {$0.rank < $1.rank})
        case .rankReversed , .holdingReversed :
             coins.sort(by: {$0.rank > $1.rank})
        case .price :
             coins.sort(by: {$0.currentPrice < $1.currentPrice})
            
        case .priceReversed :
             coins.sort(by: {$0.currentPrice > $1.currentPrice})

        }
    }
    
    private func sortHoldingCoinIfNeeded(coins:[CoinModel]) -> [CoinModel] {
        //will only sort by holdings and holdingReversed if needed
        switch sortOptions {
        case .holdings :
            return coins.sorted(by: {$0.currentHoldingsValue > $1.currentHoldingsValue})
        case .holdingReversed :
            return coins.sorted(by: {$0.currentHoldingsValue < $1.currentHoldingsValue})
        default:
            return coins
        }
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
