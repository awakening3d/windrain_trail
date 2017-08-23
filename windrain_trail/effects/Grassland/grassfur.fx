
//--- system variables, player feed value ----
texture tTX0;
texture tTX1;
texture tTX2;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecLight={0.0f,0.0f,0.0f,1.0f};
vector _vecLightColor={1,1,1,1};


// --- user variables ---
vector vecShellDistance={1.0f,0.0f,0.0f,1.0f}; //shell distance
vector vecAmbient={.01f,.01f,.01f,1.0f}; //ambient
vector vecDiffuse={.08f,.08f,.08f,1.0f}; //diffuse
vector vecSpecular={.05f,.05f,.05f,1.0f}; //specular

//vector for uv transform
// x,y - uv scale; z,w - uv offset
// u = u * x + z; v = v * y + w
vector vecUV={1.0f,1.0f,0.0f,0.0f};
vector vecUV2={1.0f,1.0f,0.0f,0.0f};
vector vecUV3={1.0f,1.0f,0.0f,0.0f};




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

	// get shell distance
	mov r1, c7

	// offset shell in direction of normal
	mul r1.x, r1.x, c5.x		// c5.x - pass count
	mul r1.xyz, r1.xxx, v1.xyz
	add r0.xyz, r0.xyz, r1.xyz

	// output transformed vertex
	m4x4 oPos, r0, c0

	// output texture coordinates
	mov r1, c64 // vecUV
	mul r2.xy, r1.zw, c5.x // pass count
	mad oT0, v2.xy, r1.xy, r2.xy

	mov r1, c65 // vecUV2
	mad r2, v0.xz, r1.xy, r1.zw
	sub r2.y, c6.w, r2.y // v = 1 - v
	mov oT1, r2

	sub r2, v0, c6
	mov r1, c66 // vecUV3
	mad oT2, r2.xz, r1.xy, r1.zw

	mov oD0, c13

	};




technique T0
{

  pass P1
  {
  Texture[0]=<tTX1>;
  ColorOp[0] = SelectArg2;
  AlphaOp[0] = SelectArg1;
  MipFilter[0] = None;


  Texture[1]=<tTX0>;
  ColorOp[1] = SelectArg1;
  AlphaArg1[1] = Texture;
  AlphaArg2[1] = Current;
  AlphaOp[1] = Modulate2x;

  Texture[2]=<tTX2>;
  ColorOp[2] = Modulate; //SelectArg1;

    SrcBlend = SrcAlpha;
    DestBlend = One;
	AlphaBlendEnable = True;

	AlphaTestEnable=True;
	AlphaRef=0x08;
	AlphaFunc=GreaterEqual;

	ZWriteEnable=False;

	// vertex shader constant
	VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
	VertexShaderConstant[4] = <_vecLight>;
	VertexShaderConstant[5] = {0,0,0,0}; //pass
	VertexShaderConstant[6] = <_vecEye>; // eye
	VertexShaderConstant[7] = <vecShellDistance>; //shell distance
//	VertexShaderConstant[8] = <matWorld>;

	VertexShaderConstant[12] = <vecAmbient>; //ambient
	VertexShaderConstant[13] = <vecDiffuse>; //diffuse
	VertexShaderConstant[14] = <vecSpecular>; //specular
	VertexShaderConstant[15] = <_vecLightColor>; //light color

	VertexShaderConstant[64] = <vecUV>;
	VertexShaderConstant[65] = <vecUV2>;
	VertexShaderConstant[66] = <vecUV3>;

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
/*
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
*/
}




technique T1
{

  pass P1
  {
  ColorOp[0] = Disable;
    SrcBlend = Zero;
    DestBlend = One;
	AlphaBlendEnable = True;
  }
}
