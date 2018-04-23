//
//  MLLine.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/12.
//

import Foundation
import CoreGraphics

struct MLLine {
    var begin: CGPoint
    var end: CGPoint
    
    var pointSize: CGFloat
    var color: MLColor
    
    init(begin: CGPoint, end: CGPoint, pointSize: CGFloat, color: MLColor) {
        self.begin = begin
        self.end = end
        self.pointSize = pointSize
        self.color = color
    }
    
    init(begin: CGPoint, end: CGPoint, pencil: MLPencil) {
        self.init(begin: begin, end: end, pointSize: pencil.pointSize, color: pencil.mlColor)
    }
}
