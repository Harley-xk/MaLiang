//
//  Canvas.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/11.
//

import UIKit

open class Canvas: MLView {

    open var brush: Brush! {
        didSet {
            texture = brush.texture
        }
    }
    
    open override func setup() {
        super.setup()
        brush = Brush(texture: MLTexture.default)
        
        /// gesture to render line
        let paintingGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePaingtingGesture(_:)))
        paintingGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(paintingGesture)
        
        /// gesture to render dot
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
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
            clear(display: false)
            for element in doc.elements {
                let texture = getCachedTexture(with: element.textureId)
                if texture == nil {
                    doc.createTexture(for: element)
                }
                for line in element.lines {
                    self.texture = texture
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
    private var lastRenderedPoint: CGPoint?
    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator, isEnd: Bool = false) {
        let vertices = bezier.pushPoint(point)
        if vertices.count >= 2 {
            var lastPoint = lastRenderedPoint ?? vertices[0]
            for i in 1 ..< vertices.count {
                let p = vertices[i]
                if  // end point of line
                    (isEnd && i == vertices.count - 1) ||
                    // ignore step
                    brush.pointStep <= 1 ||
                    // distance larger than step
                    (brush.pointStep > 1 && lastPoint.distance(to: p) >= brush.pointStep)
                {
                    let line = MLLine(begin: lastPoint, end: p, brush: brush)
                    self.renderLine(line, display: false)
                    lastPoint = p
                    lastRenderedPoint = p
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
            var line = MLLine(begin: location, end: location, brush: brush)
            /// fix the opacity of color when there is only one point
            let delta = max((brush.pointSize - brush.pointStep), 0) / brush.pointSize
            let opacity = brush.opacity + (1 - brush.opacity) * delta
            line.color = brush.color.mlcolorWith(opacity: opacity)
            self.renderLine(line)
        }
    }
    
    @objc private func handlePaingtingGesture(_ gesture: UIPanGestureRecognizer) {
        
        let location = gesture.gl_location(in: self)

        if gesture.state == .began {
            lastRenderedPoint = location
            bezierGenerator.begin(with: location)
        }
        else if gesture.state == .changed {
            pushPoint(location, to: bezierGenerator)
        }
        else if gesture.state == .ended {
            pushPoint(location, to: bezierGenerator, isEnd: true)
            bezierGenerator.finish()
            document?.finishCurrentElement()
        }
    }
}
