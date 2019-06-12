//
//  Shader.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef Shader_h
#define Shader_h

#import <OpenGL/gl3.h>
#import <OpenGL/glu.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import <stdio.h>
#import <string>
#import "glm.hpp"

class Shader {
public:
    
    GLuint ID;
    
    Shader() { }
    
    Shader &Use();
    
    void unUse();
    
    void Compile(const GLchar *vertexSource, const GLchar *fragmentSource, const GLchar *geometrySource = nullptr);
    
    void SetFloat    (const GLchar *name, GLfloat value, GLboolean useShader = false);
    
    void SetInteger  (const GLchar *name, GLint value, GLboolean useShader = false);
    
    void SetVector2f (const GLchar *name, GLfloat x, GLfloat y, GLboolean useShader = false);
    
    void SetVector2f (const GLchar *name, const glm::vec2 &value, GLboolean useShader = false);
    
    void SetVector3f (const GLchar *name, GLfloat x, GLfloat y, GLfloat z, GLboolean useShader = false);
    
    void SetVector3f (const GLchar *name, const glm::vec3 &value, GLboolean useShader = false);
    
    void SetVector4f (const GLchar *name, GLfloat x, GLfloat y, GLfloat z, GLfloat w, GLboolean useShader = false);
    
    void SetVector4f (const GLchar *name, const glm::vec4 &value, GLboolean useShader = false);
    
    void SetMatrix4  (const GLchar *name, const glm::mat4 &matrix, GLboolean useShader = false);
    
private:
    
    void CheckCompileErrors(GLuint object, std::string type);
};

#endif /* Shader_hpp */
