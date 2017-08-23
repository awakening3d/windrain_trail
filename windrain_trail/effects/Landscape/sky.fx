
#include "..\include\atmosphere.fx"

//--- system variables, player feed value ----

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};


struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : TEXCOORD0;     // vertex diffuse color
	float3 Specular   : TEXCOORD1;     // vertex specular color
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0)
{
	VS_OUTPUT o;

	ATMO_VS_OUTPUT atmo=atmosphere(vPosition,_vecEye,matView,false);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;
    o.Pos = mul(float4(vPosition,1), matTotal);

	return o;
};



float4 mainps(VS_OUTPUT In) : COLOR 
{
	return float4(In.Specular,1);
};


technique T0
{
  pass P0
  {

    VertexShader = compile vs_2_0 mainvs();
    PixelShader  = compile ps_2_0 mainps();

	CullMode=None;
	//ZWriteEnable=False;

  } // of pass0
}
