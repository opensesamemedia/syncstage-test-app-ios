//
//  SDKInitializationViewController.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 01/06/2022.
//

import UIKit
import SyncStageSDK

class SDKInitializationViewController: UIViewController {

    @IBOutlet var accessTokenTextView: UITextView!
    @IBOutlet var userPicker: UIPickerView!
    @IBOutlet var initializeSDKButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var directMonitorSwitch: UISwitch!
    @IBOutlet var forceInternalMicSwitch: UISwitch!
    @IBOutlet var networkLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    private let accessTokenKey = "AccessToken"

    var selectedUser: Int = 0
    var directMonitor = false
    var forceInternalMic = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scan QR", style: .plain, target: self, action: #selector(scanAction))
        
        accessTokenTextView.layer.borderColor = UIColor.systemGray.cgColor
        accessTokenTextView.layer.borderWidth = 1
        
        networkLabel.text = "Network Type: \(NetworkDetector.getConnectionType())"
        descriptionLabel.attributedText = NSMutableAttributedString().systemFontWith(text: "Here you can paste your Access Token or read it using a QR code. You can get your token on ", size: 14, weight: .regular)
            .systemFontWith(text: "sync-stage.com", size: 14, weight: .bold)
            .systemFontWith(text: " website.", size: 14, weight: .regular)
        
        if let accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
            accessTokenTextView.text = accessToken
        }
        
        directMonitorSwitch.setOn(directMonitor, animated: false)
        directMonitorSwitch.addTarget(self, action: #selector(updateDirectMonitor), for: .valueChanged)
        forceInternalMicSwitch.setOn(forceInternalMic, animated: false)
        forceInternalMicSwitch.addTarget(self, action: #selector(updateForceInternalMic), for: .valueChanged)
    }
    
    @objc func updateDirectMonitor() {
        directMonitor = directMonitorSwitch.isOn
    }
    
    @objc func updateForceInternalMic() {
        forceInternalMic = forceInternalMicSwitch.isOn
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged), name: .networkDidChange, object: nil)
        networkChanged()
        directMonitorSwitch.setOn(directMonitor, animated: false)
        forceInternalMicSwitch.setOn(forceInternalMic, animated: false)
    }

    @objc func networkChanged() {
        networkLabel.text = "Network type: \(NetworkDetector.getConnectionType())"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .networkDidChange, object: nil)
    }
    
    @objc func scanAction() {
        let scannerViewController = ScannerViewController()
        scannerViewController.delegate = self
        self.present(scannerViewController, animated: true)
    }

    @IBAction func initializeSDK(sender: UIButton) {
        if accessTokenTextView.text.isEmpty {
            let alert = UIAlertController(title: "Warning",
                                          message: "The access token is missing",
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }

        activityIndicator.startAnimating()
        initializeSDKButton.isEnabled = false
        /*SyncStageManager.shared.initSDK(accessToken: accessTokenTextView.text, userId: selectedUser) { [weak self] error in
            if let error = error {
                self?.activityIndicator.stopAnimating()
                self?.initializeSDKButton.isEnabled = true
                self?.showAlert(with: "Warning", message: "Failed to initiate the SyncStageSDK with error: \(error.localizedDescription)")
                return
            }
            if let token = self?.accessTokenTextView.text, let key = self?.accessTokenKey {
                UserDefaults.standard.set(token, forKey: key)
            }

            SyncStageManager.shared.connect(with: self?.directMonitor ?? false, forceInternalMicEnabled: self?.forceInternalMic ?? false) { [weak self] error in
                self?.activityIndicator.stopAnimating()
                self?.initializeSDKButton.isEnabled = true
                if let error = error {
                    self?.showAlert(with: "Warning", message: "Failed to connect with error: \(error.localizedDescription)")
                } else {
                    self?.performSegue(withIdentifier: "Session", sender: self)
                }
            }
        }*/
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Session", let destVC = segue.destination as? SessionViewController {
            destVC.directMonitor = directMonitor
            destVC.forceInternalMic = forceInternalMic
        }
    }
}

extension SDKInitializationViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
}

extension SDKInitializationViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.label
        pickerLabel.text = "User \(row)"
        pickerLabel.font = UIFont.systemFont(ofSize: 14)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUser = row
    }
}

extension SDKInitializationViewController: ScannerDelegate {
    func qrCodeDetected(with value: String) {
        if let url = URL(string: value), let data = try? Data(contentsOf: url) {
            let accessToken = String(data: data, encoding: .utf8)
            accessTokenTextView.text = accessToken
        }
    }
}
