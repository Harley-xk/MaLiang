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

extension CGSize {
    func fillingRect(in targetRect: CGRect) -> CGRect {
        let rect: CGRect
        let aspect = width / height
        if targetRect.size.width / aspect > targetRect.size.height {
            let height = targetRect.size.width / aspect
            rect = CGRect(x: 0, y: (targetRect.size.height - height) / 2,
                          width: targetRect.size.width, height: height)
        } else {
            let width = targetRect.size.height * aspect
            rect = CGRect(x: (targetRect.size.width - width) / 2, y: 0,
                          width: width, height: targetRect.size.height)
        }
        return rect
    }
}

extension UIImage {
    func resized(in targetRect: CGRect) -> UIImage {
        var newImage = self
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: targetRect)
            newImage = renderer.image { context in
                guard let cgImage = cgImage else { return }
                let rect = size.fillingRect(in: targetRect)
                context.cgContext.draw(cgImage, in: rect)
            }
        } else if let imageRef = cgImage {
            let rect = size.fillingRect(in: targetRect)
            let context =  CGContext(data: nil,
                                     width: Int(targetRect.size.width),
                                     height: Int(targetRect.size.height),
                                     bitsPerComponent: imageRef.bitsPerComponent,
                                     bytesPerRow: 0,
                                     space: imageRef.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                     bitmapInfo: imageRef.bitmapInfo.rawValue)
            context?.interpolationQuality = .high
            context?.draw(imageRef, in: rect)
            if let newImageRef = context?.makeImage() {
                newImage = UIImage(cgImage: newImageRef)
            }
        }
        
        return newImage
    }
}
