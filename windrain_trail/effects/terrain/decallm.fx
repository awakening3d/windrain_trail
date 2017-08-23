//--- system variables, player feed value ----
#include "..\include\common.fx"
#include "..\include\shadow_common.fx"
//#include "..\include\atmosphere.fx"


bool _bBlendPass = false;

//texture tTXn {n = 0..7}
texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;

matrix matTotal; //matWorld*matView*matProj;
matrix matWorld; //World Matrix
matrix matView;  //View Matrix

// terrain
vector _decal_tile_param = { 512, 512, 0, 0 }; // nTileW, nTileH


//---- user variables ---
vector vecOffset={-0.06f, -0.03f, -0.03f, 1.0f};


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float3 pos : TEXCOORD1; // vertex position in world space
   float3 normal : TEXCOORD2; // vertex normal in world space

//   float3 atmoE : TEXCOORD3;
//   float3 atmoI : TEXCOORD4;
};


VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0)
{
	VS_OUTPUT o;

//	ATMO_VS_OUTPUT atmo=atmosphere(pos,_vecEye,matView);
//	o.atmoE=atmo.colorE;
//	o.atmoI=atmo.colorI;
  
	o.Pos = mul(pos, matTotal);
	o.uv = uv;
	o.pos = mul(float4(pos.xyz ,1),matWorld); //vertex pos in world space
	o.normal = n;

	return o;
};

sampler texalpha=sampler_state {
	Texture = <tTX0>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
	MIPFILTER = None;
};

sampler texbase=sampler_state {
	Texture = <tTX1>;
	ADDRESSU=Wrap;
	ADDRESSV=Wrap;
	MipFilter = Linear;
};

sampler texlightmap=sampler_state {
	Texture = <tTX3>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
};



float4 mainps(VS_OUTPUT i, uniform bool bPS20=false, uniform bool bPS30=false) : COLOR0
{
	float4 alphacol = tex2D(texalpha, i.uv);

	float2 uv = i.uv;
	uv.x *= _decal_tile_param.x;
	uv.y *= _decal_tile_param.y;

	float4 base=tex2D(texbase, uv);
	float3 diffuseL = 0;
	float3 specularL = 0;

	lighting2l( bPS20, bPS30, diffuseL, specularL, i.pos, i.normal, base.a );

	if (_bBlendPass) {
		if (bPS30) if ( dot(diffuseL,1) < 0.01 && dot(specularL,1) < 0.01 ) discard;
	} else {
		diffuseL += tex2D(texlightmap, i.uv) + _vAmbientColor;
	}

	base.rgb = base.rgb * diffuseL + specularL;
	base.a = alphacol.a;

	if (_bBlendPass) base.rgb *= alphacol.a;

	return base;
};


//---- T0 ---- ps 3.0
technique T1
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
