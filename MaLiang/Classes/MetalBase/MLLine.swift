//
//  MLLine.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/12.
//

import Foundation
import CoreGraphics

/// a shot line with serveral points, base unit of line strip
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

/// a line strip with lines and brush info
open class LineStrip: CanvasElement {
    
    /// element index
    public var index: Int = 0
    
    /// identifier of bursh used to render this line strip
    public var brushIdentifier: String?
    
    /// line units of this line strip
    open private(set) var lines: [MLLine] = []
    
    /// brush used to render this line strip
    open internal(set) weak var brush: Brush? {
        didSet {
            brushIdentifier = brush?.identifier
        }
    }
    
    init(lines: [MLLine], brush: Brush) {
        self.lines = lines
        self.brush = brush
        self.brushIdentifier = brush.identifier
        remakBuffer()
    }
    
    open func append(lines: [MLLine]) {
        self.lines.append(contentsOf: lines)
        vertex_buffer = nil
    }
    
    public func drawSelf(on target: RenderTarget) {
        brush?.render(lineStrip: self, on: target)
    }
    
    /// get vertex buffer for this line strip, remake if not exists
    open func retrieveBuffers() -> MTLBuffer? {
        if vertex_buffer == nil {
            remakBuffer()
        }
        return vertex_buffer
    }
    
    /// count of vertexes, set when remake buffers
    open private(set) var vertexCount: Int = 0
    
    private var vertex_buffer: MTLBuffer?
    
    private func remakBuffer() {
        
        guard lines.count > 0 else {
            return
        }
        
        var vertexes: [Point] = []
        
        lines.forEach { (line) in
            let scale = UIScreen.main.scale
            var line = line
            line.begin = line.begin * scale
            line.end = line.end * scale
            let count = max(line.length / line.pointStep, 1)
            for i in 0 ..< Int(count) {
                let index = CGFloat(i)
                let x = line.begin.x + (line.end.x - line.begin.x) * (index / count)
                let y = line.begin.y + (line.end.y - line.begin.y) * (index / count)
                vertexes.append(Point(x: x, y: y, color: line.color, size: line.pointSize * scale))
            }
        }
        
        vertexCount = vertexes.count
        vertex_buffer = sharedDevice?.makeBuffer(bytes: vertexes, length: MemoryLayout<Point>.stride * vertexCount, options: .cpuCacheModeWriteCombined)
    }
    
    // MARK: - Coding

    enum CodingKeys: String, CodingKey {
        case index
        case brushIdentifier
        case lines
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = try container.decode(Int.self, forKey: .index)
        brushIdentifier = try container.decode(String.self, forKey: .brushIdentifier)
        lines = try container.decode([MLLine].self, forKey: .lines)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(brushIdentifier, forKey: .brushIdentifier)
        try container.encode(lines, forKey: .lines)
    }
}
