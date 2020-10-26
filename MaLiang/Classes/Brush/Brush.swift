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

    init(touch: UITouch, on view: UIView) {
        if #available(iOS 9.1, *) {
            point = touch.preciseLocation(in: view)
        } else {
            point = touch.location(in: view)
        }
        force = touch.force
        
        // force on devices not supporting from a finger is always 0, reset to 0.3
        if touch.type == .direct, force == 0 {
            force = 1
        }
    }
    
    init(point: CGPoint, force: CGFloat) {
        self.point = point
        self.force = force
    }
}

open class Brush {
    
    // unique identifier for a specifyed brush, should not be changed over all your apps
    // make this value uniform when saving or reading canvas content from a file
    open var name: String
    
    /// interal texture
    open private(set) var textureID: String?
    
    /// target to draw
    open weak var target: Canvas?

    // opacity of texture, affects the darkness of stroke
    open var opacity: CGFloat = 0.3 {
        didSet {
            updateRenderingColor()
        }
    }
    
    // width of stroke line in points
    open var pointSize: CGFloat = 4

    // this property defines the minimum distance (measureed in points) of nearest two textures
    // defaults to 1, this means erery texture calculated will be rendered, dictance calculation will be skiped
    open var pointStep: CGFloat = 1
    
    // sensitive of pointsize changed from force, if sets to 0, stroke size will not be affected by force
    // sets to 1 to make an everage affect
    open var forceSensitive: CGFloat = 0
    
    // indicate if the stroke size in visual will be scaled along with the Canvas
    // defaults to false, the stroke size in visual will stay with the original value
    open var scaleWithCanvas = false
    
    // force used when tap the canvas, defaults to 0.1
    open var forceOnTap: CGFloat = 1
    
    /// color of stroke
    open var color: UIColor = .black {
        didSet {
            updateRenderingColor()
        }
    }
    
    /// texture rotation for this brush
    public enum Rotation {
        /// angele is fixed to specified value
        case fixed(CGFloat)
        /// angle of texture is random
        case random
        /// angle of texture is ahead with to line orientation
        case ahead
    }
    
    /// texture rotation for this brush, defaults to .fixed(0)
    open var rotation = Rotation.fixed(0)
    
    // randering color, same color to the color property with alpha reseted to alpha * opacity
    internal var renderingColor: MLColor = MLColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    // called when color or opacity changed
    private func updateRenderingColor() {
        renderingColor = color.toMLColor(opacity: opacity)
    }
    
    // designed initializer, will be called by target when reigster called
    // identifier is not necessary if you won't save the content of your canvas to file
    required public init(name: String?, textureID: String?, target: Canvas) {
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
    
    /// get a line with specified begin and end location with force info
    open func makeLine(from: Pan, to: Pan) -> [MLLine] {
        let endForce = from.force * 0.95 + to.force * 0.05
        let forceRate = pow(endForce, forceSensitive)
        return makeLine(from: from.point, to: to.point, force: forceRate)
    }
    
    /// make lines to render with specified begin and end location
    ///
    /// - Parameters:
    ///   - from: begin location
    ///   - to: end location
    ///   - force: force that effects the line width
    ///   - uniqueColor: these lines will use current color as unique color if sets to true, defaults to false
    /// - Returns: lines to render
    open func makeLine(from: CGPoint, to: CGPoint, force: CGFloat? = nil, uniqueColor: Bool = false) -> [MLLine] {
        let force = force ?? forceOnTap
        let scale = scaleWithCanvas ? 1 : canvasScale
        let line = MLLine(begin: (from + canvasOffset) / canvasScale,
                          end: (to + canvasOffset) / canvasScale,
                          pointSize: pointSize * force / scale,
                          pointStep: pointStep / scale,
                          color: uniqueColor ? renderingColor : nil)
        return [line]
    }
    
    /// some brush may have cached unfinished lines, return them here
    open func finishLineStrip(at end: Pan) -> [MLLine] {
        return []
    }

    private var canvasScale: CGFloat {
        return target?.screenTarget?.scale ?? 1
    }
    
    private var canvasOffset: CGPoint {
        return target?.screenTarget?.contentOffset ?? .zero
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
        attachment.sourceRGBBlendFactor = .sourceAlpha
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
        
        if let vertex_buffer = lineStrip.retrieveBuffers(rotation: rotation) {
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
    
    // MARK: - Bezier
    // optimize stroke with bezier path, defaults to true
    //    private var enableBezierPath = true
    private var bezierGenerator = BezierGenerator()
    
    // MARK: - Drawing Actions
    private var lastRenderedPan: Pan?
    
    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator, force: CGFloat, isEnd: Bool = false, on canvas: Canvas) {
        var lines: [MLLine] = []
        let vertices = bezier.pushPoint(point)
        guard vertices.count >= 2 else {
            return
        }
        var lastPan = lastRenderedPan ?? Pan(point: vertices[0], force: force)
        let deltaForce = (force - (lastRenderedPan?.force ?? force)) / CGFloat(vertices.count)
        for i in 1 ..< vertices.count {
            let p = vertices[i]
            if  // end point of line
                (isEnd && i == vertices.count - 1) ||
                    // ignore step
                    pointStep <= 1 ||
                    // distance larger than step
                    (pointStep > 1 && lastPan.point.distance(to: p) >= pointStep)
            {
                let force = lastPan.force + deltaForce
                let pan = Pan(point: p, force: force)
                let line = makeLine(from: lastPan, to: pan)
                lines.append(contentsOf: line)
                lastPan = pan
                lastRenderedPan = pan
            }
        }
        render(lines: lines, on: canvas)
    }
    
    open func render(lines: [MLLine], on canvas: Canvas) {
        canvas.render(lines: lines)
    }

    // MARK: - Touches

    // called when touches began event triggered on canvas
    open func renderBegan(from pan: Pan, on canvas: Canvas) -> Bool {
        lastRenderedPan = pan
        bezierGenerator.begin(with: pan.point)
        pushPoint(pan.point, to: bezierGenerator, force: pan.force, on: canvas)
        return true
    }
    
    // called when touches moved event triggered on canvas
    open func renderMoved(to pan: Pan, on canvas: Canvas) -> Bool {
        guard bezierGenerator.points.count > 0 else { return false }
        guard pan.point != lastRenderedPan?.point else {
            return false
        }
        pushPoint(pan.point, to: bezierGenerator, force: pan.force, on: canvas)
        return true
    }
    
    // called when touches ended event triggered on canvas
    open func renderEnded(at pan: Pan, on canvas: Canvas) {
        defer {
            bezierGenerator.finish()
            lastRenderedPan = nil
        }
        
        let count = bezierGenerator.points.count
        if count >= 3 {
            pushPoint(pan.point, to: bezierGenerator, force: pan.force, isEnd: true, on: canvas)
        } else if count > 0 {
            canvas.renderTap(at: bezierGenerator.points.first!, to: bezierGenerator.points.last!)
        }
        
        let unfishedLines = finishLineStrip(at: Pan(point: pan.point, force: pan.force))
        if unfishedLines.count > 0 {
            canvas.render(lines: unfishedLines)
        }
    }
}

// MARK: - Deprecated
extension Brush {
    @available(*, deprecated, message: "", renamed: "makeLine(from:to:)")
    open func pan(from: Pan, to: Pan) -> MLLine {
        return makeLine(from: from, to: to).first!
    }
    
    @available(*, deprecated, message: "", renamed: "makeLine(from:to:force:)")
    open func line(from: CGPoint, to: CGPoint, force: CGFloat = 1) -> MLLine {
        return makeLine(from: from, to: to, force: force).first!
    }
}
