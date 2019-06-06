//
//  ParticleGenerator.cpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/31.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#include "ParticleGenerator.h"

ParticleGenerator::ParticleGenerator(Shader shader,
                                     Texture2D texture,
                                     GLuint amount): shader(shader), texture(texture), amount(amount)
{
    this->Init();
}

void ParticleGenerator::Draw()
{
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    this->shader.Use();
    for (Particle p : particles) {
        //只有存活的粒子才需要绘制
        if (p.life > 0.0f) {
            this->shader.SetVector2f("offset", p.position);
            this->shader.SetVector4f("color", p.color);
            this->texture.Bind();
            glActiveTexture(GL_TEXTURE0);
            glBindVertexArray(this->vao);
            glDrawArrays(GL_TRIANGLES, 0, 6);
            glBindVertexArray(0);
        }
    }
    //将混合模式恢复到默认
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void ParticleGenerator::Update(GLfloat dt, GameObject &object, GLuint newParticles, glm::vec2 offset)
{
    //添加新的粒子
    for (GLuint i = 0; i < newParticles; i ++) {
        int unusedParticle = this->FirstUnusedParticle();
        this->RespawnParticle(this->particles[unusedParticle], object, offset);
    }
    
    //更新所有粒子
    for (GLuint i = 0; i < this->amount; i ++) {
        Particle &p = this->particles[i];
        //更新每个粒子的生命值
        p.life -= 5 * dt;
        if (p.life > 0.0f) {
            p.position -= p.velocity * dt;
            p.color.a -= dt * 2.0;
        }
    }
}

void ParticleGenerator::Init()
{
    GLuint vbo;
    GLfloat particle_quad[] = {
        0.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 0.0f,
        
        0.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f
    };
    glGenVertexArrays(1, &this->vao);
    glGenBuffers(1, &vbo);
    glBindVertexArray(this->vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(particle_quad), particle_quad, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (GLvoid *)0);
    glBindVertexArray(0);
    
    //生成 amount 个粒子对象
    for (int i = 0; i < amount; i ++) {
        particles.push_back(Particle());
    }
}

int ParticleGenerator::FirstUnusedParticle()
{
    for (int i = lastUsedParticle; i < this->amount; i ++) {
        if (particles[i].life <= 0.0f) {
            lastUsedParticle = i;
            return i;
        }
    }
    for (int i = 0; i < lastUsedParticle; i ++) {
        if (particles[i].life <= 0.0f) {
            lastUsedParticle = i;
            return i;
        }
    }
    lastUsedParticle = 0;
    return 0;
}

void ParticleGenerator::RespawnParticle(Particle &particle, GameObject &object, glm::vec2 offset)
{
    GLfloat random = ((rand() % 100) - 50) / 10.0f;
    GLfloat colorR = ((rand() % 100) / 100.0f);
    GLfloat colorG = ((rand() % 100) / 100.0f);
    GLfloat colorB = ((rand() % 100) / 100.0f);
    particle.position = object.position + random + offset;
    particle.color = glm::vec4(colorR, colorG, colorB, 1.0f);
    particle.life = 1.0f;
    particle.velocity = object.velocity * 0.1f;
}
