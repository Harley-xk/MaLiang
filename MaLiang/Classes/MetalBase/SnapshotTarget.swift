//
//  SnapshotTarget.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/18.
//

import Foundation

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
        guard let cgimage = getCGImage() else {
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
    
    /// get CIImage from canvas content
    open func getCIImage() -> CIImage? {
        canvas?.redraw(on: self, display: false)
        commitCommands()
        if let texture = texture, let ciimage = CIImage(mtlTexture: texture, options: nil) {
            return ciimage.oriented(forExifOrientation: 4)
        }
        return nil
    }
    
    /// get CGImage from canvas content
    open func getCGImage() -> CGImage? {
        guard let ciimage = getCIImage() else {
            return nil
        }
        let context = CIContext() // Prepare for create CGImage
        let rect = CGRect(origin: .zero, size: drawableSize)
        return context.createCGImage(ciimage, from: rect)
    }
}
