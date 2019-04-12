//
//  MLLine.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/12.
//

import Foundation
import CoreGraphics

public struct MLLine: Codable {
    var begin: CGPoint
    var end: CGPoint
    
    var pointSize: CGFloat
    var pointStep: CGFloat
    var color: MLColor

    init(begin: CGPoint, end: CGPoint, pointSize: CGFloat, pointStep: CGFloat, color: MLColor,
         scaleFactor: CGFloat = 1, offset: CGPoint) {
        self.begin = (begin + offset) / scaleFactor
        self.end = (end + offset) / scaleFactor
        self.pointSize = pointSize / scaleFactor
        self.pointStep = pointStep / (scaleFactor)
        self.color = color
    }
    
    var length: CGFloat {
        return begin.distance(to: end)
    }
}

