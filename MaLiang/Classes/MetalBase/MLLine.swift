//
//  MLLine.swift
//  Chrysan
//
//  Created by Harley-xk on 2019/4/24.
//

import Foundation
import CoreGraphics

/// a shot line with serveral points, base unit of line strip
public struct MLLine: Codable {
    var begin: CGPoint
    var end: CGPoint
    
    var pointSize: CGFloat
    var pointStep: CGFloat
    
    // optional color, color of line strip will be used if this sets to nil
    var color: MLColor?
    
    init(begin: CGPoint, end: CGPoint, pointSize: CGFloat, pointStep: CGFloat, color: MLColor?,
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
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case begin
        case end
        case size
        case step
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let beginInts = try container.decode([Int].self, forKey: .begin)
        let endInts = try container.decode([Int].self, forKey: .end)
        begin = CGPoint.make(from: beginInts)
        end = CGPoint.make(from: endInts)
        let intSize = try container.decode(Int.self, forKey: .size)
        pointSize = CGFloat(intSize) / 10
        let intStep = try container.decode(Int.self, forKey: .step)
        pointStep = CGFloat(intStep) / 10
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(begin.encodeToInts(), forKey: .begin)
        try container.encode(end.encodeToInts(), forKey: .end)
        try container.encode(Int(pointSize * 10), forKey: .size)
        try container.encode(Int(pointStep * 10), forKey: .step)
    }
}
