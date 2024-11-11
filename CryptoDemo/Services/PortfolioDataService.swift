//
//  PortfolioDataService.swift
//  CryptoDemo
//
//  Created by Philophobic on 11/11/24.
//

import Foundation
import CoreData

class PortfolioDataService {
    
    private let container : NSPersistentContainer
    private let containerName : String = "PortfolioContainer"
    private let entityName = "PortfolioEntity"
    
    @Published var savedEntity : [PortfolioEntity] = []
    
    init() {
        self.container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("error Loading data:\(error.localizedDescription)")
            }
            getPortfolio()
        }
    }
    
    
    func updatePortfoilo(coin:CoinModel,amount:Double) {
        if let entity = savedEntity.first(where: {$0.coidId == coin.id}) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            }else {
                delete(entity: entity)
            }
            
        }else  {
            addCoins(coin: coin, amount: amount)
        }
    }
    
    private func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        do {
            savedEntity =  try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching in data \(error.localizedDescription)")
        }
        
    }
    
    
    private func addCoins(coin:CoinModel,amount:Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coidId = coin.id
        entity.amount = amount
        applyChnages()
    }
    
    private func update(entity:PortfolioEntity,amount:Double) {
        entity.amount = amount
        applyChnages()
    }
    
    private func delete(entity:PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChnages()
    }
    
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error Saving in core data \(error.localizedDescription)")
        }
    }
    
    private func applyChnages(){
        save()
        getPortfolio()
    }
}
