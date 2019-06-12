//
//  TextRenderer.cpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/6/4.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import "TextRenderer.h"
#import "ResourceManager.h"
#include <ft2build.h>
#import <Foundation/Foundation.h>
#include FT_FREETYPE_H
#import "ext.hpp"

TextRenderer::TextRenderer(GLuint width, GLuint height)
{
    textShader = ResourceManager::LoadShader("text.vs", "text.fs", nullptr, "text");
    glm::mat4 projectionMatrix = glm::ortho(0.0f, static_cast<GLfloat>(width), static_cast<GLfloat>(height), 0.0f);
    textShader.SetMatrix4("projectionMatrix", projectionMatrix, true);
    textShader.SetInteger("textTexture", 0, true);
    textShader.unUse();
    
    glGenVertexArrays(1, &vao);
    glGenBuffers(1, &vbo);
    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 6 * 4, NULL, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

void TextRenderer::Load(std::string font, GLuint fontSize)
{
    characters.clear();
    /**
     1. 初始化字体库
     */
    FT_Library ft;
    if (FT_Init_FreeType(&ft)) printf("初始化FT_Library失败");
    /**
     2. 初始化face
     */
    FT_Face face;
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:font.c_str()] ofType:nil];
    if (FT_New_Face(ft, path.UTF8String, 0, &face)) printf("加载字体失败");
    /**
     3. 设置字体大小
     */
    FT_Set_Pixel_Sizes(face, 0, fontSize);
    /**
     4. 设置字体纹理一字节对齐
     OpenGL要求所有的纹理都是4字节对齐的，即纹理的大小永远是4字节的倍数。通常这并不会出现什么问题，
     因为大部分纹理的宽度都为4的倍数并/或每像素使用4个字节，但是现在我们每个像素只用了一个字节，它可以是任意的宽度。
     通过将纹理解压对齐参数设为1，这样才能确保不会有对齐问题（它可能会造成段错误）
     */
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    for (GLubyte c = 0; c < 128; c ++) {
        if (FT_Load_Char(face, c, FT_LOAD_RENDER)) {
            printf("%c :加载字形失败", c);
            continue;
        }
        //为每一个字符生成字体纹理
        GLuint texture;
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_RED,
                     face->glyph->bitmap.width,
                     face->glyph->bitmap.rows,
                     0,
                     GL_RED,
                     GL_UNSIGNED_BYTE,
                     face->glyph->bitmap.buffer);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        Character character = {
            texture,
            glm::ivec2(face->glyph->bitmap.width, face->glyph->bitmap.rows),
            glm::ivec2(face->glyph->bitmap_left, face->glyph->bitmap_top),
            static_cast<GLuint>(face->glyph->advance.x)
        };
        //记录字符和对应的字体纹理对象
        characters.insert(std::pair<GLchar, Character>(c, character));
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    FT_Done_Face(face);
    FT_Done_FreeType(ft);
}

void TextRenderer::RenderText(std::string text, GLfloat x, GLfloat y, GLfloat scale, glm::vec3 color)
{
    textShader.Use();
    textShader.SetVector3f("textColor", color);
    glActiveTexture(GL_TEXTURE0);
    glBindVertexArray(vao);
    
    std::string::const_iterator c;
    for (c = text.begin(); c != text.end(); c ++) {
        
        Character ch = characters[*c];
        
        GLfloat xpos = x + ch.bearing.x * scale;
        GLfloat ypos = y + (characters['H'].bearing.y - ch.bearing.y) * scale;
        
        GLfloat w = ch.size.x * scale;
        GLfloat h = ch.size.y * scale;
        
        GLfloat vertices[6][4] = {
            { xpos,     ypos + h,   0.0, 1.0 },
            { xpos + w, ypos,       1.0, 0.0 },
            { xpos,     ypos,       0.0, 0.0 },
            { xpos,     ypos + h,   0.0, 1.0 },
            { xpos + w, ypos + h,   1.0, 1.0 },
            { xpos + w, ypos,       1.0, 0.0 }
        };
        glBindTexture(GL_TEXTURE_2D, ch.textureID);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        
        x += (ch.advance >> 6) * scale;
    }
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    textShader.unUse();
}
