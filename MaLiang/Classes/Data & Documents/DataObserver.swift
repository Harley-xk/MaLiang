//
//  DataObserver.swift
//  Chrysan
//
//  Created by Harley-xk on 2019/5/14.
//

import Foundation

/// observers for data on the canvas, will get notification on data change
public protocol DataObserver: class {
    
    /// called when a line strip is begin
    func lineStrip(_ strip: LineStrip, didBeginOn data: CanvasData)
    
    /// called when a element is finished
    func element(_ element: CanvasElement, didFinishOn data: CanvasData)
    
    /// callen when clear the canvas
    func dataDidClear(_ data: CanvasData)
    
    /// callen when undo
    func dataDidUndo(_ data: CanvasData)
    
    /// callen when redo
    func dataDidRedo(_ data: CanvasData)
}

// empty implementation
public extension DataObserver {
    func lineStrip(_ strip: LineStrip, didBeginOn data: CanvasData) {}
    func element(_ element: CanvasElement, didFinishOn data: CanvasData) {}
    func dataDidClear(_ data: CanvasData) {}
    func dataDidUndo(_ data: CanvasData) {}
    func dataDidRedo(_ data: CanvasData) {}
}

final class WeakObserverBox {
    weak var observer: DataObserver?
    init(_ observer: DataObserver) {
        self.observer = observer
    }
}

// transform message to elements
extension Array where Element: WeakObserverBox {
    func lineStrip(_ strip: LineStrip, didBeginOn data: CanvasData) {
        compactMap{ $0.observer }.forEach {
            $0.lineStrip(strip, didBeginOn: data)
        }
    }
    
    func element(_ element: CanvasElement, didFinishOn data: CanvasData) {
        compactMap{ $0.observer }.forEach {
            $0.element(element, didFinishOn: data)
        }
    }
    
    func dataDidClear(_ data: CanvasData) {
        compactMap{ $0.observer }.forEach {
            $0.dataDidClear(data)
        }
    }
    
    func dataDidUndo(_ data: CanvasData) {
        compactMap{ $0.observer }.forEach {
            $0.dataDidUndo(data)
        }
    }
    
    func dataDidRedo(_ data: CanvasData) {
        compactMap{ $0.observer }.forEach {
            $0.dataDidRedo(data)
        }
    }
}
