#include "..\include\atmosphere.fx"


texture tTX0;
texture tTX1;
texture tTX2;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix
matrix matViewProj; //matView*matProj
bool _bInstancing; //instancing



vector appConst = {0.25f, 0.5f, 0.75f, 1.0f};

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecAppTime;



vector vSunDirNM = {0.0471744f,0.598423f,0.799484f,1};
DWORD dwSunDir=0xff85cbe5;

vector maxBright={0.3f,0.3f,0.3f,1};


struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : COLOR0;     // vertex diffuse color
	float3 Specular   : COLOR1;     // vertex specular color
	float2 uv		: TEXCOORD0;
	float2 uv1		: TEXCOORD1;
	float2 uv2		: TEXCOORD2;
	float3 l		: TEXCOORD3; //light vector in texture space
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0, float3 n: NORMAL, float3 bin: BINORMAL, float3 tan: TANGENT,
                         float4 vInstanceMatrix1 : TEXCOORD1,
                         float4 vInstanceMatrix2 : TEXCOORD2,
                         float4 vInstanceMatrix3 : TEXCOORD3 )

{
	VS_OUTPUT Out;

	
	if (_bInstancing) {
		// We've encoded the 4x3 world matrix in a 3x4, so do a quick transpose so we can use it in DX
		float4 row1 = float4(vInstanceMatrix1.x,vInstanceMatrix2.x,vInstanceMatrix3.x,0);
		float4 row2 = float4(vInstanceMatrix1.y,vInstanceMatrix2.y,vInstanceMatrix3.y,0);
		float4 row3 = float4(vInstanceMatrix1.z,vInstanceMatrix2.z,vInstanceMatrix3.z,0);
		float4 row4 = float4(vInstanceMatrix1.w,vInstanceMatrix2.w,vInstanceMatrix3.w,1);
		float4x4 mInstanceMatrix = float4x4(row1,row2,row3,row4);

		matWorld=mInstanceMatrix;
	}


	float ofs=sin(_vecAppTime.x) * vPosition.y*0.3f;
	vPosition.x+=ofs;
	vPosition.z-=ofs;

	float4 pos=mul(float4(vPosition,1),matWorld);

	ATMO_VS_OUTPUT atmo=atmosphere( pos.xyz, _vecEye, matView);
	Out.Diffuse=atmo.colorE * 0.6;
	Out.Specular=atmo.colorI;

	Out.Pos=mul(pos,matViewProj);

	Out.uv=uv;
	Out.uv1=uv;
	Out.uv2=uv;

	n=normalize(n);

    // compute the 3x3 tranform from tangent space to object space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from object 
    //   space to tangent space, though.
    float3x3 objToTangentSpace;
    objToTangentSpace[0] = tan;
    objToTangentSpace[1] = bin;
    objToTangentSpace[2] = n;

    Out.l = normalize(mul(objToTangentSpace, vSunDir)); //light vector in texture space


	return Out;
};


/*
float4 psmain( VS_OUTPUT v ) : COLOR0
{
    float4 color = float4(v.Diffuse.xyz,1);
    return color;
}*/


technique T0
{
  pass P0
  {
	// vertex shader
    VertexShader = compile vs_2_0 mainvs();
    //PixelShader  = compile ps_1_1 psmain();

	TextureFactor = <dwSunDir>;

	  // stage0
	  ColorOp[0] = Modulate2x;
	  ColorArg1[0] = Texture; //Extinction
	  ColorArg2[0] = Diffuse;
	  Texture[0] = <tTX0>;
		AlphaOp[0] = SelectArg1;
		AddressV[0] = Clamp;

	  // state1
	  ColorOp[1] = Disable;

  AlphaTestEnable=True;
  AlphaRef=0x80;
  AlphaFunc=GreaterEqual;

  SrcBlend = SrcAlpha;
  DestBlend = InvSrcAlpha;
  AlphaBlendEnable = True;
  CullMode=None;

  SpecularEnable=True;

  } // of pass0
}
