//
//  OptionsViewController.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 10/11/2022.
//

import UIKit
import AVFAudio
import SyncStageSDK

class OptionsViewController: UIViewController {
    
    @IBOutlet var directMonitor: UISwitch!
    @IBOutlet var internalMic: UISwitch!
    @IBOutlet var directMonitorVolume: UISlider!
    @IBOutlet var latencyPicker: UIPickerView!
    
    let latencyOptions = ["High quality", "Optimized", "Best performance", "Ultra fast"]

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
    
    func enableOptions(enabled: Bool) {
        directMonitor.isEnabled = enabled
        internalMic.isEnabled = enabled
        directMonitorVolume.isEnabled = enabled
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        directMonitor.isOn = SyncStageHelper.directMonitorEnabled
        internalMic.isOn = SyncStageHelper.internalMicEnabled
        directMonitorVolume.value = SyncStageHelper.instance.getDirectMonitorVolume()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
        let headphoneConnected = areHeadphonesConnected()
        enableOptions(enabled: headphoneConnected)
        
        let selectedValue = SyncStageHelper.instance.getLatencyOptimizationLevel()
        latencyPicker.selectRow(selectedValue.rawValue, inComponent: 0, animated: false)
    }
    
    @objc func handleRouteChange(notification: Notification) {
        let headphonesConnected = areHeadphonesConnected()
        enableOptions(enabled: headphonesConnected)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func areHeadphonesConnected() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.currentRoute.outputs.contains(where: { $0.portType != AVAudioSession.Port.builtInSpeaker && $0.portType != AVAudioSession.Port.builtInReceiver }) {
            return true
        }

        if let availableInputs = audioSession.availableInputs,
           availableInputs.contains(where: { $0.portType == AVAudioSession.Port.headsetMic || $0.portType == AVAudioSession.Port.usbAudio }) {
            return true
        }

        return false
    }
}

extension OptionsViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return latencyOptions.count
    }
}

extension OptionsViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.label
        pickerLabel.text = latencyOptions[row]
        pickerLabel.font = UIFont.systemFont(ofSize: 14)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let latency = LatencyOptimizationLevel(rawValue: row) ?? .optimized
        SyncStageHelper.instance.changeLatencyOptimizationLevel(value: latency)
    }
}
