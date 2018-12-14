//
//  MLColor.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/22.
//

import Foundation
import CoreGraphics

/// Color to render on MLView
public struct MLColor: Equatable, Codable {
    public var red: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat
    
    public static var `default` = MLColor(red: 0, green: 0, blue: 0, alpha: 1)
        
    public var glColor: [Float] {
        return [red.float, green.float, blue.float, alpha.float]
    }
}
