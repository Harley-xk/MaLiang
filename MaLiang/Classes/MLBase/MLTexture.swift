//
//  MLTexture.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/22.
//

import Foundation
import CoreGraphics
import OpenGLES

open class MLTexture {
    
    var gl_id: GLuint = 0
    var gl_width: size_t
    var gl_height: size_t
    var gl_data: [GLubyte]

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
}
