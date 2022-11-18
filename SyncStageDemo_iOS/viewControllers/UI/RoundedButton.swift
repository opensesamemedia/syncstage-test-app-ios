//
//  RoundedButton.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 23/06/2022.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.layer.cornerRadius = 5
    }
}
