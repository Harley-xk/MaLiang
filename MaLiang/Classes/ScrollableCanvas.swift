//
//  ScrollableCanvas.swift
//  MaLiang_Example
//
//  Created by Harley.xk on 2018/5/2.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

open class ScrollableCanvas: Canvas {
    
    open override func setup() {
        super.setup()
        
        contentSize = bounds.size
        
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
    
    /// the actural drawable size of canvas, may larger than current bounds
    /// contentSize must between bounds size and 5120x5120
    open var contentSize: CGSize = .zero
    
    /// get snapthot image for the same size to content
    open override func snapshot() -> UIImage? {
        /// draw content in texture of the same size to content
        if contentSize == bounds.size {
            return super.snapshot()
        }
        
        /// create a new render target with same size to the content, for snapshoting
        let snapshotTarget = RenderTarget(size: contentSize * contentScaleFactor, device: device)
        redraw(on: snapshotTarget, display: false)
        snapshotTarget.commitCommands()
        if let texture = snapshotTarget.texture, let ciimage = CIImage(mtlTexture: texture, options: nil) {
            /// ciimage is downMirrored
            return UIImage(ciImage: ciimage.oriented(forExifOrientation: 4))
        }
        return nil
    }
    
    private var pinchGesture: UIPinchGestureRecognizer!
    private var moveGesture: UIPanGestureRecognizer!
    
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
        return CGPoint(x: contentSize.width * zoom - bounds.width, y: contentSize.height * zoom - bounds.height)
    }
}
