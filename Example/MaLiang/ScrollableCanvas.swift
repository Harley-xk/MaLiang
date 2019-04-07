//
//  ScrollableCanvas.swift
//  MaLiang_Example
//
//  Created by Harley.xk on 2018/5/2.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import MaLiang

open class ScrollableCanvas: UIScrollView {
    
    open var canvas: Canvas!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        // Do any additional setup after loading the view.
        panGestureRecognizer.minimumNumberOfTouches = 2
        delaysContentTouches = false
        delegate = self
    }
    
    open override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        return touches.count == 1
    }
}

extension ScrollableCanvas: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        canvas.zoomScale = scrollView.zoomScale
    }
}
