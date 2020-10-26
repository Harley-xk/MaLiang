//
//  ElementGroup.swift
//  MaLiang
//
//  Created by Harley-xk on 2020/10/26.
//

import Foundation

open class ElementGroup<E: CanvasElement>: CanvasElement {
        
    /// index in the emelent list of canvas
    /// element with smaller index will draw earlier
    /// Automatically set by Canvas.Data
    open var index: Int = 0
    
    open var elements: [E] = []
    
    /// draw this element on specifyied target
    open func drawSelf(on target: RenderTarget?) {
        elements.forEach {
            $0.drawSelf(on: target)
        }
    }
    
    open func append(_ element: E) {
        elements.append(element)
    }
}

