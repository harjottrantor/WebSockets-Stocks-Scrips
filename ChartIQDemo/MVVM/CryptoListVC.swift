//
//  ViewController.swift
//  ChartIQDemo
//
//  Created by osx on 06/09/22.
//

import UIKit
import SocketIO

class CryptoListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = ScreenViewModel()
    var disposal = DisposalCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        addSocketObservers()
    }
    deinit {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getData(completion: { [weak self] error in

            self?.tableView.reloadData()
            if SocketHandler.shared.webSocketConnection.socketState == .connected {
                self?.handleEvents(isSubscribe: true)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        handleEvents(isSubscribe: false)
    }
    
    func addSocketObservers() {
        
        SocketHandler.shared.webSocketConnection.didUpdateConnection.sink { completion in
            //Handle error here
        } receiveValue: { state in
            
            if state == .connected && !self.viewModel.coins.isEmpty {
                self.handleEvents(isSubscribe: true)
            }
        }.store(in: &disposal)

        SocketHandler.shared.webSocketConnection.didReceiveMessage.sink { completion in
            //Handle error here
        } receiveValue: { [weak self] message in
         
            self?.didReceiveUpdatedPrice(jsonText: message)
        }.store(in: &disposal)
    }
    
    func didReceiveUpdatedPrice(jsonText: String) {
        
        let data = Data(jsonText.utf8)
        do {
            let object = try JSONDecoder().decode(UpdatedSocketCoinInfo.self, from: data)
            
            if object.TYPE == "5" {
                
                if let index = viewModel.coins.firstIndex(where: { $0.symbol == object.FROMSYMBOL }), let price = object.PRICE {
                    
                    viewModel.coins[index].updatePrice(value: price)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
extension CryptoListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.coins.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinCell", for: indexPath) as! CoinCell
        
        let coin = viewModel.coins[indexPath.row]
        cell.lblName.text = coin.name
        cell.fullname.text = coin.fullName
        viewModel.coins[indexPath.row].$price
            .receive(on: DispatchQueue.main, options: nil)
            .sink { value in
                
                if let value = value {
                    cell.lblPrice.text = "\(value)"
                } else {
                    cell.lblPrice.text = "0.0"
                }
            }.store(in: &disposal)
        return cell
    }
}


extension CryptoListVC {
    
    func handleEvents(isSubscribe: Bool) {
        
        let subs = viewModel.coins.map { $0.subs }.flatMap { $0 }

        let subRequest = [
            "action": isSubscribe ? "SubAdd" : "SubRemove",
            "subs": subs
        ] as [String:Any]
        if let value = subRequest.data {

            SocketHandler.shared.webSocketConnection.send(data: value)
        }
    }
}
