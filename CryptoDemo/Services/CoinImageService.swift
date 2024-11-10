//
//  CoinImageService.swift
//  CryptoDemo
//
//  Created by Philophobic on 09/11/24.
//

import Foundation
import SwiftUI
import Combine

class CoinImageService {
    
    @Published var images : UIImage? = nil
    
    var imageSubscrption : AnyCancellable?
    let coin : CoinModel
    let instance = LocalFileManager.instance
    let imageName : String
    let folderName = "coin_Images"
    init(coinModel:CoinModel) {
        self.coin = coinModel
        imageName = coin.id
        getCoinImage()
    }
    
    
    private func getCoinImage() {
        if let savedImage = instance.getImage(imageName: imageName, folderName: folderName) {
            self.images = savedImage
            print("Retrive from Local File Manager")
        }else {
            downloadCoinImage()
            print("download coin image")

        }
    }
    
    private func downloadCoinImage() {
        guard let url = URL(string: coin.image) else  {
            return
        }
       imageSubscrption = NetworkManager.download(url: url)
            .tryMap { (data) -> UIImage? in
                return UIImage(data: data)
            }
            .sink(receiveCompletion: NetworkManager.handleCompletion(completion:)) { [weak self] returnImage in
                guard let self = self , let downloadImage = returnImage else  {
                    return
                }
                self.images = returnImage
                self.imageSubscrption?.cancel()
                self.instance.saveImage(image: downloadImage, imageName: self.imageName, folderName: self.folderName)
            }
    }
}
