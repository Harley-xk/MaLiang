//
//  Canvas.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/11.
//

import UIKit

open class Canvas: MetalView {
    
    // MARK: - Brushes
    
    /// default round point brush, will not show in registeredBrushes
    open var defaultBrush: Brush!
    
    /// printer to print image textures on canvas
    open private(set) var printer: Printer!
    
    /// the actural size of canvas in points, may larger than current bounds
    /// size must between bounds size and 5120x5120
    open var size: CGSize {
        return drawableSize / contentScaleFactor
    }
    
    // delegate & observers
    
    open weak var renderingDelegate: RenderingDelegate?
    
    internal var actionObservers = ActionObserverPool()
    
    // add an observer to observe data changes, observers are not retained
    open func addObserver(_ observer: ActionObserver) {
        // pure nil objects
        actionObservers.clean()
        actionObservers.addObserver(observer)
    }

    /// Register a brush with image data
    ///
    /// - Parameter texture: texture data of brush
    /// - Returns: registered brush
    @discardableResult open func registerBrush<T: Brush>(name: String? = nil, from data: Data) throws -> T {
        let texture = try makeTexture(with: data)
        let brush = T(name: name, textureID: texture.id, target: self)
        registeredBrushes.append(brush)
        return brush
    }
    
    /// Register a brush with image data
    ///
    /// - Parameter file: texture file of brush
    /// - Returns: registered brush
    @discardableResult open func registerBrush<T: Brush>(name: String? = nil, from file: URL) throws -> T {
        let data = try Data(contentsOf: file)
        return try registerBrush(name: name, from: data)
    }
    
    /// Register a new brush with texture already registered on this canvas
    ///
    /// - Parameter textureID: id of a texture, default round texture will be used if sets to nil or texture id not found
    open func registerBrush<T: Brush>(name: String? = nil, textureID: String? = nil) throws -> T {
        let brush = T(name: name, textureID: textureID, target: self)
        registeredBrushes.append(brush)
        return brush
    }
    
    /// current brush used to draw
    /// only registered brushed can be set to current
    /// get a brush from registeredBrushes and call it's use() method to make it current
    open internal(set) var currentBrush: Brush!
    
    /// All registered brushes
    open private(set) var registeredBrushes: [Brush] = []
    
    /// find a brush by name
    /// nill will be retured if brush of name provided not exists
    open func findBrushBy(name: String?) -> Brush? {
        return registeredBrushes.first { $0.name == name }
    }
    
    /// All textures created by this canvas
    open private(set) var textures: [MLTexture] = []
    
    /// make texture and cache it with ID
    ///
    /// - Parameters:
    ///   - data: image data of texture
    ///   - id: id of texture, will be generated if not provided
    /// - Returns: created texture, if the id provided is already exists, the existing texture will be returend
    @discardableResult
    override open func makeTexture(with data: Data, id: String? = nil) throws -> MLTexture {
        // if id is set, make sure this id is not already exists
        if let id = id, let exists = findTexture(by: id) {
            return exists
        }
        let texture = try super.makeTexture(with: data, id: id)
        textures.append(texture)
        return texture
    }
    
    /// find texture by textureID
    open func findTexture(by id: String) -> MLTexture? {
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
    
    // MARK: - Zoom and scale
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

    // setup gestures
    open var paintingGesture: PaintingGestureRecognizer?
    open var tapGesture: UITapGestureRecognizer?

    open func setupGestureRecognizers() {
        /// gesture to render line
        paintingGesture = PaintingGestureRecognizer.addToTarget(self, action: #selector(handlePaingtingGesture(_:)))
        /// gesture to render dot
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
    
    
    /// this will setup the canvas and gestures、default brushs
    open override func setup() {
        super.setup()
        
        /// initialize default brush
        defaultBrush = Brush(name: "maliang.default", textureID: nil, target: self)
        currentBrush = defaultBrush
        
        /// initialize printer
        printer = Printer(name: "maliang.printer", textureID: nil, target: self)
        
        data = CanvasData()
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
            data.appendClearAction()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    // MARK: - Document
    public private(set) var data: CanvasData!
    
    /// reset data on canvas, this method will drop the old data object and create a new one.
    ///
    /// - Parameter redraw: if should redraw the canvas after, defaults to true
    ///
    /// - Attention: SAVE your data before calling this method!
    open func resetData(redraw: Bool = true) {
        data = CanvasData()
        if redraw {
            self.redraw()
        }
    }
    
    public func undo() {
        if let data = data, data.undo() {
            redraw()
        }
    }
    
    public func redo() {
        if let data = data, data.redo() {
            redraw()
        }
    }
    
    /// redraw elemets in document
    /// - Attention: this method must be called on main thread
    open func redraw(on target: RenderTarget? = nil) {
    
        let target = target ?? screenTarget!
        
        data.finishCurrentElement()
        
        target.updateBuffer(with: drawableSize)
        target.clear()
        
        data.elements.forEach { $0.drawSelf(on: target) }
        
        /// submit commands
        target.commitCommands()
        
        actionObservers.canvas(self, didRedrawOn: target)
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
        guard vertices.count >= 2 else {
            return
        }
        var lastPan = lastRenderedPan ?? Pan(point: vertices[0], force: force)
        let deltaForce = (force - (lastRenderedPan?.force ?? force)) / CGFloat(vertices.count)
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
                let force = lastPan.force + deltaForce
                let pan = Pan(point: p, force: force)
                let line = currentBrush.makeLine(from: lastPan, to: pan)
                lines.append(contentsOf: line)
                lastPan = pan
                lastRenderedPan = pan
            }
        }
        render(lines: lines)
    }
    
    // MARK: - Rendering
    open func render(lines: [MLLine]) {
        data.append(lines: lines, with: currentBrush)
        // create a temporary line strip and draw it on canvas
        LineStrip(lines: lines, brush: currentBrush).drawSelf(on: screenTarget)
        /// submit commands
        screenTarget.commitCommands()
    }
    
    open func renderTap(at point: CGPoint, to: CGPoint? = nil) {
        let brush = currentBrush!
        let lines = brush.makeLine(from: point, to: to ?? point)
        render(lines: lines)
    }
    
    /// draw a chartlet to canvas
    ///
    /// - Parameters:
    ///   - point: location where to draw the chartlet
    ///   - size: size of texture
    ///   - textureID: id of texture for drawing
    ///   - rotation: rotation angle of texture for drawing
    open func renderChartlet(at point: CGPoint, size: CGSize, textureID: String, rotation: CGFloat = 0) {
        
        let chartlet = Chartlet(center: point, size: size, textureID: textureID, angle: rotation, canvas: self)

        guard renderingDelegate?.canvas(self, shouldRenderChartlet: chartlet) ?? true else {
            return
        }
        
        data.append(chartlet: chartlet)
        chartlet.drawSelf(on: screenTarget)
        screenTarget.commitCommands()
        setNeedsDisplay()
        
        actionObservers.canvas(self, didRenderChartlet: chartlet)
    }
    
    // MARK: - Gestures
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized {
            let location = gesture.location(in: self)
            
            guard renderingDelegate?.canvas(self, shouldRenderTapAt: location) ?? true else {
                return
            }
            
            renderTap(at: location)
            let unfishedLines = currentBrush.finishLineStrip(at: Pan(point: location, force: currentBrush.forceOnTap))
            if unfishedLines.count > 0 {
                render(lines: unfishedLines)
            }
            data.finishCurrentElement()
            
            actionObservers.canvas(self, didRenderTapAt: location)
        }
    }
    
    @objc private func handlePaingtingGesture(_ gesture: PaintingGestureRecognizer) {
        
        let location = gesture.location(in: self)
        
        if gesture.state == .began {
            /// 结束上一个图案
            data.finishCurrentElement()

            /// 取实际的手势起点作为笔迹的起点
            let acturalBegin = gesture.acturalBeginLocation
            
            guard renderingDelegate?.canvas(self, shouldBeginLineAt: acturalBegin, force: gesture.force) ?? true else {
                return
            }
            
            lastRenderedPan = Pan(point: acturalBegin, force: gesture.force)
            bezierGenerator.begin(with: acturalBegin)
            pushPoint(location, to: bezierGenerator, force: gesture.force)
            
            actionObservers.canvas(self, didBeginLineAt: acturalBegin, force: gesture.force)
        }
        else if gesture.state == .changed {
            guard bezierGenerator.points.count > 0 else { return }
            pushPoint(location, to: bezierGenerator, force: gesture.force)
            actionObservers.canvas(self, didMoveLineTo: location, force: gesture.force)
        }
        else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            let count = bezierGenerator.points.count
            guard count > 0 else { return }
            if count < 3 {
                renderTap(at: bezierGenerator.points.first!, to: bezierGenerator.points.last!)
            } else {
                pushPoint(location, to: bezierGenerator, force: gesture.force, isEnd: true)
            }
            bezierGenerator.finish()
            lastRenderedPan = nil
            let unfishedLines = currentBrush.finishLineStrip(at: Pan(point: location, force: gesture.force))
            if unfishedLines.count > 0 {
                render(lines: unfishedLines)
            }
            data.finishCurrentElement()
            
            actionObservers.canvas(self, didFinishLineAt: location, force: gesture.force)
        }
    }
}
