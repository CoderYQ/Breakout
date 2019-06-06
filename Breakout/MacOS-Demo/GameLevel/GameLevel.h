//
//  GameLevel.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef GameLevel_h
#define GameLevel_h
#import <OpenGL/OpenGL.h>
#import <stdio.h>
#import <vector>
#import "GameObject.h"

class GameLevel {
    
public:
    
    // Level state
    std::vector<GameObject> bricks;
    
    // Constructor
    GameLevel() { }
    
    // Loads level from file
    void Load(const GLchar *file, GLuint levelWidth, GLuint levelHeight);
    
    // Render level
    void Draw(SpriteRenderer &renderer);
    
    // Check if the level is completed (all non-solid tiles are collided)
    bool IsCompleted();
    
private:
    
    // Initialize level from tile data
    void Init(std::vector<std::vector<GLuint>> tileData, GLuint levelWidth, GLuint levelHeight);
};

#endif /* GameLevel_hpp */
