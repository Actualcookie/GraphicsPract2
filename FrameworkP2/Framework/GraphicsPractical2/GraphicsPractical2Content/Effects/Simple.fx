//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265
//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime
// Top level variables for Lambertian shading
float4x4 WorldInverseTranspose;

float3 LightDirection;
float4 DiffuseColor = float4(1, 1, 1, 1);
float DiffuseStrenght = 1.0;
//Variables for Lambertian shading + Ambient colors
float4 AmbientColor;
float AmbientIntensity;
// Matrices for 3D perspective projection 
float4x4 View, Projection, World;
float4 Color;
//---------------------------------- Input / Output structures ----------------------------------

// Each member of the struct has to be given a "semantic", to indicate what kind of data should go in
// here and how it should be treated. Read more about the POSITION0 and the many other semantics in 
// the MSDN library
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float4 Normal : NORMAL0;
	float4 Color : COLOR0;
};

// The output of the vertex shader. After being passed through the interpolator/rasterizer it is also 
// the input of the pixel shader. 
// Note 1: The values that you pass into this struct in the vertex shader are not the same as what 
// you get as input for the pixel shader. A vertex shader has a single vertex as input, the pixel 
// shader has 3 vertices as input, and lets you determine the color of each pixel in the triangle 
// defined by these three vertices. Therefor, all the values in the struct that you get as input for 
// the pixel shaders have been linearly interpolated between there three vertices!
// Note 2: You cannot use the data with the POSITION0 semantic in the pixel shader.

struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float4 tex : TEXCOORD2;
	float4 TNormal : TEXCOORD1;
	float4 Color : COLOR0;
};

//------------------------------------------ Functions ------------------------------------------

// Implement the Coloring using normals assignment here
float4 NormalColor( VertexShaderOutput input ) 
{
	float4 color = input.TNormal.xyzw;
	return color;
}

// Implement the Procedural texturing assignment here
float4 ProceduralColor(VertexShaderOutput output)
{
	if (sin(Pi*output.tex.y / 0.15) > 0 && sin(Pi*output.tex.x / 0.15)>0 || sin(Pi*output.tex.y / 0.15)<0 && sin(Pi*output.tex.x / 0.15)<0)
	{
		float4 color = output.TNormal;
		return color;
	}
	else
	{
		float4 color = -output.TNormal;
			return color;
	}
	
}

//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	output.tex = input.Position3D;
	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
    float4 viewPosition  = mul(worldPosition, View);
	output.Position2D    = mul(viewPosition, Projection);
	output.TNormal = input.Normal;
	//Lambertian shading code goes here
	float4 Lnormal = mul(input.Normal, WorldInverseTranspose);
	float lightStrenght = dot(Lnormal, LightDirection);
	output.Color = saturate(DiffuseColor * DiffuseStrenght * lightStrenght);

	return output;
}

float4 SimplePixelShader(VertexShaderOutput output) : COLOR0
{
	//NormalColoring
	//float4 color = NormalColor(output);
	//Procedural Coloring
	float4 color = ProceduralColor(output);
	return color;
	//LamBertian Shading with ambient guesses
	//return saturate(output.Color + AmbientColor * AmbientIntensity);
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader  = compile ps_2_0 SimplePixelShader();
	}
}