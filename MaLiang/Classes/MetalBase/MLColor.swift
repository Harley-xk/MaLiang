//
//  MLColor.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/22.
//

import Foundation
import simd
import UIKit

public struct MLColor: Codable {
    public internal(set) var red: Float
    public internal(set) var green: Float
    public internal(set) var blue: Float
    public internal(set) var alpha: Float
    
    public static var black = UIColor.black.toMLColor()
    public static var white = UIColor.white.toMLColor()
    
    public func toFloat4() -> vector_float4 {
        return vector_float4(red, green, blue, alpha)
    }
    
    public init(red: Float, green: Float, blue: Float, alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    // MARK: - Single value codable for MLColor
    
    // hex string must be saved as format of: ffffffff
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        var int = UInt32()
        Scanner(string: hexString).scanHexInt32(&int)
        let a, r, g, b: UInt32
        (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        (alpha, red, green, blue) = (Float(a) / 255.0, Float(r) / 255.0, Float(g) / 255.0, Float(b) / 255.0)
    }
    
    // hex string must be saved as format of: AARRGGBB
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let reds = red < 0 ? 0 : red
        let greens = green < 0 ? 0 : green
        let blues = blue < 0 ? 0 : blue
        let aInt = Int(alpha * 255) << 24
        let rInt = Int(reds * 255) << 16
        let gInt = Int(greens * 255) << 8
        let bInt = Int(blues * 255)
        let argb = aInt | rInt | gInt | bInt
        let hex = String(format:"%08x", argb)
        try container.encode(hex)
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
