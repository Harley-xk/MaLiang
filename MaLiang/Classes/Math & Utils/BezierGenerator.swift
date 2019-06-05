//
//  BezierGenerator.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/10.
//

import UIKit

class BezierGenerator {

    enum Style {
        case linear
        case quadratic  // this is the only style currently supported
        case cubic
    }
        
    init() {
    }
    
    init(beginPoint: CGPoint) {
        begin(with: beginPoint)
    }
    
    func begin(with point: CGPoint) {
        step = 0
        points.removeAll()
        points.append(point)
    }
    
    func pushPoint(_ point: CGPoint) -> [CGPoint] {
        if point == points.last {
            return []
        }
        points.append(point)
        if points.count < style.pointCount {
            return []
        }
        step += 1
        let result = genericPathPoints()
        return result
    }
    
    func finish() {
        step = 0
        points.removeAll()
    }
    
    var points: [CGPoint] = []
    var style: Style = .quadratic
    
    private var step = 0
    private func genericPathPoints() -> [CGPoint] {
        
        var begin: CGPoint
        var control: CGPoint
        let end = CGPoint.middle(p1: points[step], p2: points[step + 1])

        var vertices: [CGPoint] = []
        if step == 1 {
            begin = points[0]
            let middle1 = CGPoint.middle(p1: points[0], p2: points[1])
            control = CGPoint.middle(p1: middle1, p2: points[1])
        } else {
            begin = CGPoint.middle(p1: points[step - 1], p2: points[step])
            control = points[step]
        }
        
        /// segements are based on distance about start and end point
        let dis = begin.distance(to: end)
        let segements = max(Int(dis / 5), 2)

        for i in 0 ..< segements {
            let t = CGFloat(i) / CGFloat(segements)
            let x = pow(1 - t, 2) * begin.x + 2.0 * (1 - t) * t * control.x + t * t * end.x
            let y = pow(1 - t, 2) * begin.y + 2.0 * (1 - t) * t * control.y + t * t * end.y
            vertices.append(CGPoint(x: x, y: y))
        }
        vertices.append(end)
        return vertices
    }
}

extension BezierGenerator.Style {
    var pointCount: Int {
        switch self {
        case .quadratic: return 3
        default: return Int.max
        }
    }
}

