
#version 410

in vec2 texCoord;

//游戏场景渲染成的纹理对象
uniform sampler2D sceneTexture;

uniform bool chaos;
uniform bool confuse;
uniform bool shake;

//采样点距离本片段的偏移距离
const float offset = 1.0 / 300;
const float fractionalWidthOfPixel = 0.001;
const float aspectRatio = 100.0 / 800.0; //为了形成和窗口等比例大小的像素块

out vec4 fragColor;

void main()
{
    //采样算子
    vec2 offsets[9] = vec2[](
                             vec2(-offset, offset),  // top-left
                             vec2(0.0f,    offset),  // top-center
                             vec2(offset,  offset),  // top-right
                             vec2(-offset, 0.0f),    // center-left
                             vec2(0.0f,    0.0f),    // center-center
                             vec2(offset,  0.0f),    // center-right
                             vec2(-offset, -offset), // bottom-left
                             vec2(0.0f,    -offset), // bottom-center
                             vec2(offset,  -offset)  // bottom-right
                             );
    //模糊算子
    float blur_kernel[9] = float[](
                                   1.0 / 16, 2.0 / 16, 1.0 / 16,
                                   2.0 / 16, 4.0 / 16, 2.0 / 16,
                                   1.0 / 16, 2.0 / 16, 1.0 / 16
                                   );
    //边缘检测算子
    float edge_kernel[9] = float[](
                                   -1, -1, -1,
                                   -1,  8, -1,
                                   -1, -1, -1
                                   );
    vec3 samples[9];
    
    if (chaos || shake)
    {
        for (int i = 0; i < 9; i ++) {
            samples[i] = vec3(texture(sceneTexture, texCoord.st + offsets[i]));
        }
    }
    
    if (chaos)
    {
        for (int i = 0; i < 9; i ++) {
            fragColor += vec4(samples[i] * edge_kernel[i], 0.0f);
        }
        fragColor.a = 1.0;
    }
    else if (confuse)
    {
        fragColor = vec4(1.0 - texture(sceneTexture, texCoord).rgb, 1.0);
    }
    else if(shake)
    {
        for(int i = 0; i < 9; i++) {
            fragColor += vec4(samples[i] * blur_kernel[i], 0.0f);
        }
        fragColor.a = 1.0f;
    }
    else
    {
        fragColor = texture(sceneTexture, texCoord);
    }
}
