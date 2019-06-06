//
//  ParticleGenerator.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/31.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef ParticleGenerator_h
#define ParticleGenerator_h

#import <OpenGL/OpenGL.h>
#import <stdio.h>
#import <vector>
#import "glm.hpp"
#import "ext.hpp"
#import "Shader.h"
#import "Texture2D.h"
#import "GameObject.h"

/**
 表示单个粒子
 */
struct Particle {
    //坐标、速率
    glm::vec2 position, velocity;
    //颜色
    glm::vec4 color;
    //存活时长
    GLfloat life;
    
    Particle() : position(0.0f), velocity(0.0f), color(1.0f), life(0.0f) { }
};

class ParticleGenerator {
    
public:
    
    ParticleGenerator(Shader shader, Texture2D texture, GLuint amount);
    
    //渲染所有的粒子
    void Draw();
    
    //更新所有的粒子
    void Update(GLfloat dt, GameObject &object, GLuint newParticles, glm::vec2 offset = glm::vec2(0.0f, 0.0f));
    
private:
    
    //粒子数组
    std::vector<Particle> particles;
    
    //粒子总数
    GLuint amount;
    
    Shader shader;
    
    Texture2D texture;
    
    GLuint vao;
    
    //上一次用到的粒子下标
    int lastUsedParticle = 0;
    
    void Init();
    
    int FirstUnusedParticle();
    
    void RespawnParticle(Particle &particle, GameObject &object, glm::vec2 offset = glm::vec2(0.0f, 0.0f));
};

#endif /* ParticleGenerator_hpp */
