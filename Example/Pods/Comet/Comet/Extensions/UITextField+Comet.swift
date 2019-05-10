//
//  UITextField+Comet.swift
//  Comet
//
//  Created by Harley on 2016/11/8.
//
//

import Foundation

public extension UITextField {
    
    func setPlaceholderColor(_ color: UIColor) {
        
        if let string = self.placeholder {
            if !string.isEmpty {
                let attributedString = NSAttributedString(string: string, attributes: [.foregroundColor : color])
                self.attributedPlaceholder = attributedString
            }
        } else if let string = self.attributedPlaceholder {
            if string.length > 0 {
                let attributedString = NSMutableAttributedString(attributedString: string)
                attributedString.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, string.length))
                self.attributedPlaceholder = attributedString
            }
        }
    }    
}
