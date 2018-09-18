//
//  Brush.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/6.
//

import Foundation
import OpenGLES
import UIKit

public struct Pan {
    var point: CGPoint
    var force: CGFloat
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
    
    // sensitive of pointsize changed from force, from 0 - 1
    open var forceSensitive: CGFloat = 0
    
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
    
    open func line(from: CGPoint, to: CGPoint) -> MLLine {
        let color = self.color.mlcolorWith(opacity: opacity)
        return MLLine(begin: from, end: to, pointSize: pointSize, pointStep: pointStep, color: color)
    }
    
    open func pan(from: Pan, to: Pan) -> MLLine {
        let color = self.color.mlcolorWith(opacity: opacity)
        var endForce = from.force * 0.95 + to.force * 0.05
        endForce = pow(endForce, forceSensitive)
        let line = MLLine(begin: from.point, end: to.point, pointSize: pointSize * endForce, pointStep: pointStep, color: color)
        return line
    }
}

final class Eraser: Brush {
    
    /// only a global eraser needed
    public static let global = Eraser()
    
    private init() {
        let texture = MLTexture(image: BundleUtil.image(name: "point")!.cgImage!)
        texture.gl_blend_enabled = false
        super.init(texture: texture)
        pointSize = 10
        opacity = 1
        forceSensitive = 0
    }
    
    // color of eraser can't be changed
    override public var color: UIColor {
        get {
            return .clear
        }
        set {
            // set color of eraser will do nothing
        }
    }
}
