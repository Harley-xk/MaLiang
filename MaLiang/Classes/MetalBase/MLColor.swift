//
//  MLColor.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/22.
//

import Foundation
import simd
import UIKit

struct MLColor: Codable {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float
    
    static var black = MLColor(red: 0, green: 0, blue: 0, alpha: 1)
    static var white = MLColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    func toFloat4() -> vector_float4 {
        return vector_float4(red, green, blue, alpha)
    }
}

extension UIColor {
    func toMLColor(opacity: CGFloat = 1) -> MLColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return MLColor(red: Float(r), green: Float(g), blue: Float(b), alpha: Float(a * opacity))
    }
    
    func toClearColor() -> MTLClearColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return MTLClearColorMake(Double(r), Double(g), Double(b), Double(a))
    }
}
