//--- system variables, player feed value ----

//texture tTXn (n = 0..7)
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
vector _vecLightParam = { 1000000.0f, 0.0f, 0.0f, 0.0f }; //light parameters ( range*range, reserved, reserved, reserved )



     // Definition of the vertex shader, declarations then assembly
    VertexShader vsdiffuse =
    asm
    {
	vs_1_1
	
	dcl_position v0
	dcl_color	 v1
	dcl_texcoord v2
	dcl_normal v7	
	dcl_tangent v8
	dcl_binormal v9

	// c0-c3 contains composite transform matrix
	m4x4 oPos, v0, c0   // transform vertices by view/projection matrix
	mov oD1, v1

	// v2 texture coordination
	mov  oT0.xy, v2
	mov  oT1.xy, v2

	// c4 lpos
	add  r0, c4, -v0		// L = lpos - vertex, L in object space


	//distance of light to vertex
	dp3 r1.x, r0, r0
	slt r9, r1.x, c7.x // r9 = distance < range ? 1 : 0


	// v8 Tangent,  x
	// v9 Binormal, y
	// v7 normal,   z

	// matrix for object space to surface space
	// ( Tan.x  Tan.y  Tan.z ) = ( v3.x v3.y v3.z )   ( L.x )
	// ( Bin.x  Bin.y  Bin.z ) = ( v4.x v4.y v4.z ) * ( L.y )
	// ( nor.x  nor.y  nor.z ) = ( v1.x v1.y v1.z )   ( L.z )

	dp3  r1.y, v8, r0
	dp3  r1.x, v9, -r0
	dp3  r1.z, v7, r0


	// r1 L vector in texture space

	// normalize vector in r1
	dp3  r1.w, r1, r1		// r1.w = |r1|^2
	rsq  r1.w, r1.w			// r1.w = 1/sqrt(r0.w) = 1/|r1|
	mul  r1.xyz, r1, r1.w	// r1 - normalized L vector in texture space

	mul r1, r1, r9 //range limit

	// <-1, 1>  to  <0,1>
	// c5  0.5, 0.5, 0.5, 0.5
	mad  oD0, r1, c5, c5
	};


     // Definition of the vertex shader, declarations then assembly
    VertexShader vsvcolor =
    asm
    {
	vs_1_1
	
	dcl_position v0
	dcl_color	 v1
	dcl_texcoord v2

	// c0-c3 contains composite transform matrix
	m4x4 oPos, v0, c0   // transform vertices by view/projection matrix
	mov oD1, v1
	};


technique T1
{
  pass P1 //diffuse x texture
  {
  // stage0
  ColorOp[0] = DotProduct3;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Diffuse;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;
  Texture[1] = <tTX1>;

  // stage2
  ColorOp[2] = Disable;

	// vertex shader
	VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
	VertexShaderConstant[4] = <_vecLight>;
	VertexShaderConstant[5] = {0.5f,0.5f,0.5f,0.5f};
	VertexShaderConstant[7] = <_vecLightParam>;

	VertexShader = <vsdiffuse>;

  } // of pass1

  pass P2 // x vertex color
  {
  // stage 0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Specular;

  // stage1
  ColorOp[1] = Disable;

  // alpha blend
  SrcBlend = DestColor;
  DestBlend = SrcColor;
  AlphaBlendEnable = True;
  ZWriteEnable = False;

	// vertex shader
	VertexShader = <vsvcolor>;

  } // of pass2

} //of technique T1