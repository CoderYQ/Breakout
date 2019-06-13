
#version 410

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec2 a_texCoord;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

out vec2 o_texCoord;

void main() {
    o_texCoord = a_texCoord;
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(a_position.xyz, 1.0);
}
