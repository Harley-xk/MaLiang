//
//  ShaderUtil.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/12.
//

import Foundation
import OpenGLES

public struct ShaderUtil {
    
    /* Shader Utilities */
    /* Compile a shader from the provided source(s) */
    public static func compileShader(_ target: GLenum, _ count: GLsizei, _ sources: UnsafePointer<UnsafePointer<GLchar>?>, _ shader: inout GLuint) -> GLint {
        var status: GLint = 0        
        shader = glCreateShader(target)
        glShaderSource(shader, count, sources, nil)
        glCompileShader(shader)
        glGetShaderiv(shader, GL_COMPILE_STATUS.gluint, &status)
        return status
    }
    
    
    /* Link a program with all currently attached shaders */
    public static func linkProgram(_ program: GLuint) -> GLint {
        var status: GLint = 0
        glLinkProgram(program)
        glGetProgramiv(program, GL_LINK_STATUS.gluint, &status)
        return status
    }
    
    
    /* Validate a program (for i.e. inconsistent samplers) */
    public static func validateProgram(_ program: GLuint) -> GLint {
        var status: GLint = 0
        glValidateProgram(program)
        glGetProgramiv(program, GL_VALIDATE_STATUS.gluint, &status)
        return status
    }
    
    
    /* Return named uniform location after linking */
    public static func getUniformLocation(_ program: GLuint, _ uniformName: UnsafePointer<CChar>) -> GLint {
        return glGetUniformLocation(program, uniformName)
    }
    
    
    /* Shader Conveniences */
    /* Convenience wrapper that compiles, links, enumerates uniforms and attribs */
    @discardableResult
    public static func createProgram(_ _vertSource: UnsafePointer<CChar>, _ _fragSource: UnsafePointer<CChar>, _ attribNames: [String], _ attribLocations: [GLuint], _ uniformNames: [String], _ uniformLocations: inout [GLint], _ program: inout GLuint) -> GLint {
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
        
        return status
    }
}

