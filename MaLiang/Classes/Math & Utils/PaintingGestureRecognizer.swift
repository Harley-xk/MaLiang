//
//  PaintingGestureRecognizer.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/5/3.
//

import UIKit.UIGestureRecognizerSubclass


open class PaintingGestureRecognizer: UIPanGestureRecognizer {

    private weak var targetView: UIView!
    
    @discardableResult
    class func addToTarget(_ target: UIView, action: Selector?) -> PaintingGestureRecognizer {
        let ges = PaintingGestureRecognizer(targetView: target, action: action)
        target.addGestureRecognizer(ges)
        return ges
    }
    
    convenience init(targetView t: UIView, action: Selector?) {
        self.init(target: t, action: action)
        targetView = t
        maximumNumberOfTouches = 1
        
    }
    
    /// 当前压力值，启用压力感应时，使用真实的压力，否则使用模拟压感
    var force: CGFloat = 1
    
    /// 是否启用压力感应，默认开启
    var forceEnabled = true
    
    private func updateForceFromTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
                
        if forceEnabled {
            force = max(0, touch.force / 3)
        } else {
            // use simulated force
            let vel = velocity(in: targetView)
            var length = vel.distance(to: .zero)
            length = min(length, 5000)
            length = max(100, length)
            force = sqrt(1000 / length)
        }
    }
    
    // MARK: - Touch Handling
    /// due to the delay of pangesture, this is the actural begin point of the gesture
    var acturalBeginLocation: CGPoint = CGPoint.zero

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        /// 修正 pan gesture 的延迟导致的第一个点不正确的问题，
//        if let first = touches.first {
//            acturalBeginLocation = first.location(in: targetView)
//        }
        updateForceFromTouches(touches)
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        updateForceFromTouches(touches)
        super.touchesMoved(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        updateForceFromTouches(touches)
        super.touchesEnded(touches, with: event)
    }
}
