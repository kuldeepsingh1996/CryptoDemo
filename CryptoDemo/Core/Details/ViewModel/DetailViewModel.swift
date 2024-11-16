//
//  DetailViewModel.swift
//  CryptoDemo
//
//  Created by Philophobic on 14/11/24.
//

import Foundation
import Combine

class DetailViewModel : ObservableObject {
    
    private let coinDataService : CoinDetailDataService
    private var cancelAbales = Set<AnyCancellable>()
    @Published var overViewStatics : [StatisticModel] = []
    @Published var additionalStatics : [StatisticModel] = []
    
    @Published  var coin : CoinModel
    init(coin: CoinModel) {
        self.coin = coin
        self.coinDataService = CoinDetailDataService(coin: coin)
        addSubscribers()
    }
    
    
    private func addSubscribers() {
        coinDataService.$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatics)
            .sink { [weak self] returnedArrays in
                self?.overViewStatics = returnedArrays.overView
                self?.additionalStatics = returnedArrays.additional
               
            }
            .store(in: &cancelAbales)
    }
    
    
    private func mapDataToStatics(coinDetailModel:CoinDetailModel?,coinModel:CoinModel) -> (overView:[StatisticModel],additional:[StatisticModel]) {
        let price = coinModel.currentPrice.asCurrencyWith6Decimals()
        let priceChange = coinModel.priceChangePercentage24H
        let priceStat = StatisticModel(title: "Current Price", value: price, percentageChange: priceChange)
        
        let marketCap = "$" + (coinModel.marketCap?.formattedWithAbbreviations() ?? "")
        let marketCapChnage = coinModel.marketCapChange24H
        let marketCapStat = StatisticModel(title: "Market Capitilization", value: marketCap, percentageChange: marketCapChnage)
        
        let rank = "\(coinModel.rank)"
        let rankStat = StatisticModel(title: "Rank", value: rank)
        
        let volume = "$" + "\(coinModel.totalVolume?.formattedWithAbbreviations() ?? "")"
        let volumeStat = StatisticModel(title: "Volume", value: volume)
        let overViewArrays : [StatisticModel] = [
            priceStat,marketCapStat , rankStat , volumeStat
        ]
        
        //Additional
        let high = coinModel.high24H?.asCurrencyWith6Decimals() ?? "n/a"
        let highStat = StatisticModel(title: "24h High", value: high)
        
        let low = coinModel.low24H?.asCurrencyWith6Decimals() ?? "n/a"
        let lowStat = StatisticModel(title: "24h Low", value: low)
        
        let priceChange24h = coinModel.priceChange24H?.asCurrencyWith6Decimals() ?? "n/a"
        let priceChangePercent2 = coinModel.priceChangePercentage24H
        let priceChangeStat = StatisticModel(title: "24h Price Chnage", value: priceChange24h, percentageChange: priceChangePercent2)
        
        let marketCapChange = "$" + "\(coinModel.marketCapChange24H?.formattedWithAbbreviations() ?? "")"
        let marketCapChangePercent2 = coinModel.marketCapChangePercentage24H
        let marketCapChnageStat = StatisticModel(title: "24h Market Cap Change", value: marketCapChange, percentageChange: marketCapChangePercent2)
        
        let blockTime = coinDetailModel?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        
        let blockStat = StatisticModel(title: "Block Time", value: blockTimeString)
        
        let hashing = coinDetailModel?.hashingAlgorithm ?? "n/a"
        let hashingStat = StatisticModel(title: "Hashing Algorithm", value: hashing)
        let additionalArr : [StatisticModel] = [
            highStat,lowStat,priceChangeStat,marketCapChnageStat,blockStat,hashingStat
        ]
        
        return (overViewArrays,additionalArr)
    }
    
}
