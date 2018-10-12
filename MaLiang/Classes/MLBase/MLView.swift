//
//  MLView.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/6.
//

import UIKit
import OpenGLES
import GLKit

struct Uniform {
    static let mvp = 0
    static let pointSize = 1
    static let vertexColor = 2
    static let texture = 3
    static let count = 4
}

struct Attribute {
    static let vertex: GLuint = 0
    static let count: GLuint = 1
}

open class MLView: UIView {
    
    // MARK: - Functions
    // Erases the screen, redisplay the buffer if display sets to true
    open func clear(display: Bool = true) {
        EAGLContext.setCurrent(context)
        
        // Clear the buffer
        glBindFramebuffer(GL_FRAMEBUFFER.gluint, viewFramebuffer)
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClear(GL_COLOR_BUFFER_BIT.gluint)
        
        if display {
            displayBuffer()
        }
    }
    
    /// current scale of canvas, will set stroke line size to fit this
    public internal(set) var scale: CGFloat = 1
    
    // MARK: - Color & Testure
    
    // last rendered color
    private var currentColor: MLColor = .default
    
    // change glcolor if brush color changed
    private func updateColor(to newColor: MLColor) {
        guard currentColor != newColor else {
            return
        }
        // Update the brush color
        if initialized {
            glUniform4fv(shaderProgram.uniform[Uniform.vertexColor], 1, newColor.glColor)
            currentColor = newColor
        }
    }
    
    /// currently used texture
    open var texture: MLTexture! {
        didSet {
            cacheTextureIfNeeds(texture)
            glBindTexture(GL_TEXTURE_2D.gluint, texture.gl_id)
            if texture.gl_blend_enabled {
                glEnable(GL_BLEND.gluint)
            } else {
                glDisable(GL_BLEND.gluint)
                glColor4f(0, 0, 0, 0)
            }
        }
    }
    
    func getCachedTexture(with id: GLuint) -> MLTexture? {
        return cachedTextures.first{ $0.gl_id == id }
    }
    
    /// Cache a texture if not cached
    private var cachedTextures: [MLTexture] = []
    private func cacheTextureIfNeeds(_ texture: MLTexture) {
        
        /// ignore already cached texture
        guard texture.gl_id == 0 else {
            return
        }
        
        /// create gl texture and get an id
        texture.createGLTexture()
        
        /// default Texture is hold by mlview, needn't to be cached
        if texture.gl_id != MLTexture.default.gl_id {
            cachedTextures.append(texture)
        }
    }
    
    /// clear all cachedTexture when delloac or memery warnings
    open func clearCachedTextures() {
        let ids = cachedTextures.compactMap{ $0.gl_id }
        glDeleteTextures(ids.count.int32, ids)
    }
    
    // MARK: - Private Property
    // The pixel dimensions of the backbuffer
    private var backingWidth: GLint = 0
    private var backingHeight: GLint = 0
    
    private var context: EAGLContext!
    
    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    private var viewRenderbuffer: GLuint = 0
    private var viewFramebuffer: GLuint = 0
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    private var depthRenderbuffer: GLuint = 0
    
    private var needsClear: Bool = false
    
    // Shader objects
    private var vertexShader: GLuint = 0
    private var fragmentShader: GLuint = 0
    private var shaderProgram: ShaderProgram!
    
    
    // Buffer Objects
    private var vboId: GLuint = 0
    
    private var initialized: Bool = false
    
    // Implement this to override the default layer class (which is [CALayer class]).
    // We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
    override open class var layerClass : AnyClass {
        return CAEAGLLayer.self
    }
    
    private var glLayer: CAEAGLLayer {
        return layer as! CAEAGLLayer
    }
    
    struct ShaderProgram {
        
        static let point = 0
        
        var vert: String
        var frag: String
        var uniform: [GLint]
        var id: GLuint
    }
    
    // MARK: - Initialize
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    open func setup() {
        
        let uniform: [GLint] = Array(repeating: 0, count: Uniform.count)
        shaderProgram = ShaderProgram(vert: "point.vsh", frag: "point.fsh", uniform: uniform, id: 0)
        
        glLayer.isOpaque = false
        
        // In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
        glLayer.drawableProperties = [
            kEAGLDrawablePropertyRetainedBacking: true,
            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ]
        
        context = EAGLContext(api: .openGLES3)
        
        if context == nil || !EAGLContext.setCurrent(context) {
            fatalError("EAGLContext cannot be created")
        }
        
        // Set the view's scale factor as you wish
        contentScaleFactor = UIScreen.main.scale
        
        // Make sure to start with a cleared buffer
        needsClear = true
        
        // initializ OpenGL
        initialized = initGL()
    }
    
    // If our view is resized, we'll be asked to layout subviews.
    // This is the perfect opportunity to also update the framebuffer so that it is
    // the same size as our display area.
    override open func layoutSubviews() {
        
        EAGLContext.setCurrent(context)
        
        if !initialized {
            initialized = initGL()
        } else {
            resize(from: glLayer)
        }
        
        // Clear the framebuffer the first time it is allocated
        if needsClear {
            clear(display: false)
            needsClear = false
        }
    }
    
    private func setupShaders() {
        
        let vsrc = FileUtil.readData(forResource: shaderProgram.vert)
        let fsrc = FileUtil.readData(forResource: shaderProgram.frag)
        
        var attribUsed: [String] = []
        var attrib: [GLuint] = []
        let attribName: [String] = ["inVertex"]
        let uniformName: [String] = ["MVP", "pointSize", "vertexColor", "texture"]
        
        var prog: GLuint = 0
        vsrc.withUnsafeBytes {(vsrcChars: UnsafePointer<GLchar>) in
            
            // auto-assign known attribs
            for (j, name) in attribName.enumerated() {
                if strstr(vsrcChars, name) != nil {
                    attrib.append(GLuint(j))
                    attribUsed.append(name)
                }
            }
            
            fsrc.withUnsafeBytes {(fsrcChars: UnsafePointer<GLchar>) in
                _ = ShaderUtil.createProgram(UnsafeMutablePointer(mutating: vsrcChars), UnsafeMutablePointer(mutating: fsrcChars),
                                             attribUsed, attrib,
                                             uniformName, &shaderProgram.uniform,
                                             &prog)
            }
        }
        shaderProgram.id = prog
        
        glUseProgram(shaderProgram.id)
        
        // the brush texture will be bound to texture unit 0
        glUniform1i(shaderProgram.uniform[Uniform.texture], 0)
        
        // viewing matrices
        let projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth.float, 0, backingHeight.float, -1, 1)
        let modelViewMatrix = GLKMatrix4Identity
        var MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
        
        withUnsafePointer(to: &MVPMatrix) {ptrMVP in
            ptrMVP.withMemoryRebound(to: GLfloat.self, capacity: 16) {ptrGLfloat in
                glUniformMatrix4fv(shaderProgram.uniform[Uniform.mvp], 1, GL_FALSE.uint8, ptrGLfloat)
            }
        }
        
        // initialize brush color
        glUniform4fv(shaderProgram.uniform[Uniform.vertexColor], 1, currentColor.glColor)
    }
    
    private func initGL() -> Bool {
        // Generate IDs for a framebuffer object and a color renderbuffer
        glGenFramebuffers(1, &viewFramebuffer)
        glGenRenderbuffers(1, &viewRenderbuffer)
        
        glBindFramebuffer(GL_FRAMEBUFFER.gluint, viewFramebuffer)
        glBindRenderbuffer(GL_RENDERBUFFER.gluint, viewRenderbuffer)
        // This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
        // allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
        context.renderbufferStorage(GL_RENDERBUFFER.int, from: glLayer)
        glFramebufferRenderbuffer(GL_FRAMEBUFFER.gluint, GL_COLOR_ATTACHMENT0.gluint, GL_RENDERBUFFER.gluint, viewRenderbuffer)
        
        glGetRenderbufferParameteriv(GL_RENDERBUFFER.gluint, GL_RENDERBUFFER_WIDTH.gluint, &backingWidth)
        glGetRenderbufferParameteriv(GL_RENDERBUFFER.gluint, GL_RENDERBUFFER_HEIGHT.gluint, &backingHeight)
        
        // For this sample, we do not need a depth buffer. If you do, this is how you can create one and attach it to the framebuffer:
        //    glGenRenderbuffers(1, &depthRenderbuffer);
        //    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        //    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
        //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        if glCheckFramebufferStatus(GL_FRAMEBUFFER.gluint) != GL_FRAMEBUFFER_COMPLETE.gluint {
            NSLog("failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER.gluint))
            return false
        }
        
        // Setup the view port in Pixels
        glViewport(0, 0, backingWidth, backingHeight)
        
        // Create a Vertex Buffer Object to hold our data
        glGenBuffers(1, &vboId)
        
        // Load the default texture
        texture = MLTexture.default
        
        // Load shaders
        self.setupShaders()
        
        // Enable blending and set a blending function appropriate for premultiplied alpha pixel data
        glEnable(GL_BLEND.gluint)
        glBlendFunc(GL_ONE.gluint, GL_ONE_MINUS_SRC_ALPHA.gluint)
        
        return true
    }
    
    @discardableResult
    private func resize(from layer: CAEAGLLayer) -> Bool {
        
        // Allocate color buffer backing based on the current layer size
        glBindRenderbuffer(GL_RENDERBUFFER.gluint, viewRenderbuffer)
        context.renderbufferStorage(GL_RENDERBUFFER.int, from: layer)
        glGetRenderbufferParameteriv(GL_RENDERBUFFER.gluint, GL_RENDERBUFFER_WIDTH.gluint, &backingWidth)
        glGetRenderbufferParameteriv(GL_RENDERBUFFER.gluint, GL_RENDERBUFFER_HEIGHT.gluint, &backingHeight)
        
        // For this sample, we do not need a depth buffer. If you do, this is how you can allocate depth buffer backing:
        //    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        //    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
        //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        if glCheckFramebufferStatus(GL_FRAMEBUFFER.gluint) != GL_FRAMEBUFFER_COMPLETE.gluint {
            NSLog("Failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER.gluint))
            return false
        }
        
        // Update projection matrix
        let projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth.float, 0, backingHeight.float, -1, 1)
        let modelViewMatrix = GLKMatrix4Identity // this sample uses a constant identity modelView matrix
        var MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
        
        withUnsafePointer(to: &MVPMatrix) { ptrMVP in
            ptrMVP.withMemoryRebound(to: GLfloat.self, capacity: 16) {ptrGLfloat in
                glUniformMatrix4fv(shaderProgram.uniform[Uniform.mvp], 1, GL_FALSE.uint8, ptrGLfloat)
            }
        }
        
        // Update viewport
        glViewport(0, 0, backingWidth, backingHeight)
        
        return true
    }
    
    // Releases resources when they are not longer needed.
    deinit {
        // Destroy framebuffers and renderbuffers
        if viewFramebuffer != 0 {
            glDeleteFramebuffers(1, &viewFramebuffer)
        }
        if viewRenderbuffer != 0 {
            glDeleteRenderbuffers(1, &viewRenderbuffer)
        }
        if depthRenderbuffer != 0 {
            glDeleteRenderbuffers(1, &depthRenderbuffer)
        }
        // texture
        clearCachedTextures()
        glDeleteTextures(1, &MLTexture.default.gl_id)
        // vbo
        if vboId != 0 {
            glDeleteBuffers(1, &vboId)
        }
        
        // tear down context
        if EAGLContext.current() === context {
            EAGLContext.setCurrent(nil)
        }
    }
    
    
    private func renderLines(_ lines: [MLLine]) {
        
        for line in lines {
            renderLine(line, display: false)
        }
        
        displayBuffer()        
    }
    
    // Drawings a line onscreen based on where the user touches
    open func renderLine(_ line: MLLine, display: Bool = true) {
        
        EAGLContext.setCurrent(context)
        glBindFramebuffer(GL_FRAMEBUFFER.gluint, viewFramebuffer)
        
        // Convert locations from Points to Pixels
        let scale = self.contentScaleFactor
        var start = line.begin
        start.x *= scale
        start.y *= scale
        var end = line.end
        end.x *= scale
        end.y *= scale
        
        // Allocate vertex array buffer
        var vertexBuffer: [GLfloat] = []
        
        // Add points to the buffer so there are drawing points every X pixels
        let count = max(Int(ceilf(sqrtf((end.x - start.x).float * (end.x - start.x).float + (end.y - start.y).float * (end.y - start.y).float) / (contentScaleFactor.float * line.pointStep.float)) * self.scale.float) + 1, 1)
        
        vertexBuffer.reserveCapacity(count * 2)
        vertexBuffer.removeAll(keepingCapacity: true)
        for i in 0 ..< count {
            vertexBuffer.append(start.x.float + (end.x - start.x).float * (i.float / count.float))
            vertexBuffer.append(start.y.float + (end.y - start.y).float * (i.float / count.float))
        }
        
        /// update color if needs
        updateColor(to: line.color)
        
        // Load data to the Vertex Buffer Object
        glBindBuffer(GL_ARRAY_BUFFER.gluint, vboId)
        glBufferData(GL_ARRAY_BUFFER.gluint, count * 2 * MemoryLayout<GLfloat>.size, vertexBuffer, GL_DYNAMIC_DRAW.gluint)
        
        glEnableVertexAttribArray(Attribute.vertex)
        glVertexAttribPointer(Attribute.vertex, 2, GL_FLOAT.gluint, GL_FALSE.uint8, 0, nil)
        
        // set line size
        glUniform1f(shaderProgram.uniform[Uniform.pointSize], GLfloat(line.pointSize) * GLfloat(contentScaleFactor) / GLfloat(self.scale))
        
        // Draw
        glDrawArrays(GL_POINTS.gluint, 0, count.int32)
        
        if display {
            displayBuffer()
        }
    }
    
    func displayBuffer() {
        // Display the buffer
        glBindRenderbuffer(GL_RENDERBUFFER.gluint, viewRenderbuffer)
        context.presentRenderbuffer(GL_RENDERBUFFER.int)
    }
    
}
