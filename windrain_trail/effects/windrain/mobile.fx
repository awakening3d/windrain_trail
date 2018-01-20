#include "..\include\atmosphere.fx"


matrix matProjInv; //Inverse Projection Matrix
matrix matViewInv; //Inverse View Matrix
matrix matWorldInv; //Inverse World Matrix

matrix matWorld; //World Matrix
matrix matWorldView; //matWorld*matView


matrix matTotal; //matWorld*matView*matProj;

matrix matView;
matrix matProj;


vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)

vector _vecLight; // position of light0
vector _vecLightColor; // color of light0

vector _vecLight1; // position of light1
vector _vecLightColor1; // color of light1


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;

   float3 Diffuse    : COLOR0;
   float3 Specular   : COLOR1;
};


VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT o;
  
	float3 posWorld=mul(pos,matWorld);

	ATMO_VS_OUTPUT atmo=atmosphere( posWorld.xyz, _vecEye, matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;

	o.Pos = mul(pos, matTotal);
	o.uv = uv;

	return o;
};



technique T0
{
  pass P0
  {
  VertexShader = compile vs_1_1 mainvs();

  // stage0
  //ColorOp[0] = SelectArg1;
  //ColorArg1[0] = Diffuse;
  //ColorArg1[0] = Texture;

  // stage1
  ColorOp[1] = Disable;

  SpecularEnable=True;
  }
}