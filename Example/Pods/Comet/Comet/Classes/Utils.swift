//
//  Utils.swift
//  Comet
//
//  Created by Harley.xk on 16/6/27.
//
//

import Foundation
import UIKit

/// 定义一个空函数的别名，方便使用
public typealias EmptyHandler = () -> ()

open class Utils {
    
    /// 系统版本号
    open class var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /// App Bundle Identifier
    open class var bundleIdentifier: String {
        let infoDictionary = Bundle.main.infoDictionary!
        return infoDictionary["CFBundleIdentifier"] as! String
    }
    
    /// App 版本号
    open class var appVersion: String {
        let infoDictionary = Bundle.main.infoDictionary!
        return infoDictionary["CFBundleShortVersionString"] as! String
    }

    /// App Build 号
    open class var appBuild: String {
        let infoDictionary = Bundle.main.infoDictionary!
        return infoDictionary["CFBundleVersion"] as! String
    }
    
    /// 设备唯一标识号
    open class var deviceUUID: String {
        return UIDevice.current.identifierForVendor!.uuidString
    }

    /// 设备型号
    ///
    /// @return iPhone 1,2 etc...
    open class var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// 电话呼叫
    ///
    /// - Parameters:
    ///   - phone: 被叫方的电话号码
    ///   - immediately: 是否跳过确认提示
    /// - Return: 不支持电话功能时返回 false
    @discardableResult open class func call(_ phone: String, immediately: Bool = false) -> Bool {
        let typeString = immediately ? "tel" : "telprompt"
        if let callURL = URL(string: typeString + "://" + phone),
            UIApplication.shared.canOpenURL(callURL) {
            UIApplication.shared.openURL(callURL)
            return true
        }
        return false
    }

}


