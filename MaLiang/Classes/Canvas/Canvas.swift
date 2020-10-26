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
    
    /// pencil only mode for apple pencil, defaults to false
    /// if sets to true, all touches with toucheType that is not pencil will be ignored
    open var isPencilMode = false {
        didSet {
            // enable multiple touch for pencil mode
            // this makes user to draw with pencil when finger is already on the screen
            isMultipleTouchEnabled = isPencilMode
        }
    }
    
    open var useFingersToErase = false
    
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
    
    /// Reigster an already initialized Brush to this Canvas
    /// - Parameter brush: Brush already initialized
    
    open func register<T: Brush>(brush: T) {
        brush.target = self
        registeredBrushes.append(brush)
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
    
    @available(*, deprecated, message: "this property will be removed soon, set the property forceSensitive on brush to 0 instead, changing this value will cause no affects")
    open var forceEnabled: Bool = true
    
    // MARK: - Zoom and scale
    /// the scale level of view, all things scales
    open var scale: CGFloat {
        get {
            return screenTarget?.scale ?? 1
        }
        set {
            screenTarget?.scale = newValue
        }
    }
    
    /// the zoom level of render target, only scale render target
    open var zoom: CGFloat {
        get {
            return screenTarget?.zoom ?? 1
        }
        set {
            screenTarget?.zoom = newValue
        }
    }
    
    /// the offset of render target with zoomed size
    open var contentOffset: CGPoint {
        get {
            return screenTarget?.contentOffset ?? .zero
        }
        set {
            screenTarget?.contentOffset = newValue
        }
    }
    
    // setup gestures
    open var paintingGesture: PaintingGestureRecognizer?
    open var tapGesture: UITapGestureRecognizer?
    
    /// this will setup the canvas and gestures、default brushs
    open override func setup() {
        super.setup()
        
        /// initialize default brush
        defaultBrush = Brush(name: "maliang.default", textureID: nil, target: self)
        currentBrush = defaultBrush
        
        /// initialize printer
        printer = Printer(name: "maliang.printer", textureID: nil, target: self)
        
        data = CanvasData()
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
    /// - Attention: SAVE your data before call this method!
    /// - Parameter redraw: if should redraw the canvas after, defaults to true
    open func resetData(redraw: Bool = true) {
        let oldData = data!
        let newData = CanvasData()
        // link registered observers to new data
        newData.observers = data.observers
        data = newData
        if redraw {
            self.redraw()
        }
        data.observers.data(oldData, didResetTo: newData)
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
    /// - Attention: thie method must be called on main thread
    open func redraw(on target: RenderTarget? = nil) {
        
        guard let target = target ?? screenTarget else {
            return
        }
        
        data.finishCurrentElement()
        
        target.updateBuffer(with: drawableSize)
        target.clear()
        
        data.elements.forEach { $0.drawSelf(on: target) }
        
        /// submit commands
        target.commitCommands()
        
        actionObservers.canvas(self, didRedrawOn: target)
    }
    
    // MARK: - Rendering
    open func render(lines: [MLLine]) {
        data.append(lines: lines, with: currentBrush)
        // create a temporary line strip and draw it on canvas
        LineStrip(lines: lines, brush: currentBrush).drawSelf(on: screenTarget)
        /// submit commands
        screenTarget?.commitCommands()
    }
    
    open func renderTap(at point: CGPoint, to: CGPoint? = nil) {
        
        guard renderingDelegate?.canvas(self, shouldRenderTapAt: point) ?? true else {
            return
        }
        
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
    open func renderChartlet(
        at point: CGPoint,
        size: CGSize,
        textureID: String,
        rotation: CGFloat = 0,
        grouped: Bool = false
    ) {
        
        let chartlet = Chartlet(center: point, size: size, textureID: textureID, angle: rotation, canvas: self)
        
        guard renderingDelegate?.canvas(self, shouldRenderChartlet: chartlet) ?? true else {
            return
        }
        
        data.append(chartlet: chartlet, grouped: grouped)
        chartlet.drawSelf(on: screenTarget)
        screenTarget?.commitCommands()
        setNeedsDisplay()
        
        actionObservers.canvas(self, didRenderChartlet: chartlet)
    }
    
    // MARK: - Touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pan = firstAvaliablePan(from: touches) else {
            return
        }
        guard renderingDelegate?.canvas(self, shouldBeginLineAt: pan.point, force: pan.force) ?? true else {
            return
        }
        if currentBrush.renderBegan(from: pan, on: self) {
            actionObservers.canvas(self, didBeginLineAt: pan.point, force: pan.force)
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pan = firstAvaliablePan(from: touches) else {
            return
        }
        if currentBrush.renderMoved(to: pan, on: self) {
            actionObservers.canvas(self, didMoveLineTo: pan.point, force: pan.force)
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pan = firstAvaliablePan(from: touches) else {
            return
        }
        currentBrush.renderEnded(at: pan, on: self)
        data.finishCurrentElement()
        actionObservers.canvas(self, didFinishLineAt: pan.point, force: pan.force)
    }
    
    public func firstAvaliablePan(from touches: Set<UITouch>) -> Pan? {
        var touch: UITouch?
        if #available(iOS 9.1, *), isPencilMode {
            touch = touches.first { (t) -> Bool in
                return t.type == .pencil
            }
        } else {
            touch = touches.first
        }
        guard let t = touch else {
            return nil
        }
        return Pan(touch: t, on: self)
    }
}
