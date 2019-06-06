//
//  BallObject.cpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#include "BallObject.h"
#import <stdio.h>

glm::vec2 BallObject::Move(GLfloat dt, GLuint window_width)
{
    // 如果没有固定在挡板上
    if (!isStuck) {
        position += velocity * dt;
        //1. 碰撞到了窗口的上边界
        if (position.y <= 0.0f)
        {
            velocity.y = -velocity.y;
            position.y = 0.0f;
        }
        //2. 碰撞到了窗口的左边界
        if (position.x <= 0.0f)
        {
            velocity.x = -velocity.x;
            position.x = 0.0f;
        }
        //3. 碰撞到了窗口的右边界
        else if (position.x + size.x >= window_width)
        {
            velocity.x = -velocity.x;
            position.x = window_width - size.x;
        }
    }
    return position;
}

void BallObject::Reset(glm::vec2 position, glm::vec2 velocity)
{
    this->position = position;
    this->velocity = velocity;
    isStuck = true;
    sticky = false;
    passThrough = false;
}
