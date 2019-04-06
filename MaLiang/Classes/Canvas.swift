//
//  Canvas.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/11.
//

import UIKit

open class Canvas: MetalView {
    
    
    // MARK: - Brushes
    
    /// Register a brush with image data
    ///
    /// - Parameter texture: texture data of brush
    /// - Returns: registered brush
    @discardableResult open func registerBrush(with texture: Data) throws -> Brush {
        let texture = try makeTexture(with: texture)
        let brush = Brush(texture: texture, target: self)
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
    
    /// current brush used to draw
    /// only registered brushed can be set to current
    /// get a brush from registeredBrushes and call it's use() method to make it current
    open internal(set) var currentBrush: Brush!
    
    /// All registered brushes
    open private(set) var registeredBrushes: [Brush] = []
    
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
        
        do {
            let path = Bundle.maliang.path(forResource: "point", ofType: "png")!
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            try currentBrush = registerBrush(with: data)
        } catch {
            
        }
        
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
            document?.appendClearAction()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    // MARK: - Document
    public private(set) var document: Document?
    public func setupDocument() throws {
        document = try Document()
    }
    
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
    private func redraw() {
    }
//        if let doc = document {
//
//            super.clear(display: false)
//
//            /// find elements to draw, until last clear action
//            let count = doc.actions.count
//            var elementsToRedraw: [CanvasElement] = []
//            for i in 0 ..< count {
//                let index = count - i - 1
//                let action = doc.actions[index]
//                guard action.actionType != .clear, let element = action.element else {
//                    break
//                }
//                elementsToRedraw.insert(element, at: 0)
//            }
//
//            /// redraw with the order it does originaly
//            for element in elementsToRedraw {
//                if let texture = getCachedTexture(for: element) {
//                    self.texture = texture
//                }
//                for line in element.lines {
//                    super.renderLine(line, display: false)
//                }
//            }
//            displayBuffer()
//            texture = brush.texture
//        }
//    }
//
//    func getCachedTexture(for element: CanvasElement) -> MLTexture? {
//        if let t = super.getCachedTexture(with: element.textureId) {
//            return t
//        }
//        return document?.createTexture(for: element)
//    }
    
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
                let pointStep = currentBrush.pointStep / self.zoomScale
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
        currentBrush.render(lines: lines)
        if display {
            presentRenderTarget()
        }
//        super.renderLine(line, display: display)
//        document?.appendLines([line], with: brush.texture)
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
            document?.finishCurrentElement()
        }
    }
    
    @objc private func handlePaingtingGesture(_ gesture: PaintingGestureRecognizer) {
        
        let location = gesture.location(in: self)
        
        if gesture.state == .began {
            /// 取实际的手势起点作为笔迹的起点
            let acturalBegin = gesture.acturalBeginLocation
            document?.finishCurrentElement()
            lastRenderedPan = Pan(point: location, force: gesture.force)
            bezierGenerator.begin(with: location)
            lastRenderedPan = Pan(point: acturalBegin, force: gesture.force)
            bezierGenerator.begin(with: acturalBegin)
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
            document?.finishCurrentElement()
        }
    }
}
