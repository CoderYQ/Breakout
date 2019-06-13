
#version 410

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec3 a_color;
layout (location = 2) in vec2 a_texCoord;

out vec3 o_color;
out vec2 o_texCoord;

void main() {
    o_color = a_color;
    o_texCoord = a_texCoord;
    gl_Position = vec4(a_position.xyz, 1.0);
}
