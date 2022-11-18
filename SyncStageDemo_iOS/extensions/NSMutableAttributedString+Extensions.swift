//
//  NSMutableAttributedString+Extensions.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 23/06/2022.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func systemFontWith(text: String, size: CGFloat, weight: UIFont.Weight) -> NSMutableAttributedString {
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size, weight: weight)]
            let string = NSMutableAttributedString(string: text, attributes: attributes)
            self.append(string)
            return self
        }
    }
