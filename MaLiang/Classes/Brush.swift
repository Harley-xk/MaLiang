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
    
    init(texture: MTLTexture?, target: Canvas) {
        self.texture = texture
        self.target = target
        self.updatePointPipeline()
    }
    
    /// use this brush to draw
    open func use() {
        target?.currentBrush = self
    }
    
    open func line(from: CGPoint, to: CGPoint) -> MLLine {
        let color = self.color.mlcolorWith(opacity: opacity)
        return MLLine(begin: from, end: to, pointSize: pointSize, pointStep: pointStep, color: color)
    }
    
    open func pan(from: Pan, to: Pan) -> MLLine {
        let color = self.color.mlcolorWith(opacity: opacity)
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
        let fragment_func = library?.makeFunction(name: "fragment_point_func")
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = vertex_func
        rpd.fragmentFunction = fragment_func
        rpd.colorAttachments[0].pixelFormat = target.metalLayer.pixelFormat
        rpd.colorAttachments[0].isBlendingEnabled = true
        rpd.colorAttachments[0].alphaBlendOperation = .add
        rpd.colorAttachments[0].rgbBlendOperation = .add
        rpd.colorAttachments[0].sourceRGBBlendFactor = .one
        rpd.colorAttachments[0].sourceAlphaBlendFactor = .one
        rpd.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        rpd.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineState = try! device.makeRenderPipelineState(descriptor: rpd)
    }

    open func renderLine(_ line: MLLine) {
        
        guard let target = target, let device = target.device else {
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
        var start = line.begin
//        start.x *= scale
//        start.y *= scale
        var end = line.end
//        end.x *= scale
//        end.y *= scale
        
        // Allocate vertex array buffer
        var vertexBuffer: [Point] = []
        
        // Add points to the buffer so there are drawing points every X pixels
        let count = max(Int(ceilf(sqrtf((end.x - start.x).float * (end.x - start.x).float + (end.y - start.y).float * (end.y - start.y).float) / (line.pointStep.float)) * target.zoomScale.float) + 1, 1)

        for i in 0 ..< count {
            let x = start.x.float + (end.x - start.x).float * (i.float / count.float)
            let y = start.y.float + (end.y - start.y).float * (i.float / count.float)
            vertexBuffer.append(Point(x: x, y: y, size: Float(line.pointSize * scale)))
        }
        
        if let vertex_buffer = device.makeBuffer(bytes: vertexBuffer, length: MemoryLayout<Point>.stride * count, options: .cpuCacheModeWriteCombined) {
            commandEncoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            commandEncoder?.setVertexBuffer(target.uniform_buffer, offset: 0, index: 1)
            commandEncoder?.setFragmentTexture(texture, index: 0)
            commandEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 1)
        }
        
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
    }
    
}

public final class Eraser: Brush {
    
    /// only a global eraser needed
//    public static let global = Eraser()
    
//    private init() {
//        super.init(texture: nil, target: nil)
//        pointSize = 10
//        opacity = 1
//        forceSensitive = 0
//    }
    
    // color of eraser can't be changed
    override public var color: UIColor {
        get {
            return .clear
        }
        set {
            // set color of eraser will do nothing
        }
    }
}
