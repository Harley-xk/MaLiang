//
//  UIResponder+Comet.swift
//  Comet
//
//  Created by Harley on 2016/11/8.
//
//

import Foundation

public extension UIResponder {
    
    /// 解除任何可能存在的第一响应者
    @discardableResult class func resignAnyFirstResponder() -> Bool {
        return UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// 用于在 IB 中指定移除第一响应者事件
    @IBAction func autoResignFirstResponder() {
        resignFirstResponder()
    }
    
    /// 用于在 IB 中指定第一响应者事件
    @IBAction func autoBecomFirstResponder() {
        becomeFirstResponder()
    }
}

extension UIViewController {
    
    // 检查当前视图控制器是否包含第一响应者，会遍历响应链以及子视图检查
    public var containsFirstResponder: Bool {
        // 从子视图中找到第一响应者的概率较大，所以先检查子视图
        if view.containsFirstResponder {
            return true
        }
        // 检查响应链
        var responder: UIResponder? = self
        while responder != nil {
            if responder!.isFirstResponder {
                return true
            }
            responder = responder?.next
        }
        return false
    }
}

extension UIView {
    
    // 检查当前视图是否包含第一响应者，会遍历所有子视图检查
    public var containsFirstResponder: Bool {
        if isFirstResponder {
            return true
        }
        for subView in subviews {
            let result = subView.isFirstResponder
            if result {
                return true
            }
        }
        return false
    }
}


