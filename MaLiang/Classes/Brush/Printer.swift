//
//  Printer.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/25.
//

import Foundation
import Metal

/// Printer is a special brush witch can print images to canvas
public final class Printer: Brush {
    
    /// make shader fragment function from the library made by makeShaderLibrary()
    /// overrides to provide your own fragment function
    public override func makeShaderFragmentFunction(from library: MTLLibrary) -> MTLFunction? {
        return library.makeFunction(name: "fragment_point_func_original")
    }
    
    /// Blending options for this brush, overrides to implement your own blending options
    public override func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true
        
        attachment.rgbBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        attachment.alphaBlendOperation = .add
        attachment.sourceAlphaBlendFactor = .oneMinusDestinationAlpha
        attachment.destinationAlphaBlendFactor = .one
    }
    
    //
    internal func render(chartlet: Chartlet, on renderTarget: RenderTarget? = nil) {
        
    }
}
