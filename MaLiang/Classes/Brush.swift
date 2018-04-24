//
//  Brush.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/6.
//

import Foundation
import OpenGLES
import UIKit

open class Brush {
    
    // opacity of texture, affects the darkness of stroke
    // set opacity to 1 may cause heavy aliasing
    open var opacity: CGFloat = 0.3
    
    // width of stroke line in points
    open var pointSize: CGFloat = 4 {
        didSet {
            pencil.pointSize = pointSize
        }
    }

    // this property defines the minimum distance (measureed in points) of nearest two textures
    // defaults to 1, this means erery texture calculated will be rendered, dictance calculation will be skiped
    open var pointStep: CGFloat = 1 {
        didSet {
            pencil.pointStep = pointStep
        }
    }
    
    /// color of stroke
    open var color: UIColor = .black {
        didSet {
            pencil.mlColor = color.mlcolorWith(opacity: opacity)
        }
    }
    
    var texture: UIImage {
        return UIImage(cgImage: pencil.gl_texture)
    }
    
    var pencil: MLPencil

    public init(texture: UIImage) {
        guard let cgImage = texture.cgImage else {
            fatalError("GLPencil needs a CoreGraphics based image")
        }
        self.pencil = MLPencil(texture: cgImage)
    }
    
    init(pencil: MLPencil) {
        self.pencil = pencil
    }
}
