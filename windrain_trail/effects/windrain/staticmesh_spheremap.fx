//--- system variables, player feed value ----
#include "..\include\common.fx"

//texture tTXn {n = 0..7}
texture tTX0;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix


//---- user variables ---
vector vecOffset={-0.03f, -0.03f, -0.03f, 1.0f};



struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float4 Diffuse    : COLOR0;
//   float4 Specular   : COLOR1;
};


VS_OUTPUT mainvs(float4 pos: POSITION, float4 vcolor: COLOR0, float3 n: NORMAL, float2 uv: TEXCOORD0, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT o;
  
	o.Pos = mul(pos, matTotal);
	o.Diffuse = vcolor;
	
	n =	mul(n,(float3x3)matWorld);
	n =	normalize( mul(n,(float3x3)matView) );

	o.uv = float2( n.x*0.5+0.5, n.y*-0.5+0.5);


	return o;
};




sampler texbase=sampler_state {
	Texture = <tTX0>;
};



float4 mainps(VS_OUTPUT i) : COLOR0
{
	float4 color = tex2D(texbase,i.uv);
	color.rgb *= i.Diffuse.rgb;
	return color;
};


//---- T0 ---- ps 2.0
technique T0
{
  pass P1
  {
     VertexShader = compile vs_2_0 mainvs();
     PixelShader  = compile ps_2_0 mainps();
  }
} //of technique T0


//----- T1 --- ps 1.4
technique T1
{
  pass P1
  {
     VertexShader = compile vs_1_1 mainvs();
     PixelShader  = compile ps_1_4 mainps();
  }
} //of technique T1


//--- T2 ---- no ps
technique T2
{
  pass P0
  {
  Texture[0] = <tTX0>;
  }
} //of technique T2