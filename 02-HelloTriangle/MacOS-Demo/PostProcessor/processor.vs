
#version 410

layout (location = 0) in vec4 vertex;

uniform bool chaos; //边缘检测
uniform bool confuse; //上下翻转
uniform bool shake; //抖动

uniform float time;

out vec2 texCoord;

void main()
{
    /**
     使用GPU版的全屏四边形，最重要的一点就是不需要对坐标进行各种矩阵的转换
     */
    gl_Position = vec4(vertex.xy, 0.0f, 1.0f);
    vec2 tempTexCoord = vertex.zw;
    texCoord = tempTexCoord;
    
    if(chaos)
    {
        //运动效果
        float strength = 0.3;
        vec2 pos = vec2(tempTexCoord.x + sin(time) * strength, tempTexCoord.y + cos(time) * strength);
        texCoord = pos;
    }
    else if(confuse)
    {
        texCoord = vec2(1.0 - tempTexCoord.x, 1.0 - tempTexCoord.y);
    }
    else
    {
        texCoord = tempTexCoord;
    }
    
    if (shake)
    {
        float strength = 0.01;
        gl_Position.x += cos(time * 10) * strength;
        gl_Position.y += cos(time * 15) * strength;
    }
}
