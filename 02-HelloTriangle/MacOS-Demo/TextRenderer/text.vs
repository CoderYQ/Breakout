
#version 410

layout (location = 0) in vec4 vertex;

out vec2 texCoord;

uniform mat4 projectionMatrix;

void main()
{
    texCoord = vertex.zw;
    gl_Position = projectionMatrix * vec4(vertex.xy, 0.0, 1.0);
}
