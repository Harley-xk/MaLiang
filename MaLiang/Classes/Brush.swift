//
//  Brush.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/6.
//

import Foundation
import OpenGLES
import UIKit


extension MLLine {
    init(begin: CGPoint, end: CGPoint, brush: Brush) {
        let color = brush.color.mlcolorWith(opacity: brush.opacity)
        self.init(begin: begin, end: end, pointSize: brush.pointSize, pointStep: brush.pointStep, color: color)
    }
}

open class Brush {
        
    // opacity of texture, affects the darkness of stroke
    // set opacity to 1 may cause heavy aliasing
    open var opacity: CGFloat = 0.3
    
    // width of stroke line in points
    open var pointSize: CGFloat = 4

    // this property defines the minimum distance (measureed in points) of nearest two textures
    // defaults to 1, this means erery texture calculated will be rendered, dictance calculation will be skiped
    open var pointStep: CGFloat = 1
    
    /// color of stroke
    open var color: UIColor = .black
    
    /// interal texture
    var texture: MLTexture

    public init(texture: UIImage) {
        guard let cgImage = texture.cgImage else {
            fatalError("GLPencil needs a CoreGraphics based image")
        }
        self.texture = MLTexture(image: cgImage)
    }
    
    init(texture: MLTexture) {
        self.texture = texture
    }
}

final class Eraser: Brush {
    
    /// only a global eraser needed
    public static let global = Eraser()
    
    private init() {
        let texture = MLTexture.default.copy()
        texture.gl_blend_enabled = false
        super.init(texture: texture)
        pointSize = 10
        opacity = 1
    }
    
    // color of eraser can't be changed
    override open var color: UIColor {
        get {
            return .clear
        }
        set {
            // set color of eraser will do nothing
        }
    }
}
