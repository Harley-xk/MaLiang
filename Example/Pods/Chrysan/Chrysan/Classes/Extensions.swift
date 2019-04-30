//
//  Extensions.swift
//  Chrysan
//
//  Created by Harley on 2016/11/14.
//
//

import Foundation

public extension UIView {
    
    private struct AssociatedKeys {
        static var chrysanViewKey = "Chrysan.ChrysanKey"
    }
    
    var chrysan: ChrysanView {
        get {
            var hud = objc_getAssociatedObject(self, &AssociatedKeys.chrysanViewKey) as? ChrysanView
            if hud == nil {
                hud = ChrysanView.chrysan(withView: self)
                self.chrysan = hud!
            }
            return hud!
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.chrysanViewKey, newValue as ChrysanView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public extension UIViewController {
    
    var chrysan: ChrysanView {
        get {
            return view.chrysan
        }
        set {
            view.chrysan = newValue
        }
    }
    
}


