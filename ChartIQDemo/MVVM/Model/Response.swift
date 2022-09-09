//
//  Response.swift
//  ChartIQDemo
//
//  Created by osx on 06/09/22.
//

import Foundation
class Response<T: Decodable>: Decodable {
    
    var Data: T?
}
class Coin: Decodable {
    
    var CoinInfo: CoinInfo
    var ConversionInfo: ConversionInfo
}

class CoinInfo: Decodable {
    
    var Name: String
    var FullName: String
}
class ConversionInfo: Decodable {
 
    var CurrencyFrom: String
    var CurrencyTo: String
    var SubBase: String
    var SubsNeeded: [String]
    var TotalTopTierVolume24H: Decimal
    var TotalVolume24H: Decimal
}
class UpdatedSocketCoinInfo: Decodable {
    
    var TYPE: String?
    var FROMSYMBOL: String?
    var PRICE: Decimal?
}
