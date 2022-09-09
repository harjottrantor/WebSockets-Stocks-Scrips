//
//  Network.swift
//  ChartIQDemo
//
//  Created by osx on 06/09/22.
//

import Foundation
import Alamofire

class APIProvider {
    
    static var shared = APIProvider()
    func performRequest<T: Decodable>(urlPath: String, type: T.Type, method: HTTPMethod ,params: [String:Any], success: @escaping(T) -> Void, failure: @escaping(String) -> Void) {
        
        guard let url = URL(string: urlPath) else {
            return
        }
        var request = URLRequest(url: url)

        switch method {
        case .get:
            
            let newUrl = self.paramsAsUrl(url: url, params: params)
            print(newUrl)
            request = URLRequest(url: newUrl)
            
        default:
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {}
        }
        
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        AF.request(request).validate().responseDecodable(of: Response<T>.self) { (response) in

            print(response.data?.toDictionary)
            
            switch response.result {
            case .success(let value):

                if let data = value.Data {
                    success(data)
                } else {
                    failure("Error")
                }
            case .failure(_):

                print("Error : \(response.result)")
                failure("Error")
            }
        }
    }
    
    private func paramsAsUrl(url: URL, params: [String:Any]) -> URL {
        
        var newUrl = url.absoluteString
        if !params.isEmpty {

            newUrl += "?"
            for (key, value) in params {
                if let arr = value as? [String] {
                    let types = arr.joined(separator: ",")
                    newUrl = "\(newUrl)\(key)=\(types)&"
                } else {
                    newUrl = "\(newUrl)\(key)=\(value)&"
                }
            }
            newUrl.removeLast()
        }
        return URL(string: newUrl) ?? url
    }
}
