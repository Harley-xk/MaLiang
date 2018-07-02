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
    public var color: MLColor
    
    init(begin: CGPoint, end: CGPoint, pointSize: CGFloat, pointStep: CGFloat, color: MLColor) {
        self.begin = begin
        self.end = end
        self.pointSize = pointSize
        self.pointStep = pointStep
        self.color = color
    }
}
