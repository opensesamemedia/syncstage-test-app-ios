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
    
    var zoneId: String?
    var zonesList = [Zone]()
    
    var displayName = ""
    var userId = ""
    var sessionCode = ""
    
    private let joinSessionSegueIdentifier = "JoinSession"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        label.attributedText = NSMutableAttributedString().systemFontWith(text: "Session location", size: 24, weight: .semibold)
            .systemFontWith(text: "\nSelect the closest location for all session participants.", size: 14, weight: .regular)

        getZonesList()
    }
    
    func getZonesList() {
        // get zones list
        let hud = HUDView.show(view: view)
        SyncStageHelper.instance.zoneList(completion: { [weak self] result in
            hud.hide()
            switch result {
            case .success(let zones):
                self?.zonesList = zones
                self?.zoneId = zones.first?.zoneId
                self?.locationPickerView.reloadAllComponents()
            case .failure(let error):
                NSLog(error.localizedDescription)
                let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                    self?.getZonesList()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                self?.showAlert(with: "Warning", message: "Failed to get zones list, please retry.", actions: [retryAction, cancelAction])
            }
        })
    }

    @IBAction func startSession() {
        guard let zoneId = zoneId else {
            self.showAlert(with: "Warning", message: "You should select a zone.")
            return
        }

        let hud = HUDView.show(view: view)
        SyncStageHelper.instance.createSession(zoneId: zoneId, userId: userId, completion: { [weak self] result in
            hud.hide()
            switch result {
            case .success(let sessionIdentifier):
                self?.sessionCode = sessionIdentifier.sessionCode
                self?.performSegue(withIdentifier: self?.joinSessionSegueIdentifier ?? "", sender: self)
            case .failure(let error):
                self?.showAlert(with: "Warning", message: error.localizedDescription)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == joinSessionSegueIdentifier, let destVC = segue.destination as? CurrentSessionViewController {
            destVC.displayName = displayName
            destVC.userId = userId
            destVC.code = sessionCode
        }
    }
}

extension SessionLocationViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return zonesList.count
    }
}

extension SessionLocationViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.label
        pickerLabel.text = zonesList[row].zoneName
        pickerLabel.font = UIFont.systemFont(ofSize: 14)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let zone = zonesList[row]
        zoneId = zone.zoneId
    }
}
