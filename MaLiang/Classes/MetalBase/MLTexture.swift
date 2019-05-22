//
//  MLTexture.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/18.
//

import Foundation
import Metal
import UIKit

/// texture with UUID
open class MLTexture: Hashable {
    
    open private(set) var id: String
    
    open private(set) var texture: MTLTexture
    
    init(id: String, texture: MTLTexture) {
        self.id = id
        self.texture = texture
    }

    // size of texture in points
    open lazy var size: CGSize = {
        let scaleFactor = UIScreen.main.nativeScale
        return CGSize(width: CGFloat(texture.width) / scaleFactor, height: CGFloat(texture.height) / scaleFactor)
    }()

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: MLTexture, rhs: MLTexture) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension MTLTexture {
    
    /// get CIImage from this texture
    func toCIImage() -> CIImage? {
        let image = CIImage(mtlTexture: self, options: [.colorSpace: CGColorSpaceCreateDeviceRGB()])
        return image?.oriented(forExifOrientation: 4)
    }
    
    /// get CGImage from this texture
    func toCGImage() -> CGImage? {
        guard let ciimage = toCIImage() else {
            return nil
        }
        let context = CIContext() // Prepare for create CGImage
        let rect = CGRect(origin: .zero, size: ciimage.extent.size)
        return context.createCGImage(ciimage, from: rect)
    }
    
    /// get UIImage from this texture
    func toUIImage() -> UIImage? {
        guard let cgimage = toCGImage() else {
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
    
    /// get data from this texture
    func toData() -> Data? {
        guard let image = toUIImage() else {
            return nil
        }
        return image.pngData()
    }
}
