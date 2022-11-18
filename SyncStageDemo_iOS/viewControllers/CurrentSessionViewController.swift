//
//  CurrentSessionViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 09/11/2022.
//

import UIKit
import SyncStageSDK

class CurrentSessionViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var muteButton: UIButton!
    
    var displayName: String!
    var userId: String!
    var code: String!
    
    var session: Session?
    var isMuted = false
    var connections = [ConnectionModel]()
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) { }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        
        SyncStageHelper.instance.userDelegate = self
        SyncStageHelper.instance.connectivityDelegate = self
        codeLabel.text = code
        
        // get zones list
        let hud = HUDView.show(view: view)
        SyncStageHelper.instance.join(sessionCode: code, userId: userId, displayName: displayName, completion: { [weak self] result in
            hud.hide()
            switch result {
            case .success(let session):
                self?.session = session
                self?.update(session: session)
                self?.tableView.reloadData()
            case .failure(let error):
                NSLog(error.localizedDescription)
                let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                self?.showAlert(with: "Warning", message: error.localizedDescription, actions: [okAction])
            }
        })
    }
    
    func update(session: Session) {
        connections.removeAll()
        if let transmitter = session.transmitter {
            connections.append(ConnectionModel(connection: transmitter))
        }
        for receiver in session.receivers {
            connections.append(ConnectionModel(connection: receiver))
        }
    }
    
    @IBAction func copyToClipboard() {
        UIPasteboard.general.string = code
        showAlert(with: "Warning", message: "Session code \(code ?? "") copied to clipboard")
    }

    @IBAction func endSession() {
        if let transmitterId = session?.transmitter?.identifier {
            let hud = HUDView.show(view: view)
            SyncStageHelper.instance.leave(transmitterId: transmitterId, completion: { [weak self] error in
                NSLog("Session left.")
                hud.hide()
                self?.navigationController?.popViewController(animated: true)
            })
        }
    }

    @IBAction func mute() {
        isMuted.toggle()
        if let transmitter = connections.first {
            transmitter.isMuted = isMuted
        }
        SyncStageHelper.instance.toggleMicrophone(mute: isMuted)
        let imageName = isMuted ? "mic.slash" : "mic"
        let config = UIImage.SymbolConfiguration(textStyle: .body, scale: .large)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        image?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        muteButton.setImage(image, for: .normal)
        tableView.reloadData()
    }
}

extension CurrentSessionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return receiver count + transmitter
        return connections.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let connection = connections[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell {
            cell.userNameLabel.text = indexPath.row == 0 ? "You (\(connection.displayName ?? ""))" : connection.displayName ?? displayName
            cell.connectionIndicatorView.backgroundColor = connection.isConnected ? .green : .red
            cell.volumeSlider.isHidden = indexPath.row == 0
            if indexPath.row != 0 {
                cell.volumeSlider.value = SyncStageHelper.instance.getReceiverVolume(identifier: connection.identifier)
            }
            cell.isMutedImageView.image = UIImage(systemName: connection.isMuted ? "mic.slash" : "mic")
            cell.accessoryType = .none
            
            cell.connectionId = connection.identifier

            return cell
        }
        return UITableViewCell()
    }
    
    func reloadCellAt(index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}

extension CurrentSessionViewController: SyncStageConnectivityDelegate {
    func transmitterConnectivityChanged(connected: Bool) {
        connections.first?.isConnected = connected
        reloadCellAt(index: 0)
    }
    
    func receiverConnectivityChanged(identifier: String, connected: Bool) {
        if let index = connections.firstIndex(where: { $0.identifier == identifier }) {
            connections[index].isConnected = connected
            reloadCellAt(index: index)
        }
    }
}

extension CurrentSessionViewController: SyncStageUserDelegate {
    
    func sessionOut() {
        let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        self.showAlert(with: "Alert", message: "Session out!", actions: [okAction])
    }
    
    
    func userJoined(connection: SyncStageSDK.Connection) {
        connections.append(ConnectionModel(connection: connection))
        tableView.reloadData()
    }
    
    func userLeft(identifier: String) {
        connections.removeAll(where: { $0.identifier == identifier })
        tableView.reloadData()
    }
    
    func userMuted(identifier: String) {
        if let index = connections.firstIndex(where: { $0.identifier == identifier }) {
            connections[index].isMuted = true
            reloadCellAt(index: index)
        }
    }
    
    func userUnmuted(identifier: String) {
        if let index = connections.firstIndex(where: { $0.identifier == identifier }) {
            connections[index].isMuted = false
            reloadCellAt(index: index)
        }
    }
}
