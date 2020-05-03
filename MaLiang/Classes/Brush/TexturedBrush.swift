//
//  TexturedBrush.swift
//  Chrysan
//
//  Created by Harley-xk on 2019/5/5.
//

import Foundation
import CoreGraphics
import Metal

public final class TexturedBrush: Brush {

    /// color of stroke
    public var foregroundImage: UIImage? {
        didSet {
            updateRenderingTexture()
        }
    }
    private var testTexture: MTLTexture?

    private func updateRenderingTexture() {
        guard let foregroundImage = foregroundImage else { return }
        if let texture = try? target?.makeTexture(with: foregroundImage.pngData()!) {
            testTexture = target?.findTexture(by: texture.id)?.texture
        }
    }

    /// make shader fragment function from the library made by makeShaderLibrary()
    /// overrides to provide your own fragment function
    public override func makeShaderFragmentFunction(from library: MTLLibrary) -> MTLFunction? {
        return library.makeFunction(name: "fragment_point_func_test")
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
            if let testTexture = testTexture {
                commandEncoder?.setFragmentTexture(testTexture, index: 1)
            }
            commandEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: lineStrip.vertexCount)
        }

        commandEncoder?.endEncoding()
    }
}

