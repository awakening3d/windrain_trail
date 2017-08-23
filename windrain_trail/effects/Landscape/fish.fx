// Skinned Mesh Effect file 
#include "..\include\atmosphere.fx"

texture tTX1;


// Matrix Pallette
static const int MAX_MATRICES = 64;
float4x3    matWorldMatrixArray[MAX_MATRICES];
int nWeightNum = 0;

matrix matViewProj;
matrix matView;  //View Matrix


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecLight={0.0f,0.0f,0.0f,1.0f};
vector _vecLightColor={1,1,1,1}; // color of light0
dword _dwLightColor=0xffffffff;


///////////////////////////////////////////////////////
struct VS_INPUT
{
    float4  Pos             : POSITION;
    float4  BlendWeights    : BLENDWEIGHT;
    int4  BlendIndices		: BLENDINDICES;
    float3  Normal          : NORMAL;
    float3  Tex0            : TEXCOORD0;

	float3 tan : TANGENT;
	float3 bin : BINORMAL;
};

struct VS_OUTPUT
{
    float4  Pos     : POSITION;
    float4  Diffuse : COLOR0;
	float4  Specular : COLOR1;
    float2  Tex0    : TEXCOORD0;
	float2  Tex1    : TEXCOORD1;

	float3 atmoDiffuse    : TEXCOORD2;     // vertex diffuse color
	float3 atmoSpecular   : TEXCOORD3;     // vertex specular color

};


VS_OUTPUT VShade(VS_INPUT i, uniform int NumBones)
{
    VS_OUTPUT   o;
    float3      Pos = 0.0f;
    float3      Normal = 0.0f;
    float       LastWeight = 0.0f;

	float3		tan = 0;
	float3		bin	= 0;
    

    // cast the vectors to arrays for use in the for loop below
    float BlendWeightsArray[4] = (float[4])i.BlendWeights;
    int   IndexArray[4]        = (int[4])i.BlendIndices;
    
    // calculate the pos/normal using the "normal" weights 
    //        and accumulate the weights to calculate the last weight
    for (int iBone = 0; iBone < NumBones; iBone++)
    {
        LastWeight = LastWeight + BlendWeightsArray[iBone];
        
        Pos += mul(float4(i.Pos.xyz,1), matWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
        Normal += mul(i.Normal, matWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
		tan += mul(i.tan, matWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
		bin += mul(i.bin, matWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
    }
    LastWeight = 1.0f - LastWeight; 

    // Now that we have the calculated weight, add in the final influence
    Pos += (mul(float4(i.Pos.xyz,1), matWorldMatrixArray[IndexArray[NumBones]]) * LastWeight);
    Normal += (mul(i.Normal, matWorldMatrixArray[IndexArray[NumBones]]) * LastWeight);
	tan += (mul(i.tan, matWorldMatrixArray[IndexArray[NumBones]]) * LastWeight);
	bin += (mul(i.bin, matWorldMatrixArray[IndexArray[NumBones]]) * LastWeight);

    
    // transform position from world space into view and then projection space
    o.Pos = mul(float4(Pos.xyz, 1.0f), matViewProj);

    // normalize normals
    Normal = normalize(Normal);
	tan = normalize(tan);
	bin = normalize(bin);


    float3x3 matToTangentSpace;
    matToTangentSpace[0] = tan;
    matToTangentSpace[1] = bin;
    matToTangentSpace[2] = Normal;
	
	float3 vL=_vecLight.xyz-Pos;
	float3 vE=_vecEye.xyz-Pos;

	// transform light vector to tangent space
	vL=normalize(mul(matToTangentSpace, vL));
	vE=normalize(mul(matToTangentSpace, vE));

	float3 vH = normalize(vE+vL);

    //and pack into [0..1] range
    o.Diffuse.xyz = vL * 0.5 + 0.5.xxx;
	o.Diffuse.w = 1.0f;

    o.Specular.xyz = vH * 0.5 + 0.5.xxx;
	o.Specular.w = 1.0f;

    // copy the input texture coordinate through
    o.Tex0  = i.Tex0.xy;
	o.Tex1  = i.Tex0.xy;


	ATMO_VS_OUTPUT atmo=atmosphere(Pos,_vecEye,matView);
	o.atmoDiffuse=atmo.colorE;
	o.atmoSpecular=atmo.colorI;

    return o;
}




VertexShader vsArray[4] = { compile vs_2_0 VShade(0), 
                            compile vs_2_0 VShade(1),
                            compile vs_2_0 VShade(2),
                            compile vs_2_0 VShade(3)
                          };





sampler texnormal;

sampler texbase=sampler_state {
	Texture = <tTX1>;
};


float4 mainps( VS_OUTPUT In ) : COLOR0
{
	float4 base=tex2D(texbase, In.Tex0);

    //fetch bump normal and unpack it to [-1..1] range
    float3 bumpNormal = 2 * tex2D(texnormal, In.Tex0) - 1;
	float3 vL = In.Diffuse.xyz * 2 -1;
	float3 vH = In.Specular.xyz * 2 -1;

    float diffuse = dot(bumpNormal, vL);
	float specular =  dot(bumpNormal, vH)*0.5;
	specular = pow( saturate(specular), 16 );


	float3 color= (base.xyz*diffuse+specular)*_vecLightColor;


	color*=In.atmoDiffuse;
	color+=In.atmoSpecular;

    return float4(color,1);
}


technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = (vsArray[nWeightNum]);
        PixelShader  = compile ps_2_0 mainps();
    }
};

//////////////////////////////////////
// Techniques specs follow
//////////////////////////////////////
technique t1
{

  pass P1 // specular
  {
  TextureFactor = <_dwLightColor>;

  // stage0
  ColorArg2[0] = Specular;
  ColorOp[0] = DotProduct3;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Current;
  ColorArg2[1] = Current;

  // stage2
  ColorOp[2] = Modulate;
  ColorArg1[2] = Current;
  ColorArg2[2] = Current;

  // stage 3
  ColorOp[3] = Modulate;
  ColorArg1[3] = TFactor;
  ColorArg2[3] = Current;

  // stage4
  ColorOp[4] = Disable;

	VertexShader = (vsArray[nWeightNum]);

  } // of pass1


  pass P2 //diffuse x texture
  {
  TextureFactor = <_dwLightColor>;

  // stage0
  ColorArg2[0] = Diffuse;
  ColorOp[0] = DotProduct3;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;

  Texture[1] = <tTX1>;

  // stage 2
  ColorOp[2] = Modulate;
  ColorArg1[2] = TFactor;
  ColorArg2[2] = Current;

  // stage3
  ColorOp[3] = Disable;


  // alpha blend
  SrcBlend = One;
  DestBlend = One;
  AlphaBlendEnable = True;
  ZWriteEnable = False;

	VertexShader = (vsArray[nWeightNum]);

  } // of pass2

}

