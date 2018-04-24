//
//  MLColor.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/22.
//

import Foundation
import CoreGraphics

/// Color to render on MLView
struct MLColor: Equatable, Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
    static var `default` = MLColor(red: 0, green: 0, blue: 0, alpha: 1)
        
    var glColor: [Float] {
        return [red.float, green.float, blue.float, alpha.float]
    }
}
