//
//  Utils.swift
//  MaLiang
//
//  Created by Harley.xk on 2017/11/7.
//

import UIKit
import OpenGLES

struct BundleUtil {
    static var bundle: Bundle {
        var bundle: Bundle = Bundle.main
        let framework = Bundle(for: Canvas.classForCoder())
        if let resource = framework.path(forResource: "MaLiang", ofType: "bundle") {
            bundle = Bundle(path: resource) ?? Bundle.main
        }
        return bundle
    }
    
    static func image(name: String) -> UIImage? {
        return UIImage(named: name, in: BundleUtil.bundle, compatibleWith: nil)
    }
}

struct FileUtil {
    static func readData(forResource name: String, withExtension ext: String? = nil) -> Data {
        let url = BundleUtil.bundle.url(forResource: name, withExtension: ext)!
        var source = try! Data(contentsOf: url)
        var trailingNul: UInt8 = 0
        source.append(&trailingNul, count: 1)
        return source
    }
}


struct ShaderUtil {
    
    /* Shader Utilities */
    
    /* Compile a shader from the provided source(s) */
    static func compileShader(_ target: GLenum,
        _ count: GLsizei,
        _ sources: UnsafePointer<UnsafePointer<GLchar>?>,
        _ shader: inout GLuint) -> GLint
    {
        var logLength: GLint = 0
        var status: GLint = 0
        
        shader = glCreateShader(target)
        glShaderSource(shader, count, sources, nil)
        glCompileShader(shader)
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH.gluint, &logLength)
        if logLength > 0 {
            let log = UnsafeMutablePointer<CChar>.allocate(capacity: logLength.int)
            glGetShaderInfoLog(shader, logLength, &logLength, log)
            LogInfo("Shader compile log:\n%@", args: String(cString: log))
            log.deallocate(capacity: logLength.int)
        }
        
        glGetShaderiv(shader, GL_COMPILE_STATUS.gluint, &status)
        if status == 0 {
            LogError("Failed to compile shader:\n")
            for i in 0 ..< count.int {
                LogInfo("%@", args: sources[i].map{String(cString: $0)} ?? "")
            }
        }
        LogGLError()
        
        return status
    }
    
    
    /* Link a program with all currently attached shaders */
    static func linkProgram(_ program: GLuint) -> GLint {
        var logLength: GLint = 0, status: GLint = 0
        
        glLinkProgram(program)
        glGetProgramiv(program, GL_INFO_LOG_LENGTH.gluint, &logLength)
        if logLength > 0 {
            let log = UnsafeMutablePointer<CChar>.allocate(capacity: logLength.int)
            glGetProgramInfoLog(program, logLength, &logLength, log)
            LogInfo("Program link log:\n%@", args: String(cString: log))
            log.deallocate(capacity: logLength.int)
        }
        
        glGetProgramiv(program, GL_LINK_STATUS.gluint, &status)
        if status == 0 {
            LogError("Failed to link program %d", args: program)
        }
        LogGLError()
        
        return status
    }
    
    
    /* Validate a program (for i.e. inconsistent samplers) */
    static func validateProgram(_ program: GLuint) -> GLint {
        var logLength: GLint = 0, status: GLint = 0
        
        glValidateProgram(program)
        glGetProgramiv(program, GL_INFO_LOG_LENGTH.gluint, &logLength)
        if logLength > 0 {
            let log = UnsafeMutablePointer<CChar>.allocate(capacity: logLength.int)
            glGetProgramInfoLog(program, logLength, &logLength, log)
            LogInfo("Program validate log:\n%@", args: String(cString: log))
            log.deallocate(capacity: logLength.int)
        }
        
        glGetProgramiv(program, GL_VALIDATE_STATUS.gluint, &status)
        if status == 0 {
            LogError("Failed to validate program %d", args: program)
        }
        LogGLError()
        
        return status
    }
    
    
    /* Return named uniform location after linking */
    static func getUniformLocation(_ program: GLuint, _ uniformName: UnsafePointer<CChar>) -> GLint {
        
        return glGetUniformLocation(program, uniformName)
        
    }
    
    
    /* Shader Conveniences */
    
    /* Convenience wrapper that compiles, links, enumerates uniforms and attribs */
    @discardableResult
    static func createProgram(_ _vertSource: UnsafePointer<CChar>,
        _ _fragSource: UnsafePointer<CChar>,
        _ attribNames: [String],
        _ attribLocations: [GLuint],
        _ uniformNames: [String],
        _ uniformLocations: inout [GLint],
        _ program: inout GLuint) -> GLint
    {
        var vertShader: GLuint = 0, fragShader: GLuint = 0, prog: GLuint = 0, status: GLint = 1
        
        prog = glCreateProgram()
        
        var vertSource: UnsafePointer<CChar>? = _vertSource
        status *= compileShader(GL_VERTEX_SHADER.gluint, 1, &vertSource, &vertShader)
        var fragSource: UnsafePointer<CChar>? = _fragSource
        status *= compileShader(GL_FRAGMENT_SHADER.gluint, 1, &fragSource, &fragShader)
        glAttachShader(prog, vertShader)
        glAttachShader(prog, fragShader)
        
        for i in 0..<attribNames.count {
            if !attribNames[i].isEmpty {
                glBindAttribLocation(prog, attribLocations[i], attribNames[i])
            }
        }
        
        status *= linkProgram(prog)
        status *= validateProgram(prog)
        
        if status != 0 {
            for i in 0..<uniformNames.count {
                if !uniformNames[i].isEmpty {
                    uniformLocations[i] = getUniformLocation(prog, uniformNames[i])
                }
            }
            program = prog
        }
        if vertShader != 0 {
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDeleteShader(fragShader)
        }
        LogGLError()
        
        return status
    }
}

// MARK: - Log Utils

fileprivate func LogInfo(_ format: String, args: CVarArg...) {
    print(String(format: format, arguments: args), terminator: "")
}
fileprivate func LogError(_ format: String, args: CVarArg...) {
    print(String(format: format, arguments: args), terminator: "")
}

fileprivate func LogGLError(_ file: String = #file, line: Int = #line) {
    let err = glGetError()
    if err != GL_NO_ERROR.gluint {
        print("GLError: \(String(err, radix: 16)) caught at \(file):\(line)")
    }
}

// MARK: - Number Extensions

extension Int32 {
    var gluint: GLuint {
        return GLuint(self)
    }

    var int: Int {
        return Int(self)
    }
    
    var float: Float {
        return Float(self)
    }
    
    var uint8: UInt8 {
        return UInt8(self)
    }
}

extension Int {
    var float: Float {
        return Float(self)
    }
    
    var cgfloat: CGFloat {
        return CGFloat(self)
    }
    
    var int32: Int32 {
        return Int32(self)
    }
}

extension CGFloat {
    var float: Float {
        return Float(self)
    }
}

// MARK: - Color Utils
extension UIColor {
    var glcolor: [Float] {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red.float, green.float, blue.float, alpha.float]
    }
    
    func glcolorWith(opacity: Float = 1) -> [Float]{
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red.float * opacity, green.float * opacity, blue.float * opacity, alpha.float * opacity]
    }
}

// MARK: - Point Utils
extension CGPoint {
    static func middle(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }

    func distance(to other: CGPoint) -> CGFloat {
        let p = pow(x - other.x, 2) + pow(y - other.y, 2)
        return sqrt(p)
    }
}



