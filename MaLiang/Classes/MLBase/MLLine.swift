//
//  MLLine.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/12.
//

import Foundation
import CoreGraphics

public struct MLLine: Codable {
    public var begin: CGPoint
    public var end: CGPoint
    
    public var pointSize: CGFloat
    public var pointStep: CGFloat
    public var color: MLColor
    
    public init(begin: CGPoint, end: CGPoint, pointSize: CGFloat, pointStep: CGFloat, color: MLColor) {
        self.begin = begin
        self.end = end
        self.pointSize = pointSize
        self.pointStep = pointStep
        self.color = color
    }
}
