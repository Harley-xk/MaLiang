//
//  ChrysanConfig.swift
//  Chrysan
//
//  Created by Harley.xk on 2018/5/11.
//

import Foundation

public enum ChrysanStyle {
    case whiteLargeIndicator
    case whiteIndicator
    case grayIndicator
    case animationImages([UIImage])
    
    var activityStyle: UIActivityIndicatorView.Style? {
        switch self {
        case .whiteLargeIndicator: return .whiteLarge
        case .whiteIndicator: return .white
        case .grayIndicator: return .gray
        default: return nil
        }
    }
}

/// HUD 配置选项，决定 HUD 的显示样式
public class ChrysanConfig {
    
    /// 菊花在视图中水平方向上的偏移，默认为正中
    public var offsetX: CGFloat = 0
    /// 菊花在视图中竖直方向上的偏移，默认为正中
    public var offsetY: CGFloat = 0
    
    /// 遮罩颜色，遮挡 UI 的视图层的颜色，默认透明
    public var maskColor = UIColor.clear
    
    /// 菊花背景样式，使用系统自带的毛玻璃特效，默认为黑色样式
    public var hudStyle = UIBlurEffect.Style.dark
    
    /// 菊花的样式，默认为 white large
    public var chrysanStyle: ChrysanStyle = ChrysanStyle.whiteLargeIndicator
    
    /// 播放动画时每一帧的时间间隔，默认 0.05，只有当 activityStyle == animationImages 时生效
    public var frameDuration: TimeInterval = 0.05
    
    /// icon 及文字颜色，默认为白色
    public var color = UIColor.white
    
    /// 配置的名称，用来在多个配置间做区分，没有实际意义
    public var name: String?

    /// 全局默认配置
    public class func `default`() -> ChrysanConfig {
        return _default
    }
    
    private static var _default = ChrysanConfig(name: "Default")
    
    public init(name: String? = nil) {
        self.name = name
    }
}
