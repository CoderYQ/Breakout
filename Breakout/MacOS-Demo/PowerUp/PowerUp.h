//
//  PowerUp.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/6/4.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef PowerUp_h
#define PowerUp_h

#import "GameObject.h"

const glm::vec2 SIZE(60, 20);

const glm::vec2 VELOCITY(0.0f, 150.0f);

class PowerUp: public GameObject {
    
public:
    
    /**
     道具的类型:
     speed: 加锁道具
     sticky: 粘滞道具
     pass-through: 穿透道具
     pad-size-increase: 挡板加长道具
     confuse: 翻转道具
     chaos: 晃动道具
     */
    std::string type;
    
    //道具的持续时长
    GLfloat duration;
    
    //道具目前是否被激活
    GLboolean activated;
    
    PowerUp(std::string type, //类型
            glm::vec3 color, //颜色
            GLfloat duration, //持续时长
            glm::vec2 position, //位置坐标
            Texture2D texture) //纹理
    : GameObject(position, SIZE, texture, color, VELOCITY), type(type), duration(duration), activated(GL_FALSE) { }
};

#endif /* PowerUp_hpp */
