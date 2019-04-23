//
//  UINavigationBar+Comet.swift
//  Comet
//
//  Created by Harley on 2016/11/8.
//
//

import Foundation

public extension UINavigationBar {
    
    /// 定义导航栏的全局颜色
    class func customizeAppearenceColorWith(barTint: UIColor, foreground: UIColor) {
        
        self.appearance().barTintColor = barTint
        self.appearance().tintColor = foreground
        self.appearance().textColor = foreground
    }
    
    /// 设置导航栏的文字颜色
    var textColor: UIColor? {
        get {
            return self.titleTextAttributes?[.foregroundColor] as? UIColor
        }
        set {
            var attributes = self.titleTextAttributes ?? [NSAttributedString.Key : Any]()
            attributes[.foregroundColor] = newValue
            self.titleTextAttributes = attributes
        }
    }
    
    /// 设置导航栏标题的字体
    var titleFont: UIFont? {
        get {
            return self.titleTextAttributes?[.font] as? UIFont
        }
        set {
            var attributes = self.titleTextAttributes ?? [NSAttributedString.Key : Any]()
            attributes[.font] = newValue
            self.titleTextAttributes = attributes
        }
    }
}
