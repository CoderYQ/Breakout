
#version 410

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

in VS_OUT {
    vec2 texCoord;
} gs_in[];

out vec2 texCoord;

void main()
{
    gl_Position = gl_in[0].gl_Position;
    texCoord = gs_in[0].texCoord;
    EmitVertex();
    
    gl_Position = gl_in[1].gl_Position;
    texCoord = gs_in[1].texCoord;
    EmitVertex();
    
    gl_Position = gl_in[2].gl_Position;
    texCoord = gs_in[2].texCoord;
    EmitVertex();
    
    EndPrimitive();
}
