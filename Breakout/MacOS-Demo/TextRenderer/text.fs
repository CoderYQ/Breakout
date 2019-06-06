
#version 410

in vec2 texCoord;

out vec4 fragColor;

uniform sampler2D textTexture;

uniform vec3 textColor;

void main()
{
    vec4 sampled = vec4(1.0, 1.0, 1.0, texture(textTexture, texCoord).r);
    fragColor = vec4(textColor, 1.0) * sampled;
//    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}

