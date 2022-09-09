//
//  CoinViewModel.swift
//  ChartIQDemo
//
//  Created by osx on 08/09/22.
//

import Foundation
class CoinViewModel: ObservableObject {
    
    var name: String {
        model.CoinInfo.Name
    }
    var fullName: String {
        model.CoinInfo.FullName
    }
   
    var symbol: String {
        model.ConversionInfo.CurrencyFrom
    }
    var subs: [String] {
        model.ConversionInfo.SubsNeeded.map{ $0 }
    }
    @Published var price: Double?
    
    var model: Coin
    
    init(model: Coin) {
        self.model = model
    }
    
    func updatePrice(value: Decimal) {
        
        self.price = value.doubleValue
        
    }
}
