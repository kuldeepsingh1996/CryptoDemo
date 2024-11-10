//
//  CoinImageViewModel.swift
//  CryptoDemo
//
//  Created by Philophobic on 09/11/24.
//

import Foundation
import SwiftUI
import Combine


class CoinImageViewModel:ObservableObject {
    
    @Published var image:UIImage? = nil
    @Published var isLoading : Bool = false
    
    private let coin : CoinModel
    private let dataService : CoinImageService
    private var cancelabels = Set<AnyCancellable>()
    
    init(coin:CoinModel) {
        self.coin = coin
        self.dataService = CoinImageService(coinModel: coin)
        self.isLoading = true
        addSubcribers()

    }
    
    private func addSubcribers() {
        dataService.$images
            .sink { [weak self] (_) in
                self?.isLoading = true
            } receiveValue: { returnImage in
                self.image = returnImage
            }
            .store(in: &cancelabels)

    }
}
