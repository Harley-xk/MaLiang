//
//  Brush.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/6.
//

import Foundation
import OpenGLES
import UIKit

open class Brush: MLPencil {
    
    // opacity of texture, affects the darkness of stroke
    open var opacity: Float = 0.3
    
    // this property defines the minimum distance (measureed in points) of nearest two textures
    // defaults to 1, this means erery texture calculated will be rendered, dictance calculation will be skiped
    open var strokeStep: CGFloat = 1
    
    /// color of stroke
    open var color: UIColor = .black {
        didSet {
            mlColor = color.mlcolorWith(opacity: opacity)
        }
    }
    
    var texture: UIImage

    public init(texture: UIImage) {
        guard let cgImage = texture.cgImage else {
            fatalError("GLPencil needs a CoreGraphics based image")
        }
        self.texture = texture
        super.init(texture: cgImage)
    }
}
