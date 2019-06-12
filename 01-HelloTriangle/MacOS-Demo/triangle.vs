
#version 410

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec3 a_color;

out vec3 o_color;

void main() {
    o_color = a_color;
    gl_Position = vec4(a_position.xyz, 1.0);
}
