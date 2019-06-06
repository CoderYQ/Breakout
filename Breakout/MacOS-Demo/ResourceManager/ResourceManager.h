//
//  ResourceManager.hpp
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/30.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef ResourceManager_h
#define ResourceManager_h

#import <map>
#import <stdio.h>
#import "Texture2D.h"
#import "Shader.h"

class ResourceManager {
public:
    // Resource storage
    static std::map<std::string, Shader> shaders;
    static std::map<std::string, Texture2D> textures;
    
    // Loads (and generates) a shader program from file loading vertex, fragment (and geometry) shader's source code. If gShaderFile is not nullptr, it also loads a geometry shader
    static Shader LoadShader(const GLchar *vShaderFile, const GLchar *fShaderFile, const GLchar *gShaderFile, std::string name);
    
    // Retrieves a stored sader
    static Shader& GetShader(std::string name);
    
    // Loads (and generates) a texture from file
    static Texture2D LoadTexture(const GLchar *file, GLboolean alpha, std::string name);
    
    // Retrieves a stored texture
    static Texture2D& GetTexture(std::string name);
    
    // Properly de-allocates all loaded resources
    void Clear();
    
private:
    
    // Private constructor, that is we do not want any actual resource manager objects. Its members and functions should be publicly available (static).
    ResourceManager() {}
    
    // Loads and generates a shader from file
    static Shader LoadShaderFromFile(const GLchar *vShaderFile, const GLchar *fShaderFile, const GLchar *gShaderFile = nullptr);
    
    // Loads a single texture from file
    static Texture2D LoadTextureFromFile(const GLchar *file, GLboolean alpha, GLboolean turn = false);
    
    static char *LoadFileContent(const char *path, int &filesize);
};

#endif /* ResourceManager_hpp */
