#include "..\include\common.fx"
#include "..\include\shadow_common.fx"

//#include "..\include\atmosphere.fx"



//--- system variables, player feed value ----

//texture tTXn (n = 0..7)

texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;
texture tTX4;
texture tTX5;

bool _bBlendPass = false;

matrix matTotal; //matWorld*matView*matProj;
matrix matWorld; //World Matrix
matrix matView;  //View Matrix



vector _layer_tile_param = { 256,256,256,256};



struct VS_OUTPUT {
	float4 Pos: POSITION;
	float2 uv	 : TEXCOORD0;
	float3 pos : TEXCOORD1; // vertex position in world space
	float3 normal : TEXCOORD2; // vertex normal in world space

//	float3 Diffuse    : TEXCOORD6;     // vertex diffuse color
//	float3 Specular   : TEXCOORD7;     // vertex specular color

};



VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0)
{
	VS_OUTPUT o;

//	ATMO_VS_OUTPUT atmo=atmosphere(pos,_vecEye,matView);
//	o.Diffuse=atmo.colorE;
//	o.Specular=atmo.colorI;

	o.Pos = mul( pos, matTotal);
	o.pos = mul(float4(pos.xyz,1),matWorld); //vertex pos in world space

	o.normal = normalize( mul(n,(float3x3)matWorld) );
	o.uv=uv;

	return o;
};




sampler texAlpha=sampler_state {
	Texture = <tTX0>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
	MIPFILTER = None;
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
	MIPFILTER = None;
};


float4 mainps(VS_OUTPUT i, uniform bool bPS20=false, uniform bool bPS30=false) : COLOR0
{

	float3 diffuseL=0;
	float3 specularL=0;

	lighting2l( bPS20, bPS30, diffuseL, specularL, i.pos, i.normal, 1 );
//	return float4(diffuseL,1);

	if (_bBlendPass) {
		if (bPS30) if ( dot(diffuseL,1) < 0.01 && dot(specularL,1) < 0.01 ) discard;
	} else {
		diffuseL += tex2D(texLightmap, i.uv) + _vAmbientColor;
	}


	float4 alpha = tex2D(texAlpha, i.uv);
	float3 base1 = tex2D(texBase1, i.uv*_layer_tile_param.x);
	float3 base2 = tex2D(texBase2, i.uv*_layer_tile_param.y);
	float3 base3 = tex2D(texBase3, i.uv*_layer_tile_param.z);
	float3 base4 = tex2D(texBase4, i.uv*_layer_tile_param.w);


	float3 decal = lerp( base1, base2, alpha.r );
	decal = lerp( decal, base3, alpha.g );
	decal = lerp( decal, base4, alpha.b );

	float4 color = alpha.a;
	color.rgb = decal * diffuseL + specularL;
	//color.xyz*=i.Diffuse;
	//color.xyz+=i.Specular;

	return color;
};




//---- T0 ---- ps 3.0
technique T0
{
  pass P1
  {
  	AlphaTestEnable=True;
  	AlphaRef=0x08;
  	AlphaFunc=Less;

     VertexShader = compile vs_3_0 mainvs();
     PixelShader  = compile ps_3_0 mainps(true,true);
  }
} //of technique T0



//---- T1 ---- ps 2.0
technique T1
{
  pass P1
  {
  	AlphaTestEnable=True;
  	AlphaRef=0x08;
  	AlphaFunc=Less;

     VertexShader = compile vs_2_0 mainvs();
     PixelShader  = compile ps_2_0 mainps(true);
  }
} //of technique T1
