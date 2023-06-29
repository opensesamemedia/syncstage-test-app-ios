//
//  SessionLocationViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 08/11/2022.
//

import UIKit
import SyncStageSDK

class SessionLocationViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var locationPickerView: UIPickerView!
    
    var servers = [ServerInstance]()
    private var selectedServer: ServerInstance?
    
    var displayName = ""
    var userId = ""
    var sessionCode = ""
    
    private let joinSessionSegueIdentifier = "JoinSession"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        label.attributedText = NSMutableAttributedString().systemFontWith(text: "Session location", size: 24, weight: .semibold)
            .systemFontWith(text: "\nSelect the closest location for all session participants.", size: 14, weight: .regular)

        getServersList()
    }
    
    func getServersList() {
        // get zones list
        let hud = HUDView.show(view: view)
        SyncStageHelper.instance.getServerInstances { result in
            hud.hide()
            switch result {
            case .success(let servers):
                self.servers = servers
                self.selectedServer = servers.first
                self.locationPickerView.reloadAllComponents()
            case .failure(let error):
                NSLog(error.localizedDescription)
                let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                    self?.getServersList()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                self.showAlert(with: "Warning", message: "Failed to get servers list, please retry.", actions: [retryAction, cancelAction])
            }
        }
    }

    @IBAction func startSession() {
        guard let _ = selectedServer else {
            self.showAlert(with: "Warning", message: "You should select a zone.")
            return
        }

        self.performSegue(withIdentifier: joinSessionSegueIdentifier , sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == joinSessionSegueIdentifier,
           let destVC = segue.destination as? CreateOrJoinSessionViewController {
            destVC.displayName = displayName
            destVC.server = selectedServer
        }
    }
}

extension SessionLocationViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servers.count
    }
}

extension SessionLocationViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.label
        pickerLabel.text = servers[row].zoneName
        pickerLabel.font = UIFont.systemFont(ofSize: 14)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedServer = servers[row]
    }
}
