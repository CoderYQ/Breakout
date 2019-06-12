
#version 410

in vec3 o_color;

out vec4 fragColor;

void main() {
    fragColor = vec4(o_color.rgb, 1.0);
}
