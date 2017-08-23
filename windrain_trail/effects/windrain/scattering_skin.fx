// Skinned Mesh Effect file 
#include "..\include\atmosphere.fx"

// Matrix Pallette
static const int MAX_MATRICES = 64;
float4x3    matWorldMatrixArray[MAX_MATRICES];
int nWeightNum = 0;


matrix matTotal; //matWorld*matView*matProj;
matrix matView;
matrix matViewProj;

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};

vector _vAmbientColor; // material's ambient color


///////////////////////////////////////////////////////
struct VS_INPUT
{
    float4  Pos             : POSITION;
    float4  BlendWeights    : BLENDWEIGHT;
    int4  BlendIndices		: BLENDINDICES;
    float3  Normal          : NORMAL;
    float3  Tex0            : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4  Pos     : POSITION;
    float3  Diffuse : COLOR0;
	float3  Specular : COLOR1;
    float2  Tex0    : TEXCOORD0;
};


VS_OUTPUT VShade(VS_INPUT i, uniform int NumBones)
{
    VS_OUTPUT   o;
    float3      Pos = 0.0f;
    float3      Normal = 0.0f;
    float       LastWeight = 0.0f;
   

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
    }
    LastWeight = 1.0f - LastWeight; 

    // Now that we have the calculated weight, add in the final influence
    Pos += (mul(float4(i.Pos.xyz,1), matWorldMatrixArray[IndexArray[NumBones]]) * LastWeight);
    Normal += (mul(i.Normal, matWorldMatrixArray[IndexArray[NumBones]]) * LastWeight);

    
    // transform position from world space into view and then projection space
    o.Pos = mul(float4(Pos.xyz, 1.0f), matViewProj);

    // normalize normals
    float3 n  = normalize(Normal);

	ATMO_VS_OUTPUT atmo=atmosphere( Pos.xyz, _vecEye, matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;


	float3 v2eye=_vecEye-Pos.xyz;
	v2eye=normalize(v2eye);

	float ne=dot(n,v2eye);
	if (ne<0) n=-n;

	//light0
	float3 v2l=vSunDir;
	float diffuse = dot(n, v2l);

	float3 h=v2eye+v2l;
	h=normalize(h);
	float specular =  dot(n, h)*.5;
	specular = pow( saturate(specular), 16);

	//light1
	v2l=float3(0,1,0);
	diffuse += dot(n,v2l);

	o.Diffuse *= diffuse*.5;
	o.Specular += specular;

    // copy the input texture coordinate through
    o.Tex0  = i.Tex0.xy;

    return o;
}




VertexShader vsArray[4] = { compile vs_2_0 VShade(0), 
                            compile vs_2_0 VShade(1),
                            compile vs_2_0 VShade(2),
                            compile vs_2_0 VShade(3)
                          };





sampler texbase;

float4 mainps( VS_OUTPUT In ) : COLOR0
{
	float4 base=tex2D(texbase, In.Tex0);

	float4 color  = base;
	color.xyz*= (In.Diffuse+_vAmbientColor);
	color.xyz+=In.Specular;
	return color;
}


technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = (vsArray[nWeightNum]);
        PixelShader  = compile ps_2_0 mainps();

	CullMode=None;
    }
};