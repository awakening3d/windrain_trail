#include "..\include\atmosphere.fx"

texture tTX0;
texture tTX1;

matrix matTotal; //matWorld*matView*matProj;

matrix matView;  //View Matrix

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};


struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : TEXCOORD1;     // vertex diffuse color
	float3 Specular   : TEXCOORD2;     // vertex specular color

	float2 uv	  : TEXCOORD0;
	float2 uv1	: TEXCOORD3;
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0, float2 uv1: TEXCOORD1)
{
	VS_OUTPUT o;

	ATMO_VS_OUTPUT atmo=atmosphere(vPosition,_vecEye,matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;


	o.Pos = mul(float4(vPosition,1), matTotal);

	o.uv = uv;
	o.uv1 = uv1;

	return o;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};


sampler texBase=sampler_state {
	Texture = <tTX0>;
};

sampler texLightmap = sampler_state {
	Texture = <tTX1>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
	//MIPFILTER = None;
};


PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;

	float4 basec = tex2D(texBase, In.uv);
	float4 lightmap = tex2D(texLightmap, In.uv1);

	Out.Color = basec;
	Out.Color.xyz*=lightmap;
	Out.Color.xyz*=In.Diffuse;
	Out.Color.xyz+=In.Specular;

	return Out;
};




technique T0
{
  pass P0
  {

  VertexShader = compile vs_2_0 mainvs();
  PixelShader  = compile ps_2_0 mainps();

  }
}