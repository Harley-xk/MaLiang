//
//  MLCanvas.swift
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

struct Line {
    var start: CGPoint
    var end: CGPoint
}

open class Canvas: UIView {
    
    // MARK: - Open Property
    open var brush: Brush {
        willSet {
            if brush.id != 0 {
                glDeleteTextures(1, &brush.id)
            }
        }
        didSet {
            if initialized {
                brush.createTexture()
                glUseProgram(programs[ShaderProgram.point].id)
                glUniform1f(programs[ShaderProgram.point].uniform[Uniform.pointSize], GLfloat(brush.strokeWidth) * GLfloat(contentScaleFactor))

                // alpha changed with different brushes, so color needs to be reset
                resetColor()
            }
        }
    }
    
    open var brushColor: UIColor = .black {
        didSet {
            // Update the brush color
            resetColor()
        }
    }
    
    // optimize stroke with bezier path, defaults to true
    private var enableBezierPath = true
    
    // MARK: - Functions
    // Erases the screen
    open func erase() {
        EAGLContext.setCurrent(context)
        
        // Clear the buffer
        glBindFramebuffer(GL_FRAMEBUFFER.gluint, viewFramebuffer)
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClear(GL_COLOR_BUFFER_BIT.gluint)
        
        // Display the buffer
        glBindRenderbuffer(GL_RENDERBUFFER.gluint, viewRenderbuffer)
        context.presentRenderbuffer(GL_RENDERBUFFER.int)
    }
    
    private func resetColor() {
        // Update the brush color
        let glcolor = brushColor.glcolorWith(opacity: brush.opacity)
        if initialized {
            glUseProgram(programs[ShaderProgram.point].id)
            glUniform4fv(programs[ShaderProgram.point].uniform[Uniform.vertexColor], 1, glcolor)
        }
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
    
    private var firstTouch: Bool = false
    private var needsErase: Bool = false
    
    // Shader objects
    private var vertexShader: GLuint = 0
    private var fragmentShader: GLuint = 0
    private var programs: [ShaderProgram]
    
    
    // Buffer Objects
    private var vboId: GLuint = 0
    
    private var initialized: Bool = false
    
    private var location: CGPoint = CGPoint()
    private var previousLocation: CGPoint = CGPoint()
    
    private var bezierGenerator = BezierGenerator()
    
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
    // The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
    required public init?(coder: NSCoder) {
        
        brush = Brush(texture: BundleUtil.image(name: "point")!)
        programs = [ShaderProgram(
            vert: "point.vsh",
            frag: "point.fsh",
            uniform: Array(repeating: 0, count: Uniform.count),
            id: 0
            )]
        
        super.init(coder: coder)
        
        guard let _ = self.layer as? CAEAGLLayer else {
            return nil
        }
        
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
        needsErase = true
    }
    
    // If our view is resized, we'll be asked to layout subviews.
    // This is the perfect opportunity to also update the framebuffer so that it is
    // the same size as our display area.
    override open func layoutSubviews() {
        
        EAGLContext.setCurrent(context)
        
        if !initialized {
            initialized = initGL()
            brushColor = .black
        } else {
            resize(from: glLayer)
        }
        
        // Clear the framebuffer the first time it is allocated
        if needsErase {
            erase()
            needsErase = false
        }
    }
    
    private func setupShaders() {
        
        for i in 0 ..< programs.count {
            
            let vsrc = FileUtil.readData(forResource: programs[i].vert)
            let fsrc = FileUtil.readData(forResource: programs[i].frag)
            
            var attribUsed: [String] = []
            var attrib: [GLuint] = []
            let attribName: [String] = [
                "inVertex",
                ]
            let uniformName: [String] = [
                "MVP", "pointSize", "vertexColor", "texture",
                ]
            
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
                                                 uniformName, &programs[i].uniform,
                                                 &prog)
                }
            }
            programs[i].id = prog
            
            if i == ShaderProgram.point {
                glUseProgram(programs[ShaderProgram.point].id)
                
                // the brush texture will be bound to texture unit 0
                glUniform1i(programs[ShaderProgram.point].uniform[Uniform.texture], 0)
                
                // viewing matrices
                let projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth.float, 0, backingHeight.float, -1, 1)
                let modelViewMatrix = GLKMatrix4Identity
                var MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
                
                withUnsafePointer(to: &MVPMatrix) {ptrMVP in
                    ptrMVP.withMemoryRebound(to: GLfloat.self, capacity: 16) {ptrGLfloat in
                        glUniformMatrix4fv(programs[ShaderProgram.point].uniform[Uniform.mvp], 1, GL_FALSE.uint8, ptrGLfloat)
                    }
                }
                
                // point size
                glUniform1f(programs[ShaderProgram.point].uniform[Uniform.pointSize], GLfloat(brush.strokeWidth) * GLfloat(contentScaleFactor))

                // initialize brush color
                glUniform4fv(programs[ShaderProgram.point].uniform[Uniform.vertexColor], 1, brushColor.glcolor)
                
            }
        }
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
        
        // Load the brush texture
        if brush.id == 0 {
            brush.createTexture()
        }
        
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
        
        glUseProgram(programs[ShaderProgram.point].id)
        withUnsafePointer(to: &MVPMatrix) { ptrMVP in
            ptrMVP.withMemoryRebound(to: GLfloat.self, capacity: 16) {ptrGLfloat in
                glUniformMatrix4fv(programs[ShaderProgram.point].uniform[Uniform.mvp], 1, GL_FALSE.uint8, ptrGLfloat)
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
        if brush.id != 0 {
            glDeleteTextures(1, &brush.id)
        }
        // vbo
        if vboId != 0 {
            glDeleteBuffers(1, &vboId)
        }
        
        // tear down context
        if EAGLContext.current() === context {
            EAGLContext.setCurrent(nil)
        }
    }
    
    override open var canBecomeFirstResponder : Bool {
        return true
    }
    
    // MARK: - Drawing Actions
    private var lastRenderedPoint: CGPoint?
    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator) {
        let vertices = bezier.pushPoint(point)
        if vertices.count >= 2 {
            var lastPoint = lastRenderedPoint ?? vertices[0]
            for i in 1 ..< vertices.count {
                let p = vertices[i]
                if brush.strokeWidth <= 1 ||
                   (brush.strokeWidth > 1 && lastPoint.distance(to: p) >= brush.strokeStep) {
                    self.renderLine(from: lastPoint, to: p, display: false)
                    lastPoint = p
                    lastRenderedPoint = p
                }
            }
        }
        displayBuffer()
    }
    
    private func renderLines(_ lines: [Line]) {
        
        for line in lines {
            renderLine(from: line.start, to: line.end, display: false)
        }
        
        // Display the buffer
        glBindRenderbuffer(GL_RENDERBUFFER.gluint, viewRenderbuffer)
        context.presentRenderbuffer(GL_RENDERBUFFER.int)
    }
    
    // Drawings a line onscreen based on where the user touches
    private func renderLine(from _start: CGPoint, to _end: CGPoint, display: Bool = true) {
        
        EAGLContext.setCurrent(context)
        glBindFramebuffer(GL_FRAMEBUFFER.gluint, viewFramebuffer)
        
        // Convert locations from Points to Pixels
        let scale = self.contentScaleFactor
        var start = _start
        start.x *= scale
        start.y *= scale
        var end = _end
        end.x *= scale
        end.y *= scale
        
        // Allocate vertex array buffer
        var vertexBuffer: [GLfloat] = []
        
        // Add points to the buffer so there are drawing points every X pixels
        let count = max(Int(ceilf(sqrtf((end.x - start.x).float * (end.x - start.x).float + (end.y - start.y).float * (end.y - start.y).float) / (brush.strokeStep * contentScaleFactor).float)), 1)
        vertexBuffer.reserveCapacity(count * 2)
        vertexBuffer.removeAll(keepingCapacity: true)
        for i in 0 ..< count {
            vertexBuffer.append(start.x.float + (end.x - start.x).float * (i.float / count.float))
            vertexBuffer.append(start.y.float + (end.y - start.y).float * (i.float / count.float))
        }
        
        // Load data to the Vertex Buffer Object
        glBindBuffer(GL_ARRAY_BUFFER.gluint, vboId)
        glBufferData(GL_ARRAY_BUFFER.gluint, count * 2 * MemoryLayout<GLfloat>.size, vertexBuffer, GL_DYNAMIC_DRAW.gluint)
        
        
        glEnableVertexAttribArray(Attribute.vertex)
        glVertexAttribPointer(Attribute.vertex, 2, GL_FLOAT.gluint, GL_FALSE.uint8, 0, nil)
        
        // Draw
        glUseProgram(programs[ShaderProgram.point].id)
        glDrawArrays(GL_POINTS.gluint, 0, count.int32)
        
        if display {
            displayBuffer()
        }
    }
    
    private func displayBuffer() {
        // Display the buffer
        glBindRenderbuffer(GL_RENDERBUFFER.gluint, viewRenderbuffer)
        context.presentRenderbuffer(GL_RENDERBUFFER.int)
    }
    
    // MARK: - Gestures
    
    // Handles the start of a touch
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        firstTouch = true
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        location = touch.location(in: self)
        location.y = bounds.size.height - location.y
        
        lastRenderedPoint = location
        if enableBezierPath {
            bezierGenerator.begin(with: location)
        }
    }
    
    // Handles the continuation of a touch.
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        if firstTouch {
            firstTouch = false
            previousLocation = location
        } else {
            previousLocation = touch.previousLocation(in: self)
            previousLocation.y = bounds.size.height - previousLocation.y
        }
        
        location = touch.location(in: self)
        location.y = bounds.size.height - location.y
        
        if enableBezierPath {
            // Render the stroke with bezier optmized path
            pushPoint(location, to: bezierGenerator)
        } else {
            // Render the stroke directly
            self.renderLine(from: previousLocation, to: location)
        }
        
    }
    
    // Handles the end of a touch event when the touch is a tap.
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        if firstTouch {
            firstTouch = false
            previousLocation = touch.previousLocation(in: self)
            previousLocation.y = bounds.size.height - previousLocation.y
            self.renderLine(from: previousLocation, to: location)
        }
        
        if enableBezierPath {
            pushPoint(location, to: bezierGenerator)
            bezierGenerator.finish()
        }
    }
    
    // Handles the end of a touch event.
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If appropriate, add code necessary to save the state of the application.
        // This application is not saving state.
    }
}
