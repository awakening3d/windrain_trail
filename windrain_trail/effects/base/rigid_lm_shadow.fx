//--- system variables, player feed value ----
#include "..\include\common.fx"
#include "..\include\shadow_common.fx"


//texture tTXn {n = 0..7}
texture tTX0;
texture tTX1;



bool _bBlendPass = false;

matrix matTotal; //matWorld*matView*matProj;
matrix matWorld; //World Matrix


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float2 uv1 : TEXCOORD1;
   float3 pos : TEXCOORD2; // vertex position in world space
   float3 normal : TEXCOORD5; // vertex normal in world space
};



VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0, float2 uv1: TEXCOORD1)
{
	VS_OUTPUT o;
 
	o.Pos = mul(pos, matTotal);
	o.uv = uv;
	o.uv1 = uv1;

	o.normal = normalize( mul(n,(float3x3)matWorld) );

	o.pos = mul( pos, matWorld ); //vertex pos in world space

	return o;
};



sampler texbase=sampler_state {
	Texture = <tTX0>;
	MipFilter = Linear;
};

sampler texlightmap=sampler_state {
	Texture = <tTX1>;
	MipFilter = Linear;
};





float4 mainps(VS_OUTPUT i, uniform bool bPS20=false, uniform bool bPS30=false) : COLOR0
{
	float4 base=tex2D(texbase,i.uv);

	float3 diffuseL=0;
	float3 specularL=0;

	lighting2l( bPS20, bPS30, diffuseL, specularL, i.pos, i.normal, base.a );


	if (_bBlendPass) {
		if (bPS30) if ( dot(diffuseL,1) < 0.01 && dot(specularL,1) < 0.01 ) discard;
	} else {
		diffuseL += tex2D(texlightmap,i.uv1) + _vAmbientColor;
	}

	base.rgb = base.rgb * diffuseL + specularL;

	return base;
};


//---- T0 ---- ps 3.0
technique T0
{
  pass P1
  {
     VertexShader = compile vs_3_0 mainvs();
     PixelShader  = compile ps_3_0 mainps(true,true);
  }
} //of technique T0



//---- T1 ---- ps 2.0
technique T1
{
  pass P1
  {
     VertexShader = compile vs_2_0 mainvs();
     PixelShader  = compile ps_2_0 mainps(true);
  }
} //of technique T1


//--- T3 ---- no ps
technique T3
{
  pass P2 //diffuse x texture
  {
  SpecularEnable=False;

  // stage0
  ColorOp[0] = Modulate;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Current;

  Texture[0] = <tTX0>;

  // stage 1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;

  Texture[1] = <tTX1>;

  // stage 3
  ColorOp[3] = Disable;

	// vertex shader
	// vertex shader constant
	VertexShader = compile vs_1_1 mainvs();

  } // of pass2

} //of technique T3

