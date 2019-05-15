//
//  WeakObjectBox.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/5/15.
//

import Foundation

final class WeakObjectBox {
    
    weak var unboxed: AnyObject?

    init(_ object: AnyObject?) {
        unboxed = object
    }
}

class WeakObjectsPool {
    
    private var boxes: [WeakObjectBox] = []
    
    // add a object in to pool
    func addObject(_ object: AnyObject) {
        boxes.append(WeakObjectBox(object))
    }
    
    // remove boxes of released object
    func clean() {
        boxes = boxes.compactMap { $0.unboxed == nil ? nil : $0 }
    }
    
    // return unreleased objects
    var aliveObjects: [AnyObject] {
        return boxes.compactMap { $0.unboxed }
    }
}
