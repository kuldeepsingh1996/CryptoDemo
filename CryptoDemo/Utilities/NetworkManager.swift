//
//  NetworkManager.swift
//  CryptoDemo
//
//  Created by Philophobic on 09/11/24.
//

import Foundation
import Combine

class NetworkManager {
    
    enum NetwokingError : LocalizedError {
        case badURLResponse(url:URL)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case.badURLResponse(url:let url) :
                return "[🔥] Bad Response from URL: \(url)"
            case .unknown :
                return "[⚠️] Unknown Error Occured"
            }
        }
        
    }
    
    static func download(url:URL) -> AnyPublisher<Data,Error> {
        
       return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap({try handleUrlResponse(output: $0,url: url)})
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func handleUrlResponse(output:URLSession.DataTaskPublisher.Output,url:URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse ,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw NetwokingError.badURLResponse(url: url)
        }
        return output.data
        
    }
    static func handleCompletion(completion:Subscribers.Completion<Error>) {
        switch completion {
        case .finished :
            break
        case .failure(let error) :
            print(error.localizedDescription)
        }
    }
}
