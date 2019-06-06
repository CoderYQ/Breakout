
#version 410

/**
 vertex 输入数据
 vec2 表示位置信息, 2D平面没有 z 坐标
 vec2 表示纹理信息
 */
layout (location = 0) in vec4 vertex;

/**
 输出纹理坐标
 输出该粒子的颜色
 */
out vec2 texCoord;
out vec4 particleColor;

uniform mat4 projectionMatrix;
uniform vec2 offset;
uniform vec4 color;

void main()
{
    float scale = 10.0f;
    texCoord = vertex.zw;
    particleColor = color;
    gl_Position = projectionMatrix * vec4((vertex.xy * scale) + offset, 0.0, 1.0);
}
