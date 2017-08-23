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


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};

vector _layer_tile_param = { 256,256,256,256};



struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : TEXCOORD6;     // vertex diffuse color
	float3 Specular   : TEXCOORD7;     // vertex specular color

	float2 uv	  : TEXCOORD0;
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0)
{
	VS_OUTPUT o;

	ATMO_VS_OUTPUT atmo=atmosphere(vPosition,_vecEye,matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;


	o.Pos = mul(float4(vPosition,1), matTotal);

	o.uv=uv;

	return o;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};


sampler texAlpha=sampler_state {
	Texture = <tTX0>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
};

sampler texBase1=sampler_state {
	Texture = <tTX1>;
	ADDRESSU=Wrap;
	ADDRESSV=Wrap;
};

sampler texBase2=sampler_state {
	Texture = <tTX2>;
	ADDRESSU=Wrap;
	ADDRESSV=Wrap;
};

sampler texBase3=sampler_state {
	Texture = <tTX3>;
	ADDRESSU=Wrap;
	ADDRESSV=Wrap;
};

sampler texBase4=sampler_state {
	Texture = <tTX4>;
	ADDRESSU=Wrap;
	ADDRESSV=Wrap;
};

sampler texLightmap=sampler_state {
	Texture = <tTX5>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
	//MIPFILTER = None;
};


PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;
/*
	float4 alpha = tex2D(texAlpha, In.uv);
	float3 base1 = tex2D(texBase1, In.uv*512);
	float3 base2 = tex2D(texBase2, In.uv*512);
	float3 base3 = tex2D(texBase3, In.uv*32);
	float3 base4 = tex2D(texBase4, In.uv*256);
	float3 lightmap = tex2D(texLightmap, In.uv);
*/
	float4 alpha = tex2D(texAlpha, In.uv);
	float3 base1 = tex2D(texBase1, In.uv*_layer_tile_param.x);
	float3 base2 = tex2D(texBase2, In.uv*_layer_tile_param.y);
	float3 base3 = tex2D(texBase3, In.uv*_layer_tile_param.z);
	float3 base4 = tex2D(texBase4, In.uv*_layer_tile_param.w);
	float3 lightmap = tex2D(texLightmap, In.uv);


	float3 decal = lerp( base1, base2, alpha.r );
	decal = lerp( decal, base3, alpha.g );
	decal = lerp( decal, base4, alpha.b );

	Out.Color.xyz=decal;
	Out.Color.xyz*=lightmap;
	Out.Color.xyz*=In.Diffuse;
	Out.Color.xyz+=In.Specular;

	Out.Color.a=1;

	//Out.Color.rgb = decal;

	return Out;
};




technique T0
{
  pass P0
  {
    VertexShader = compile vs_2_0 mainvs();
    PixelShader  = compile ps_2_0 mainps();

  } // of pass0
}
