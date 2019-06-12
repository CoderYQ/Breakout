//
//  ResourceManager.cpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#import "ResourceManager.h"
#import "stb_image.h"
#import <Foundation/Foundation.h>

/**
 初始化静态成员变量
 */
std::map<std::string, Texture2D> ResourceManager::textures;
std::map<std::string, Shader> ResourceManager::shaders;

Shader ResourceManager::LoadShader(const GLchar *vShaderFile, const GLchar *fShaderFile, const GLchar *gShaderFile, std::string name)
{
    shaders[name] = LoadShaderFromFile(vShaderFile, fShaderFile, gShaderFile);
    return shaders[name];
}

Shader& ResourceManager::GetShader(std::string name)
{
    return shaders[name];
}

Texture2D ResourceManager::LoadTexture(const GLchar *file, GLboolean alpha, std::string name)
{
    textures[name] = LoadTextureFromFile(file, alpha);
    return textures[name];
}

Texture2D& ResourceManager::GetTexture(std::string name)
{
    return textures[name];
}

void ResourceManager::Clear()
{
    // (Properly) delete all shaders
    for (auto iter : shaders) {
        glDeleteProgram(iter.second.ID);
    }
    // (Properly) delete all textures
    for (auto iter : textures) {
        glDeleteTextures(1, &iter.second.ID);
    }
}

Shader ResourceManager::LoadShaderFromFile(const GLchar *vShaderFile, const GLchar *fShaderFile, const GLchar *gShaderFile)
{
    int fileSize = 0;
    //加载vs文件
    const GLchar *vShaderCode = LoadFileContent(vShaderFile, fileSize);
    //加载fs文件
    const GLchar *fShaderCode = LoadFileContent(fShaderFile, fileSize);
    //加载gs文件
    const GLchar *gShaderCode = LoadFileContent(gShaderFile, fileSize);
    
    Shader shader;
    shader.Compile(vShaderCode, fShaderCode, gShaderFile != nullptr ? gShaderCode : nullptr);
    return shader;
}

Texture2D ResourceManager::LoadTextureFromFile(const GLchar *imageFile, GLboolean alpha, GLboolean turn)
{
    Texture2D texture;
    if (alpha) {
        texture.internal_Format = GL_RGBA;
        texture.image_Format = GL_RGBA;
        texture.wrap_S = GL_CLAMP_TO_EDGE;
        texture.wrap_T = GL_CLAMP_TO_EDGE;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:imageFile] ofType:nil];
    int width, height, nrChannels;
    //可能需要翻转一下图片
    if (turn) stbi_set_flip_vertically_on_load(turn);
    unsigned char *data = stbi_load(filePath.UTF8String, &width, &height, &nrChannels, 0);
    if (!data) printf("%s: 图片加载失败", imageFile);
    
    GLenum format = GL_RGB;
    if (data) {
        switch (nrChannels) {
            case 1:
                format = GL_RED;
                break;
            case 3:
                format = GL_RGB;
                break;
            case 4:
                format = GL_RGBA;
                break;
        }
        texture.image_Format = format;
    }
    // Now generate texture
    texture.Generate(width, height, data);
    // And finally free image data
    stbi_image_free(data);
    return texture;
}

char * ResourceManager::LoadFileContent(const char *path, int &filesize) {
    char *fileContent = nullptr;
    if (path == nullptr) return fileContent;
    filesize = 0;
    NSString *nsPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:path] ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:nsPath];
    if (data.length > 0) {
        filesize = (int)data.length;
        fileContent = new char[filesize + 1];
        memcpy(fileContent, [data bytes], filesize);
        fileContent[filesize] = '\0';
    } else {
        printf("%s: 文件加载错误", path);
    }
    return fileContent;
}
