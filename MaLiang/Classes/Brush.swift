//
//  Brush.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/6.
//

import Foundation
import MetalKit
import UIKit

public struct Pan {
    var point: CGPoint
    var force: CGFloat
}

open class Brush {
    
    // automatically set by canvas after being registered to
    public internal(set) var identifier: UUID?
        
    // opacity of texture, affects the darkness of stroke
    // set opacity to 1 may cause heavy aliasing
    open var opacity: CGFloat = 0.3
    
    // width of stroke line in points
    open var pointSize: CGFloat = 4

    // this property defines the minimum distance (measureed in points) of nearest two textures
    // defaults to 1, this means erery texture calculated will be rendered, dictance calculation will be skiped
    open var pointStep: CGFloat = 1
    
    // sensitive of pointsize changed from force, from 0 - 1
    open var forceSensitive: CGFloat = 0
    
    /// color of stroke
    open var color: UIColor = .black
    
    /// interal texture
    var texture: MTLTexture?

    /// target to draw
    weak var target: Canvas?
    
    init(texture: MTLTexture? = nil, target: Canvas) {
        self.texture = texture
        self.target = target
        self.updatePointPipeline()
    }
    
    /// use this brush to draw
    open func use() {
        target?.currentBrush = self
    }
    
    open func line(from: CGPoint, to: CGPoint) -> MLLine {
        let color = self.color.toMLColor(opacity: opacity)
        return MLLine(begin: from, end: to, pointSize: pointSize, pointStep: pointStep, color: color)
    }
    
    open func pan(from: Pan, to: Pan) -> MLLine {
        let color = self.color.toMLColor(opacity: opacity)
        var endForce = from.force * 0.95 + to.force * 0.05
        endForce = pow(endForce, forceSensitive)
        let line = MLLine(begin: from.point, end: to.point, pointSize: pointSize * endForce, pointStep: pointStep, color: color)
        return line
    }
    
    // MARK: - Render Actions
    private var pipelineState: MTLRenderPipelineState!
    
    private func updatePointPipeline() {
        
        guard let target = target, let device = target.device else {
            return
        }
        
        let library = device.makeDefaultLibrary()
        let vertex_func = library?.makeFunction(name: "vertex_point_func")
        let fragment_func = library?.makeFunction(name: texture == nil ? "fragment_point_func_without_texture" : "fragment_point_func")
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = vertex_func
        rpd.fragmentFunction = fragment_func
        rpd.colorAttachments[0].pixelFormat = target.metalLayer.pixelFormat
        setupBlendOptions(for: rpd.colorAttachments[0]!)
        pipelineState = try! device.makeRenderPipelineState(descriptor: rpd)
    }
    
    
    /// Blending options for this brush, override to implement your own blending options
    open func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true
        attachment.alphaBlendOperation = .add
        attachment.rgbBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.sourceAlphaBlendFactor = .one
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }

    open func render(lines: [MLLine]) {
        
        guard lines.count > 0, let target = target, let device = target.device else {
            return
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor.colorAttachments[0]
        attachment?.texture = target.renderTarget
        attachment?.loadAction = .load
        attachment?.storeAction = .store
        
        let commandQueue = device.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        
        // Convert locations from Points to Pixels
        let scale = target.contentScaleFactor
        
        // Allocate vertex array buffer
        var vertexes: [Point] = []
        
        lines.forEach { (line) in
            let start = line.begin; let end = line.end
            let count = max(line.length / line.pointStep, 1) * scale
            for i in 0 ..< Int(count) {
                let index = CGFloat(i)
                let x = start.x + (end.x - start.x) * (index / count)
                let y = start.y + (end.y - start.y) * (index / count)
                vertexes.append(Point(x: x, y: y, color: line.color, size: line.pointSize * scale))
            }
        }
        
        
        if let vertex_buffer = device.makeBuffer(bytes: vertexes, length: MemoryLayout<Point>.stride * vertexes.count, options: .cpuCacheModeWriteCombined) {
            commandEncoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            commandEncoder?.setVertexBuffer(target.uniform_buffer, offset: 0, index: 1)
            if let texture = texture {
                commandEncoder?.setFragmentTexture(texture, index: 0)
            }
            commandEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertexes.count)
        }
        
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
    }
    
}
