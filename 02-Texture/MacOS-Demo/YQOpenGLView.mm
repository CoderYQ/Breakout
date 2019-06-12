//
//  YQOpenGLView.m
//  MacOS-Demo
//
//  Created by RMKJ on 2019/4/18.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>
#import <OpenGL/glu.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import "YQOpenGLView.h"
#import "stb_image.h"

@implementation YQOpenGLView {
    __weak NSTimer *_timer;
    GLuint VAO, VBO, program;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] = {
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAStencilSize, 8,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion4_1Core,
        0
    };
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
    NSOpenGLContext *openGLContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
    [self setOpenGLContext:openGLContext];
    [self.openGLContext makeCurrentContext];
    
    //使用垂直刷新率同步缓冲区交换
    GLint sync = 1;
    CGLSetParameter(CGLGetCurrentContext(), kCGLCPSwapInterval, &sync);
    
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.016 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf setNeedsDisplay:YES];
    }];
    _timer = timer;
}

- (void)prepareOpenGL {
    [super prepareOpenGL];
    
    //vertexs
    GLfloat vertices[] = {
        /* 左下方顶点 */        /* 红色 */      /* 纹理坐标 */
        -0.5f, -0.5f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0, 0.0,
        /* 右下方顶点 */        /* 绿色 */
        0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f, 1.0, 0.0,
        /* 上方顶点 */          /* 蓝色 */
        0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f, 0.5, 1.0,
    };
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);
    
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)0);
    
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(3 * sizeof(float)));
    
    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(6 * sizeof(float)));
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    //shader
    char *vsCode = (char *)[self loadContent:@"triangle.vs"];
    GLuint vsShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vsShader, 1, &vsCode, nullptr);
    glCompileShader(vsShader);
    
    GLint result = GL_TRUE;
    glGetShaderiv(vsShader, GL_COMPILE_STATUS, &result);
    if (result == GL_FALSE) {
        char log[1024] = { 0 };
        GLsizei logLength = 0;
        glGetShaderInfoLog(vsShader, 1024, &logLength, log);
        glDeleteShader(vsShader);
        NSLog(@"顶点着色器编译失败：%s",log);
    }
    
    char *fsCode = (char *)[self loadContent:@"triangle.fs"];
    GLuint fsShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fsShader, 1, &fsCode, nullptr);
    glCompileShader(fsShader);
    
    glGetShaderiv(fsShader, GL_COMPILE_STATUS, &result);
    if (result == GL_FALSE) {
        char log[1024] = { 0 };
        GLsizei logLength = 0;
        glGetShaderInfoLog(fsShader, 1024, &logLength, log);
        NSLog(@"片元着色器编译失败：%s",log);
    }
    
    //program
    program = glCreateProgram();
    glAttachShader(program, vsShader);
    glAttachShader(program, fsShader);
    glLinkProgram(program);
    glDeleteShader(vsShader);
    glDeleteShader(fsShader);
    
    //检查程序的链接状态
    glGetProgramiv(program, GL_LINK_STATUS, &result);
    if(result == GL_FALSE) {
        char infoLog[512];
        glGetProgramInfoLog(program, 512, NULL, infoLog);
        NSLog(@"程序链接失败 %s", infoLog);
    }
    
    //生成纹理
    int width, height, nrChannels;
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"awesomeface.png" ofType:nil];
    unsigned char *data = stbi_load(imagePath.UTF8String, &width, &height, &nrChannels, 0);
    if (!data) NSLog(@"图片数据加载失败");
    
    unsigned int texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
    glGenerateMipmap(GL_TEXTURE_2D);
    
    stbi_image_free(data);
    
    glClearColor(0.1, 0.3, 0.3, 1.0);
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(program);
    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glFlush();
}

- (unsigned char *)loadContent:(NSString *)fileName {
    NSString *vsPath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSData *vsData = [NSData dataWithContentsOfFile:vsPath];
    unsigned char *vsContent = new unsigned char[vsData.length + 1];
    memcpy(vsContent, vsData.bytes, vsData.length);
    vsContent[vsData.length] = '\0';
    return vsContent;
}

@end
