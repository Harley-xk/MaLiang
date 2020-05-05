//
//  TexturedBrush.swift
//  Chrysan
//
//  Created by Harley-xk on 2019/5/5.
//

import Foundation
import CoreGraphics
import Metal
import AVFoundation

public final class TexturedBrush: Brush {

    /// color of stroke
    public var foregroundImage: UIImage? {
        didSet {
            updateRenderingTexture()
        }
    }
    private var foregroundBrushTexture: MTLTexture?

    private func updateRenderingTexture() {
        guard let foregroundImage = foregroundImage,
            let target = target else { return }
        if let texture = try? target.makeTexture(with: foregroundImage.pngData()!) {
            foregroundBrushTexture = target.findTexture(by: texture.id)?.texture
        }
    }

    /// make shader fragment function from the library made by makeShaderLibrary()
    /// overrides to provide your own fragment function
    public override func makeShaderFragmentFunction(from library: MTLLibrary) -> MTLFunction? {
        return library.makeFunction(name: "fragment_point_func_test")
    }

    /// Blending options for this brush, overrides to implement your own blending options
    public override func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true

        attachment.rgbBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha

        attachment.alphaBlendOperation = .max
        attachment.sourceAlphaBlendFactor = .sourceAlpha
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }

    /// render a specifyed line strip by this brush
    internal override func render(lineStrip: LineStrip, on renderTarget: RenderTarget? = nil) {

        let renderTarget = renderTarget ?? target?.screenTarget

        guard lineStrip.lines.count > 0, let target = renderTarget else {
            return
        }

        /// make sure reusable command buffer is ready
        target.prepareForDraw()

        /// get commandEncoder form resuable command buffer
        let commandEncoder = target.makeCommandEncoder()

        commandEncoder?.setRenderPipelineState(pipelineState)

        if let vertex_buffer = lineStrip.retrieveBuffers(rotation: rotation) {
            commandEncoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            commandEncoder?.setVertexBuffer(target.uniform_buffer, offset: 0, index: 1)
            commandEncoder?.setVertexBuffer(target.transform_buffer, offset: 0, index: 2)
            if let texture = texture {
                commandEncoder?.setFragmentTexture(texture, index: 0)
            }
            if let testTexture = foregroundBrushTexture {
                commandEncoder?.setFragmentTexture(testTexture, index: 1)
            }
            commandEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: lineStrip.vertexCount)
        }

        commandEncoder?.endEncoding()
    }
}

