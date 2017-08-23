#include "..\..\include\common.fx"
#include "..\..\include\shadow_common.fx"

//--- system variables, player feed value ----
texture tTX0;
texture tTX1;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix


vector __vFactor = {5, 10, 0, 1 }; // x: shell distance, y: uvscale, z: uv offset, w: color intensity
vector vecFactorScale = { 0.1, 0.1, 0.001, .1 }; // x: shell distance scale, y: uvscale scale, z: uvoffset scale, w: color scale


    // Definition of the vertex shader, declarations then assembly
    VertexShader vsfur =
    asm
    {
   	vs_1_1
 
	dcl_position v0
	dcl_normal	 v1
	dcl_texcoord v2

	// get model space vertex
	mov r0, v0

	mov r4, c16 // factor scale
	mul r7, r4, c7 // r7: scaled factor

	// offset shell in direction of normal
	mul r1.x, r7.x, c5.x		// c5.x - pass count
	mul r1.xyz, r1.xxx, v1.xyz
	add r0.xyz, r0.xyz, r1.xyz

	// output transformed vertex
	m4x4 oPos, r0, c0

	// output texture coordinates
	//mov r1, c64 // vecUV
	mul r2.xy, r7.zz, c5.x // pass count
	mad oT0, v2.xy, r7.yy, r2.xy
	mov oT1, v2


	//lighting

	// c4 - lpos, c8 - matWorldInv
	mov  r2, c4
	m4x3 r0, r2, c8 // light position to object space
	add  r0, r0, -v0		// L = lpos - vertex, L in object space

	// normalize vector in r0
	dp3  r0.w, r0, r0		// r0.w = |r0|^2
	rsq  r0.w, r0.w			// r0.w = 1/sqrt(r0.w) = 1/|r0|
	mul  r0.xyz, r0, r0.w	// r0 - normalized L vector

	// c12 - ambient, c13 - diffuse, c14 - specular , c15 - light color
	dp3 r1, r0, v1
	mul r1, r1, c15

	mul r2, c13, r7.w
	mul r3, c12, r7.w
	mad oD0, r1, r2, r3

	//specular
	// c6 eye
	mov  r2, c6
	m4x3 r1, r2, c8 // eye position to object space
	add  r1, r1, -v0	// VertexToEyeVector

	// normalize vector in r1
	dp3  r1.w, r1, r1		// r1.w = |r1|^2
	rsq  r1.w, r1.w			// r1.w = 1/sqrt(r1.w) = 1/|r1|
	mul  r1.xyz, r1, r1.w	// r1 - normalized E vector

	add  r0, r0, r1		// HalfVector

	// normalize vector in r0
	dp3  r0.w, r0, r0		// r0.w = |r0|^2
	rsq  r0.w, r0.w			// r0.w = 1/sqrt(r0.w) = 1/|r0|
	mul  r0.xyz, r0, r0.w	// r0 - normalized L vector

	dp3 r1, r0, v1

	mul r1.x, r1.x, r1.x
	mul r1.x, r1.x, r1.x
	mul r1.x, r1.x, r1.x

	mul r3, c14, r7.w
	mul oD1, r1.x, r3
	};




technique T0
{
  pass P0
  {
  Texture[0]=<tTX0>;
  }

  pass P1
  {
  Texture[0]=<tTX1>;
  ColorOp[0] = SelectArg2;
  AlphaOp[0] = SelectArg1;

  Texture[1]=<tTX0>;
  ColorOp[1] = Modulate;

    SrcBlend = SrcAlpha;
    DestBlend = One;
	AlphaBlendEnable = True;
//	CullMode=None;

	// vertex shader constant
	VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
	VertexShaderConstant[4] = <_vecLight>;
	VertexShaderConstant[5] = {0,0,0,0}; //pass
	VertexShaderConstant[6] = <_vecEye>; // eye
	VertexShaderConstant[7] = <__vFactor>; //shell distance, uv
	VertexShaderConstant[8] = <matWorldInv>;

	VertexShaderConstant[12] = <_vAmbientColor>; //ambient
	VertexShaderConstant[13] = <_vDiffuseColor>; //diffuse
	VertexShaderConstant[14] = <_vSpecularColor>; //specular
	VertexShaderConstant[15] = <_vecLightColor>; //light color
	VertexShaderConstant[16] = <vecFactorScale>; // factor scale

	VertexShader = <vsfur>;
  }

  pass P2
  {
	VertexShaderConstant[5] = {1,0,0,0}; //pass
  }

  pass P3
  {
	VertexShaderConstant[5] = {2,0,0,0}; //pass
  }

  pass P4
  {
	VertexShaderConstant[5] = {3,0,0,0}; //pass
  }

  pass P5
  {
	VertexShaderConstant[5] = {4,0,0,0}; //pass
  }

  pass P6
  {
	VertexShaderConstant[5] = {5,0,0,0}; //pass
  }

  pass P7
  {
	VertexShaderConstant[5] = {6,0,0,0}; //pass
  }

  pass P8
  {
	VertexShaderConstant[5] = {7,0,0,0}; //pass
  }

  pass P9
  {
	VertexShaderConstant[5] = {8,0,0,0}; //pass
  }

  pass P10
  {
	VertexShaderConstant[5] = {9,0,0,0}; //pass
  }

  pass P11
  {
	VertexShaderConstant[5] = {10,0,0,0}; //pass
  }

  pass P12
  {
	VertexShaderConstant[5] = {11,0,0,0}; //pass
  }

  pass P13
  {
	VertexShaderConstant[5] = {12,0,0,0}; //pass
  }

}
