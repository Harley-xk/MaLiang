//
//  Numbers+Comet.swift
//  Comet
//
//  Created by Harley.xk on 2017/8/18.
//

import Foundation

// Convert String to Numbers
public extension String {
    
    // convert string to int
    // returns 0 if failed
    var intValue: Int {
        return Int(self) ?? 0
    }
    
    // convert string to double
    // returns 0 if failed
    var doubleValue: Double {
        return Double(self) ?? 0
    }
    
    // convert string to float
    // returns 0 if failed
    var floatValue: Float {
        return Float(self) ?? 0
    }
}

// Convert Float to String
public extension Float {
    
    // 返回指定小数位数的字符串
    func string(decimals: Int = 0) -> String {
        return String(format: "%.\(decimals)f", self)
    }
    
    // 返回指定格式的字符串
    func string(format: String?) -> String {
        if let format = format {
            return String(format: format, self)
        } else {
            return string(decimals: 0)
        }
    }
}

// Convert Double to String
public extension Double {
    // 返回指定小数位数的字符串
    func string(decimals: Int = 0) -> String {
        return String(format: "%.\(decimals)f", self)
    }
    // 返回指定格式的字符串
    func string(format: String?) -> String {
        if let format = format {
            return String(format: format, self)
        } else {
            return string(decimals: 0)
        }
    }
}

public extension Int {
    
    // 返回指定格式的字符串
    func string(format: String? = nil) -> String {
        if let format = format {
            return String(format: format, self)
        } else {
            return "\(self)"
        }
    }
    
    // random number from min to max
    static func random(min: Int = 0, max: Int) -> Int {
        let random = Int(arc4random())
        let number = random % (max + 1 - min) + min
        return number
    }
    
    /// 返回当前值是否是偶数
    var isEven: Bool {
        return self % 2 == 0
    }
}
