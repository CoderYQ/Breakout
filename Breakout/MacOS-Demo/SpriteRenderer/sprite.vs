
#version 410

/**
 vertex 输入数据
 vec2 表示位置信息, 2D平面没有 z 坐标
 vec2 表示纹理信息
 */
layout (location = 0) in vec4 vertex;

/**
 * 输出纹理坐标
 */
out VS_OUT {
    vec2 texCoord;
} vs_out;

uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;

void main()
{
    vs_out.texCoord = vertex.zw;
    gl_Position = projectionMatrix * modelMatrix * vec4(vertex.xy, 0.0, 1.0);
}
