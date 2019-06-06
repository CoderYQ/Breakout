//
//  SpriteRenderer.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef SpriteRenderer_h
#define SpriteRenderer_h

#import <stdio.h>
#import "Shader.h"
#import "Texture2D.h"

/**
 粒子渲染器: 通过传入着色器程序、纹理、坐标、大小等属性渲染出一个矩形块
 */
class SpriteRenderer {
    
public:
    
    SpriteRenderer(Shader &shader);
    
    ~SpriteRenderer();
    
    void DrawSprite(Texture2D &texture,
                    glm::vec2 position,
                    glm::vec2 size = glm::vec2(10, 10),
                    GLfloat rotate = 0.0f, //旋转角度
                    glm::vec3 color = glm::vec3(1.0f));
private:
    
    Shader shader;
    
    GLuint quadVAO;
    
    void initRenderData();
};

#endif /* SpriteRenderer_hpp */
