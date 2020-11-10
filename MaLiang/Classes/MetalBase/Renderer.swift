//
//  Renderer.swift
//  MaLiang
//
//  Created by Harley-xk on 2020/11/4.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    
    weak var canvas: Canvas?
    
    init(delegateTo canvas: Canvas) throws {
        guard let device = sharedDevice,
              let queue = device.makeCommandQueue() else {
            throw MLError.initializationError
        }
        self.device = device
        self.commandQueue = queue
        self.canvas = canvas
        
        super.init()
        canvas.delegate = self
        
        let backgroundColor = canvas.backgroundColor ?? .white
        let descriptor = canvas.currentRenderPassDescriptor
        descriptor?.colorAttachments[0].clearColor = backgroundColor.toClearColor()
        descriptor?.colorAttachments[0].loadAction = .load
        descriptor?.colorAttachments[0].storeAction = .store
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        
        let buffer = commandQueue.makeCommandBuffer()
        guard let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        let commandEncoder = buffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        var lines = canvas?.data.elements.compactMap { $0 as? LineStrip } ?? []
        
        if let current = canvas?.data.currentElement as? LineStrip {
            lines.append(current)
        }
        
        guard let target = canvas?.screenTarget else {
            return
        }
        
        for lineStrip in lines {

            guard let brush = lineStrip.brush ?? canvas?.defaultBrush else {
                continue
            }
            commandEncoder?.setRenderPipelineState(brush.pipelineState)

            if let vertex_buffer = lineStrip.retrieveBuffers(rotation: brush.rotation) {
                commandEncoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
                commandEncoder?.setVertexBuffer(target.uniform_buffer, offset: 0, index: 1)
                commandEncoder?.setVertexBuffer(target.transform_buffer, offset: 0, index: 2)
                if let texture = brush.texture {
                    commandEncoder?.setFragmentTexture(texture, index: 0)
                }
                commandEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: lineStrip.vertexCount)
            }
        }
        
        commandEncoder?.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        buffer?.present(drawable)
        buffer?.commit()
    }
}
