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
    
    open override func setup() {
        super.setup()
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGestureRecognizer(_:)))
        addGestureRecognizer(pinchGesture)
    }

    private var currentZoomScale: CGFloat = 1
    
    @objc private func handlePinchGestureRecognizer(_ gesture: UIPinchGestureRecognizer) {
        print(gesture.scale)
        
        switch gesture.state {
        case .began: fallthrough
        case .changed:
            var scale = currentZoomScale * gesture.scale * gesture.scale
            scale = max(scale, 0.1)
            scale = min(scale, 20)
            zoomScale = scale
            redraw()
        case .ended: fallthrough
        case .cancelled: fallthrough
        case .failed:
            currentZoomScale = zoomScale
        default: break
        }
    }
}
