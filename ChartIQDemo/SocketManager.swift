//
//  SocketManager.swift
//  ChartIQDemo
//
//  Created by osx on 07/09/22.
//

import Foundation
protocol WebSocketConnection {
    
    func send(text: String)
    func send(data: Data)
    func connect()
    func disconnect()
    
    var socketState: SocketState {
        get set
    }
    
    var didUpdateConnection: PassthroughSubject<SocketState, Error> { get set }
    var didReceiveMessage: PassthroughSubject<String, Error> { get set }
    var didReceiveData: PassthroughSubject<Data, Error> { get set }
    var didFailedWithError: PassthroughSubject<String, Error> { get set }
}
import Combine
class WebSocketTaskConnection: NSObject, WebSocketConnection {
    
    var socket: URLSessionWebSocketTask!
    var urlSession: URLSession!
    let delegateQueue = OperationQueue()
    var socketState: SocketState = .disconnected
    
    var didReceiveMessage = PassthroughSubject<String, Error>()
    var didReceiveData = PassthroughSubject<Data, Error>()
    var didUpdateConnection = PassthroughSubject<SocketState, Error>()
    var didFailedWithError = PassthroughSubject<String, Error>()
    
    init(url: URL) {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        socket = urlSession.webSocketTask(with: url)
    }
    
}
extension WebSocketTaskConnection: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
        socketState = .connected
        didUpdateConnection.send(socketState)
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        socketState = .disconnected
        didUpdateConnection.send(socketState)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let error = error {
            didFailedWithError.send(completion: .failure(error))
        }
    }
    
    func connect() {
        socket.resume()
        listen()
    }
    func disconnect() {
        socket.cancel(with: .goingAway, reason: nil)
    }
    
    func listen() {
        
        socket.receive { result in
            switch result {
            case .failure(let error):
                self.didFailedWithError.send(completion: .failure(error))
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text = ", text)
                    self.didReceiveMessage.send(text)
                case .data(let data):
                    self.didReceiveData.send(data)
                    break
                @unknown default:
                    fatalError()
                }
                
                self.listen()
            }
        }
    }
    func send(text: String) {
        
        socket.send(URLSessionWebSocketTask.Message.string(text)) { error in
            if let error = error {
                self.didFailedWithError.send(completion: .failure(error))
            }
        }
    }
    
    func send(data: Data) {
        socket.send(URLSessionWebSocketTask.Message.data(data)) { error in
            if let error = error {
                self.didFailedWithError.send(completion: .failure(error))
            }
        }
    }
}
class SocketHandler {
    
    static var shared = SocketHandler()
    var webSocketConnection: WebSocketConnection
    
    init() {
        
        webSocketConnection = WebSocketTaskConnection(url: socketURL)
    }
}
