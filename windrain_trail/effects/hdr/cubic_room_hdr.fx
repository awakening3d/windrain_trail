#include "..\include\hdrformats.fx"

int gMode=0;  // 0: F16, 1: RGB16, 2: RGBE8

sampler cubemap;


matrix matTotal; //matWorld*matView*matProj;

   
   // Definition of the vertex shader, declarations then assembly
   VertexShader vsdiffuse =
   asm
   {
   vs_1_1
   
	dcl_position	v0
	dcl_normal		v1
	dcl_texcoord	v2


   // c0-c3 contains composite transform matrix
   m4x4 oPos, v0, c0   // transform vertices by view/projection matrix
   //m3x3 r0, v1, c4
   mov oT0, v1
   };



float4 psmain(in float3 vTex : TEXCOORD0 ) : COLOR
{
   float4 vSample=texCUBE(cubemap, vTex);

	if (1==gMode)
		vSample.rgb=DecodeRGB16(vSample);
	else if (2==gMode)
		vSample.rgb=DecodeRGBE8(vSample);

   return vSample;
}



technique T0
{
   pass P0
   {
   // stage0
   ColorOp[0] = SelectArg1;
   ColorArg1[0] = Texture;
   // stage1
   ColorOp[1] = Disable;

   MipFilter[0]=None;
   CullMode=None;

   VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
   VertexShader = <vsdiffuse>;

   PixelShader  = compile ps_2_0 psmain(); 

   }
}