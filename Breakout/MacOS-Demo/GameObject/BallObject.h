//
//  BallObject.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef BallObject_h
#define BallObject_h

#import "GameObject.h"

class BallObject: public GameObject {
    
public:
    
    //球的半径
    GLfloat radius;
    
    //是否被固定在挡板上
    bool isStuck;
    
    //是否允许被粘滞
    GLboolean sticky;
    
    //是否允许被穿透
    GLboolean passThrough;
    
    BallObject() : GameObject(), radius(12.5f), isStuck(true) { }
    
    BallObject(glm::vec2 pos,
               GLfloat radius,
               glm::vec2 velocity,
               Texture2D sprite)
    : GameObject(pos, glm::vec2(radius * 2, radius * 2), sprite, glm::vec3(1.0f), velocity), radius(radius), isStuck(true) {}
    
    glm::vec2 Move(GLfloat dt, GLuint window_width);
    
    //重置小球的位置
    void Reset(glm::vec2 position, glm::vec2 velocity);
};

#endif /* BallObject_hpp */
