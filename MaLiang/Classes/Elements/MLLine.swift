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
    public internal(set) var begin: CGPoint
    public internal(set) var end: CGPoint
    
    public internal(set) var pointSize: CGFloat
    public internal(set) var pointStep: CGFloat
    
    // optional color, color of line strip will be used if this sets to nil
    public internal(set) var color: MLColor?
    
    public init(begin: CGPoint, end: CGPoint, pointSize: CGFloat, pointStep: CGFloat, color: MLColor?) {
        self.begin = begin
        self.end = end
        self.pointSize = pointSize
        self.pointStep = pointStep
        self.color = color
    }
    
    public var length: CGFloat {
        return begin.distance(to: end)
    }
    
    public var angle: CGFloat {
        return end.angel(to: begin)
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case begin
        case end
        case size
        case step
        case color
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
        color = try? container.decode(MLColor.self, forKey: .color)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(begin.encodeToInts(), forKey: .begin)
        try container.encode(end.encodeToInts(), forKey: .end)
        try container.encode(Int(pointSize * 10), forKey: .size)
        try container.encode(Int(pointStep * 10), forKey: .step)
        if let color = self.color {
            try container.encode(color, forKey: .color)
        }
    }
}
