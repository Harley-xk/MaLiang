//
//  UIAlertController+Comet.swift
//  Comet
//
//  Created by Harley on 2016/11/8.
//
//

import UIKit

public extension UIAlertController {
    
    func addAction(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction)->())? = nil) {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        self.addAction(action)
    }
}


