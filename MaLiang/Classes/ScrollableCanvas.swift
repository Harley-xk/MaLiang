//
//  ScrollableCanvas.swift
//  MaLiang_Example
//
//  Created by Harley.xk on 2018/5/2.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

open class ScrollableCanvas: Canvas {
    
    private var pinchGesture: UIPinchGestureRecognizer!
    private var moveGesture: UIPanGestureRecognizer!
    
    open override func setup() {
        super.setup()
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGestureRecognizer(_:)))
        addGestureRecognizer(pinchGesture)
        
        moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMoveGestureRecognizer(_:)))
        moveGesture.minimumNumberOfTouches = 2
        addGestureRecognizer(moveGesture)
    }
    
    /// the max zoomScale of canvas, will cause redraw if the new value is less than current
    open var maxScale: CGFloat = 3 {
        didSet {
            if maxScale < zoom {
                self.zoom = maxScale
                self.scale = maxScale
                self.redraw()
            }
        }
    }
    
    private var currentZoomScale: CGFloat = 1
    private var offsetAnchor: CGPoint = .zero
    private var beginLocation: CGPoint = .zero
    
    @objc private func handlePinchGestureRecognizer(_ gesture: UIPinchGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            beginLocation = location
            offsetAnchor = location + contentOffset
        case .changed:
            guard gesture.numberOfTouches >= 2 else {
                return
            }
            var scale = currentZoomScale * gesture.scale * gesture.scale
            scale = scale.between(min: 1, max: maxScale)
            self.zoom = scale
            self.scale = zoom
            let offset = offsetAnchor * (scale / currentZoomScale) - location
            contentOffset = offset.between(min: .zero, max: maxOffset)
            redraw()
        case .ended: fallthrough
        case .cancelled: fallthrough
        case .failed:
            currentZoomScale = zoom
        default: break
        }
    }
    
    @objc private func handleMoveGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            offsetAnchor = location + contentOffset
        case .changed:
            guard gesture.numberOfTouches >= 2 else {
                return
            }
            contentOffset = (offsetAnchor - location).between(min: .zero, max: maxOffset)
            redraw()
        default: break
        }
    }
    
    private var maxOffset: CGPoint {
        return CGPoint(x: bounds.width * (zoom - 1), y: bounds.height * (zoom - 1))
    }
}
