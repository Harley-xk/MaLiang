//
//  Chartlet.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/23.
//

import Foundation
import CoreGraphics
import Metal

/// not implemented yet
open class Chartlet: CanvasElement {
    
    public var index: Int = 0
    
    public var center: CGPoint
    
    public var size: CGSize
    
    public var textureID: UUID
//    public var texture: MLTexture
    
    /// a weak refreance to canvas
    weak var canvas: Canvas?
    
    init(center: CGPoint, size: CGSize, textureID: UUID, canvas: Canvas) {
        let offset = canvas.contentOffset
        let scale = canvas.scale
        self.canvas = canvas
        self.center = (center + offset) / scale
        self.size = size / scale
        self.textureID = textureID
    }
    
    /// draw self with printer of canvas
    public func drawSelf(on target: RenderTarget) {
        canvas?.printer.render(chartlet: self, on: target)
    }
    
    /// get vertex buffer for this line strip, remake if not exists
    open func retrieveBuffers() -> MTLBuffer? {
        if vertex_buffer == nil {
            remakBuffer()
        }
        return vertex_buffer
    }
    
    private var vertex_buffer: MTLBuffer?
    
    private func remakBuffer() {
        
        let scale = canvas?.printer.target?.contentScaleFactor ?? UIScreen.main.nativeScale

        let center = self.center * scale
        let halfSize = self.size * scale * 0.5
        
        let vertexes = [
            Vertex(position: CGPoint(x: center.x - halfSize.width, y: center.y - halfSize.height), textCoord: CGPoint(x: 0, y: 0)),
            Vertex(position: CGPoint(x: center.x + halfSize.width , y: center.y - halfSize.height), textCoord: CGPoint(x: 1, y: 0)),
            Vertex(position: CGPoint(x: center.x - halfSize.width , y: center.y + halfSize.height), textCoord: CGPoint(x: 0, y: 1)),
            Vertex(position: CGPoint(x: center.x + halfSize.width , y: center.y + halfSize.height), textCoord: CGPoint(x: 1, y: 1)),
        ]
        vertex_buffer = sharedDevice?.makeBuffer(bytes: vertexes, length: MemoryLayout<Vertex>.stride * 4, options: .cpuCacheModeWriteCombined)
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case index
        case center
        case size
        case texture
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = try container.decode(Int.self, forKey: .index)
        let centerInts = try container.decode([Int].self, forKey: .center)
        center = CGPoint.make(from: centerInts)
        let sizeInts = try container.decode([Int].self, forKey: .size)
        size = CGSize.make(from: sizeInts)
        textureID = try container.decode(UUID.self, forKey: .texture)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(center.encodeToInts(), forKey: .center)
        try container.encode(size.encodeToInts(), forKey: .size)
        try container.encode(textureID, forKey: .texture)
    }
}
