//
//  SpriteRenderer.cpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#include "SpriteRenderer.h"
#import "glm.hpp"
#import "ext.hpp"

SpriteRenderer::SpriteRenderer(Shader &shader)
{
    this->shader = shader;
    this->initRenderData();
}

SpriteRenderer::~SpriteRenderer()
{
    
}

void SpriteRenderer::initRenderData()
{
    // 配置 VAO/VBO
    GLuint vbo;
    GLfloat vertices[] = {
        // 位置     // 纹理
        0.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 0.0f,
        
        0.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f
    };
    
    glGenVertexArrays(1, &quadVAO);
    glGenBuffers(1, &vbo);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glBindVertexArray(this->quadVAO);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (GLvoid*)0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

void SpriteRenderer::DrawSprite(Texture2D &texture,
                                glm::vec2 position,
                                glm::vec2 size,
                                GLfloat rotate,
                                glm::vec3 color)
{
    // 准备变换
    this->shader.Use();
    
    glm::mat4 modelMatrix = glm::mat4(1.0f);
    modelMatrix = glm::translate(modelMatrix, glm::vec3(position, 0.0f));
    modelMatrix = glm::translate(modelMatrix, glm::vec3(0.5f * size.x, 0.5f * size.y, 0.0f));
    modelMatrix = glm::rotate(modelMatrix, rotate, glm::vec3(0.0f, 0.0f, 1.0f));
    modelMatrix = glm::translate(modelMatrix, glm::vec3(-0.5f * size.x, -0.5f * size.y, 0.0f));
    
    modelMatrix = glm::scale(modelMatrix, glm::vec3(size, 1.0f));
    
    this->shader.SetMatrix4("modelMatrix", modelMatrix);
    this->shader.SetVector3f("spriteColor", color);
    
    glActiveTexture(GL_TEXTURE0);
    texture.Bind();
    
    glBindVertexArray(this->quadVAO);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArray(0);
    
    this->shader.unUse();
}
