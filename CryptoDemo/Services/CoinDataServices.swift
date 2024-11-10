//
//  CoinDataServices.swift
//  CryptoDemo
//
//  Created by Philophobic on 08/11/24.
//

import Foundation
import Combine

class CoinDataServices {
    
    @Published var allCoins : [CoinModel] = []
    var coinSubcrption : AnyCancellable?
    init() {
        getAllCoins()
    }
    
    private func getAllCoins() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h") else  {
            return
        }
        coinSubcrption = NetworkManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkManager.handleCompletion, receiveValue: {  [weak self] returnedCoin in
                self?.allCoins = returnedCoin
                self?.coinSubcrption?.cancel()
            })
    }
    
}
