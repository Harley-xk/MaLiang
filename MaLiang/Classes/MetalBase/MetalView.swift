//
//  MetalView.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/3.
//  Copyright © 2019 Harley-xk. All rights reserved.
//

import UIKit
import QuartzCore
import MetalKit

internal let sharedDevice = MTLCreateSystemDefaultDevice()

open class MetalView: MTKView {
    
    // MARK: - Brush Textures
    
    func makeTexture(with data: Data, id: String? = nil) throws -> MLTexture {
        guard metalAvaliable else {
            throw MLError.simulatorUnsupported
        }
        let textureLoader = MTKTextureLoader(device: device!)
        let texture = try textureLoader.newTexture(data: data, options: [.SRGB : false])
        return MLTexture(id: id ?? UUID().uuidString, texture: texture)
    }
    
    func makeTexture(with file: URL, id: String? = nil) throws -> MLTexture {
        let data = try Data(contentsOf: file)
        return try makeTexture(with: data, id: id)
    }
    
    // MARK: - Functions
    // Erases the screen, redisplay the buffer if display sets to true
    open func clear(display: Bool = true) {
        screenTarget?.clear()
        if display {
            setNeedsDisplay()
        }
    }

    // MARK: - Render
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        screenTarget?.updateBuffer(with: drawableSize)
    }

    open override var backgroundColor: UIColor? {
        didSet {
            clearColor = (backgroundColor ?? .black).toClearColor()
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

    open func setup() {
        guard metalAvaliable else {
            print("<== Attension ==>")
            print("You are running MaLiang on a Simulator, whitch is not supported by Metal. So painting is not alvaliable now. \nBut you can go on testing your other businesses which are not relative with MaLiang. Or you can also runs MaLiang on your Mac with Catalyst enabled now.")
            print("<== Attension ==>")
            return
        }
        
        device = sharedDevice
        isOpaque = false

        screenTarget = RenderTarget(size: drawableSize, pixelFormat: colorPixelFormat, device: device)
        commandQueue = device?.makeCommandQueue()

        setupTargetUniforms()

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
        pipelineState = try device?.makeRenderPipelineState(descriptor: rpd)
    }

    // render target for rendering contents to screen
    internal var screenTarget: RenderTarget?
    
    private var commandQueue: MTLCommandQueue?

    // Uniform buffers
    private var render_target_vertex: MTLBuffer!
    private var render_target_uniform: MTLBuffer!
    
    func setupTargetUniforms() {
        let size = drawableSize
        let w = size.width, h = size.height
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
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard metalAvaliable,
            let target = screenTarget,
            let texture = target.texture else {
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor.colorAttachments[0]
        attachment?.clearColor = clearColor
        attachment?.texture = currentDrawable?.texture
        attachment?.loadAction = .clear
        attachment?.storeAction = .store
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        
        commandEncoder?.setVertexBuffer(render_target_vertex, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(render_target_uniform, offset: 0, index: 1)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        commandEncoder?.endEncoding()
        if let drawable = currentDrawable {
            commandBuffer?.present(drawable)
        }
        commandBuffer?.commit()        
    }
}

// MARK: - Simulator fix

internal var metalAvaliable: Bool = {
    #if targetEnvironment(simulator)
    if #available(iOS 13.0, *) {
        return true
    } else {
        return false
    }
    #else
    return true
    #endif
}()
