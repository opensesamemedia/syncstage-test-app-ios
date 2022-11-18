//
//  MicrophoneAccessViewController.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 01/06/2022.
//

import UIKit
import AVFAudio

class MicrophoneAccessViewController: UIViewController {
    
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        label.attributedText = NSMutableAttributedString().systemFontWith(text: "SyncStage", size: 14, weight: .bold).systemFontWith(text: " requires access to your microphone to let the others to hear you.", size: 14, weight: .regular)
    }
    
    func openSettings(alert: UIAlertAction!) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func showAlert() {
        let settingsAction = UIAlertAction(title: "Open Settings",
                                           style: UIAlertAction.Style.default,
                                           handler: openSettings)
        let cancelAction = UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.default,
                                      handler: nil)
        self.showAlert(with: "Settings", message: "Please enable microphone access in the application settings/", actions: [settingsAction, cancelAction])
    }

    @IBAction func requestAccess(sender: UIButton) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .denied:
            NSLog("Access denied")
            showAlert()
        case .granted:
            NSLog("Access granted")
            self.performSegue(withIdentifier: "userViewController", sender: self)
        case .undetermined:
            NSLog("Access undetermined")
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.performSegue(withIdentifier: "userViewController", sender: self)
                    } else {
                        self?.showAlert()
                    }
                }
            }
        @unknown default:
            NSLog("Unkown")
        }
    }
}
