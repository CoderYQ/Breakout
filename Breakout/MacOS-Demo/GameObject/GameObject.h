//
//  GameObject.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef GameObject_h
#define GameObject_h

#import <OpenGL/OpenGL.h>
#import <stdio.h>
#import "Texture2D.h"
#import "glm.hpp"
#import "ext.hpp"
#import "SpriteRenderer.h"

class GameObject {
    
public:
    
    //        位置信息   尺寸   运动速率
    glm::vec2 position, size, velocity;
    
    glm::vec3 color;
    
    //旋转角度
    GLfloat rotation;
    //是否是实心圆
    bool isSolid;
    //被碰撞了
    bool collided;
    
    Texture2D sprite;
    
    GameObject();
    
    GameObject(glm::vec2 pos,
               glm::vec2 size,
               Texture2D sprite,
               glm::vec3 color = glm::vec3(1.0f),
               glm::vec2 velocity = glm::vec2(0.0f, 0.0f));
    // Draw sprite
    virtual void Draw(SpriteRenderer &renderer);
};

#endif /* GameObject_h */
