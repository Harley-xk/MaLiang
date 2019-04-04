//
//  MLColor.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/22.
//

import Foundation
import simd
import UIKit

typealias MLColor = vector_float4

/// Color to render on MLView
extension MLColor {
    static var black = MLColor(0, 0, 0, 1)
    static var white = MLColor(1, 1, 1, 1)
}

extension UIColor {
    func toMLColor(opacity: CGFloat = 1) -> MLColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return vector_float4(Float(r), Float(g), Float(b), Float(a * opacity))
    }
}
