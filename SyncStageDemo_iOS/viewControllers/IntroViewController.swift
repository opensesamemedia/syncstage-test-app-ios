//
//  IntroViewController.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 23/06/2022.
//

import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let fontSize = CGFloat(14)
        label.attributedText = NSMutableAttributedString().systemFontWith(text: "SyncStage", size: fontSize, weight: .bold)
            .systemFontWith(text: " is a patent-pending voice chat platform that allows you to sing, jam, learn, win together with audio latency lower ", size: fontSize, weight: .regular).systemFontWith(text: "than ever before.", size: fontSize, weight: .bold)
    }
}
