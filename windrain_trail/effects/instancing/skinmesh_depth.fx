

// Matrix Pallette
static const int MAX_MATRICES = 64;
float4x3    matWorldMatrixArray[MAX_MATRICES];
matrix matViewProj;
matrix matView; //View Matrix

bool _bInstancing; //instancing

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};


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
    float	dist    : TEXCOORD0; // distance from eye
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

        Pos += mul(i.Pos, matworld) * BlendWeightsArray[iBone];
    }
    LastWeight = 1.0f - LastWeight; 

    // Now that we have the calculated weight, add in the final influence
	float4x4 matworld= matrixconvert( matWorldMatrixArray[IndexArray[NumBones]]);
	if (_bInstancing) { matworld= mul( matworld, mInstanceMatrix ); }

    Pos += (mul(i.Pos, matworld) * LastWeight);
    
    // transform position from world space into view and then projection space
    Output.hpos = mul(float4(Pos.xyz, 1.0f), matViewProj);

	float fNear=_vecBackBufDesc.z;
	float fFar=_vecBackBufDesc.w;

	Output.dist = mul( float4(Pos.xyz, 1.0f), matView).z;

	Output.dist = (Output.dist-fNear) / (fFar-fNear);

	Output.dist = saturate(Output.dist);


    return Output;
}


float4 psmain( VS_OUTPUT v ) : COLOR0
{
    float4 color = float4(v.dist,v.dist,v.dist,v.dist);
    return color;
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
	    PixelShader  = compile ps_1_1 psmain(); 
    }
}

