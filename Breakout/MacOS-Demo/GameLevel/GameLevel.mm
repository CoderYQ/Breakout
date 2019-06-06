//
//  GameLevel.cpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLevel.h"
#import <fstream>
#import <sstream>
#import "ResourceManager.h"

void GameLevel::Load(const GLchar *file, GLuint levelWidth, GLuint levelHeight)
{
    //清除之前的数据
    this->bricks.clear();
    
    //从文件中加载关卡数据
    GLuint tileCode;
    GameLevel level;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:nil];
    
    std::string line;
    std::ifstream fstream(filePath.UTF8String);
    std::vector<std::vector<GLuint>> tileData;
    
    if (fstream) {
        // Read each line from level file
        while (std::getline(fstream, line)) {
            std::istringstream sstream(line);
            std::vector<GLuint> row;
            // Read each word seperated by spaces
            while (sstream >> tileCode) {
                row.push_back(tileCode);
            }
            tileData.push_back(row);
        }
        if (tileData.size() > 0) this->Init(tileData, levelWidth, levelHeight);
    }
}

void GameLevel::Init(std::vector<std::vector<GLuint>> tileData, GLuint levelWidth, GLuint levelHeight)
{
    // Calculate dimensions
    GLuint height = (GLuint)tileData.size();
    GLuint width = (GLuint)tileData[0].size(); // Note we can index vector at [0] since this function is only called if height > 0
    GLfloat unit_width = levelWidth / static_cast<GLfloat>(width), unit_height = levelHeight / height;
    
    // Initialize level tiles based on tileData
    for (GLuint y = 0; y < height; ++y) {
        
        // Check block type from level data (2D level array)
        for (GLuint x = 0; x < width; ++x) {
            // Solid
            if (tileData[y][x] == 1) {
                glm::vec2 pos(unit_width * x, unit_height * y);
                glm::vec2 size(unit_width, unit_height);
                GameObject obj(pos, size, ResourceManager::GetTexture("block_solid"), glm::vec3(0.8f, 0.8f, 0.7f));
                obj.isSolid = GL_TRUE;
                this->bricks.push_back(obj);
                
            // Non-solid; now determine its color based on level data
            } else if (tileData[y][x] > 1) {
                glm::vec3 color = glm::vec3(1.0f); // original: white
                if (tileData[y][x] == 2) {
                    color = glm::vec3(0.2f, 0.8f, 1.0f);
                    
                } else if (tileData[y][x] == 3) {
                    color = glm::vec3(0.0f, 0.8f, 0.0f);
                    
                } else if (tileData[y][x] == 4) {
                    color = glm::vec3(0.9f, 0.9f, 0.4f);
                    
                } else if (tileData[y][x] == 5) {
                    color = glm::vec3(1.0f, 0.5f, 0.0f);
                }
                
                glm::vec2 pos(unit_width * x, unit_height * y);
                glm::vec2 size(unit_width, unit_height);
                GameObject obj(pos, size, ResourceManager::GetTexture("block"), color);
                this->bricks.push_back(obj);
            }
        }
    }
}

void GameLevel::Draw(SpriteRenderer &renderer) {
    for (GameObject &obj : this->bricks) {
        /**
         对于每个方块, 只有在其没有被破坏的情况下才绘制, 以此达到小球破坏方块的效果
         */
        if (!obj.collided) obj.Draw(renderer);
    }
}

bool GameLevel::IsCompleted()
{
    for (GameObject &block : bricks) {
        if (!block.isSolid && !block.collided) return false;
    }
    return true;
}

