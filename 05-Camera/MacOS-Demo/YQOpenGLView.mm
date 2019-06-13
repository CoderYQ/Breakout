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
#import "Glm/glm.hpp"
#import "ext.hpp"
#import "stb_image.h"
#import "Camera.h"

extern GLfloat vertices[36 * 5];
extern glm::vec3 cubePositions[10];
float duration;

/**
 1. 尝试按住鼠标左键、右键拖动切换摄像机的观察角度
 2. 尝试按下 W、S、A、D、M、N 移动摄像机的位置
 */

@implementation YQOpenGLView {
    __weak NSTimer *_timer;
    GLuint VAO, VBO, program, imageTexture;
    GLuint modelLoc, viewLoc, projectionLoc;
    glm::mat4 viewMatrix, projectionMatrix;
    Camera camera;
    CGPoint _originalPointer; //鼠标按下的那个点的坐标点
    CGPoint _lastPointer; //鼠标上一次按下的那个坐标点
    bool _isDraging; //鼠标是否正在被按住拖拽
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    camera.onKeyBoardDown(event.characters.UTF8String[0] - 32);
}

- (void)mouseUp:(NSEvent *)event {
    _isDraging = false;
}

- (void)rightMouseUp:(NSEvent *)event {
    _isDraging = false;
}

- (void)rightMouseDown:(NSEvent *)event {
    CGEventRef downEvent = CGEventCreate(NULL);
    _originalPointer = CGEventGetLocation(downEvent);
    _isDraging = true;
    _lastPointer = _originalPointer;
    CFRelease(downEvent);
}

- (void)mouseDown:(NSEvent *)event {
    CGEventRef downEvent = CGEventCreate(NULL);
    _originalPointer = CGEventGetLocation(downEvent);
    _isDraging = true;
    _lastPointer = _originalPointer;
    CFRelease(downEvent);
}

- (void)mouseDragged:(NSEvent *)event {
    CGEventRef drugEvent = CGEventCreate(NULL);
    CGPoint point = CGEventGetLocation(drugEvent);
    if(_isDraging){
        camera.onMouseMove(point.x - _lastPointer.x, point.y - _lastPointer.y);
        _lastPointer = point;
    }
    CFRelease(drugEvent);
}

- (void)rightMouseDragged:(NSEvent *)event {
    CGEventRef drugEvent = CGEventCreate(NULL);
    CGPoint point = CGEventGetLocation(drugEvent);
    if(_isDraging){
        camera.onRightMouseMove(point.x - _lastPointer.x);
        _lastPointer = point;
    }
    CFRelease(drugEvent);
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
        duration += 0.016;
    }];
    _timer = timer;
}

- (void)prepareOpenGL {
    [super prepareOpenGL];
    
    glGenVertexArrays(1,&VAO);
    glBindVertexArray(VAO);
    
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT,GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 2, GL_FLOAT,GL_FALSE, 5 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    //shader
    char *vsCode = (char *)[self loadContent:@"coordinateSystem.vs"];
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
    
    char *fsCode = (char *)[self loadContent:@"coordinateSystem.fs"];
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
    
    glGenTextures(1, &imageTexture);
    glBindTexture(GL_TEXTURE_2D, imageTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glGenerateMipmap(GL_TEXTURE_2D);
    
    stbi_image_free(data);
    
    //设置uniform变量
    viewMatrix = glm::mat4(1.0f);
    viewMatrix = glm::translate(camera.GetViewMatrix(), glm::vec3(0.0f, 0.0f, -3.0f));
    projectionMatrix = glm::perspective(45.0f, 800.0f / 800.0f, 0.1f, 100.0f);
    
    modelLoc = glGetUniformLocation(program, "modelMatrix");
    viewLoc = glGetUniformLocation(program, "viewMatrix");
    projectionLoc = glGetUniformLocation(program, "projectionMatrix");
    camera = Camera(glm::vec3(0.0f, 0.0f, 4.0f));
    
    glClearColor(0.1, 0.3, 0.3, 1.0);
    glEnable(GL_DEPTH_TEST);
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(program);
    glBindVertexArray(VAO);
    
    glBindTexture(GL_TEXTURE_2D, imageTexture);
    glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(camera.GetViewMatrix()));
    glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projectionMatrix));

    for(GLuint i = 0; i < 10; i++){
        glm::mat4 model = glm::mat4(1.0f);
        model = glm::translate(model, cubePositions[i]);
        model = camera.GetModelMatrix(model);
        float angle = 30.0f * (i + 1) * duration * 20;
        model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.4f));
        glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
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

//位置信息
glm::vec3 cubePositions[10] = {
    glm::vec3( 0.0f,  0.0f,  0.0f),
    glm::vec3( 2.0f,  5.0f, -15.0f),
    glm::vec3(-1.5f, -2.2f, -2.5f),
    glm::vec3(-3.8f, -2.0f, -12.3f),
    glm::vec3( 2.4f, -0.4f, -3.5f),
    glm::vec3(-1.7f,  3.0f, -7.5f),
    glm::vec3( 1.3f, -2.0f, -2.5f),
    glm::vec3( 1.5f,  2.0f, -2.5f),
    glm::vec3( 1.5f,  0.2f, -1.5f),
    glm::vec3(-1.3f,  1.0f, -1.5f)
};
//顶点信息
GLfloat vertices[36*5] = {
    //position            //texture
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
    
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
};
