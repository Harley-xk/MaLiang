//
//  MetalView.swift
//  MaLiang_Example
//
//  Created by Harley-xk on 2019/4/3.
//  Copyright © 2019 Harley-xk. All rights reserved.
//

import UIKit
import QuartzCore
import MetalKit

open class MetalView: MTKView {
    
    // MARK: - Brush Textures
    
    func makeTexture(with data: Data) throws -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: device!)
        return try textureLoader.newTexture(data: data, options: [.SRGB : false])
    }
    
    func makeTexture(with file: URL) throws -> MTLTexture {
        let data = try Data(contentsOf: file)
        return try makeTexture(with: data)
    }
    
    // MARK: - Functions
    // Erases the screen, redisplay the buffer if display sets to true
    open func clear(display: Bool = true) {
        screenTarget.clear()
        if display {
            presentRenderTarget()
        }
    }

    // MARK: - Render
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateBuffers()
    }


    open override var backgroundColor: UIColor? {
        didSet {
            clearColor = (backgroundColor ?? .white).toClearColor()
        }
    }

    // MARK: - Setup
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        setup()
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    #if !targetEnvironment(simulator)
    var metalLayer: CAMetalLayer {
        guard let layer = layer as? CAMetalLayer else {
            fatalError("Metal initialize failed!")
        }
        return layer
    }
    #endif
    
    open func setup() {
        device = MTLCreateSystemDefaultDevice()
        isOpaque = false

        screenTarget = RenderTarget(size: drawableSize, device: device)
        
        updateBuffers()

        do {
            try setupPiplineState()
        } catch {
            fatalError("Metal initialize failed: \(error.localizedDescription)")
        }
    }

    // pipeline state
    
    private var pipelineState: MTLRenderPipelineState!

    private func setupPiplineState() throws {
        let library = device?.libraryForMaLiang()
        let vertex_func = library?.makeFunction(name: "vertex_render_target")
        let fragment_func = library?.makeFunction(name: "fragment_render_target")
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = vertex_func
        rpd.fragmentFunction = fragment_func
        rpd.colorAttachments[0].pixelFormat = colorPixelFormat
        rpd.colorAttachments[0].isBlendingEnabled = true
        rpd.colorAttachments[0].alphaBlendOperation = .add
        rpd.colorAttachments[0].rgbBlendOperation = .add
        rpd.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        rpd.colorAttachments[0].sourceAlphaBlendFactor = .one
        rpd.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        rpd.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineState = try device?.makeRenderPipelineState(descriptor: rpd)
    }

    // render target for rendering contents to screen
    internal var screenTarget: RenderTarget!

    // Uniform buffers
    private var render_target_vertex: MTLBuffer!
    private var render_target_uniform: MTLBuffer!

    private func updateBuffers() {
        screenTarget.updateBuffer(with: drawableSize)
        updateZoomUniform()
    }
    
    func updateZoomUniform() {
        let size = drawableSize
        let w = size.width * (screenTarget.zoom / screenTarget.scale ), h = size.height * (screenTarget.zoom / screenTarget.scale)
        let vertices = [
            Vertex(position: CGPoint(x: 0 , y: 0), textCoord: CGPoint(x: 0, y: 0)),
            Vertex(position: CGPoint(x: w , y: 0), textCoord: CGPoint(x: 1, y: 0)),
            Vertex(position: CGPoint(x: 0 , y: h), textCoord: CGPoint(x: 0, y: 1)),
            Vertex(position: CGPoint(x: w , y: h), textCoord: CGPoint(x: 1, y: 1)),
        ]
        render_target_vertex = device?.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: .cpuCacheModeWriteCombined)
        
        let metrix = Matrix.identity
        metrix.scaling(x: 2 / Float(size.width), y: -2 / Float(size.height), z: 1)
        metrix.translation(x: -1, y: 1, z: 0)
        render_target_uniform = device?.makeBuffer(bytes: metrix.m, length: MemoryLayout<Float>.size * 16, options: [])
    }
    
    internal func presentRenderTarget() {
        
        /// commit target commands before drawing
        screenTarget.commitCommands()
        
        #if !targetEnvironment(simulator)
        
        guard let drawable = metalLayer.nextDrawable(), let texture = screenTarget.texture else {
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor.colorAttachments[0]
        attachment?.clearColor = clearColor
        attachment?.texture = drawable.texture
        attachment?.loadAction = .clear
        attachment?.storeAction = .store
        
        let commandQueue = device?.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        
        commandEncoder?.setVertexBuffer(render_target_vertex, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(render_target_uniform, offset: 0, index: 1)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
        #endif
    }
}
