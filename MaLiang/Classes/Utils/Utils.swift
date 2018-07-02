//
//  Utils.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/7.
//

import UIKit

struct BundleUtil {
    static var bundle: Bundle {
        var bundle: Bundle = Bundle.main
        let framework = Bundle(for: MLView.classForCoder())
        if let resource = framework.path(forResource: "MaLiang", ofType: "bundle") {
            bundle = Bundle(path: resource) ?? Bundle.main
        }
        return bundle
    }
    
    static func image(name: String) -> UIImage? {
        return UIImage(named: name, in: BundleUtil.bundle, compatibleWith: nil)
    }
}

struct FileUtil {
    static func readData(forResource name: String, withExtension ext: String? = nil) -> Data {
        let url = BundleUtil.bundle.url(forResource: name, withExtension: ext)!
        var source = try! Data(contentsOf: url)
        var trailingNul: UInt8 = 0
        source.append(&trailingNul, count: 1)
        return source
    }
}

// MARK: - Number Extensions

extension Int32 {
    var gluint: GLuint {
        return GLuint(self)
    }

    var int: Int {
        return Int(self)
    }
    
    var float: Float {
        return Float(self)
    }
    
    var uint8: UInt8 {
        return UInt8(self)
    }
}

extension Int {
    var float: Float {
        return Float(self)
    }
    
    var cgfloat: CGFloat {
        return CGFloat(self)
    }
    
    var int32: Int32 {
        return Int32(self)
    }
}

extension CGFloat {
    var float: Float {
        return Float(self)
    }
}

// MARK: - Color Utils
public extension UIColor {
    var mlcolor: MLColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MLColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func mlcolorWith(opacity: CGFloat = 1) -> MLColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MLColor(red: red * opacity, green: green * opacity, blue: blue * opacity, alpha: alpha * opacity)
    }
}

extension UIGestureRecognizer {
    func gl_location(in view: UIView?) -> CGPoint {
        guard let view = view else {
            return .zero
        }
        var location = self.location(in: view)
        location.y = view.bounds.size.height - location.y
        return location
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



