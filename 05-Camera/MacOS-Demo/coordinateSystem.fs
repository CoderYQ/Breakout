
#version 410

uniform sampler2D imageTexture;

in vec2 o_texCoord;

out vec4 fragColor;

void main() {
    fragColor = texture(imageTexture, o_texCoord);
}
