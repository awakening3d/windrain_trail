#include ".\common.fx"


// Matrix Pallette
static const int MAX_MATRICES = 64;
float4x3    matWorldMatrixArray[MAX_MATRICES];
matrix matViewProj;
matrix matWorld;
matrix matView; //View Matrix


vector _vecEye;


bool _bInstancing = false; //instancing

///////////////////////////////////////////////////////
struct VS_INPUT
{
    float4  Pos             : POSITION;
    float4  BlendWeights    : BLENDWEIGHT;
    int4  BlendIndices    : BLENDINDICES;
	float4 vInstanceMatrix1 : TEXCOORD1;
	float4 vInstanceMatrix2 : TEXCOORD2;
	float4 vInstanceMatrix3 : TEXCOORD3;

};

struct VS_OUTPUT
{
    float4	hpos   : POSITION;  // vertex position 
	float3	pos		:  TEXCOORD0; // vertex position in world space
};



VS_OUTPUT VShade(VS_INPUT i, uniform int NumBones)
{
    VS_OUTPUT Output;
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
    for (int iBone = 0; iBone < NumBones; iBone++)
    {
        LastWeight = LastWeight + BlendWeightsArray[iBone];
        
	float4x4 matworld= matrixconvert( matWorldMatrixArray[IndexArray[iBone]]);
	if (_bInstancing) { matworld= mul( matworld, mInstanceMatrix ); }
        Pos += mul(float4(i.Pos.xyz,1), matworld) * BlendWeightsArray[iBone];
    }
    LastWeight = 1.0f - LastWeight; 

    // Now that we have the calculated weight, add in the final influence
    float4x4 matworld= matrixconvert( matWorldMatrixArray[IndexArray[NumBones]]);
    if (_bInstancing) { matworld= mul( matworld, mInstanceMatrix ); }
    Pos += (mul(float4(i.Pos.xyz,1), matworld) * LastWeight);

    
    // transform position from world space into view and then projection space
    Output.hpos = mul(float4(Pos.xyz, 1.0f), matViewProj);
	Output.pos = Pos;

    return Output;
}


float4 psmain( VS_OUTPUT i ) : COLOR0
{
	float dist = length( i.pos.xyz - _vecEye.xyz );
	return encode_depth(dist);
}




int nWeightNum = 2;
VertexShader vsArray[4] = { compile vs_2_0 VShade(0), 
                            compile vs_2_0 VShade(1),
                            compile vs_2_0 VShade(2),
                            compile vs_2_0 VShade(3)
                          };





//////////////////////////////////////
// Techniques specs follow
//////////////////////////////////////
technique t0
{
    pass p0
    {
        VertexShader = (vsArray[nWeightNum]);
	    PixelShader  = compile ps_2_0 psmain();
		CullMode=None;
    }
}

