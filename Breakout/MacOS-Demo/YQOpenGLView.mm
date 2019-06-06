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
#import <Carbon/Carbon.h>
#import "YQOpenGLView.h"
#import "Game.h"

@implementation YQOpenGLView {
    __weak NSTimer *_timer;
    //游戏场景对象
    Game *_game;
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
    glEnable(GL_BLEND);
    _game = new Game(NSWidth(self.bounds), NSHeight(self.bounds));
    _game->Init();
}

- (void)reshape {
    [super reshape];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    _game->ProcessInput(event.characters.UTF8String[0]);
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //游戏场景渲染
    _game->Render();
    
    //更新小球的位置
    _game->Update();
    
    glFlush();
}

@end
