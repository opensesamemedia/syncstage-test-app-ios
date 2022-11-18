//
//  SessionViewController.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 01/06/2022.
//

import Foundation
import UIKit
import SyncStageSDK
import AVFAudio

class SessionViewController: StreamBaseViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var connectButton: RoundedButton!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var networkLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var directMonitorSwitch: UISwitch!
    @IBOutlet var forceInternalMicSwitch: UISwitch!
    @IBOutlet var muteSwitch: UISwitch!

    var connectionData: ConnectionData?
    var directMonitor = false
    var forceInternalMic = false
    var muted = false
    var colors: [UIColor] = [.green, .yellow, .blue, .red, .purple, .brown, .orange]
    var isDisconnected = false
    var inBackgroundMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.reloadData()
        networkLabel.text = "Network Type: \(NetworkDetector.getConnectionType())"
        updateInfo()
        directMonitorSwitch.setOn(directMonitor, animated: false)
        directMonitorSwitch.addTarget(self, action: #selector(updateDirectMonitor), for: .valueChanged)
        forceInternalMicSwitch.setOn(forceInternalMic, animated: false)
        forceInternalMicSwitch.addTarget(self, action: #selector(updateForceInternalMic), for: .valueChanged)
        /*let isMuted = SyncStageManager.shared.isTransmitterMuted()
        muteSwitch.setOn(isMuted, animated: false)
        muteSwitch.addTarget(self, action: #selector(updateMute), for: .valueChanged)*/
    }

    @objc func updateDirectMonitor() {
        directMonitor = directMonitorSwitch.isOn
        directMonitorSwitch.isUserInteractionEnabled = false
        /*SyncStageManager.shared.toggleDirectMonitor(enable: directMonitor) {
            self.directMonitorSwitch.isUserInteractionEnabled = true
        }*/
    }

    @objc func updateForceInternalMic() {
        forceInternalMic = forceInternalMicSwitch.isOn
        forceInternalMicSwitch.isUserInteractionEnabled = false
        /*SyncStageManager.shared.toggleInternalMic(enable: forceInternalMicSwitch.isOn) {
            self.forceInternalMicSwitch.isUserInteractionEnabled = true
        }*/
    }

    @objc func updateMute() {
        muted = muteSwitch.isOn
        //SyncStageManager.shared.toggleMuteTransmitter(mute: muted)
    }

    override func didEnterBackground() {
        inBackgroundMode = true
    }

    override func willEnterForeground() {
        inBackgroundMode = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //SyncStageManager.shared.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged), name: .networkDidChange, object: nil)
        networkChanged()
    }

    @objc func networkChanged() {
        networkLabel.text = "Network Type: \(NetworkDetector.getConnectionType())"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .networkDidChange, object: nil)
        if self.isMovingFromParent {
            if let sdkViewController = self.navigationController?.viewControllers.last as? SDKInitializationViewController {
                sdkViewController.forceInternalMic = forceInternalMic
                sdkViewController.directMonitor = directMonitor
            }
            //SyncStageManager.shared.delegate = nil
            /*SyncStageManager.shared.disconnect { error in
                if let error = error {
                    NSLog(error.localizedDescription)
                }
            }*/
        }
    }

    @IBAction func refresh() {
        /*SyncStageManager.shared.recoverCurrentSession { error in
            if let error = error {
                let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                self.showAlert(with: "Warning", message: error.localizedDescription, actions: [okAction])
            }
        }*/
    }

    @IBAction func disconnect(sender: UIButton) {
        activityIndicator.startAnimating()
        connectButton.isEnabled = false
        /*SyncStageManager.shared.disconnect { [weak self] error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
            self?.activityIndicator.stopAnimating()
            self?.navigationController?.popViewController(animated: true)
        }*/
    }

    func updateInfo() {
        //versionLabel.text = "Version \(SyncStageManager.shared.getSDKVersion())"
    }

    func update(with connectionData: ConnectionData?) {
        self.connectionData = connectionData
        if !isDisconnected, connectButton.isEnabled, connectionData?.txStream == nil {
            isDisconnected = true
            if !inBackgroundMode {
                streamDisconnected()
            }
        }
        tableView.reloadData()
        if let streamDetailsVC = self.navigationController?.viewControllers.last as? StreamDetailViewController {
            if let stream = connectionData?.rxStreams.first(where: { $0.streamId == streamDetailsVC.stream.streamId }) {
                streamDetailsVC.updateStream = stream
            }
        }
    }

    func streamDisconnected() {
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            DispatchQueue.main.async {
                self.disconnect(sender: self.connectButton)
            }
        }
        self.showAlert(with: "Warning", message: "Transmitter disconnected!", actions: [okAction])
        
    }
}

extension SessionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let connectionData = self.connectionData {
            switch section {
            case 0:
                return 1
            case 1:
                return connectionData.rxStreams.count
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = connectionData {
            return 2
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Transmitter"
        case 1:
            return "Receivers"
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell {
                if let connectionData = connectionData {
                    let stream = connectionData.txStream
                    cell.userNameLabel.text = stream?.streamName ?? "NA"
                    cell.connectionIndicatorView.backgroundColor = stream?.isConnected == true ? .green : .red
                    cell.qualitySlider.isHidden = true
                    cell.accessoryType = .none
                }
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell {
                if let connectionData = connectionData {
                    let stream = connectionData.rxStreams[indexPath.row]
                    cell.userNameLabel.text = stream.streamName
                    cell.connectionIndicatorView.backgroundColor = stream.isConnected ? .green : .red
                    cell.qualitySlider.isHidden = false
                    cell.qualitySlider.value = Float(stream.quality)
                    cell.qualitySlider.tintColor = colors[indexPath.row]
                    cell.accessoryType = .disclosureIndicator
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension SessionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, let stream = connectionData?.rxStreams[indexPath.row] {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let streamDetailVC = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as? StreamDetailViewController {
                streamDetailVC.stream = stream
                self.navigationController?.pushViewController(streamDetailVC, animated: true)
            }
        }
    }
}

/*extension SessionViewController: SyncStageDelegate {
    func onOperationError(errorCode: SyncStageErrorCode, message: String) {
        NSLog(message)
    }
    
    func onConnectionDataChange(connectionData: ConnectionData) {
        NSLog("connectionData changed")
        update(with: connectionData)
    }
    
    func onStreamListChange(connectionData: ConnectionData) {
        NSLog("onStreamListChange changed")
        update(with: connectionData)
    }
}*/

class StreamCell: UITableViewCell {
    @IBOutlet var streamNameLabel: UILabel!
    @IBOutlet var streamId: UILabel!
    @IBOutlet var isConnectedLabel: UILabel!
    @IBOutlet var volumeLabel: UILabel!
    @IBOutlet var qualityLabel: UILabel!
    @IBOutlet var networkJitterLabel: UILabel!
    @IBOutlet var patcketsOnTimeLabel: UILabel!
    @IBOutlet var networkDelayLabel: UILabel!
}

class TransmitterCell: UITableViewCell {
    @IBOutlet var streamNameLabel: UILabel!
    @IBOutlet var streamId: UILabel!
    @IBOutlet var isConnectedLabel: UILabel!
}
