//
//  Canvas.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/11.
//

import UIKit

open class Canvas: MLView {

    /// specify a brush to paint
    open var brush: Brush! {
        didSet {
            texture = brush.texture
        }
    }
    
    /// enable force
    open var forceEnabled: Bool {
        get {
            return paintingGesture.forceEnabled
        }
        set {
            paintingGesture.forceEnabled = newValue
        }
    }
    
    /// this will setup the canvas and gestures、default brushs
    open override func setup() {
        super.setup()
        brush = Brush(texture: MLTexture.default)
        
        /// gesture to render line
        paintingGesture = PaintingGestureRecognizer.addToTarget(self, action: #selector(handlePaingtingGesture(_:)))
        /// gesture to render dot
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    private var paintingGesture: PaintingGestureRecognizer!
    
    
    /// clear all things on the canvas
    ///
    /// - Parameter display: redraw the canvas if this sets to true
    open override func clear(display: Bool = true) {
        super.clear(display: display)
        
        if display {
            document?.appendClearAction()
        }
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
        if let doc = document {
            
            super.clear(display: false)

            /// find elements to draw, until last clear action
            let count = doc.actions.count
            var elementsToRedraw: [CanvasElement] = []
            for i in 0 ..< count {
                let index = count - i - 1
                let action = doc.actions[index]
                guard action.actionType != .clear, let element = action.element else {
                    break
                }
                elementsToRedraw.insert(element, at: 0)
            }
            
            /// redraw with the order it does originaly
            for element in elementsToRedraw {
                var texture = getCachedTexture(with: element.textureId)
                if texture == nil {
                    doc.createTexture(for: element)
                    texture = getCachedTexture(with: element.textureId)
                }
                self.texture = texture
                for line in element.lines {
                    super.renderLine(line, display: false)
                }
            }
            displayBuffer()
            texture = brush.texture
        }
    }
        
    // MARK: - Bezier
    // optimize stroke with bezier path, defaults to true
//    private var enableBezierPath = true
    private var bezierGenerator = BezierGenerator()

    // MARK: - Drawing Actions
    private var lastRenderedPan: Pan?

    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator, force: CGFloat, isEnd: Bool = false) {
        let vertices = bezier.pushPoint(point)
        if vertices.count >= 2 {
            var lastPan = lastRenderedPan ?? Pan(point: vertices[0], force: force)
            let deltaForce = (force - (lastRenderedPan?.force ?? 0)) / vertices.count.cgfloat
            for i in 1 ..< vertices.count {
                let p = vertices[i]
                let pointStep = brush.pointStep / self.scale
                if  // end point of line
                    (isEnd && i == vertices.count - 1) ||
                    // ignore step
                    pointStep <= 1 ||
                    // distance larger than step
                    (pointStep > 1 && lastPan.point.distance(to: p) >= pointStep)
                {
                    let f = lastPan.force + deltaForce
                    let pan = Pan(point: p, force: f)
                    let line = brush.pan(from: lastPan, to: pan)
                    self.renderLine(line, display: false)
                    lastPan = pan
                    lastRenderedPan = pan
                }
            }
        }
        displayBuffer()
    }
    
    // MARK: - Rendering
    override open func renderLine(_ line: MLLine, display: Bool = true) {
        super.renderLine(line, display: display)
        document?.appendLines([line], with: brush.texture)
    }

    // MARK: - Gestures
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized {
            let location = gesture.gl_location(in: self)
            var line = brush.line(from: location, to: location)
            /// fix the opacity of color when there is only one point
            let delta = max((brush.pointSize - brush.pointStep), 0) / brush.pointSize
            let opacity = brush.opacity + (1 - brush.opacity) * delta
            line.color = brush.color.mlcolorWith(opacity: opacity)
            self.renderLine(line)
            document?.finishCurrentElement()
        }
    }
    
    @objc private func handlePaingtingGesture(_ gesture: PaintingGestureRecognizer) {
        
        let location = gesture.gl_location(in: self)
        
        if gesture.state == .began {
            document?.finishCurrentElement()
            lastRenderedPan = Pan(point: location, force: gesture.force)
            bezierGenerator.begin(with: location)
        }
        else if gesture.state == .changed {
            pushPoint(location, to: bezierGenerator, force: gesture.force)
        }
        else if gesture.state == .ended {
            pushPoint(location, to: bezierGenerator, force: gesture.force, isEnd: true)
            bezierGenerator.finish()
            lastRenderedPan = nil
            document?.finishCurrentElement()
        }
    }
}
