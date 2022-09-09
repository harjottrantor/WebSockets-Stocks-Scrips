//
//  Extension.swift
//  ChartIQDemo
//
//  Created by osx on 07/09/22.
//

import Foundation

extension Data {
    
    var toDictionary: [String: Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .allowFragments) as? [String: Any]
            return json
        } catch let error {
            print(error)
            return nil
        }
    }
}
extension Dictionary {
    
    var data: Data? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
           return jsonData
        } catch {
            return nil
        }
    }
    var jsonString: String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            return jsonString
        } catch {
            return nil
        }
        
    }
}
extension String {
    
    var object: [String:Any] {
        
        do {
            
            let data = Data(self.utf8)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}
extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
