#include "..\include\atmosphere.fx"
//--- system variables, player feed value ----
texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecLight={0.0f,0.0f,0.0f,1.0f};
vector _vecLightColor={1,1,1,1};


//vector vSunDir = {-0.0471744f, 0.799484f, 0.598423f,1};


// --- user variables ---
vector vecShellDistance={1.0f,0.0f,0.0f,1.0f}; //shell distance
vector vecAmbient={.01f,.01f,.01f,1.0f}; //ambient
vector vecDiffuse={.08f,.08f,.08f,1.0f}; //diffuse
vector vecSpecular={.05f,.05f,.05f,1.0f}; //specular

//vector for uv transform
// x,y - uv scale; z,w - uv offset
// u = u * x + z; v = v * y + w
vector vecUV={1.0f,1.0f,0.0f,0.0f};
vector vecUV2={1.0f,1.0f,0.0f,0.0f};
vector vecUV3={1.0f,1.0f,0.0f,0.0f};

vector vecPass : register(c5) ={0,0,0,0};


struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : TEXCOORD6;     // vertex diffuse color
	float3 Specular   : TEXCOORD7;     // vertex specular color
	float2 uv1		: TEXCOORD1;
	float2 uv2		: TEXCOORD2;

	float3 l		: TEXCOORD3; //light vector in texture space
    float3 h		: TEXCOORD4; //half vector in texture space
	float3 up		: TEXCOORD5; //up vector in texture space
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0, float3 n: NORMAL, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT o;

	ATMO_VS_OUTPUT atmo=atmosphere(vPosition,_vecEye,matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;

	// offset shell in direction of normal
	float3 pos=vPosition + vecShellDistance.x * vecPass.x * n; //world space vertex pos
	o.Pos = mul( float4(pos,1), matTotal );

	// output texture coordinates
	o.uv1 = vPosition.xz * vecUV2.xy + vecUV2.zw;
	o.uv1.y = 1-o.uv1.y;

	o.uv2=(vPosition-_vecEye).xz*vecUV3.xy + vecUV3.zw;


    // compute the 3x3 tranform from tangent space to object space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from object 
    //   space to tangent space, though.
    float3x3 objToTangentSpace;
    objToTangentSpace[0] = tan;
    objToTangentSpace[1] = bin;
    objToTangentSpace[2] = n;

    o.l = normalize(mul(objToTangentSpace, vSunDir)); //light vector in texture space

	float3 v2eye=_vecEye-vPosition.xyz;
	v2eye=normalize(v2eye);

	float3 h=v2eye+vSunDir;
	h=normalize(h);

    o.h = normalize(mul(objToTangentSpace, h)); //half vector in texture space


	o.up = normalize(mul(objToTangentSpace, float3(0,1,0))); //up vector in texture space
	o.up *= (1-step(vPosition.y,500)); //under water check


	return o;
};





sampler texGreenNormal=sampler_state {
	Texture = <tTX0>;
};

sampler texNormal=sampler_state {
	Texture = <tTX1>;
};

sampler texFur=sampler_state {
	Texture = <tTX2>;
	MipFilter = None;
};

sampler texMask=sampler_state {
	Texture = <tTX3>;
};


	float3 vGreenColor={.3,.6,.3};
	float3 vStoneColor={.3,.3,.3};
	float fGreenUV=256;
	float fStoneUV=8;
	float fFurUV=128;


float4 mainps(VS_OUTPUT In) : COLOR0
{

    //fetch bump normal and unpack it to [-1..1] range
    float4 stoneNormal = tex2D(texNormal, In.uv1*fStoneUV);
	float4 greenNormal = tex2D(texGreenNormal, In.uv1*fGreenUV);
	float4 fur = tex2D(texFur,In.uv1*fFurUV);
	float4 mask = tex2D(texMask,In.uv2);

	stoneNormal = 2 * stoneNormal - 1;
	greenNormal = 2 * greenNormal - 1;

	float diffuse2 = saturate( dot(greenNormal.xyz, In.l) ); //*shadow;

	float up=saturate( dot(stoneNormal.xyz, In.up) );

	float3 greencolor=vGreenColor*diffuse2*up; //*greenNormal.a;

	float3 color=greencolor*In.Diffuse+In.Specular;

	float alpha=fur.a*up*mask.r*16;
	//alpha*=alpha;
	return float4(color,alpha);
};





technique T0
{

  pass P1
  {
	  /*
  Texture[0]=<tTX1>;
  ColorOp[0] = SelectArg2;
  AlphaOp[0] = SelectArg1;
  MipFilter[0] = None;


  Texture[1]=<tTX0>;
  ColorOp[1] = SelectArg1;
  AlphaArg1[1] = Texture;
  AlphaArg2[1] = Current;
  AlphaOp[1] = Modulate;

  Texture[2]=<tTX2>;
  ColorOp[2] = Modulate; //SelectArg1;
*/


    SrcBlend = SrcAlpha;
    DestBlend = InvSrcAlpha;
	AlphaBlendEnable = True;

	AlphaTestEnable=True;
	AlphaRef=0x08;
	AlphaFunc=GreaterEqual;

	ZWriteEnable=False;

	VertexShaderConstant[5] = {0,0,0,0}; //pass

    VertexShader = compile vs_2_0 mainvs();
    PixelShader  = compile ps_2_0 mainps();
  }

  pass P2
  {
	VertexShaderConstant[5] = {1,0,0,0}; //pass
  }

  pass P3
  {
	VertexShaderConstant[5] = {2,0,0,0}; //pass
  }

  pass P4
  {
	VertexShaderConstant[5] = {3,0,0,0}; //pass
  }
/*
  pass P5
  {
	VertexShaderConstant[5] = {4,0,0,0}; //pass
  }

  pass P6
  {
	VertexShaderConstant[5] = {5,0,0,0}; //pass
  }

  pass P7
  {
	VertexShaderConstant[5] = {6,0,0,0}; //pass
  }

  pass P8
  {
	VertexShaderConstant[5] = {7,0,0,0}; //pass
  }

  pass P9
  {
	VertexShaderConstant[5] = {8,0,0,0}; //pass
  }

  pass P10
  {
	VertexShaderConstant[5] = {9,0,0,0}; //pass
  }

  pass P11
  {
	VertexShaderConstant[5] = {10,0,0,0}; //pass
  }

  pass P12
  {
	VertexShaderConstant[5] = {11,0,0,0}; //pass
  }

  pass P13
  {
	VertexShaderConstant[5] = {12,0,0,0}; //pass
  }
*/
}


/*

technique T1
{

  pass P1
  {
  ColorOp[0] = Disable;
    SrcBlend = Zero;
    DestBlend = One;
	AlphaBlendEnable = True;
  }
}
*/