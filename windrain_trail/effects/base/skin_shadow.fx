// Skinned Mesh Effect file 
#include "..\include\common.fx"
#include "..\include\shadow_common.fx"

texture tTX0;

bool _bInstancing = false; //instancing

bool _bBlendPass = false;

// Matrix Pallette
static const int MAX_MATRICES = 64;
float4x3    matWorldMatrixArray[MAX_MATRICES];
int nWeightNum = 0;


matrix matViewProj;



///////////////////////////////////////////////////////
struct VS_INPUT
{
    float4  Pos             : POSITION;
    float4  BlendWeights    : BLENDWEIGHT;
    int4  BlendIndices		: BLENDINDICES;
    float3  Normal          : NORMAL;
    float2 uv		: TEXCOORD0;

	float4 vInstanceMatrix1 : TEXCOORD1;
	float4 vInstanceMatrix2 : TEXCOORD2;
	float4 vInstanceMatrix3 : TEXCOORD3;
};


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float3 pos : TEXCOORD1; // vertex position in world space
   float3 normal : TEXCOORD2; // vertex normal in world space
};



VS_OUTPUT VShade(VS_INPUT i, uniform int NumBones)
{
    VS_OUTPUT   o;
    float3      Pos = 0.0f;
    float3      Normal = 0.0f;
    float       LastWeight = 0.0f;


	float4x4 mInstanceMatrix;
	if (_bInstancing) {
		// We've encoded the 4x3 world matrix in a 3x4, so do a quick transpose so we can use it in DX
		float4 row1 = float4(i.vInstanceMatrix1.x,i.vInstanceMatrix2.x,i.vInstanceMatrix3.x,0);
		float4 row2 = float4(i.vInstanceMatrix1.y,i.vInstanceMatrix2.y,i.vInstanceMatrix3.y,0);
		float4 row3 = float4(i.vInstanceMatrix1.z,i.vInstanceMatrix2.z,i.vInstanceMatrix3.z,0);
		float4 row4 = float4(i.vInstanceMatrix1.w,i.vInstanceMatrix2.w,i.vInstanceMatrix3.w,1);
		mInstanceMatrix = float4x4(row1,row2,row3,row4);
	}


    // cast the vectors to arrays for use in the for loop below
    float BlendWeightsArray[4] = (float[4])i.BlendWeights;
    int   IndexArray[4]        = (int[4])i.BlendIndices;
    
    // calculate the pos/normal using the "normal" weights 
    //        and accumulate the weights to calculate the last weight
    for (int iBone = 0; iBone < NumBones; iBone++) {
        LastWeight = LastWeight + BlendWeightsArray[iBone];
        
	float4x4 matworld= matrixconvert( matWorldMatrixArray[IndexArray[iBone]]);
	if (_bInstancing) { matworld= mul( matworld, mInstanceMatrix ); }
        Pos += mul(float4(i.Pos.xyz,1), matworld) * BlendWeightsArray[iBone];
        Normal += mul(i.Normal, (float3x3)matworld) * BlendWeightsArray[iBone];
    }
    LastWeight = 1.0f - LastWeight; 

    // Now that we have the calculated weight, add in the final influence
	float4x4 matworld= matrixconvert( matWorldMatrixArray[IndexArray[NumBones]]);
	if (_bInstancing) { matworld= mul( matworld, mInstanceMatrix ); }


    Pos += (mul(float4(i.Pos.xyz,1), matworld) * LastWeight);
    Normal += (mul(i.Normal, (float3x3)matworld) * LastWeight);

    
	o.pos = Pos;
    // transform position from world space into view and then projection space
    o.Pos = mul(float4(Pos.xyz, 1.0f), matViewProj);

    // normalize normals
    o.normal = normalize(Normal);

	o.uv = i.uv;

    return o;
}


sampler texbase = sampler_state {
	Texture = <tTX0>;
	MipFilter = Linear;
};



float4 mainps(VS_OUTPUT i, uniform bool bPS20=false, uniform bool bPS30=false) : COLOR0
{
	float4 base = tex2D(texbase,i.uv);

	float3 diffuseL=0;
	float3 specularL=0;

	lighting2l( bPS20, bPS30, diffuseL, specularL, i.pos, i.normal, base.a );


	if (_bBlendPass) {
		if (bPS30) if ( dot(diffuseL,1) < 0.01 && dot(specularL,1) < 0.01 ) discard;
	} else {
		diffuseL += _vAmbientColor;
	}

	base.rgb = base.rgb * diffuseL + specularL;

	return base;
};



VertexShader vsArray[4] = { compile vs_3_0 VShade(0), 
                            compile vs_3_0 VShade(1),
                            compile vs_3_0 VShade(2),
                            compile vs_3_0 VShade(3)
                          };


technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = (vsArray[nWeightNum]);
        PixelShader  = compile ps_3_0 mainps(true,true);
    }
};




VertexShader vsArray2[4] = { compile vs_2_0 VShade(0), 
                             compile vs_2_0 VShade(1),
                             compile vs_2_0 VShade(2),
                             compile vs_2_0 VShade(3)
                           };

technique T1
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = (vsArray2[nWeightNum]);
        PixelShader  = compile ps_2_0 mainps(true);
    }
};