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
        super.init(size: size, pixelFormat: canvas.colorPixelFormat, device: canvas.device)
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
        canvas?.redraw(on: self)
        commitCommands()
    }
}
