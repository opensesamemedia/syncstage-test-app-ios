//
//  DiscoveryViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 19/05/2023.
//

import UIKit
import SyncStageSDK

class DiscoveryViewController: UIViewController {

    @IBOutlet var automatedSelectionSwitch: UISwitch!
    
    var displayName = ""

    private let discoverySegueIdentifier = "startDiscovery"
    private let manualSelectionSegueIdentifier = "manualSelection"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        automatedSelectionSwitch.isOn = true

        initSyncStage()
    }

    func initSyncStage() {
        let hud = HUDView.show(view: view)
        SyncStageHelper.instance = SyncStage(completion: { error in
            hud.hide()
            if let error = error {
                NSLog(error.localizedDescription)
                let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                    self?.initSyncStage()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                self.showAlert(with: "Warning", message: "Failed to initiate SyncStage SDK, please retry.", actions: [retryAction, cancelAction])
                return
            }
            NSLog("SyncStage initiation completed.")
        })
    }

    @IBAction func next(sender: UIButton) {
        if automatedSelectionSwitch.isOn {
            self.performSegue(withIdentifier: discoverySegueIdentifier, sender: self)
        } else {
            self.performSegue(withIdentifier: manualSelectionSegueIdentifier, sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == discoverySegueIdentifier, let destVC = segue.destination as? StartDiscoveryViewController {
            destVC.displayName = displayName
        } else if segue.identifier == manualSelectionSegueIdentifier, let destVC = segue.destination as? SessionLocationViewController {
            destVC.displayName = displayName
        }
    }
}
