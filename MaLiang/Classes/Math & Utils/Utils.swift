//
//  Utils.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/7.
//

import UIKit
import Metal
import simd

extension Bundle {
    static var maliang: Bundle {
        var bundle: Bundle = Bundle.main
        let framework = Bundle(for: Canvas.self)
        if let resource = framework.path(forResource: "MaLiang", ofType: "bundle") {
            bundle = Bundle(path: resource) ?? Bundle.main
        }
        return bundle
    }
}

extension MTLDevice {
    func libraryForMaLiang() -> MTLLibrary? {
        let framework = Bundle(for: Canvas.self)
        guard let resource = framework.path(forResource: "default", ofType: "metallib") else {
            return nil
        }
        return try? makeLibrary(filepath: resource)
    }
}

extension MTLTexture {
    func clear() {
        let region = MTLRegion(
            origin: MTLOrigin(x: 0, y: 0, z: 0),
            size: MTLSize(width: width, height: height, depth: 1)
        )
        let bytesPerRow = 4 * width
        let data = Data(capacity: Int(bytesPerRow * height))
        if let bytes = data.withUnsafeBytes({ $0.baseAddress }) {
            replace(region: region, mipmapLevel: 0, withBytes: bytes, bytesPerRow: bytesPerRow)
        }
    }
}

// MARK: - Point Utils
extension CGPoint {
    
    func between(min: CGPoint, max: CGPoint) -> CGPoint {
        return CGPoint(x: x.valueBetween(min: min.x, max: max.x),
                       y: y.valueBetween(min: min.y, max: max.y))
    }
    
    // MARK: - Codable utils
    static func make(from ints: [Int]) -> CGPoint {
        return CGPoint(x: CGFloat(ints.first ?? 0) / 10, y: CGFloat(ints.last ?? 0) / 10)
    }
    
    func encodeToInts() -> [Int] {
        return [Int(x * 10), Int(y * 10)]
    }
}

extension CGSize {
    // MARK: - Codable utils
    static func make(from ints: [Int]) -> CGSize {
        return CGSize(width: CGFloat(ints.first ?? 0) / 10, height: CGFloat(ints.last ?? 0) / 10)
    }
    
    func encodeToInts() -> [Int] {
        return [Int(width * 10), Int(height * 10)]
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
    }
}

/// called when saving or reading finished
public typealias ResultHandler = (Result<Void, Error>) -> ()

/// called when saving or reading progress changed
public typealias ProgressHandler = (CGFloat) -> ()


// MARK: - Progress reporting
/// report progress via progresshander on main queue
internal func reportProgress(_ progress: CGFloat, on handler: ProgressHandler?) {
    DispatchQueue.main.async {
        handler?(progress)
    }
}

internal func reportProgress(base: CGFloat, unit: Int, total: Int, on handler: ProgressHandler?) {
    let progress = CGFloat(unit) / CGFloat(total) * (1 - base) + base
    reportProgress(progress, on: handler)
}
