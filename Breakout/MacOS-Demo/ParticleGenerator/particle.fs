
#version 410

/**
 * 顶点着色器的输出, 作为片段着色器的输入
 */
in vec2 texCoord;
in vec4 particleColor;

/**
 * 片段着色器的输出
 */
out vec4 fragColor;

/**
 * 1. 纹理图片
 * 2. 点精灵的颜色
 */
uniform sampler2D imageTexture;

void main()
{
    fragColor = (vec4(0.8) - texture(imageTexture, texCoord)) * particleColor;
}
