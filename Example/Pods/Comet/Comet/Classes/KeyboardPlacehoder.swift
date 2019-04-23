//
//  KeyboardPlacehoderView.swift
//  Comet
//
//  Created by Harley-xk on 2019/3/4.
//

import UIKit

/**
 *  键盘占位器，在键盘弹出时调整自身尺寸，保证与键盘在父试图中的投影同步
 */

open class KeyboardPlacehoder: UIView {
    
    /// 代理对象, 用来接收键盘动画事件，用于处理某些需要与键盘同步响应的效果
    public typealias DelegatingTarget = (AnyObject & KeyboardManagerDelegatingTarget)
    public var delegate: DelegatingTarget?
    
    /**
     *  临时启用或关闭管理器
     */
    public var enabled = true
    
    
    // MARK: - Private Logics
    private var heightConstraint: NSLayoutConstraint!
    private var keyboardStatus = KeyboardManager.KeyboardStatus.hidden
    private var currentKeyboardHeight: CGFloat = 0
    
    private func registerKeyboardEvents() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard keyboardStatus == .hidden else {
            return
        }
        
        keyboardStatus = .showing
        updateForKeyboard(withNotification: notification)
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        guard keyboardStatus == .showing else {
            return
        }
        
        keyboardStatus = .shown
        updateForKeyboard(withNotification: notification)
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        guard keyboardStatus == .hidding else {
            return
        }
        keyboardStatus = .hidden
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard keyboardStatus == .shown else {
            return
        }
        updateForKeyboard(withNotification: notification)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard keyboardStatus != .hidden, currentKeyboardHeight > 0 else {
            return
        }
        keyboardStatus = .hidding
        
        guard enabled else {
            return
        }
        
        let userInfo = notification.userInfo!
        let timeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let option = UIView.AnimationOptions(rawValue: UInt(truncating: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber))
        
        let keyboardChangedHeight = currentKeyboardHeight
        currentKeyboardHeight = 0;

        // 异步执行动画，防止把其他的系统动画框到同一个动画 context 中来
        DispatchQueue.main.async {
            UIView.animate(withDuration: timeInterval, delay: 0, options:option, animations: {
                self.heightConstraint.constant = 0
                self.delegate?.animationsAlongsidesKeyboardFrame(keyboardStatus: self.keyboardStatus, offset: keyboardChangedHeight, notification: notification)
                self.rootView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private func updateForKeyboard(withNotification notification: Notification) {
        guard enabled, let superview = superview else {
            return
        }
        
        let userInfo = notification.userInfo!
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let frameInView = superview.convert(endFrame, from: superview.window)
        let superViewHeight = superview.bounds.height
        let bottomOffset = max(0, superViewHeight - (frameInView.origin.y + frameInView.size.height))
        let bottomInset = max(0, superViewHeight - (frame.origin.y + frame.size.height))
        var keyBoardHeight = superViewHeight - frameInView.origin.y - bottomOffset - bottomInset
        keyBoardHeight = max(0, keyBoardHeight)
        
        let timeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let option = UIView.AnimationOptions(rawValue: UInt(truncating: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber))
        
        let keyboardChangedHeight = keyBoardHeight - currentKeyboardHeight
        currentKeyboardHeight = keyBoardHeight;

        // 异步执行动画，防止把其他的系统动画框到同一个动画 context 中来
        DispatchQueue.main.async {
            UIView.animate(withDuration: timeInterval, delay: 0, options:option, animations: {
                self.delegate?.animationsAlongsidesKeyboardFrame(keyboardStatus: self.keyboardStatus, offset: keyboardChangedHeight, notification: notification)
                self.heightConstraint.constant = keyBoardHeight
                self.rootView.layoutIfNeeded()
            }, completion: nil);
        }
    }
    
    // MARK: - On Enter
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        addConstraint(heightConstraint)
        registerKeyboardEvents()
    }
    
    private var rootView: UIView {
        var father: UIView = self
        while let view = father.superview {
            father = view
        }
        return father
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
