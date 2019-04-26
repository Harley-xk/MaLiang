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
    
    // unique identifier for a specifyed brush, should not be changed over all your apps
    // make this value uniform when saving or reading canvas content from a file
    open internal(set) var name: String
    
    /// interal texture
    open private(set) var textureID: UUID?
    
    /// target to draw
    open private(set) weak var target: Canvas?

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
    
    // designed initializer, will be called by target when reigster called
    // identifier is not necessary if you won't save the content of your canvas to file
    required public init(name: String?, textureID: UUID?, target: Canvas) {
        self.name = name ?? UUID().uuidString
        self.target = target
        self.textureID = textureID
        if let id = textureID {
            texture = target.findTexture(by: id)?.texture
        }
        updatePointPipeline()
    }
    
    /// use this brush to draw
    open func use() {
        target?.currentBrush = self
    }
    
    /// get a line with specified begin and end location
    open func line(from: CGPoint, to: CGPoint) -> MLLine {
        let color = self.color.toMLColor(opacity: opacity)        
        let line = MLLine(begin: from, end: to, pointSize: pointSize,
                          pointStep: pointStep, color: color,
                          scaleFactor: target?.screenTarget.scale ?? 1,
                          offset: target?.screenTarget.contentOffset ?? .zero)
        return line
    }
    
    /// get a line with specified begin and end location with force info
    open func pan(from: Pan, to: Pan) -> MLLine {
        let color = self.color.toMLColor(opacity: opacity)
        var endForce = from.force * 0.95 + to.force * 0.05
        endForce = pow(endForce, forceSensitive)
        let line = MLLine(begin: from.point, end: to.point,
                          pointSize: pointSize * endForce, pointStep: pointStep, color: color,
                          scaleFactor: target?.screenTarget.scale ?? 1,
                          offset: target?.screenTarget.contentOffset ?? .zero)
        return line
    }
    
    // MARK: - Render tools
    /// texture for this brush, readonly
    open private(set) weak var texture: MTLTexture?
    
    /// pipeline state for this brush
    open private(set) var pipelineState: MTLRenderPipelineState!
    
    /// make shader library for this brush, overrides to provide your own shader library
    open func makeShaderLibrary(from device: MTLDevice) -> MTLLibrary? {
        return device.libraryForMaLiang()
    }
    
    /// make shader vertex function from the library made by makeShaderLibrary()
    /// overrides to provide your own vertex function
    open func makeShaderVertexFunction(from library: MTLLibrary) -> MTLFunction? {
        return library.makeFunction(name: "vertex_point_func")
    }
    
    /// make shader fragment function from the library made by makeShaderLibrary()
    /// overrides to provide your own fragment function
    open func makeShaderFragmentFunction(from library: MTLLibrary) -> MTLFunction? {
        if texture == nil {
            return library.makeFunction(name: "fragment_point_func_without_texture")
        }
        return library.makeFunction(name: "fragment_point_func")
    }
    
    /// Blending options for this brush, overrides to implement your own blending options
    open func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true

        attachment.rgbBlendOperation = .add
        attachment.sourceRGBBlendFactor = .one
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        attachment.alphaBlendOperation = .add
        attachment.sourceAlphaBlendFactor = .one
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }
    
    // MARK: - Render Actions

    private func updatePointPipeline() {
        
        guard let target = target, let device = target.device, let library = makeShaderLibrary(from: device) else {
            return
        }
        
        let rpd = MTLRenderPipelineDescriptor()
        
        if let vertex_func = makeShaderVertexFunction(from: library) {
            rpd.vertexFunction = vertex_func
        }
        if let fragment_func = makeShaderFragmentFunction(from: library) {
            rpd.fragmentFunction = fragment_func
        }
        
        rpd.colorAttachments[0].pixelFormat = target.colorPixelFormat
        setupBlendOptions(for: rpd.colorAttachments[0]!)
        pipelineState = try! device.makeRenderPipelineState(descriptor: rpd)
    }

    /// render a specifyed line strip by this brush
    internal func render(lineStrip: LineStrip, on renderTarget: RenderTarget? = nil) {
        
        let renderTarget = renderTarget ?? target?.screenTarget
        
        guard lineStrip.lines.count > 0, let target = renderTarget else {
            return
        }
        
        /// make sure reusable command buffer is ready
        target.prepareForDraw()
        
        /// get commandEncoder form resuable command buffer
        let commandEncoder = target.makeCommandEncoder()
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        
        if let vertex_buffer = lineStrip.retrieveBuffers() {
            commandEncoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            commandEncoder?.setVertexBuffer(target.uniform_buffer, offset: 0, index: 1)
            commandEncoder?.setVertexBuffer(target.transform_buffer, offset: 0, index: 2)
            if let texture = texture {
                commandEncoder?.setFragmentTexture(texture, index: 0)
            }
            commandEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: lineStrip.vertexCount)
        }
        
        commandEncoder?.endEncoding()
    }
}
