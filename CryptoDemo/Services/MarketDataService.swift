//
//  MarketDataService.swift
//  CryptoDemo
//
//  Created by Philophobic on 10/11/24.
//

import Foundation
import Combine

class MarketDataService {
    
    @Published var marketData : MarketDataModel? = nil
    var marketDataSubcrption : AnyCancellable?
    init() {
        getGlobalMarketData()
    }
    
     func getGlobalMarketData() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else  {
            return
        }
        marketDataSubcrption = NetworkManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkManager.handleCompletion, receiveValue: {  [weak self] returnMarketData in
                self?.marketData = returnMarketData.data
                self?.marketDataSubcrption?.cancel()
            })
    }
    
}
