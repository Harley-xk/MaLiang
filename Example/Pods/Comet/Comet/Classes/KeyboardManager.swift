//
//  KeyboardManager.swift
//  Comet
//
//  Created by Harley.xk on 16/6/28.
//
//

import Foundation
import UIKit

/**
 *  键盘管理器，用于在键盘弹出或收起时调整相应视图，以保证相关内容始终可见
 *
 *  使用方法：
 *  1、将需要始终可见的视图放置于 UIScrollView 或其子类中
 *  2、设置合适的约束
 *  3、获取全局 HKKeyboardManager，并关联对应的约束和视图
 */

open class KeyboardManager {
    
    open class var `default`: KeyboardManager {
        return defaultKeyboardManager
    }
    
    /// Set Gloable KeyboardManager to delegate keyboard events for viewController
    /// 将键盘管理器设置为指定视图控制器的代理，处理键盘事件
    ///
    /// - Parameters:
    ///   - positionConstraint: 键盘UI变化时需要调整的约束
    ///   - viewToAdjust: 键盘变化时需要调整的视图
    open func delegate(for viewController: UIViewController, positionConstraint: NSLayoutConstraint, viewToAdjust: UIView) {
        self.viewController = viewController
        self.viewToAdjust = viewToAdjust
        self.positionConstraint = positionConstraint
        self.originalConstant = positionConstraint.constant
        self.originalBottomSpace = viewBottomSpace()
        enabled = true
    }
    
    /// 在视图退出后解除代理任务
    /// 如果此时已经绑定了其它的控制器，则该方法会跳过，不会再次尝试停止代理
    open func stopDelegate(for viewController: UIViewController) {
        guard self.viewController == viewController else {
            return
        }
        self.viewController = nil
        self.viewToAdjust = nil
        self.positionConstraint = nil
        UIResponder.resignAnyFirstResponder()
        keyboardStatus = .hidden
        enabled = false
    }
    
    /**
     *  临时启用或关闭管理器
     */
    var enabled = true
    
    /**
     *  是否与键盘同时执行调整动画，默认为 YES。设置为 NO 后，将会在键盘显示之后再执行动画。
     */
    var animateAlongwithKeyboard = true
    
    private enum KeyboardStatus {
        case hidden
        case shown
        case showing
    }
    private var keyboardStatus = KeyboardStatus.hidden
    
    private weak var viewController: UIViewController?
    private weak var viewToAdjust: UIView?
    private weak var positionConstraint: NSLayoutConstraint?
    
    private var originalConstant: CGFloat = 0
    private var originalBottomSpace: CGFloat = 0
    private var currentKeyboardHeight: CGFloat = 0
    
    fileprivate init() {
        registerKeyboardEvents()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Logics
    private func registerKeyboardEvents() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func viewBottomSpace() -> CGFloat {
        guard let vc = viewController, let view = viewToAdjust else {
            return 0
        }
        var bottomOffSet: CGFloat = 0
        if let scrollView = view as? UIScrollView {
            bottomOffSet = scrollView.contentInset.bottom
            bottomOffSet = max(0, bottomOffSet)
        }
        return vc.view.frame.size.height - view.frame.size.height - view.frame.origin.y + bottomOffSet;
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard keyboardStatus == .hidden else {
            return
        }
        
        self.originalBottomSpace = viewBottomSpace();
        if (self.animateAlongwithKeyboard) {
            updateForKeyboard(withNotification: notification)
        }
        keyboardStatus = .showing
    }
    
    @objc
    private func keyboardDidShow(_ notification: Notification) {
        guard keyboardStatus == .showing else {
            return
        }
        
        updateForKeyboard(withNotification: notification)
        keyboardStatus = .shown
    }
    
    @objc
    private func keyboardWillChangeFrame(_ notification: Notification) {
        guard keyboardStatus != .hidden else {
            return
        }
        updateForKeyboard(withNotification: notification)
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        guard keyboardStatus != .hidden, let viewController = self.viewController, let positionConstraint = self.positionConstraint else {
            return
        }
        
        if (enabled) {
            let userInfo = notification.userInfo!
            let timeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let option = UIView.AnimationOptions(rawValue: UInt(truncating: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber))
            
            UIView.animate(withDuration: timeInterval, delay: 0, options:option, animations: {
                positionConstraint.constant = self.originalConstant
                viewController.view.layoutIfNeeded()
            }, completion: nil)
            currentKeyboardHeight = 0;
        }
        keyboardStatus = .hidden
    }
    
    private func updateForKeyboard(withNotification notification: Notification) {
        guard let viewController = self.viewController, let positionConstraint = self.positionConstraint, enabled else {
            return
        }
        
        let userInfo = notification.userInfo!
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let frameInView = viewController.view.convert(endFrame, from: viewController.view.window)
        var keyBoardHeight = viewController.view.frame.size.height - frameInView.origin.y
        keyBoardHeight = max(0, keyBoardHeight)
        
        let bottomSpace = self.originalBottomSpace;
        if (bottomSpace > keyBoardHeight) {
            return;
        }
        
        let offset = keyBoardHeight - bottomSpace;
        
        let timeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let option = UIView.AnimationOptions(rawValue: UInt(truncating: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber))
        
        UIView.animate(withDuration: timeInterval, delay: 0, options:option, animations: {
            positionConstraint.constant = self.originalConstant + offset
            viewController.view.layoutIfNeeded()
        }, completion: nil);
        
        self.currentKeyboardHeight = keyBoardHeight;
    }
}

fileprivate let defaultKeyboardManager = KeyboardManager()
