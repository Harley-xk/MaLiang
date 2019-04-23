//
//  Bool+Comet.swift
//  Comet
//
//  Created by Harley.xk on 2018/1/24.
//

import Foundation

public extension Bool {
    /// 将当前自身的值取反
    @available(*, deprecated, message: "Use the new method toggle() instead", renamed: "toggle()")
    mutating func reverse() {
        self = !self
    }
}
