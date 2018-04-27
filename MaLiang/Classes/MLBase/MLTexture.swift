//
//  MLTexture.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/22.
//

import Foundation
import CoreGraphics
import OpenGLES

struct CodableTexture: Codable {
    var w: size_t
    var h: size_t
    var bytes: [GLubyte]
    var blend: Bool
}

extension MLTexture {
    var codable: CodableTexture {
        return CodableTexture(w: gl_width, h: gl_height, bytes: gl_data, blend: gl_blend_enabled)
    }
}

open class MLTexture {
    
    static let `default` = MLTexture(image: BundleUtil.image(name: "point")!.cgImage!)
    
    public internal(set) var gl_id: GLuint = 0
    public private(set) var gl_width: size_t
    public private(set) var gl_height: size_t
    public private(set) var gl_data: [GLubyte]
    
    var gl_blend_enabled = true
    
    init(image: CGImage) {
        
        // Get the width and height of the image
        gl_width = image.width
        gl_height = image.height
        // Allocate  memory needed for the bitmap context
        gl_data = [GLubyte](repeating: 0, count: gl_width * gl_height * 4)
        // Use  the bitmatp creation function provided by the Core Graphics framework.
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let brushContext = CGContext(data: &gl_data, width: gl_width, height: gl_height, bitsPerComponent: 8, bytesPerRow: gl_width * 4, space: image.colorSpace!, bitmapInfo: bitmapInfo)
        // After you create the context, you can draw the  image to the context.
        brushContext?.draw(image, in: CGRect(x: 0.0, y: 0.0, width: gl_width.cgfloat, height: gl_height.cgfloat))
    }
    
    func createGLTexture() {
        guard gl_id == 0 else {
            return
        }
        glGenTextures(1, &gl_id)
        // Bind the texture name.
        glBindTexture(GL_TEXTURE_2D.gluint, gl_id)
        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D.gluint, GL_TEXTURE_MIN_FILTER.gluint, GL_LINEAR)
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D.gluint, 0, GL_RGBA, gl_width.int32, gl_height.int32, 0, GL_RGBA.gluint, GL_UNSIGNED_BYTE.gluint, gl_data)
    }
    
    /// copy current texture, the copied obj will share the same texture data with this one
    func copy() -> MLTexture {
        return MLTexture(texture: self)
    }
        
    private init(texture: MLTexture) {
        self.gl_id = texture.gl_id
        self.gl_width = texture.gl_width
        self.gl_height = texture.gl_height
        self.gl_data = texture.gl_data
        self.gl_blend_enabled = texture.gl_blend_enabled
    }

}
