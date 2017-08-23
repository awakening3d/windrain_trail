#include "..\include\atmosphere.fx"

//--- system variables, player feed value ----

//texture tTXn (n = 0..7)

texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;
texture tTX4;
texture tTX5;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix

vector _vecAppTime;

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};

vector _terrain_size; // x - min x, y - min z, z - width, w - height


struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : TEXCOORD6;     // vertex diffuse color
	float3 Specular   : TEXCOORD7;     // vertex specular color

	float2 uv	  : TEXCOORD0;
	float2 lmuv	  : TEXCOORD1;
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0)
{
	VS_OUTPUT o;

	vPosition.x += sin(_vecAppTime.x + (vPosition.x+vPosition.z)*0.01f ) * (1-uv.y) * 2;

	ATMO_VS_OUTPUT atmo=atmosphere(vPosition,_vecEye,matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;

	o.Pos = mul(float4(vPosition,1), matTotal);

	o.uv=uv;

	uv = (vPosition.xz - _terrain_size.xy) / _terrain_size.zw;
	o.lmuv.x = uv.x;
	o.lmuv.y = 1-uv.y;
	return o;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};


sampler texMain=sampler_state {
	Texture = <tTX0>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
	MipMapLodBias = -1;
	//MIPFILTER = None;
};

sampler texLightmap=sampler_state {
	Texture = <tTX1>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
	//MIPFILTER = None;
};


PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;

	float4 basec = tex2D(texMain, In.uv);
	float3 lightmap = tex2D(texLightmap, In.lmuv);

	Out.Color.xyz=basec;
	Out.Color.xyz *= lerp(1, lightmap, saturate(In.uv.y+0.5) );
	Out.Color.xyz*=In.Diffuse;
	Out.Color.xyz+=In.Specular;

	Out.Color.a=basec.a;


	return Out;
};




technique T0
{
  pass P0
  {
    VertexShader = compile vs_2_0 mainvs();
    PixelShader  = compile ps_2_0 mainps();


	CullMode=None;
	AlphaTestEnable=True;
	AlphaRef=0x08;
	AlphaFunc=GreaterEqual;

	SrcBlend = SrcAlpha;
	DestBlend = InvSrcAlpha;
	//AlphaBlendEnable = True;

	//MipFilter[0] = None;

  } // of pass0
}
