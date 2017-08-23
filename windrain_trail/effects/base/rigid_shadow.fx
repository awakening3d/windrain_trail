//--- system variables, player feed value ----
#include "..\include\common.fx"
#include "..\include\shadow_common.fx"


//texture tTXn {n = 0..7}
texture tTX0;

bool _bInstancing = false; //instancing

bool _bBlendPass = false;

matrix matTotal; //matWorld*matView*matProj;
matrix matWorld; //World Matrix
matrix matViewProj; //matView*matProj


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float3 pos : TEXCOORD1; // vertex position in world space
   float3 normal : TEXCOORD2; // vertex normal in world space
};



VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0,
                         float4 vInstanceMatrix1 : TEXCOORD1,
                         float4 vInstanceMatrix2 : TEXCOORD2,
                         float4 vInstanceMatrix3 : TEXCOORD3 )

{
	VS_OUTPUT o;
  
	if (_bInstancing) {
		// We've encoded the 4x3 world matrix in a 3x4, so do a quick transpose so we can use it in DX
		float4 row1 = float4(vInstanceMatrix1.x,vInstanceMatrix2.x,vInstanceMatrix3.x,0);
		float4 row2 = float4(vInstanceMatrix1.y,vInstanceMatrix2.y,vInstanceMatrix3.y,0);
		float4 row3 = float4(vInstanceMatrix1.z,vInstanceMatrix2.z,vInstanceMatrix3.z,0);
		float4 row4 = float4(vInstanceMatrix1.w,vInstanceMatrix2.w,vInstanceMatrix3.w,1);
		matWorld = float4x4(row1,row2,row3,row4);

		o.pos = mul(pos, matWorld); //vertex pos in world space
		o.Pos = mul( float4(o.pos,1), matViewProj);
	} else {
		o.pos = mul(pos, matWorld); //vertex pos in world space
		o.Pos = mul(pos, matTotal);
	}


	o.uv.xy = uv;
	o.normal = normalize( mul(n,(float3x3)matWorld) );

	return o;
};


sampler texbase=sampler_state {
	Texture = <tTX0>;
	MipFilter = Linear;
};








float4 mainps(VS_OUTPUT i, uniform bool bPS20=false, uniform bool bPS30=false) : COLOR0
{
	float4 base = tex2D(texbase,i.uv);

	float3 diffuseL=0;
	float3 specularL=0;

	lighting2l( bPS20, bPS30, diffuseL, specularL, i.pos, i.normal, base.a );


	if (_bBlendPass) {
		if (bPS30) if ( dot(diffuseL,1) < 0.01 && dot(specularL,1) < 0.01 ) discard;
	} else {
		diffuseL += _vAmbientColor;
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


