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
    
    open private(set) var id: UUID
    
    open private(set) var texture: MTLTexture
    
    init(id: UUID, texture: MTLTexture) {
        self.id = id
        self.texture = texture
    }
    
    open var width: CGFloat {
        return CGFloat(texture.width)
    }
    
    open var height: CGFloat {
        return CGFloat(texture.height)
    }
    
    open var size: CGSize {
        return CGSize(width: width, height: height)
    }

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
        return CIImage(mtlTexture: self, options: nil)?.oriented(forExifOrientation: 4)
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
