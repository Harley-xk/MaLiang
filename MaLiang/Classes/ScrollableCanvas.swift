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

    private var currentZoomScale: CGFloat = 1
    private var offsetAnchor: CGPoint = .zero
    
    @objc private func handlePinchGestureRecognizer(_ gesture: UIPinchGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            beginMove(from: location)
            fallthrough
        case .changed:
            guard gesture.numberOfTouches >= 2 else {
                return
            }
            var scale = currentZoomScale * gesture.scale * gesture.scale
            scale = max(scale, 1)
            scale = min(scale, 20)
            self.zoom = scale
            self.scale = zoom
            didMove(to: location)
            redraw()
        case .ended: fallthrough
        case .cancelled: fallthrough
        case .failed:
//            self.scale = zoom
//            didMove(to: location)
            currentZoomScale = zoom
//            redraw()
        default: break
        }
    }
    
    @objc private func handleMoveGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            beginMove(from: location)
            fallthrough
        case .changed:
            guard gesture.numberOfTouches >= 2 else {
                return
            }
            didMove(to: location)
            redraw()
//        case .ended: fallthrough
//        case .cancelled: fallthrough
//        case .failed:
//            didMove(to: location)
//            redraw()
        default: break
        }
    }
    
    private func beginMove(from location: CGPoint) {
        offsetAnchor = location + contentOffset
        print("Move from: \(location)")
    }
    
    private func didMove(to location: CGPoint) {
        self.contentOffset = offsetAnchor - location
        print("Move to: \(location)")
    }
}
