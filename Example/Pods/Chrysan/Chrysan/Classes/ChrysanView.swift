//
//  ChrysanView.swift
//  Chrysan
//
//  Created by Harley on 2016/11/11.
//
//

import UIKit

public class ChrysanView: UIView {
    /// 菊花的状态，不同的状态显示不同的icon
    public enum Status {
        /// 无状态，显示纯文字
        case plain
        /// 执行中，显示菊花
        case running
        /// 进度，环形进度条
        case progress
        /// 成功，显示勾
        case succeed
        /// 错误，显示叉
        case error
        /// 自定义，显示自定义的 icon
        case custom
    }
    
    /// UI 样式配置选项，下次显示 HUD 时生效
    open var config: ChrysanConfig = .default()
    
    /// 自定义的 icon 图片
    internal var customIcon: UIImage? = nil
    
    // MARK: - APIs
    
    /// 快速显示消息提示
    ///
    /// - Parameters:
    ///   - message: 需要显示的文字提示
    ///   - delay: 自动隐藏时间，默认不隐藏
    /// - Discussion: 
    ///   标准 API 默认参数过多，无法通过代码提示完成最常用的显示消息的方法，故特地增加了这个简便方法
    public func showMessage(_ message: String, hideDelay delay: Double = 0) {
        show(message: message, hideDelay: delay)
    }
    
    /// 快速显示纯文本消息提示
    ///
    /// - Parameters:
    ///   - message: 需要显示的文字提示
    ///   - delay: 自动隐藏时间，默认不隐藏
    /// - Discussion:
    ///   标准 API 默认参数过多，无法通过代码提示完成最常用的显示消息的方法，故特地增加了这个简便方法
    public func showPlainMessage(_ message: String, hideDelay delay: Double = 0) {
        show(.plain, message: message, hideDelay: delay)
    }
    
    /// 显示菊花
    ///
    /// - Parameters:
    ///   - status: 显示的状态，默认为 running
    ///   - message: 状态说明文字，默认为 nil
    ///   - hideDelay: 一段时间后自动隐藏，单位秒，默认0，此时不会自动隐藏
    public func show(_ status: Status = .running, message: String? = nil, hideDelay delay: Double = 0) {
        
        self.status = status
        self.message = message

        updateAndShow()
        
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.hide()
            })
        }
    }
    
    
    /// 显示处理进度
    ///
    /// - Parameters:
    ///   - progress: 进度值，范围 0 - 1
    ///   - message: 状态文字，默认为nil
    ///   - progressText: 进度条圆圈内部显示的文字，默认为百分比
    public func show(progress: CGFloat, message: String? = nil, progressText: String? = nil) {
        self.progress = progress
        self.progressText = progressText
        show(.progress, message: message, hideDelay: 0)
    }
    private var progressText: String?
    
    /// 显示自定义图标
    ///
    /// - Parameters:
    ///   - customIcon: 自定义图标，会被转换为 Template 模式
    ///   - message: 状态文字，默认为 nil
    ///   - delay: 一段时间后自动隐藏，单位秒，默认0，此时不会自动隐藏
    public func show(customIcon: UIImage, message: String? = nil, hideDelay delay: Double = 0) {
        self.customIcon = customIcon
        show(.custom, message: message, hideDelay: delay)
    }
    
    public func hide() {
        hideHUD()
    }
    
    // MARK: - Private
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var hudView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var progressView: RingProgressView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    @IBOutlet weak var positionX: NSLayoutConstraint!
    @IBOutlet weak var positionY: NSLayoutConstraint!
    @IBOutlet weak var labelSpace: NSLayoutConstraint!
    @IBOutlet weak var messageMinWidth: NSLayoutConstraint!
    @IBOutlet weak var messageToTop: NSLayoutConstraint!
    
    private var isShown = false
    
    weak private var parent: UIView!
    private var status: Status = .plain
    private var message: String?
    private var progress: CGFloat = 0

    internal class func chrysan(withView parent: UIView) -> ChrysanView? {
        
        if let views = bundle.loadNibNamed("Chrysan", owner: nil, options: nil) as? [ChrysanView], views.count > 0 {
            let chrysan = views[0]
            chrysan.setup(withView: parent)
            return chrysan
        }
        return nil
    }
    
    private class var bundle: Bundle {
        
        var bundle: Bundle = Bundle.main
        let framework = Bundle(for: ChrysanView.classForCoder())
        if let resource = framework.path(forResource: "Chrysan", ofType: "bundle") {
            bundle = Bundle(path: resource) ?? Bundle.main
        }
        
        return bundle
    }
    
    private func setup(withView view: UIView) {
        view.addSubview(self)

        parent = view
        pinEdgesToParent()
        isHidden = true
        
        hudView.layer.cornerRadius = 8
        hudView.clipsToBounds = true
    }
    
    private func pinEdgesToParent() {
        
        self.translatesAutoresizingMaskIntoConstraints = false;

        let top = pinToParent(withEdge: .top)
        let bottom = pinToParent(withEdge: .bottom)
        let left = pinToParent(withEdge: .leading)
        let right = pinToParent(withEdge: .trailing)
        
        parent.addConstraints([top, bottom, left, right])
        
        DispatchQueue.main.async {
            self.parent.layoutIfNeeded()
        }
    }
    
    private func pinToParent(withEdge edge: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: parent!, attribute: edge, relatedBy: .equal, toItem: self, attribute: edge, multiplier: 1, constant: 0)
    }
    
    private func updateAndShow() {
        
        if iconView.isAnimating {
            iconView.stopAnimating()
            iconView.animationImages = nil
        }

        messageLabel.text = message;
        updateMessageTextAlignment()
        
        positionX.constant = config.offsetX
        positionY.constant = config.offsetY
        
        backgroundView.backgroundColor = config.maskColor

        effectView.effect = UIBlurEffect(style: config.hudStyle)

        iconView.tintColor = config.color
        activityView.tintColor = config.color
        progressView.tintColor = config.color
        messageLabel.textColor = config.color
        
        if message != nil && !message!.isEmpty{
            labelSpace.constant = 8
            messageMinWidth.constant = 70
        }else {
            labelSpace.constant = 4
            messageMinWidth.constant = 50
        }
        
        messageToTop.constant = 64
        activityView.isHidden = true
        progressView.isHidden = true
        iconView.isHidden = true
        
        switch status {
        case .plain:
            messageToTop.constant = 16
        case .running:
            setupActivityViewForRunning()
        case .progress:
            progressView.isHidden = false
            progressView.setProgress(progress, text: progressText)
        case .succeed:
            iconView.isHidden = false
            iconView.image = image(name: "check")
        case .error:
            iconView.isHidden = false
            iconView.image = image(name: "cross")
        case .custom:
            iconView.isHidden = false
            iconView.image = customIcon
        }
        
        layoutIfNeeded()
        showHUD()
    }
    
    private func setupActivityViewForRunning() {
        if let activityStyle = config.chrysanStyle.activityStyle {
            activityView.isHidden = false
            activityView.style = activityStyle
        } else if case let .animationImages(images) = config.chrysanStyle {
            activityView.isHidden = true
            iconView.isHidden = false
            iconView.animationImages = images
            iconView.animationDuration = Double(images.count) * config.frameDuration
            iconView.startAnimating()
        } else {
            // do nothing
        }
    }
    
    private func updateMessageTextAlignment() {
        if status == .plain {
            messageLabel.textAlignment = .left
        }else {
            messageLabel.textAlignment = .center
        }
    }
    
    private func image(name: String) -> UIImage? {
        return UIImage(named: "chrysan_\(name).png", in: ChrysanView.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
    
    private func showHUD() {
        
        if isShown {
            return
        }
        
        isShown = true
        isHidden = false
        alpha = 0
        parent.bringSubviewToFront(self)
        parent.layoutIfNeeded()
        layer.removeAllAnimations()

        UIView.animate(withDuration: 0.15) {
            self.alpha = 1
        }
    }
    
    private func hideHUD() {
        if !isShown {
            return
        }
        
        isShown = false
        
        layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
        }) { (finished) in
            if finished {
                self.isHidden = true
                self.reset()
            }
        }
    }
    
    private func reset() {
        iconView.image = nil
        customIcon = nil
        message = nil
        progress = 0
        progressView.setProgress(0)
        iconView.animationImages = nil
        iconView.stopAnimating()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
