//
//  YQGame.cpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#import "Game.h"
#import "glm.hpp"
#import "ext.hpp"
#import "SpriteRenderer.h"
#import "ResourceManager.h"
#import <iostream>

Game::~Game()
{
    delete spriteRender;
    delete player;
    delete ball;
    delete particler;
    delete processor;
}

void Game::Init()
{
    /**
     初始化点精灵
     */
    ResourceManager::LoadShader("sprite.vs", "sprite.fs", "sprite.gs", "sprite");
    /**
     初始化 2D投影矩阵: 使左上角坐标为(0,0), 右下角坐标为(800,600).
     
     valType const & left,
     valType const & right,
     valType const & bottom,
     valType const & top,
     valType const & zNear,
     valType const & zFar
     */
    glm::mat4 projection = glm::ortho(0.0f, static_cast<GLfloat>(width), static_cast<GLfloat>(height), 0.0f, -1.0f, 1.0f);
    ResourceManager::GetShader("sprite").Use().SetInteger("image", 0, true);
    ResourceManager::GetShader("sprite").SetMatrix4("projectionMatrix", projection, true);
    ResourceManager::LoadTexture("awesomeface.png", GL_TRUE, "face");
    spriteRender = new SpriteRenderer(ResourceManager::GetShader("sprite"));
    
    /**
     初始化游戏关卡
     */
    ResourceManager::LoadTexture("background.jpg", GL_TRUE, "background");
    ResourceManager::LoadTexture("awesomeface.png", GL_TRUE, "face");
    ResourceManager::LoadTexture("block.png", GL_FALSE, "block");
    ResourceManager::LoadTexture("block_solid.png", GL_FALSE, "block_solid");
    
    GameLevel one;
    one.Load("one.lvl", width, height * 0.5);
    GameLevel two;
    two.Load("two.lvl", width, height * 0.5);
    GameLevel three;
    three.Load("three.lvl", width, height * 0.5);
    GameLevel four;
    four.Load("four.lvl", width, height * 0.5);
    
    levels.push_back(one);
    levels.push_back(two);
    levels.push_back(three);
    levels.push_back(four);
    
    /**
     初始化底部挡板
     */
    ResourceManager::LoadTexture("paddle.png", GL_FALSE, "paddle");
    glm::vec2 playerPos = glm::vec2(width / 2 - PLAYER_SIZE.x / 2, height - PLAYER_SIZE.y);
    player = new GameObject(playerPos, PLAYER_SIZE, ResourceManager::GetTexture("paddle"));
    
    /**
     初始化小球
     */
    glm::vec2 ballPos = playerPos + glm::vec2(PLAYER_SIZE.x / 2 - BALL_RADIUS, -BALL_RADIUS * 2);
    ball = new BallObject(ballPos, BALL_RADIUS, INITIAL_BALL_VELOCITY, ResourceManager::GetTexture("face"));
    
    /**
     初始化粒子生成器
     */
    ResourceManager::LoadShader("particle.vs", "particle.fs", nullptr, "particle");
    ResourceManager::LoadTexture("particle.png", GL_TRUE, "particle");
    ResourceManager::GetShader("particle").Use().SetInteger("sprite", 0);
    ResourceManager::GetShader("particle").Use().SetMatrix4("projectionMatrix", projection);
    particler = new ParticleGenerator(ResourceManager::GetShader("particle"), ResourceManager::GetTexture("particle"), 500);
    
    /**
     初始化后期处理
     */
    ResourceManager::LoadShader("processor.vs", "processor.fs", nullptr, "processor");
    processor = new PostProcessor(ResourceManager::GetShader("processor"), width, height);
    
    /**
     初始化道具纹理对象
     */
    ResourceManager::LoadTexture("powerup_speed.png", GL_TRUE, "powerup_speed");
    ResourceManager::LoadTexture("powerup_sticky.png", GL_TRUE, "powerup_sticky");
    ResourceManager::LoadTexture("powerup_increase.png", GL_TRUE, "powerup_increase");
    ResourceManager::LoadTexture("powerup_confuse.png", GL_TRUE, "powerup_confuse");
    ResourceManager::LoadTexture("powerup_chaos.png", GL_TRUE, "powerup_chaos");
    ResourceManager::LoadTexture("powerup_passthrough.png", GL_TRUE, "powerup_passthrough");
    
    /**
     初始化文本渲染
     */
    textRender = new TextRenderer(width, height);
    textRender->Load("ocraext.ttf", 30);
    
    /**
     初始化音效设置
     */
    std::vector<std::string> audioes = { "bleep.mp3", "bleep.wav", "breakout.mp3", "powerup.wav", "solid.wav" };
    for (auto audio : audioes) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:audio.c_str()] ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        audioPlayers[audio] = player;
    }
    [audioPlayers["breakout.mp3"] play];
    audioPlayers["breakout.mp3"].numberOfLoops = -1;
}

void Game::ProcessInput(const char key)
{
    float velocity = PLAYER_VELOCITY * deltaTime;
    switch (key) {
        //开始游戏
        case '\r':
        {
            state = GAME_ACTIVE;
            if (ball->isStuck) ball->isStuck = false;
        }
        break;
        
        //选择关卡
        case 'W':
        case 'w':
        {
            if (state == GAME_MENU) level = (level + 1) % 4;
        }
        break;
            
        //选择模式
        case 'S':
        case 's':
        {
            if (state == GAME_MENU) {
                if (!processor->chaos && !processor->confuse) {
                    processor->confuse = true;
                } else if (processor->confuse && !processor->chaos) {
                    processor->chaos = true;
                    processor->confuse = false;
                } else if (processor->chaos && !processor->confuse) {
                    processor->chaos = false;
                    processor->confuse = false;
                }
            }
        }
            break;
        
        //向左移动挡板
        case 'A':
        case 'a':
            if (state == GAME_ACTIVE && player->position.x >= 0) player->position.x -= velocity;
        break;
        
        //向右移动挡板
        case 'D':
        case 'd':
        if (state == GAME_ACTIVE && player->position.x <= width - player->size.x) player->position.x += velocity;
        break;
        
        default:
        break;
    }
    
    if (state == GAME_WIN && key == '\r') {
        processor->chaos = processor->confuse = false;
        state = GAME_MENU;
    }
}

void Game::Render()
{
    if (state == GAME_ACTIVE || state == GAME_MENU) {
        /**
         0,先绑定帧缓冲区
         */
        processor->BeginRender();
        /**
         1,绘制背景
         */
        spriteRender->DrawSprite(ResourceManager::GetTexture("background"),
                                 glm::vec2(0, 0),
                                 glm::vec2(width, height),
                                 0.0f,
                                 glm::vec3(1.0f, 1.0f, 1.0f));
        /**
         2,绘制关卡的方块
         */
        levels[level].Draw(*spriteRender);
        /**
         3,绘制底部挡板
         */
        player->Draw(*spriteRender);
        /**
         4,绘制粒子
         */
        particler->Draw();
        /**
         5,绘制小球
         */
        ball->Draw(*spriteRender);
        /**
         6,绘制道具
         */
        for (PowerUp &powerUp : powerUps) {
            if (!powerUp.collided) powerUp.Draw(*spriteRender);
        }
        /**
         7,绘制文本
         7.1 绘制生命值
         7.2 绘制关卡
         7.3 绘制模式
         7.4 绘制游戏时长
         */
        NSString *livesStr = [NSString stringWithFormat:@"lives:%d", lives];
        textRender->RenderText(livesStr.UTF8String, 5.0f, 5.0f, 0.8f);
        
        NSString *levelStr = [NSString stringWithFormat:@"level:%d/%lu", level, levels.size()];
        textRender->RenderText(levelStr.UTF8String, 5.0f, 30.0f, 0.8f);
        
        NSString *modeStr = nil;
        if (!processor->chaos && !processor->confuse) {
            modeStr = @"model:normal";
        } else if (processor->chaos) {
            modeStr = @"model:chaos";
        } else {
            modeStr = @"model:confuse";
        }
        textRender->RenderText(modeStr.UTF8String, 5.0f, 55.0f, 0.8f);
        
        NSString *liveTimeStr = [NSString stringWithFormat:@"liveTime:%.1f s", liveTime];
        textRender->RenderText(liveTimeStr.UTF8String, 5.0f, 80.0f, 0.8f);
        
        /**
         8,渲染帧缓冲区中的内容
         */
        gameTime += deltaTime;
        processor->EndRender();
        processor->Render(gameTime);
    }
    
    if (state == GAME_MENU) {
        float enterY = 0.0;
        //进行过游戏
        if (TEMP_LIVETIME > 0.1) {
            NSString *scoreStr = [NSString stringWithFormat:@"your time: %.1f s", TEMP_LIVETIME];
            float scoreY =  height/2 + 40.0;
            textRender->RenderText(scoreStr.UTF8String, width/2 - 190.0, scoreY, 1.4f);
            enterY = scoreY + 60.0;
            //尚未开始游戏
        } else {
            enterY = height/2 + 30;
        }
        textRender->RenderText("press Enter to start", width/2 - 145.0, enterY, 0.8f);
        textRender->RenderText("press W to select level", width/2 - 160.0, enterY + 40, 0.8f);
        textRender->RenderText("press S to select mode", width/2 - 155.0, enterY + 80, 0.8f);
    }
    
    if (state == GAME_WIN) {
        textRender->RenderText("You WON!!!", width/2 - 160.0, height/2 + 40.0, 1.0, glm::vec3(0.0, 1.0, 0.0));
        textRender->RenderText("press Enter to start", width/2 - 145.0, height/2 + 80, 1.0, glm::vec3(1.0, 1.0, 0.0));
    }
}

void Game::Update()
{
    //更新小球的位置信息
    ball->Move(deltaTime, width);
    
    //进行碰撞检测
    DoCollisions();
    
    //更新粒子效果
    particler->Update(deltaTime, *ball, 2, glm::vec2(ball->radius / 2));
    
    //更新振动效果
    if (shakeTime > 0.0) {
        shakeTime -= deltaTime;
        if (shakeTime <= 0.0) processor->shake = false;
    }
    
    //更新道具
    UpdatePowerUps();
    
    //当小球的位置触及到地板时结束游戏
    if (ball->position.y >= height) {
        lives --;
        ResetPlayer();
        //只有在玩家的生命降为 0 时才重置
        if (lives == 0) {
            ResetLevel();
            clearPowerUps();
            state = GAME_MENU;
            TEMP_LIVETIME = liveTime;
            liveTime = 0.0;
        }
    } else {
        if (state == GAME_ACTIVE) liveTime += deltaTime;
    }
    
    //赢得比赛
    if (state == GAME_ACTIVE && levels[level].IsCompleted()) {
        ResetPlayer();
        ResetLevel();
        clearPowerUps();
        state = GAME_WIN;
        processor->chaos = processor->confuse = false;
    }
}

//对所有的小球进行碰撞检测
void Game::DoCollisions()
{
    /**
     1. 将小球和所有的方块进行碰撞检测
     */
    for (GameObject &box : levels[level].bricks) {
        //没有被破坏的方块才需要进行碰撞检测
        if (!box.collided) {
            Collision collision = CheckCollision(*ball, box);
            //如果的确发生了碰撞
            if (std::get<0>(collision)) {
                /**
                 如果是实心球, 产生振动效果
                 */
                if (box.isSolid) {
                    shakeTime = 0.05;
                    processor->shake = true;
                    [audioPlayers["solid.wav"] play];
                    
                    /**
                     1. 如果不是实心球, 将其销毁
                     2. 同时从该位置随机产生游戏道具
                     3. 播放音效
                     */
                } else {
                    box.collided = true;
                    SpawnPowerUps(box);
                    [audioPlayers["bleep.mp3"] play];
                }
                /**
                 碰撞处理
                 */
                Direction dir = std::get<1>(collision);
                glm::vec2 diff_vector = std::get<2>(collision);
                
                if (!(ball->passThrough && !box.isSolid))
                {
                    /**
                     1. 水平方向发生碰撞
                     */
                    if (dir == LEFT || dir == RIGHT) {
                        ball->velocity.x = -ball->velocity.x; // 反转水平速度
                        // 重定位
                        GLfloat penetration = ball->radius - std::abs(diff_vector.x);
                        
                        if (dir == LEFT) {
                            ball->position.x += penetration; // 将球右移
                        } else {
                            ball->position.x -= penetration; // 将球左移
                        }
                        
                        /**
                         2. 垂直方向碰撞
                         */
                    } else {
                        ball->velocity.y = -ball->velocity.y; // 反转垂直速度
                        // 重定位
                        GLfloat penetration = ball->radius - std::abs(diff_vector.y);
                        
                        if (dir == UP) {
                            ball->position.y -= penetration; // 将球上移
                        } else {
                            ball->position.y += penetration; // 将球下移
                        }
                    }
                }
            }
        }
    }
    
    /**
     2. 将挡板和道具进行碰撞检测
     */
    for (PowerUp &powerUp : powerUps) {
        if (!powerUp.collided) {
            //如果道具碰撞道了地板，那么将其销毁
            if (powerUp.position.y >= height) powerUp.collided = true;
            //检测挡板和道具的碰撞
            if (CheckCollision(*player, powerUp)) {
                ActivatePowerUp(powerUp);
                powerUp.collided = true;
                powerUp.activated = true;
                [audioPlayers["powerup.wav"] play];
            }
        }
    }
    
    /**
     3. 将小球与挡板进行碰撞检测
     */
    Collision result = CheckCollision(*ball, *player);
    if (!ball->isStuck && std::get<0>(result)) {
        // 检查碰到了挡板的哪个位置，并根据碰到哪个位置来改变速度
        GLfloat centerBoard = player->position.x + player->size.x / 2;
        GLfloat distance = (ball->position.x + ball->radius) - centerBoard;
        GLfloat percentage = distance / (player->size.x / 2);
        
        GLfloat strength = 2.0f;
        glm::vec2 oldVelocity = ball->velocity;
        ball->velocity.x = INITIAL_BALL_VELOCITY.x * percentage * strength;
        
        ball->velocity = glm::normalize(ball->velocity) * glm::length(oldVelocity);
        ball->velocity.y = -1 * abs(ball->velocity.y);
        
        ball->isStuck = ball->sticky;
        [audioPlayers["bleep.wav"] play];
    }
}

GLboolean Game::CheckCollision(GameObject &one, GameObject &two)
{
    // x轴方向碰撞
    bool collisionX = one.position.x + one.size.x >= two.position.x &&
    two.position.x + two.size.x >= one.position.x;
    // y轴方向碰撞
    bool collisionY = one.position.y + one.size.y >= two.position.y &&
    two.position.y + two.size.y >= one.position.y;
    // 只有两个轴向都有碰撞时才碰撞
    return collisionX && collisionY;
}

Collision Game::CheckCollision(BallObject &one, GameObject &two)
{
    glm::vec2 center(one.position + one.radius);
    
    glm::vec2 aabb_half_extents(two.size.x / 2, two.size.y / 2);
    glm::vec2 aabb_center(two.position.x + aabb_half_extents.x, two.position.y + aabb_half_extents.y);
    
    glm::vec2 difference = center - aabb_center;
    glm::vec2 clamped = glm::clamp(difference, -aabb_half_extents, aabb_half_extents);
    
    glm::vec2 closest = aabb_center + clamped;
    
    difference = closest - center;
    GLboolean collided = glm::length(difference) < one.radius;
    
    /**
     如果的确发生了碰撞
     计算碰撞后的速度大小和方向
     */
    if (glm::length(difference) > 0 && collided) {
        return std::make_tuple(GL_TRUE, VectorDirection(difference), difference);
    } else {
        return std::make_tuple(GL_FALSE, UP, glm::vec2(0, 0));
    }
}

Direction Game::VectorDirection(glm::vec2 target) {
    glm::vec2 compass[] = {
        glm::vec2(0.0f, 1.0f),  // 上
        glm::vec2(1.0f, 0.0f),  // 右
        glm::vec2(0.0f, -1.0f), // 下
        glm::vec2(-1.0f, 0.0f)  // 左
    };
    GLfloat max = 0.0f;
    GLuint best_match = -1;
    for (GLuint i = 0; i < 4; i++) {
        GLfloat dot_product = glm::dot(glm::normalize(target), compass[i]);
        if (dot_product > max) {
            max = dot_product;
            best_match = i;
        }
    }
    return (Direction)best_match;
}

void Game::ResetLevel()
{
    std::vector<std::string> levels = { "one.lvl", "two.lvl", "three.lvl", "four.lvl"};
    this->levels[level].Load(levels[level].c_str(), width, height * 0.5f);
    lives = INITIAL_LIVES;
}

void Game::ResetPlayer()
{
    //重置挡板的状态
    player->size = PLAYER_SIZE;
    player->position = glm::vec2(width / 2 - PLAYER_SIZE.x / 2, height - PLAYER_SIZE.y);
    player->color = glm::vec3(1.0f);
    
    //重置小球的状态
    ball->Reset(player->position + glm::vec2(PLAYER_SIZE.x / 2 - BALL_RADIUS, -(BALL_RADIUS * 2)), INITIAL_BALL_VELOCITY);
    ball->passThrough = ball->sticky = false;
    ball->color = glm::vec3(1.0f);
    
    processor->chaos = processor->confuse = false;
}

GLboolean Game::ShouldSpawn(GLuint chance)
{
    GLuint random = rand() % chance;
    return random == 0;
}

void Game::SpawnPowerUps(GameObject &block)
{
    //加速道具
    if (ShouldSpawn(30)) {
        PowerUp speed = PowerUp("speed", glm::vec3(0.5f, 0.5f, 1.0f), 0.0f, block.position, ResourceManager::GetTexture("powerup_speed"));
        powerUps.push_back(speed);
    }
    //粘滞道具
    if (ShouldSpawn(30)) {
        PowerUp speed = PowerUp("sticky", glm::vec3(1.0f, 0.5f, 1.0f), 20.0f, block.position, ResourceManager::GetTexture("powerup_sticky"));
        powerUps.push_back(speed);
    }
    //穿透道具
    if (ShouldSpawn(30)) {
        PowerUp speed = PowerUp("pass-through", glm::vec3(0.5f, 1.0f, 0.5f), 10.0f, block.position, ResourceManager::GetTexture("powerup_increase"));
        powerUps.push_back(speed);
    }
    //挡板加长道具
    if (ShouldSpawn(30)) {
        PowerUp speed = PowerUp("pad-size-increase", glm::vec3(1.0f, 0.6f, 0.4f), 0.0f, block.position, ResourceManager::GetTexture("powerup_increase"));
        powerUps.push_back(speed);
    }
    //翻转道具
    if (ShouldSpawn(15)) {
        PowerUp speed = PowerUp("confuse", glm::vec3(1.0f, 0.3f, 0.3f), 15.0f, block.position, ResourceManager::GetTexture("powerup_confuse"));
        powerUps.push_back(speed);
    }
    //晃动道具
    if (ShouldSpawn(15)) {
        PowerUp speed = PowerUp("chaos", glm::vec3(0.9f, 0.25f, 0.25f), 15.0f, block.position, ResourceManager::GetTexture("powerup_chaos"));
        powerUps.push_back(speed);
    }
}

// 根据道具类型激活道具效果
void Game::ActivatePowerUp(PowerUp &powerUp)
{
    if (powerUp.type == "speed")
    {
        ball->velocity *= 1.2;
    }
    else if (powerUp.type == "sticky")
    {
        ball->sticky = GL_TRUE;
        player->color = glm::vec3(1.0f, 0.5f, 1.0f);
    }
    else if (powerUp.type == "pass-through")
    {
        ball->passThrough = GL_TRUE;
        ball->color = glm::vec3(1.0f, 0.5f, 0.5f);
    }
    else if (powerUp.type == "pad-size-increase")
    {
        player->size.x += 50;
    }
    else if (powerUp.type == "confuse")
    {
        // 只在chaos未激活时生效
        if (!processor->confuse) processor->confuse = GL_TRUE;
    }
    else if (powerUp.type == "chaos")
    {
        // 只在chaos未激活时生效
        if (!processor->chaos) processor->chaos = GL_TRUE;
    }
}

void Game::UpdatePowerUps()
{
    for (PowerUp &powerUp : powerUps) {
        //更新道具位置，总是掉到地上
        powerUp.position += powerUp.velocity * deltaTime;
        if (powerUp.activated) {
            //减少道具效果的持续时间
            powerUp.duration -= deltaTime;
            if (powerUp.duration <= 0.0f) {
                powerUp.activated = false;
                //停用道具效果
                if (powerUp.type == "sticky")
                {
                    if (!IsOtherPowerUpActive("sticky")) {
                        ball->sticky = false;
                        player->color = glm::vec3(1.0f);
                    }
                }
                else if (powerUp.type == "pass-through")
                {
                    if (!IsOtherPowerUpActive("pass-through")) {
                        ball->passThrough = false;
                        ball->color = glm::vec3(1.0f);
                    }
                }
                else if (powerUp.type == "confuse")
                {
                    if (!IsOtherPowerUpActive("confuse")) {
                        processor->confuse = false;
                    }
                }
                else if (powerUp.type == "chaos")
                {
                    if (!IsOtherPowerUpActive("chaos")) {
                        processor->chaos = false;
                    }
                }
            }
        }
    }
    //把已经被销毁的并且没有被激活的道具移除
    powerUps.erase(std::remove_if(powerUps.begin(), powerUps.end(), [](const PowerUp &powerUp) {
        return powerUp.collided && !powerUp.activated;
    }), powerUps.end());
}

GLboolean Game::IsOtherPowerUpActive(std::string type)
{
    for (const PowerUp &powerUp : powerUps) {
        if (powerUp.activated && powerUp.type == type) return GL_TRUE;
    }
    return GL_FALSE;
}

void Game::clearPowerUps()
{
    powerUps.clear();
}
