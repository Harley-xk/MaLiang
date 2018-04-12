//
//  Canvas.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/11.
//

import UIKit

open class Canvas: GLView {

    // optimize stroke with bezier path, defaults to true
    private var enableBezierPath = true
    private var firstTouch: Bool = false
    private var location: CGPoint = CGPoint()
    private var previousLocation: CGPoint = CGPoint()
    private var bezierGenerator = BezierGenerator()

    // MARK: - Drawing Actions
    private var lastRenderedPoint: CGPoint?
    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator) {
        let vertices = bezier.pushPoint(point)
        if vertices.count >= 2 {
            var lastPoint = lastRenderedPoint ?? vertices[0]
            for i in 1 ..< vertices.count {
                let p = vertices[i]
                if brush.strokeWidth <= 1 ||
                    (brush.strokeWidth > 1 && lastPoint.distance(to: p) >= brush.strokeStep) {
                    self.renderLine(from: lastPoint, to: p, display: false)
                    lastPoint = p
                    lastRenderedPoint = p
                }
            }
        }
        displayBuffer()
    }

    // MARK: - Gestures
    
    // Handles the start of a touch
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        firstTouch = true
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        location = touch.location(in: self)
        location.y = bounds.size.height - location.y
        
        lastRenderedPoint = location
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
            previousLocation = location
        } else {
            previousLocation = touch.previousLocation(in: self)
            previousLocation.y = bounds.size.height - previousLocation.y
        }
        
        location = touch.location(in: self)
        location.y = bounds.size.height - location.y
        
        if enableBezierPath {
            // Render the stroke with bezier optmized path
            pushPoint(location, to: bezierGenerator)
        } else {
            // Render the stroke directly
            self.renderLine(from: previousLocation, to: location)
        }
        
    }
    
    // Handles the end of a touch event when the touch is a tap.
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        if firstTouch {
            firstTouch = false
            previousLocation = touch.previousLocation(in: self)
            previousLocation.y = bounds.size.height - previousLocation.y
            self.renderLine(from: previousLocation, to: location)
        }
        
        if enableBezierPath {
            pushPoint(location, to: bezierGenerator)
            bezierGenerator.finish()
        }
    }
    
    // Handles the end of a touch event.
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If appropriate, add code necessary to save the state of the application.
        // This application is not saving state.
    }    
}
