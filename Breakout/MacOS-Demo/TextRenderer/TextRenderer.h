//
//  TextRenderer.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/6/4.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef TextRenderer_h
#define TextRenderer_h

#import "glm.hpp"
#import "Shader.h"
#import <OpenGL/gl3.h>
#import <map>

struct Character {
    //每个字符对应的纹理对象
    GLuint textureID;
    //字形大小
    glm::ivec2 size;
    //从基准线到字形左部/顶部的偏移值
    glm::ivec2 bearing;
    //原点距下一个字形原点的距离
    GLuint advance;
};

class TextRenderer {
    
public:
    
    //字符-纹理字典
    std::map<GLchar, Character> characters;
    
    Shader textShader;
    
    TextRenderer(GLuint width, GLuint height);
    
    //加载字体文件
    void Load(std::string font, GLuint fontSize);
    
    //渲染文本
    void RenderText(std::string text, GLfloat x, GLfloat y, GLfloat scale, glm::vec3 color = glm::vec3(1.0f));
    
private:
    
    GLuint vao, vbo;
};

#endif /* TextRenderer_hpp */
