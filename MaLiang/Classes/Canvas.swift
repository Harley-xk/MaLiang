//
//  Canvas.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/11.
//

import UIKit

open class Canvas: MetalView {
    
    /// the scale level of view, all things scales
    open var scale: CGFloat {
        get {
            return screenTarget.scale
        }
        set {
            screenTarget.scale = newValue
        }
    }
    
    /// the zoom level of render target, only scale render target
    open var zoom: CGFloat {
        get {
            return screenTarget.zoom
        }
        set {
            screenTarget.zoom = newValue
        }
    }
    
    /// the offset of render target with zoomed size
    open var contentOffset: CGPoint {
        get {
            return screenTarget.contentOffset
        }
        set {
            screenTarget.contentOffset = newValue
        }
    }

    // MARK: - Brushes
    
    /// default round point brush, will not show in registeredBrushes
    open var defaultBrush: Brush!
    
    /// Register a brush with image data
    ///
    /// - Parameter texture: texture data of brush
    /// - Returns: registered brush
    @discardableResult open func registerBrush(with texture: Data) throws -> Brush {
        let texture = try makeTexture(with: texture)
        let brush = Brush(textureID: texture.id, target: self)
        registeredBrushes.append(brush)
        return brush
    }
    
    /// Register a brush with image data
    ///
    /// - Parameter file: texture file of brush
    /// - Returns: registered brush
    @discardableResult open func registerBrush(with file: URL) throws -> Brush {
        let data = try Data(contentsOf: file)
        return try registerBrush(with: data)
    }
    
    
    /// Register a brush with specified texture id
    ///
    /// - Parameter textureID: id of a texture, must already be registered
    open func registerBrush(with textureID: UUID) throws -> Brush {
        guard let texture = findTexture(by: textureID) else {
            throw NSError(domain: "MaLiang", code: -1, userInfo: [NSLocalizedDescriptionKey: "Texture with id: \(textureID.uuidString) not registered!"])
        }
        let brush = Brush(textureID: texture.id, target: self)
        registeredBrushes.append(brush)
        return brush
    }
    
    /// current brush used to draw
    /// only registered brushed can be set to current
    /// get a brush from registeredBrushes and call it's use() method to make it current
    open internal(set) var currentBrush: Brush!
    
    /// All registered brushes
    open private(set) var registeredBrushes: [Brush] = []
    
    open func findBrush(by id: UUID) -> Brush? {
        return registeredBrushes.first { $0.id == id }
    }
    
    /// All textures created by this canvas
    open private(set) var textures: [MLTexture] = []
    
    /// make texture and cache it with ID
    override open func makeTexture(with data: Data) throws -> MLTexture {
        let texture = try super.makeTexture(with: data)
        textures.append(texture)
        return texture
    }
    
    /// find texture by textureID
    open func findTexture(by id: UUID) -> MLTexture? {
        return textures.first { $0.id == id }
    }
    
    /// enable force
    open var forceEnabled: Bool {
        get {
            return paintingGesture?.forceEnabled ?? false
        }
        set {
            paintingGesture?.forceEnabled = newValue
        }
    }
    
    // setup gestures
    open var paintingGesture: PaintingGestureRecognizer?
    
    open func setupGestureRecognizers() {
        /// gesture to render line
        paintingGesture = PaintingGestureRecognizer.addToTarget(self, action: #selector(handlePaingtingGesture(_:)))
        /// gesture to render dot
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    
    /// this will setup the canvas and gestures、default brushs
    open override func setup() {
        super.setup()
        defaultBrush = Brush(textureID: nil, target: self)
        currentBrush = defaultBrush
        
        document = Document()
        setupGestureRecognizers()
    }
    
    /// take a snapshot on current canvas and export an image
    open func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, contentScaleFactor)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// clear all things on the canvas
    ///
    /// - Parameter display: redraw the canvas if this sets to true
    open override func clear(display: Bool = true) {
        super.clear(display: display)
        
        if display {
            document.appendClearAction()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    // MARK: - Document
    public private(set) var document: Document!
    
    public func undo() {
        if let doc = document, doc.undo() {
            redraw()
        }
    }
    
    public func redo() {
        if let doc = document, doc.redo() {
            redraw()
        }
    }
    
    /// redraw elemets in document
    open func redraw(on target: RenderTarget? = nil, display: Bool = true) {
    
        let target = target ?? screenTarget!
        
        var elementsToDraw: [CanvasElement] = []
        var elements = document.elements
        while elements.count > 0 {
            guard let element = elements.popLast() else {
                break
            }
            if case CanvasElement.clear = element {
                break
            }
            elementsToDraw.insert(element, at: 0)
        }
        
        target.updateBuffer(with: drawableSize)
        target.clear()
        
        elementsToDraw.forEach { $0.drawSelf(on: target) }
//
//        /// combine all linestrips with same brush and then draw
//        var pendingDrawingQueue: [MLLineStrip] = []
//        for item in elementsToDraw {
//            guard case let .pan(lineStrip) = item else {
//                item.drawSelf(on: target)
//                continue
//            }
//            if let last = pendingDrawingQueue.last, last.brush.identifier != lineStrip.brush.identifier {
//                drawLineStrips(pendingDrawingQueue, on: target)
//                pendingDrawingQueue.removeAll()
//            }
//            pendingDrawingQueue.append(lineStrip)
//        }
//        drawLineStrips(pendingDrawingQueue, on: target)
        
        if display {
//            setNeedsDisplay()
        }
    }
    
    internal func drawLineStrips(_ strips: [MLLineStrip], on target: RenderTarget) {
        guard strips.count > 0 else {
            return
        }
        strips.forEach { $0.drawSelf(on: target) }
    }
    
    // MARK: - Bezier
    // optimize stroke with bezier path, defaults to true
    //    private var enableBezierPath = true
    private var bezierGenerator = BezierGenerator()
    
    // MARK: - Drawing Actions
    private var lastRenderedPan: Pan?
    
    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator, force: CGFloat, isEnd: Bool = false) {
        var lines: [MLLine] = []
        let vertices = bezier.pushPoint(point)
        if vertices.count >= 2 {
            var lastPan = lastRenderedPan ?? Pan(point: vertices[0], force: force)
            let deltaForce = (force - (lastRenderedPan?.force ?? 0)) / CGFloat(vertices.count)
            for i in 1 ..< vertices.count {
                let p = vertices[i]
                let pointStep = currentBrush.pointStep
                if  // end point of line
                    (isEnd && i == vertices.count - 1) ||
                        // ignore step
                        pointStep <= 1 ||
                        // distance larger than step
                        (pointStep > 1 && lastPan.point.distance(to: p) >= pointStep)
                {
                    let f = lastPan.force + deltaForce
                    let pan = Pan(point: p, force: f)
                    let line = currentBrush.pan(from: lastPan, to: pan)
                    lines.append(line)
                    lastPan = pan
                    lastRenderedPan = pan
                }
            }
        }
        render(lines: lines)
    }
    
    // MARK: - Rendering
    open func render(lines: [MLLine], display: Bool = true) {
        document.appendLines(lines, with: currentBrush)

        let linStrip = MLLineStrip(lines: lines, brush: currentBrush)
        linStrip.drawSelf(on: screenTarget)
        
//        currentBrush.render(lines: lines)
        if display {
//            setNeedsDisplay()
        }
    }
    
    open func renderTap(at point: CGPoint, to: CGPoint? = nil) {
        let brush = currentBrush!
        var line = brush.line(from: point, to: to ?? point)
        /// fix the opacity of color when there is only one point
        let delta = max((brush.pointSize - brush.pointStep), 0) / brush.pointSize
        let opacity = brush.opacity + (1 - brush.opacity) * delta
        line.color = brush.color.toMLColor(opacity: opacity)
        render(lines: [line])
    }
    
    // MARK: - Gestures
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized {
            let location = gesture.location(in: self)
            renderTap(at: location)
            document.finishCurrentLineStrip()
        }
    }
    
    @objc private func handlePaingtingGesture(_ gesture: PaintingGestureRecognizer) {
        
        let location = gesture.location(in: self)
        
        if gesture.state == .began {
            /// 取实际的手势起点作为笔迹的起点
            let acturalBegin = gesture.acturalBeginLocation
            document.finishCurrentLineStrip()
            lastRenderedPan = Pan(point: acturalBegin, force: gesture.force)
            bezierGenerator.begin(with: acturalBegin)
            pushPoint(location, to: bezierGenerator, force: gesture.force)
        }
        else if gesture.state == .changed {
            pushPoint(location, to: bezierGenerator, force: gesture.force)
        }
        else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            let count = bezierGenerator.points.count
            if count < 3 {
                renderTap(at: bezierGenerator.points.first!, to: bezierGenerator.points.last!)
            } else {
                pushPoint(location, to: bezierGenerator, force: gesture.force, isEnd: true)
            }
            bezierGenerator.finish()
            lastRenderedPan = nil
            document.finishCurrentLineStrip()
        }
    }
}
