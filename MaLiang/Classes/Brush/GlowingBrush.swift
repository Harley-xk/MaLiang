//
//  GlowingBrush.swift
//  Chrysan
//
//  Created by Harley-xk on 2019/5/5.
//

import Foundation
import CoreGraphics
import Metal

public final class GlowingBrush: Brush {
    
//    /// make shader fragment function from the library made by makeShaderLibrary()
//    /// overrides to provide your own fragment function
//    public override func makeShaderFragmentFunction(from library: MTLLibrary) -> MTLFunction? {
//        return library.makeFunction(name: "fragment_point_func_glowing")
//    }
//
//
//    /// Blending options for this brush, overrides to implement your own blending options
//    public override func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
//        attachment.isBlendingEnabled = true
//
//        attachment.rgbBlendOperation = .add
//        attachment.sourceRGBBlendFactor = .sourceAlpha
//        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
//
//        attachment.alphaBlendOperation = .add
//        attachment.sourceAlphaBlendFactor = .one
//        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
//    }

    
    
    /// size proportion of the core line, must be set between 0 ~ 1, defaults to 0.5
    public var coreProportion: CGFloat = 0.25

    // MARK: - Overrides
    // make properties of subbrush synch with it's parent
    
    public override var pointSize: CGFloat {
        didSet {
            subBrush.pointSize = pointSize * coreProportion
        }
    }
    public override var pointStep: CGFloat {
        didSet {
            subBrush.pointStep = 1
        }
    }
    public override var forceSensitive: CGFloat {
        didSet {
            subBrush.forceSensitive = forceSensitive
        }
    }
    public override var scaleWithCanvas: Bool {
        didSet {
            subBrush.scaleWithCanvas = scaleWithCanvas
        }
    }
    public override var forceOnTap: CGFloat {
        didSet {
            subBrush.forceOnTap = forceOnTap
        }
    }


    // sub brush to render core white line
    private var subBrush: Brush!

    private var pendingCoreLines: [MLLine] = []
    
    // designed initializer, will be called by target when reigster called
    // identifier is not necessary if you won't save the content of your canvas to file
    required public init(name: String?, textureID: UUID?, target: Canvas) {
        super.init(name: name, textureID: textureID, target: target)
        subBrush = Brush(name: self.name + ".sub", textureID: nil, target: target)
        subBrush.color = .white
        subBrush.opacity = 1
    }

    /// get a line with specified begin and end location
    public override func makeLine(from: CGPoint, to: CGPoint, force: CGFloat? = nil) -> [MLLine] {
        let shadowLines = super.makeLine(from: from, to: to, force: force)
        let delta = (pointSize * (1 - coreProportion)) / 2
        var coreLines: [MLLine] = []
        
        while let first = pendingCoreLines.first?.begin, first.distance(to: from) >= delta {
            coreLines.append(pendingCoreLines.removeFirst())
        }
        let lines = subBrush.makeLine(from: from, to: to, force: force)
        pendingCoreLines.append(contentsOf: lines)
        return shadowLines + coreLines
    }
    
    public override func finishLineStrip(at end: Pan) -> [MLLine] {
        let lines = pendingCoreLines
        pendingCoreLines.removeAll()
        return lines
    }
}

