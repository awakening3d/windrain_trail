// Skinned Mesh Effect file 
#include "..\include\common.fx"


texture tTX1;


// Matrix Pallette
static const int MAX_MATRICES = 64;
float4x3    matWorldMatrixArray[MAX_MATRICES];
int nWeightNum = 0;

matrix matViewProj;

bool _bInstancing; //instancing

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};

vector _vecLight; // position of light0
vector _vecLightColor; // color of light0

vector _vecLight1; // position of light1
vector _vecLightColor1; // color of light1

bool _bSpecularEnable=true;
float _fSpecularPower=8;



///////////////////////////////////////////////////////
struct VS_INPUT
{
    float4  Pos             : POSITION;
    float4  BlendWeights    : BLENDWEIGHT;
    int4  BlendIndices		: BLENDINDICES;
    float3  Normal          : NORMAL;
    float3  Tex0            : TEXCOORD0;

     float4 vInstanceMatrix1 : TEXCOORD1;
     float4 vInstanceMatrix2 : TEXCOORD2;
     float4 vInstanceMatrix3 : TEXCOORD3;
};

struct VS_OUTPUT
{
    float4  Pos     : POSITION;
    float4  Diffuse : COLOR0; // L vector in texture space
	float4  Specular : COLOR1; // H vector in texture space
    float2  Tex0    : TEXCOORD0;
	float2  Tex1    : TEXCOORD1;
};

float4x4 matrixconvert(float4x3 m)
{
	return float4x4(	float4( m[0].x, m[0].y, m[0].z, 0),
						float4( m[1].x, m[1].y, m[1].z, 0),
						float4( m[2].x, m[2].y, m[2].z, 0),
						float4( m[3].x, m[3].y, m[3].z, 1)	);
}


VS_OUTPUT VShade(VS_INPUT i, uniform int NumBones)
{
    VS_OUTPUT   o;
    float3      pos = 0.0f;
    float3      n = 0.0f;
    float       LastWeight = 0.0f;

	float3		tan = 0;
	float3		bin	= 0;
    
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
        
        pos += mul(float4(i.Pos.xyz,1), matworld) * BlendWeightsArray[iBone];
        n += mul(i.Normal, (float3x3)matworld) * BlendWeightsArray[iBone];
    }
    LastWeight = 1.0f - LastWeight; 


    // Now that we have the calculated weight, add in the final influence
	float4x4 matworld= matrixconvert( matWorldMatrixArray[IndexArray[NumBones]]);
	if (_bInstancing) { matworld= mul( matworld, mInstanceMatrix ); }


    pos += (mul(float4(i.Pos.xyz,1), matworld) * LastWeight);
    n += (mul(i.Normal, (float3x3)matworld) * LastWeight);

    
    // transform position from world space into view and then projection space
    o.Pos = mul(float4(pos.xyz, 1.0f), matViewProj);

    // normalize normals
    n = normalize(n);


	//vertex lighting

	//light0
	vector l=dot3lighting(_vecLight.xyz,pos.xyz,n.xyz,_vecEye,_fSpecularPower,_bSpecularEnable);
	o.Diffuse=l.y*_vecLightColor;
	o.Specular=l.z*_vecLightColor;

	//light1
	l=dot3lighting(_vecLight1.xyz,pos.xyz,n.xyz,_vecEye,_fSpecularPower,_bSpecularEnable);
	o.Diffuse+=l.y*_vecLightColor1;
	o.Specular+=l.z*_vecLightColor1;


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





technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = (vsArray[nWeightNum]);
    }
};