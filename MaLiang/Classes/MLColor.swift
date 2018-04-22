//
//  MLColor.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/22.
//

import Foundation

/// Color to render on MLView
struct MLColor: Equatable {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float
    
    static var `default` = MLColor(red: 0, green: 0, blue: 0, alpha: 1)
        
    var glColor: [Float] {
        return [red, green, blue, alpha]
    }
}
