// Skinned Mesh Effect file 
#include "..\include\common.fx"

texture tTX1;


// Matrix Pallette
static const int MAX_MATRICES = 64;
float4x3    matWorldMatrixArray[MAX_MATRICES];
int nWeightNum = 0;

matrix matViewProj;

bool _bInstancing; //instancing

vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)

bool _bSpecularEnable=true;
float _fSpecularPower=8;

vector _vecLight; // position of light0
vector _vecLightColor; // color of light0

vector _vecLight1; // position of light1
vector _vecLightColor1; // color of light1

dword _dwLightColor=0xffffffff;


///////////////////////////////////////////////////////
struct VS_INPUT
{
    float4  Pos             : POSITION;
    float4  BlendWeights    : BLENDWEIGHT;
    int4	 BlendIndices		: BLENDINDICES;
    float3  Normal          : NORMAL;
    float3  uv            : TEXCOORD0;

	float3 tan : TANGENT;
	float3 bin : BINORMAL;

     float4 vInstanceMatrix1 : TEXCOORD1;
     float4 vInstanceMatrix2 : TEXCOORD2;
     float4 vInstanceMatrix3 : TEXCOORD3;
};

struct VS_OUTPUT
{
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float4 Diffuse    : COLOR0;
   float4 Specular   : COLOR1;
   float3 vL		 : TEXCOORD1;
   float3 vH		 : TEXCOORD2;
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
    float3      Normal = 0.0f;
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
        Normal += mul(i.Normal, (float3x3)matworld) * BlendWeightsArray[iBone];
		tan += mul(i.tan, (float3x3)matworld) * BlendWeightsArray[iBone];
		bin += mul(i.bin, (float3x3)matworld) * BlendWeightsArray[iBone];
    }
    LastWeight = 1.0f - LastWeight; 


    // Now that we have the calculated weight, add in the final influence
	float4x4 matworld= matrixconvert( matWorldMatrixArray[IndexArray[NumBones]]);
	if (_bInstancing) { matworld= mul( matworld, mInstanceMatrix ); }


    pos += (mul(float4(i.Pos.xyz,1), matworld) * LastWeight);
    Normal += (mul(i.Normal, (float3x3)matworld) * LastWeight);
	tan += (mul(i.tan, (float3x3)matworld) * LastWeight);
	bin += (mul(i.bin, (float3x3)matworld) * LastWeight);

    
    // transform position from world space into view and then projection space
    o.Pos = mul(float4(pos.xyz, 1.0f), matViewProj);
	o.uv=i.uv;


    // normalize normals
    Normal = normalize(Normal);
	tan = normalize(tan);
	bin = normalize(bin);


    float3x3 matToTangentSpace;
    matToTangentSpace[0] = tan;
    matToTangentSpace[1] = bin;
    matToTangentSpace[2] = Normal;
	

	float3 vE=_vecEye.xyz-pos;
	vE=normalize(mul(matToTangentSpace, vE));

	//light0
	float3 vL=_vecLight.xyz-pos;
	// transform light vector to tangent space
	vL=normalize(mul(matToTangentSpace, vL));
	float3 vH = normalize(vE+vL);

    //and pack into [0..1] range
    o.Diffuse.xyz = vL * 0.5 + 0.5.xxx;
	o.Diffuse.w = 1.0f;

    o.Specular.xyz = vH * 0.5 + 0.5.xxx;
	o.Specular.w = 1.0f;

	//light1
	vL=_vecLight1.xyz-pos;
	// transform light vector to tangent space
	o.vL = normalize(mul(matToTangentSpace, vL));
	o.vH = normalize(vE+o.vL);
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


float4 mainps( VS_OUTPUT i ) : COLOR0
{
	float4 base=tex2D(texbase,i.uv);
	float4 normal=tex2D(texnormal,i.uv)*2-1;

	vector l =dot3lightingPS(normal.xyz,i.Diffuse.xyz*2-1,i.Specular.xyz*2-1,_fSpecularPower,_bSpecularEnable);
	vector l1=dot3lightingPS(normal.xyz,i.vL,i.vH,_fSpecularPower,_bSpecularEnable);

	float4 lightdif=_vecLightColor*l.y;
	float4 lightspec=_vecLightColor*l.z;

	lightdif+=_vecLightColor1*l1.y;
	lightspec+=_vecLightColor1*l1.z;

	float4 color=base*lightdif+lightspec;
	color.a=base.a;
	return color;
};


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
   SpecularEnable=False;

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

	//VertexShader = (vsArray[nWeightNum]);

  } // of pass2

}
