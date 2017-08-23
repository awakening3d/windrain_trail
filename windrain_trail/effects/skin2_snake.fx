//--- system variables, player feed value ----

//texture tTXn (n = 0..7)
texture tTX1;
matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldView; //matWorld*matView
matrix matViewProj; //matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecLight={0.0f,0.0f,0.0f,1.0f};
dword _dwLightColor=0xffffffff;



    VertexShader vsspecular =
    
    asm
    {
	vs_1_1
	
	dcl_position v0
	dcl_blendweight v1
	dcl_blendindices v2
	dcl_normal v3
	dcl_texcoord v4
	dcl_tangent v8
	dcl_binormal v9

	/*
	;------------------------------------------------------------------------------
	; v0 = position
	; v1 = blend weights
	; v2 = blend indices
	; v3 = normal
	; v4 = texture coordinates
	; v8 = tangent
	; v9 = binormal
	;------------------------------------------------------------------------------

	;------------------------------------------------------------------------------
	; r0.w = Last blend weight
	; r1 = Blend indices
	; r2 = Temp position
	; r3 = Temp normal
	; r4 = Blended position in world space
	; r5 = Blended normal in world space
	; r6 = Blended tangent in world space
	; r7 = Blended binormal in world space
	; r8 = light dir, L in world space
	;------------------------------------------------------------------------------

	;------------------------------------------------------------------------------
	; Constants specified by the app;
	;
	; c9-c95 = world-view matrix palette
	; c8	  = diffuse * light.diffuse
	; c7	  = ambient color
	; c2-c5   = view-projection matrix
	; c1	  = light direction
	; c0	  = {1, power, 0, 765.01}; // vConst.w should be 3, but due to about hack, mul by 255 and add epsilon

	;------------------------------------------------------------------------------

	;------------------------------------------------------------------------------
	; oPos	  = Output position
	; oD0	  = Diffuse
	; oD1	  = Specular
	; oT0	  = texture coordinates
	;------------------------------------------------------------------------------
	*/

	mul r1, v2, c0.w

	//first compute the last blending weight
	dp3 r0.w,v1.xyz,c0.xxz; 
	add r0.w,-r0.w,c0.x

	//Set 1
	mov a0.x,r1.x
	m4x3 r4,v0,c[a0.x + 9] // v0 position
	m3x3 r5,v3,c[a0.x + 9] // v3 normal
	m3x3 r6, v8, c[a0.x + 9] // v8 tangent
	m3x3 r7, v9, c[a0.x + 9] // v9 binormal

	mov r2.w, c0.x
	mov r3.w, c0.x
	mov r4.w, c0.x
	mov r5.w, c0.x
	mov r6.w, c0.x
	mov r7.w, c0.x


	//blend them
	mul r4,r4,v1.xxxx
	mul r5,r5,v1.xxxx
	mul r6,r6,v1.xxxx
	mul r7,r7,v1.xxxx

	//Set 2
	mov a0.x,r1.y
	m4x3 r2,v0,c[a0.x + 9];
	m3x3 r3,v3,c[a0.x + 9];

	//add them in
	mad r4,r2,v1.yyyy,r4;
	mad r5,r3,v1.yyyy,r5;

	//for s and t
	m3x3 r2, v8, c[a0.x + 9];
	m3x3 r3, v9, c[a0.x + 9];
	mad r6,r2,v1.yyyy,r6;
	mad r7,r3,v1.yyyy,r7;

	//Set 3
	mov a0.x,r1.z
	m4x3 r2,v0,c[a0.x + 9];
	m3x3 r3,v3,c[a0.x + 9];

	//add them in
	mad r4,r2,r0.wwww,r4;
	mad r5,r3,r0.wwww,r5;

	//for s and t
	m3x3 r2, v8, c[a0.x + 9];
	m3x3 r3, v9, c[a0.x + 9];
	mad r6,r2,r0.wwww,r6;
	mad r7,r3,r0.wwww,r7;


	//compute position
	mov r4.w,c0.x
	m4x4 oPos,r4,c2

	// normalize normals
	dp3 r5.w, r5, r5
	rsq r5.w, r5.w
	mul r5, r5, r5.w

	// normalize tangent
	dp3 r6.w, r6, r6
	rsq r6.w, r6.w
	mul r6, r6, r6.w

	// normalize binormal
	dp3 r7.w, r7, r7
	rsq r7.w, r7.w
	mul r7, r7, r7.w


	// Copy texture coordinate
	mov oT0, v4
	mov oT1, v4

	// c1 lpos
	add  r8, -r4, c1		// L = lpos - vertex, L in world space
	// c7 eye
	add  r9, -r4, c7	// VertexToEyeVector, E in world space

	// normalize L
	dp3 r8.w, r8, r8
	rsq r8.w, r8.w
	mul r8, r8, r8.w

	// normalize E
	dp3 r9.w, r9, r9
	rsq r9.w, r9.w
	mul r9, r9, r9.w
	// half vector
	add  r8, r8, r9 // H in world space

	// trans H from world space to texture space
	dp3  r9.y, r6, r8
	dp3  r9.x, r7, r8
	dp3  r9.z, r5, r8
	// r9 H vector in texture space

	// normalize vector in r9
	dp3  r9.w, r9, r9
	rsq  r9.w, r9.w
	mul  r9.xyz, r9, r9.w

	// <-1, 1>  to  <0,1>
	// c6  0.5, 0.5, 0.5, 0.5
	mad  oD0, r9, c6, c6
	};





    VertexShader vsdiffuse =
    /*
    decl
    {
	stream 0;
	float v0[3];       // Position
	float v1[2];			// weight
	//ubyte v2[4];		// blend indices
	d3dcolor v2; // Use COLOR instead of UBYTE4 since Geforce3 does not support it

	float v3[3];		// normal
	float v4[2];       // Texture Coord0
	stream 1;
	float v8[3];	//s - tangent
	float v9[3];	//t - binormal
    }
    */
    asm
    {
	vs_1_1

	dcl_position v0
	dcl_blendweight v1
	dcl_blendindices v2
	dcl_normal v3
	dcl_texcoord v4
	dcl_tangent v8
	dcl_binormal v9

	/*
	;------------------------------------------------------------------------------
	; v0 = position
	; v1 = blend weights
	; v2 = blend indices
	; v3 = normal
	; v4 = texture coordinates
	; v8 = tangent
	; v9 = binormal
	;------------------------------------------------------------------------------

	;------------------------------------------------------------------------------
	; r0.w = Last blend weight
	; r1 = Blend indices
	; r2 = Temp position
	; r3 = Temp normal
	; r4 = Blended position in world space
	; r5 = Blended normal in world space
	; r6 = Blended tangent in world space
	; r7 = Blended binormal in world space
	; r8 = light dir, L in world space
	;------------------------------------------------------------------------------

	;------------------------------------------------------------------------------
	; Constants specified by the app;
	;
	; c9-c95 = world-view matrix palette
	; c8	  = diffuse * light.diffuse
	; c7	  = ambient color
	; c2-c5   = view-projection matrix
	; c1	  = light direction
	; c0	  = {1, power, 0, 765.01}; // vConst.w should be 3, but due to about hack, mul by 255 and add epsilon

	;------------------------------------------------------------------------------

	;------------------------------------------------------------------------------
	; oPos	  = Output position
	; oD0	  = Diffuse
	; oD1	  = Specular
	; oT0	  = texture coordinates
	;------------------------------------------------------------------------------
	*/

	mul r1, v2, c0.w

	//first compute the last blending weight
	dp3 r0.w,v1.xyz,c0.xxz; 
	add r0.w,-r0.w,c0.x

	//Set 1
	mov a0.x,r1.x
	m4x3 r4,v0,c[a0.x + 9] // v0 position
	m3x3 r5,v3,c[a0.x + 9] // v3 normal
	m3x3 r6, v8, c[a0.x + 9] // v8 tangent
	m3x3 r7, v9, c[a0.x + 9] // v9 binormal

	mov r2.w, c0.x
	mov r3.w, c0.x
	mov r4.w, c0.x
	mov r5.w, c0.x
	mov r6.w, c0.x
	mov r7.w, c0.x

	//blend them
	mul r4,r4,v1.xxxx
	mul r5,r5,v1.xxxx
	mul r6,r6,v1.xxxx
	mul r7,r7,v1.xxxx

	//Set 2
	mov a0.x,r1.y
	m4x3 r2,v0,c[a0.x + 9];
	m3x3 r3,v3,c[a0.x + 9];

	//add them in
	mad r4,r2,v1.yyyy,r4;
	mad r5,r3,v1.yyyy,r5;

	//for s and t
	m3x3 r2, v8, c[a0.x + 9];
	m3x3 r3, v9, c[a0.x + 9];
	mad r6,r2,v1.yyyy,r6;
	mad r7,r3,v1.yyyy,r7;

	//Set 3
	mov a0.x,r1.z
	m4x3 r2,v0,c[a0.x + 9];
	m3x3 r3,v3,c[a0.x + 9];

	//add them in
	mad r4,r2,r0.wwww,r4;
	mad r5,r3,r0.wwww,r5;

	//for s and t
	m3x3 r2, v8, c[a0.x + 9];
	m3x3 r3, v9, c[a0.x + 9];
	mad r6,r2,r0.wwww,r6;
	mad r7,r3,r0.wwww,r7;


	//compute position
	mov r4.w,c0.x
	m4x4 oPos,r4,c2

	// normalize normals
	dp3 r5.w, r5, r5
	rsq r5.w, r5.w
	mul r5, r5, r5.w

	// normalize tangent
	dp3 r6.w, r6, r6
	rsq r6.w, r6.w
	mul r6, r6, r6.w

	// normalize binormal
	dp3 r7.w, r7, r7
	rsq r7.w, r7.w
	mul r7, r7, r7.w

	// Copy texture coordinate
	mov oT0, v4
	mov oT1, v4

	// c1 lpos
	add  r8, -r4, c1		// L = lpos - vertex, L in world space

	// trans L from world space to texture space
	dp3  r9.y, r6, r8
	dp3  r9.x, r7, r8
	dp3  r9.z, r5, r8

	// r9 L vector in texture space

	// normalize vector in r9
	dp3  r9.w, r9, r9
	rsq  r9.w, r9.w
	mul  r9.xyz, r9, r9.w

	// <-1, 1>  to  <0,1>
	// c6  0.5, 0.5, 0.5, 0.5
	mad  oD0, r9, c6, c6
	};







technique T0
{

  pass P1 // specular
  {
  TextureFactor = <_dwLightColor>;

  // stage0
  ColorOp[0] = DotProduct3;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Current;
  ColorArg2[1] = Current;
  
  // stage2
  ColorOp[2] = Modulate;
  ColorArg1[2] = Current;
  ColorArg2[2] = Current;

  // stage 3
  ColorOp[3] = Modulate;
  ColorArg1[3] = TFactor;
  ColorArg2[3] = Current;

  // stage4
  ColorOp[4] = Disable;

	// vertex shader constant
	VertexShaderConstant[0] = { 1.0f, 4.0f, 0.0f, 3.0f };
	VertexShaderConstant[1] = <_vecLight>;
	VertexShaderConstant[2] = <matViewProj>;
	VertexShaderConstant[6] = {0.5f,0.5f,0.5f,0.5f};
	VertexShaderConstant[7] = <_vecEye>;


	VertexShader = <vsspecular>;

  } // of pass1


  pass P2 //diffuse x texture
  {
  TextureFactor = <_dwLightColor>;

  // stage0
  ColorOp[0] = DotProduct3;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Current;
  AlphaOp[0] = Disable;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;
  AlphaOp[1] = SelectArg1;
  MipFilter[1]=Point;


  Texture[1] = <tTX1>;

  // stage 2
  ColorOp[2] = Modulate;
  ColorArg1[2] = TFactor;
  ColorArg2[2] = Current;

  // stage3
  ColorOp[3] = Disable;


  // alpha blend
  SrcBlend = One;
  DestBlend = SrcAlpha;
  AlphaBlendEnable = True;
  ZWriteEnable = False;

	// vertex shader
	VertexShaderConstant[0] = { 1.0f, 4.0f, 0.0f, 3.0f };
	VertexShaderConstant[1] = <_vecLight>;
	VertexShaderConstant[2] = <matViewProj>;
	VertexShaderConstant[6] = {0.5f,0.5f,0.5f,0.5f};

	VertexShader = <vsdiffuse>;

  } // of pass2

} //of technique T0



//---- T1 -------

technique T1
{

  pass P1 // specular
  {
  TextureFactor = <_dwLightColor>;

  // stage0
  ColorOp[0] = DotProduct3;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Current;
  ColorArg2[1] = Current;

  // stage2
  ColorOp[2] = Disable;

	// vertex shader constant
	VertexShaderConstant[0] = { 1.0f, 4.0f, 0.0f, 3.0f };
	VertexShaderConstant[1] = <_vecLight>;
	VertexShaderConstant[2] = <matViewProj>;
	VertexShaderConstant[6] = {0.5f,0.5f,0.5f,0.5f};
	VertexShaderConstant[7] = <_vecEye>;


	VertexShader = <vsspecular>;

  } // of pass1


  pass P2
  {
  // stage0
  ColorOp[0] = Disable;
  // alpha blend
  SrcBlend = Zero;
  DestBlend = DestColor;
  AlphaBlendEnable = True;
  ZWriteEnable = False;
  } // of pass2

  pass P3
  {
  // stage0
  ColorArg1[0] = TFactor;
  ColorOp[0] = SelectArg1;
  // stage1
  ColorOp[1] = Disable;
  // alpha blend
  SrcBlend = Zero;
  DestBlend = SrcColor;
  AlphaBlendEnable = True;
  ZWriteEnable = False;
  } // of pass2

  pass P4 //diffuse x texture
  {
  TextureFactor = <_dwLightColor>;

  // stage0
  ColorArg1[0] = Texture;
  ColorOp[0] = DotProduct3;
  AlphaOp[0] = Disable;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;
  AlphaOp[1] = SelectArg1;
  MipFilter[1]=Point;


  Texture[1] = <tTX1>;

  // stage 2
  ColorOp[2] = Disable;


  // alpha blend
  SrcBlend = One;
  DestBlend = SrcAlpha;
  AlphaBlendEnable = True;
  ZWriteEnable = False;

	// vertex shader
	VertexShaderConstant[0] = { 1.0f, 4.0f, 0.0f, 3.0f };
	VertexShaderConstant[1] = <_vecLight>;
	VertexShaderConstant[2] = <matViewProj>;
	VertexShaderConstant[6] = {0.5f,0.5f,0.5f,0.5f};

	VertexShader = <vsdiffuse>;

  } // of pass4

} //of technique T1
