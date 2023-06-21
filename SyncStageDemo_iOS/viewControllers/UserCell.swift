//
//  UserCell.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 18/11/2022.
//

import UIKit
import SyncStageSDK

class UserCell: UITableViewCell {
    @IBOutlet var connectionIndicatorView: UIView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var volumeSlider: UISlider!
    @IBOutlet var isMutedImageView: UIImageView!
    @IBOutlet var jitterLabel: UILabel!
    @IBOutlet var qualityLabel: UILabel!
    @IBOutlet var pingLabel: UILabel!
    
    var connectionId = ""

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        connectionIndicatorView.layer.cornerRadius = connectionIndicatorView.frame.size.width / 2
    }
    
    @IBAction func volumeChanged(sender: UISlider) {
        let result = SyncStageHelper.instance.changeReceiverVolume(identifier: connectionId, volume: sender.value)
        if result != SyncStageErrorCode.ok {
            NSLog("Error while changing volume.")
        }
    }
}
