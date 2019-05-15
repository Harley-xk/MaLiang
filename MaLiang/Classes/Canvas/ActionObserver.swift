//
//  ActionObserver.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/5/15.
//

import Foundation
import UIKit

/// Delegate for rendering
public protocol RenderingDelegate: AnyObject {
    func canvas(_ canvas: Canvas, shouldRenderTapAt point: CGPoint) -> Bool
    func canvas(_ canvas: Canvas, shouldRenderChartlet chartlet: Chartlet) -> Bool
    // if returns false, the whole line strip will be skiped
    func canvas(_ canvas: Canvas, shouldBeginLineAt point: CGPoint, force: CGFloat) -> Bool
}

public extension RenderingDelegate {
    func canvas(_ canvas: Canvas, shouldRenderTapAt point: CGPoint) -> Bool {
        return true
    }
    
    func canvas(_ canvas: Canvas, shouldRenderChartlet chartlet: Chartlet) -> Bool {
        return true
    }
    
    func canvas(_ canvas: Canvas, shouldBeginLineAt point: CGPoint, force: CGFloat) -> Bool {
        return true
    }
}

/// Observer for canvas actions
public protocol ActionObserver: AnyObject {
    
    func canvas(_ canvas: Canvas, didRenderTapAt point: CGPoint)
    func canvas(_ canvas: Canvas, didRenderChartlet chartlet: Chartlet)

    func canvas(_ canvas: Canvas, didBeginLineAt point: CGPoint, force: CGFloat)
    func canvas(_ canvas: Canvas, didMoveLineTo point: CGPoint, force: CGFloat)
    func canvas(_ canvas: Canvas, didFinishLineAt point: CGPoint, force: CGFloat)
    
    func canvas(_ canvas: Canvas, didRedrawOn target: RenderTarget)
    
    // Only called on ScrollableCanvas
    
    func canvas(_ canvas: ScrollableCanvas, didZoomTo zoomLevel: CGFloat)
    func canvasDidScroll(_ canvas: ScrollableCanvas)
}

/// Observer for canvas actions
public extension ActionObserver {
    
    func canvas(_ canvas: Canvas, didRenderTapAt point: CGPoint) {}
    func canvas(_ canvas: Canvas, didRenderChartlet chartlet: Chartlet) {}
    
    func canvas(_ canvas: Canvas, didBeginLineAt point: CGPoint, force: CGFloat) {}
    func canvas(_ canvas: Canvas, didMoveLineTo point: CGPoint, force: CGFloat) {}
    func canvas(_ canvas: Canvas, didFinishLineAt point: CGPoint, force: CGFloat) {}
    
    func canvas(_ canvas: Canvas, didRedrawOn target: RenderTarget) {}
    
    // Only called on ScrollableCanvas
    
    func canvas(_ canvas: ScrollableCanvas, didZoomTo zoomLevel: CGFloat) {}
    func canvasDidScroll(_ canvas: ScrollableCanvas) {}
}

final class ActionObserverPool: WeakObjectsPool {
    
    func addObserver(_ observer: ActionObserver) {
        super.addObject(observer)
    }
    
    // return unreleased objects
    var aliveObservers: [ActionObserver] {
        return aliveObjects.compactMap { $0 as? ActionObserver }
    }
}

extension ActionObserverPool: ActionObserver {
    
    func canvas(_ canvas: Canvas, didRenderTapAt point: CGPoint) {
        aliveObservers.forEach { $0.canvas(canvas, didRenderTapAt: point) }
    }
    func canvas(_ canvas: Canvas, didRenderChartlet chartlet: Chartlet) {
        aliveObservers.forEach { $0.canvas(canvas, didRenderChartlet: chartlet) }
    }
    
    func canvas(_ canvas: Canvas, didBeginLineAt point: CGPoint, force: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didBeginLineAt: point, force: force) }
    }
    
    func canvas(_ canvas: Canvas, didMoveLineTo point: CGPoint, force: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didMoveLineTo: point, force: force) }
    }
    
    func canvas(_ canvas: Canvas, didFinishLineAt point: CGPoint, force: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didFinishLineAt: point, force: force) }
    }

    func canvas(_ canvas: Canvas, didRedrawOn target: RenderTarget) {
        aliveObservers.forEach { $0.canvas(canvas, didRedrawOn: target) }
    }
    
    // Only called on ScrollableCanvas
    
    func canvas(_ canvas: ScrollableCanvas, didZoomTo zoomLevel: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didZoomTo: zoomLevel) }
    }

    func canvasDidScroll(_ canvas: ScrollableCanvas) {
        aliveObservers.forEach { $0.canvasDidScroll(canvas) }
    }
}
