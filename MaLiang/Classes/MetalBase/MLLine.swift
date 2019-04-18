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

///  一条线段，保存了轨迹信息和画笔信息
open class MLLineStrip {
    
    /// 绘制这条线段所使用的画笔
    open var brush: Brush
    
    /// 组成线段的直线
    open private(set) var lines: [MLLine]
    
    init(lines: [MLLine], brush: Brush) {
        self.lines = lines
        self.brush = brush
        remakBuffer()
    }
    
    open func append(lines: [MLLine]) {
        self.lines.append(contentsOf: lines)
        vertex_buffer = nil
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
    
    internal func drawSelf(on target: RenderTarget) {
        brush.render(lineStrip: self, on: target)
    }
}
