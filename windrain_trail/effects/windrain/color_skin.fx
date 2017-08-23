// Skinned Mesh Effect file 

texture tTX1;


// Matrix Pallette
static const int MAX_MATRICES = 64;
float4x3    matWorldMatrixArray[MAX_MATRICES];
int nWeightNum = 0;

matrix matViewProj;

vector _vAmbientColor; // material's ambient color

vector _vecLight={0.0f,0.0f,0.0f,1.0f};
vector _vecEye={0.0f,1000.0f,0.0f,1.0f};


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

    //fetch bump normal and unpack it to [-1..1] range
    float3 bumpNormal = float3(0,0,1);
	float3 vL = In.Diffuse.xyz * 2 -1;
	float3 vH = In.Specular.xyz * 2 -1;

    float diffuse = saturate( dot(bumpNormal, vL) );
	//float specular =  dot(bumpNormal, vH);
	//specular = pow( saturate(specular), 4 );
	float3 color= base.xyz * (_vAmbientColor+diffuse);

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