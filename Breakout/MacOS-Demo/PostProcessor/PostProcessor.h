//
//  FrameBuffer.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/6/4.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef PostProcessor_h
#define PostProcessor_h

#import <OpenGL/OpenGL.h>
#import "Shader.h"
#import "Texture2D.h"

class PostProcessor {
    
    GLuint currentFBO;
    
    GLint previousFBO;
    
    GLuint vao;
    
    Shader rendeShader;
    
    Texture2D sceneTexture;
    
    void InitRenderData();
    
public:
    
    /**
     confuse: 反转场景中的颜色并颠倒x轴和y轴
     chaos: 利用边缘检测卷积核创造有趣的视觉效果，并以圆形旋转动画的形式移动纹理图片，实现“混沌”特效
     shake: 轻微晃动场景并附加一个微小的模糊效果
     */
    GLboolean confuse, chaos, shake;
    
    PostProcessor(Shader shader, GLuint width, GLuint height);
    
    ~PostProcessor();
    
    /**
     在渲染游戏场景之前调用, 准备帧缓冲
     */
    void BeginRender();
    
    /**
     在渲染游戏场景完毕后调用, 便于存储场景到 texture 中
     */
    void EndRender();
    
    /**
     渲染全屏四边形
     */
    void Render(float time);
};

#endif /* FrameBuffer_hpp */
