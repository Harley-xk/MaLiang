//
//  Chartlet.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/23.
//

import Foundation

/// not implemented yet
open class Chartlet: CanvasElement {
    
    public var index: Int
    
    public var center: CGPoint
    
    public var size: CGSize
    
    public var textureID: String
//    public var texture: MLTexture
    
    /// a weak refreance to canvas
    weak var canvas: Canvas?
    
    /// draw self with printer of canvas
    public func drawSelf(on target: RenderTarget) {
        canvas?.printer.render(chartlet: self, on: target)
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
        textureID = try container.decode(String.self, forKey: .texture)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(center.encodeToInts(), forKey: .center)
        try container.encode(size.encodeToInts(), forKey: .size)
        try container.encode(textureID, forKey: .texture)
    }
}
