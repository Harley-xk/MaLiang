//
//  SnapshotTarget.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/18.
//

import Foundation
import UIKit

/// Snapshoting Target, used for snapshot
open class SnapshotTarget: RenderTarget {
    
    private weak var canvas: Canvas?

    /// create target specified with a canvas
    public init(canvas: Canvas) {
        self.canvas = canvas
        var size = canvas.bounds.size
        if let scrollable = canvas as? ScrollableCanvas {
            size = scrollable.contentSize * scrollable.contentScaleFactor
        }
        super.init(size: size, device: canvas.device)
    }
    
    /// get UIImage from canvas content
    ///
    /// - Returns: UIImage, nil if failed
    open func getImage() -> UIImage? {
        syncContent()
        return texture?.toUIImage()
    }
    
    /// get CIImage from canvas content
    open func getCIImage() -> CIImage? {
        syncContent()
        return texture?.toCIImage()
    }
    
    /// get CGImage from canvas content
    open func getCGImage() -> CGImage? {
        syncContent()
        return texture?.toCGImage()
    }
    
    private func syncContent() {
        canvas?.redraw(on: self, display: false)
        commitCommands()
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
}
