//
//  Constants.swift
//  ChartIQDemo
//
//  Created by osx on 08/09/22.
//

import Foundation
let apiKey = "8a88da0e39a2558f96fe7f8c9f5133a5a188f5b9a8f75ae31704ba40c4d78ea2"
let socketURL = URL(string: "wss://streamer.cryptocompare.com/v2?api_key=\(apiKey)")!

enum SocketState {
    case connected
    case disconnected
}

import Combine
typealias DisposalCollection = Set<AnyCancellable>
