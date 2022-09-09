//
//  ScreenViewModel.swift
//  ChartIQDemo
//
//  Created by osx on 06/09/22.
//

import Foundation
class ScreenViewModel {
    
    var coins: [CoinViewModel] = []
    
    func getData(completion: @escaping(String?) -> Void) {
        
        let params = ["tsym": "USD", "page": "1", "api_key": apiKey]
        APIProvider.shared.performRequest(urlPath: "https://min-api.cryptocompare.com/data/top/totalvol", type: [Coin].self, method: .get, params: params) { response in
            
            self.coins = response.map { CoinViewModel.init(model: $0) }
            completion(nil)
        } failure: { error in
            
            completion(error.debugDescription)
        }

    }
}
