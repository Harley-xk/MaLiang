//
//  Utils.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/7.
//

import UIKit
import Metal

extension Bundle {
    static var maliang: Bundle {
        var bundle: Bundle = Bundle.main
        let framework = Bundle(for: Canvas.classForCoder())
        if let resource = framework.path(forResource: "MaLiang", ofType: "bundle") {
            bundle = Bundle(path: resource) ?? Bundle.main
        }
        return bundle
    }
}

extension MTLDevice {
    func libraryForMaLiang() -> MTLLibrary? {
        let framework = Bundle(for: Canvas.classForCoder())
        guard let resource = framework.path(forResource: "default", ofType: "metallib") else {
            return nil
        }
        return try? makeLibrary(filepath: resource)
    }
}

// MARK: - Point Utils
extension CGPoint {
    static func middle(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }

    func distance(to other: CGPoint) -> CGFloat {
        let p = pow(x - other.x, 2) + pow(y - other.y, 2)
        return sqrt(p)
    }
}



