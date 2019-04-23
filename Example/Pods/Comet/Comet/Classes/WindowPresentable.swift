//
//  WindowPresentable.swift
//  Common UI
//
//  Created by Harley.xk on 2017/4/27.
//  Copyright © 2017年 Harley-xk. All rights reserved.
//

import UIKit

public enum WindowPresentableAnimation {
    case transform
    case fade
    /// 自定义动画效果，需要在动画结束后触发回调，用于某些善后工作的处理
    /// - Attention: 注意，如果使用自定义的动画，completion 回调不会再触发，需要自己处理动画结束后的事务
    case custom((EmptyHandler?) -> ())
    case none
}

public protocol WindowPresentable: class {
    var window: UIWindow? { get set }
    var windowRoot: UIViewController { get }
    var animationDuration: TimeInterval { get }
}

/// 全局变量，保存当前所有已弹出 Window 的 Level
var GloableWindowLevels = [UIWindow.Level.normal]

extension WindowPresentable where Self: UIViewController {
    
    // MARK: - Show Hide
    public func showWindow(animation: WindowPresentableAnimation = .transform, completion: EmptyHandler? = nil) {
        let screenFrame = UIScreen.main.bounds
        
        if self.window == nil {
            self.window = UIWindow(frame: screenFrame)
        }
        let window = self.window!
        
        window.windowLevel = windowLevel
        
        window.rootViewController = self.windowRoot
        window.makeKeyAndVisible()
        
        GloableWindowLevels.append(window.windowLevel)
        
        if case .transform = animation {
            let endFrame = window.frame
            var beginFrame = screenFrame
            beginFrame.origin.y = beginFrame.size.height
            beginFrame.size = window.frame.size
            window.frame = beginFrame
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                window.frame = endFrame
            }, completion: { (finished) in
                completion?()
            })
        } else if case .fade = animation {
            window.alpha = 0
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                window.alpha = 1
            }, completion: { (finished) in
                completion?()
            })
        } else if case let .custom(ani) = animation {
            ani(nil)
        } else {
            completion?()
        }
    }
    
    public func hideWindow(animation: WindowPresentableAnimation = .fade, completion: (() -> Void)? = nil) {
        
        guard let window = self.window else {
            return
        }
        
        let block = {
            self.window?.rootViewController = nil
            self.window?.resignKey()
            self.setNeedsStatusBarAppearanceUpdate()
            self.window = nil
            GloableWindowLevels.removeLast()
        }
        
        if case .transform = animation {
            var endFrame = UIScreen.main.bounds
            endFrame.origin.y = endFrame.size.height
            endFrame.size = window.frame.size
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                window.frame = endFrame
            }, completion: { (finished) in
                block()
                completion?()
            })
        } else if case .fade = animation {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                window.alpha = 0
            }, completion: { (finished) in
                block()
                completion?()
            })
        }  else if case let .custom(ani) = animation {
            ani(block)
        } else {
            block()
            completion?()
        }
    }
    
    public var windowRoot: UIViewController {
        return self
    }
    
    public var animationDuration: TimeInterval {
        return 0.2
    }
    
    var windowLevel: UIWindow.Level {
        if let level = GloableWindowLevels.last {
            return level + 1
        }
        return .normal + 1
    }
}
