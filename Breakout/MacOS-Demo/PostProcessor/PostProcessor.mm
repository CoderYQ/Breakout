//
//  FrameBuffer.cpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/6/4.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import "PostProcessor.h"
#import <stdio.h>
#import <OpenGL/gl3.h>

PostProcessor::PostProcessor(Shader shader, GLuint width, GLuint height)
: rendeShader(shader), confuse(GL_FALSE), chaos(GL_FALSE), shake(GL_TRUE)
{
    glGenFramebuffers(1, &currentFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, currentFBO);
    
    sceneTexture.Generate(width, height, NULL);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, sceneTexture.ID, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    InitRenderData();
    
    rendeShader.SetInteger("sceneTexture", sceneTexture.ID);
}

PostProcessor::~PostProcessor()
{
    
}

//初始化全屏四边形
void PostProcessor::InitRenderData()
{
    GLuint vbo;
    GLfloat vertices[] = {
        // Pos        // Tex
        -1.0f, -1.0f, 0.0f, 0.0f, //左下
        1.0f,  1.0f, 1.0f, 1.0f, //右上
        -1.0f,  1.0f, 0.0f, 1.0f, //左上
        
        -1.0f, -1.0f, 0.0f, 0.0f, //左下
        1.0f, -1.0f, 1.0f, 0.0f, //右下
        1.0f,  1.0f, 1.0f, 1.0f //右上
    };
    glGenVertexArrays(1, &this->vao);
    glGenBuffers(1, &vbo);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindVertexArray(this->vao);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GL_FLOAT), 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

void PostProcessor::BeginRender()
{
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &previousFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, currentFBO);
    glClear(GL_COLOR_BUFFER_BIT);
}

void PostProcessor::EndRender()
{
    glBindFramebuffer(GL_FRAMEBUFFER, previousFBO);
}

void PostProcessor::Render(float time)
{
    this->rendeShader.Use();
    this->rendeShader.SetFloat("time", time);
    this->rendeShader.SetInteger("confuse", this->confuse);
    this->rendeShader.SetInteger("chaos", this->chaos);
    this->rendeShader.SetInteger("shake", this->shake);
    
    glActiveTexture(GL_TEXTURE0);
    sceneTexture.Bind();
    glBindVertexArray(this->vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArray(0);
    
    this->rendeShader.unUse();
}

