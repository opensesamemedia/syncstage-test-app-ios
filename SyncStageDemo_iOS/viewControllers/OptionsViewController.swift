//
//  OptionsViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 10/11/2022.
//

import UIKit

class OptionsViewController: UIViewController {
    
    @IBOutlet var directMonitor: UISwitch!
    @IBOutlet var internalMic: UISwitch!
    @IBOutlet var directMonitorVolume: UISlider!

    @IBAction func directMonitorChanged(sender: UISwitch) {
        SyncStageHelper.instance.toggleDirectMonitor(enable: sender.isOn)
        SyncStageHelper.directMonitorEnabled = sender.isOn
    }

    @IBAction func internalMicChanged(sender: UISwitch) {
        SyncStageHelper.instance.toggleInternalMic(enable: sender.isOn)
        SyncStageHelper.internalMicEnabled = sender.isOn
    }
    
    @IBAction func directMonitorVolumeChanged(sender: UISlider) {
        SyncStageHelper.instance.changeDirectMonitorVolume(volume: sender.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        directMonitor.isOn = SyncStageHelper.directMonitorEnabled
        internalMic.isOn = SyncStageHelper.internalMicEnabled
        directMonitorVolume.value = SyncStageHelper.instance.getDirectMonitorVolume()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func dismiss(sender: UIButton) {
        performSegue(withIdentifier: "dismissControls", sender: self)
    }
}
