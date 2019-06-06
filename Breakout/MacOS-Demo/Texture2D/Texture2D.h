//
//  Texture2D.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef Texture2D_h
#define Texture2D_h

#import <stdio.h>
#import <OpenGL/gl3.h>
#import <OpenGL/glu.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>

class Texture2D {
    
public:
    // Holds the ID of the texture object, used for all texture operations to reference to this particlar texture
    GLuint ID;
    // Texture image dimensions
    GLuint width, height; // Width and height of loaded image in pixels
    // Texture Format
    GLuint internal_Format; // Format of texture object
    GLuint image_Format; // Format of loaded image
    // Texture configuration
    GLuint wrap_S; // Wrapping mode on S axis
    GLuint wrap_T; // Wrapping mode on T axis
    GLuint filter_Min; // Filtering mode if texture pixels < screen pixels
    GLuint filter_Max; // Filtering mode if texture pixels > screen pixels
    
    // Constructor (sets default texture modes)
    Texture2D();
    
    // Generates texture from image data
    void Generate(GLuint width, GLuint height, unsigned char *data);
    
    // Binds the texture as the current active GL_TEXTURE_2D texture object
    void Bind() const;
};

#endif /* Texture2D_hpp */
