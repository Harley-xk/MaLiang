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

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        brush = defaultBrush
    }
    
    // optimize stroke with bezier path, defaults to true
    private var enableBezierPath = true
    private var firstTouch: Bool = false
//    private var location: CGPoint = CGPoint()
    private var previousLocation: CGPoint = CGPoint()
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

    // MARK: - Gestures
    override open var canBecomeFirstResponder : Bool {
        return true
    }
    
    // Handles the start of a touch
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        firstTouch = true
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        var location = touch.location(in: self)
        location.y = bounds.size.height - location.y
        
        lastRenderedPoint = location
        previousLocation = location
        if enableBezierPath {
            bezierGenerator.begin(with: location)
        }
    }
    
    // Handles the continuation of a touch.
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        if firstTouch {
            firstTouch = false
//            previousLocation = location
        } else {
            previousLocation = touch.previousLocation(in: self)
            previousLocation.y = bounds.size.height - previousLocation.y
        }
        
        var location = touch.location(in: self)
        location.y = bounds.size.height - location.y
        
        if enableBezierPath {
            // Render the stroke with bezier optmized path
            pushPoint(location, to: bezierGenerator)
        } else {
            // Render the stroke directly
            let line = MLLine(begin: previousLocation, end: location, brush: brush)
            self.renderLine(line)
        }
        
    }
    
    // Handles the end of a touch event when the touch is a tap.
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        var location = touch.location(in: self)
        location.y = bounds.size.height - location.y

        if firstTouch {
            previousLocation = touch.previousLocation(in: self)
            previousLocation.y = bounds.size.height - previousLocation.y
            var line = MLLine(begin: previousLocation, end: location, brush: brush)
            /// fix the opacity of color when there is only one point
            let delta = max((brush.pointSize - brush.pointStep), 0) / brush.pointSize
            let opacity = brush.opacity + (1 - brush.opacity) * delta
            line.color = brush.color.mlcolorWith(opacity: opacity)
            self.renderLine(line)
        }
        if enableBezierPath {
            if firstTouch {
                firstTouch = false
            } else {
                pushPoint(location, to: bezierGenerator, isEnd: true)
            }
            bezierGenerator.finish()
        } else if !firstTouch {
            let line = MLLine(begin: previousLocation, end: location, brush: brush)
            self.renderLine(line)
        }
    }
    
    // Handles the end of a touch event.
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
