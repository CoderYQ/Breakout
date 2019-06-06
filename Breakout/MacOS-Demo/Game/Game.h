//
//  Game_hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef Game_h
#define Game_h

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import <OpenGL/glu.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import <stdio.h>
#import <map>
#import "GameLevel.h"
#import "BallObject.h"
#import "ParticleGenerator.h"
#import "PostProcessor.h"
#import "PowerUp.h"
#import "TextRenderer.h"

// 初始化挡板的大小
const glm::vec2 PLAYER_SIZE(100, 20);
// 初始化挡板的速率
const GLfloat PLAYER_VELOCITY(2500.0f);
// 初始化球的速度
const glm::vec2 INITIAL_BALL_VELOCITY(100.0f, -350.0f);
// 球的半径
const GLfloat BALL_RADIUS = 20.0f;
// 玩家的初始生命值
const GLuint INITIAL_LIVES = 2;
// 玩家的游戏时长
static float TEMP_LIVETIME = 0.0f;

enum GameState {
    GAME_MENU,
    GAME_ACTIVE,
    GAME_WIN
};

enum Direction {
    UP,
    RIGHT,
    DOWN,
    LEFT
};

typedef std::tuple<GLboolean, Direction, glm::vec2> Collision;

class Game {
    
public:
    
    //当前的游戏状态
    GameState state = GAME_MENU;
    
    GLuint width, height;
    
    //游戏关卡
    std::vector<GameLevel> levels;
    
    //当前游戏的关卡
    GLuint level = 3;
    
    //玩家的生命值
    GLuint lives = INITIAL_LIVES;
    
    Game(GLuint width, GLuint height) : width(width), height(height) { }
    
    ~Game();
    
    void Init();
    
    //处理键盘输入, 控制游戏开始、停止、挡板的运动
    void ProcessInput(const char key);
    
    void Render();
    
    void Update();
    
private:
    
    //粒子渲染器
    SpriteRenderer *spriteRender;
    
    //挡板
    GameObject *player;
    
    //小球
    BallObject *ball;
    
    //粒子生成器
    ParticleGenerator *particler;
    
    //特效处理
    PostProcessor *processor;
    
    //字符渲染器
    TextRenderer *textRender;
    
    //游戏运行的时间
    float gameTime = 0.0;
    
    //玩家有效存活时间
    float liveTime = 0.0;
    
    //每帧画面的刷新间隔
    float deltaTime = 0.016;
    
    //振动时间
    float shakeTime = 0.05;
    
    //音频播放器
    std::map<std::string, AVAudioPlayer *> audioPlayers;
    
    //游戏道具
    std::vector<PowerUp> powerUps;
    
    //碰撞检测
    void DoCollisions();
    
    //发射道具
    void SpawnPowerUps(GameObject &block);
    
    //更新道具
    void UpdatePowerUps();
    
    //简单的碰撞检测
    GLboolean CheckCollision(GameObject &one, GameObject &two);
    
    //复杂的碰撞检测
    Collision CheckCollision(BallObject &one, GameObject &two);
    
    //计算小球发生碰撞后的速度大小和方向
    Direction VectorDirection(glm::vec2 target);
    
    //重置游戏关卡
    void ResetLevel();
    
    //重置挡板和小球状态
    void ResetPlayer();
    
    GLboolean ShouldSpawn(GLuint chance);
    
    //激活某个道具
    void ActivatePowerUp(PowerUp &powerUp);
    
    GLboolean IsOtherPowerUpActive(std::string type);
    
    //清空道具
    void clearPowerUps();
};


#endif /* YQGame_hpp */
