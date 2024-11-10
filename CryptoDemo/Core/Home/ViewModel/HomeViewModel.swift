//
//  HomeViewModel.swift
//  CryptoDemo
//
//  Created by Philophobic on 08/11/24.
//

import Foundation
import Combine

class HomeViewModel : ObservableObject {
    
    @Published var statics : [StatisticModel] = [
        StatisticModel(title: "Title", value: "Value", percentageChange: 1),
        StatisticModel(title: "Title", value: "Value"),
        StatisticModel(title: "Title", value: "Value"),
        StatisticModel(title: "Title", value: "Value", percentageChange: -7)

    ]
    @Published var allCoins : [CoinModel] = []
    @Published var portfolioCoins : [CoinModel] = []
    @Published var searchText : String = ""
    private let dataService = CoinDataServices()
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
}
