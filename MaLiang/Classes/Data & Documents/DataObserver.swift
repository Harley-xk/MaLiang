//
//  DataObserver.swift
//  Chrysan
//
//  Created by Harley-xk on 2019/5/14.
//

import Foundation

/// observers for data on the canvas, will get notification on data change
public protocol DataObserver: AnyObject {
    
    /// called when a line strip is begin
    func lineStrip(_ strip: LineStrip, didBeginOn data: CanvasData)
    
    /// called when a element is finished
    func element(_ element: CanvasElement, didFinishOn data: CanvasData)
    
    /// called when clear the canvas
    func dataDidClear(_ data: CanvasData)
    
    /// called when undo
    func dataDidUndo(_ data: CanvasData)
    
    /// called when redo
    func dataDidRedo(_ data: CanvasData)
    
    /// called when data of canvas have been reseted
    func data(_ data: CanvasData, didResetTo newData: CanvasData)
}

// empty implementation
public extension DataObserver {
    func lineStrip(_ strip: LineStrip, didBeginOn data: CanvasData) {}
    func element(_ element: CanvasElement, didFinishOn data: CanvasData) {}
    func dataDidClear(_ data: CanvasData) {}
    func dataDidUndo(_ data: CanvasData) {}
    func dataDidRedo(_ data: CanvasData) {}
    func data(_ data: CanvasData, didResetTo newData: CanvasData) {}
}

final class DataObserverPool: WeakObjectsPool {
    
    func addObserver(_ observer: DataObserver) {
        super.addObject(observer)
    }
    
    // return unreleased objects
    var aliveObservers: [DataObserver] {
        return aliveObjects.compactMap { $0 as? DataObserver }
    }
}

// transform message to elements
extension DataObserverPool {
    func lineStrip(_ strip: LineStrip, didBeginOn data: CanvasData) {
        aliveObservers.forEach {
            $0.lineStrip(strip, didBeginOn: data)
        }
    }
    
    func element(_ element: CanvasElement, didFinishOn data: CanvasData) {
        aliveObservers.forEach {
            $0.element(element, didFinishOn: data)
        }
    }
    
    func dataDidClear(_ data: CanvasData) {
        aliveObservers.forEach {
            $0.dataDidClear(data)
        }
    }
    
    func dataDidUndo(_ data: CanvasData) {
        aliveObservers.forEach {
            $0.dataDidUndo(data)
        }
    }
    
    func dataDidRedo(_ data: CanvasData) {
        aliveObservers.forEach {
            $0.dataDidRedo(data)
        }
    }
    
    func data(_ data: CanvasData, didResetTo newData: CanvasData) {
        aliveObservers.forEach {
            $0.data(data, didResetTo: newData)
        }
    }
}
