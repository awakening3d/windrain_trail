//blur

//--- system variables, player feed value ----
vector _vecViewport;		// {X,Y,Width,Height}


//---- user variables --------

vector vecBlurFactor = {0.001f,0.0f,0.0f,0.0f};
vector vecBlurFactor1 = {-0.001f,0.0f,0.0f,0.0f};
vector vecBlurFactor2 = {0.0f,0.001f,0.0f,0.0f};
vector vecBlurFactor3 = {0.0f,-0.001f,0.0f,0.0f};

    VertexShader vsdiffuse=
    
    //decl
    //{
	//stream 0;
	//FVF XYZW | DIFFUSE | TEX4;
//	float v0[4];       // Position
//	d3dcolor v5;		//Diffuse
//	float v7[2];		// uv0
//	float v8[2];        // uv1
//	float v9[2];        // uv2
//	float v10[2];       // uv3
    //}
  
    asm
    {
   	vs_1_1

	dcl_position v0
	dcl_color	 v5
	dcl_texcoord v7
	dcl_texcoord1 v8
	dcl_texcoord2 v9
	dcl_texcoord3 v10

	add  r2.xy, v0.xy, c0.y // xy = xy + 0.5

	rcp  r0.x, c1.z
	rcp  r0.y, c1.w
	mul  r1.xy, r0.xy, r2.xy // x/=width y/=height

//	mad  r1.xy, c0.w, -c0.z
	mul r1.xy, r1.xy, c0.w		// xy = xy * 2 -1, map [0,1] to [-1,1]
	add r1.xy, r1.xy, -c0.z

	mov r1.y, -r1.y

	mov  r1.zw, v0.zw
	mov  oPos, r1
	
	add  oT0.xy, v7, -c4.xy
//	add  oT1.xy, v7, c4.xy
//	add  oT2.xy, v7, -c4.yx
//	add  oT3.xy, v7, c4.yx
	
	};



technique T0
{

  pass P0
  {
	AddressU[0] = Clamp; AddressV[0] = Clamp;

	// vertex shader constant
	VertexShaderConstant[0] = { 0.0f, 0.5f, 1.0f, 2.0f };
	VertexShaderConstant[1] = <_vecViewport>;
	VertexShaderConstant[4] = <vecBlurFactor>;

	VertexShader = <vsdiffuse>;

	TextureFactor=0x40404040;

	//stage0
	ColorOp[0]=SelectArg1;
	ColorArg1[0]=Texture;
	//stage1
	ColorOp[1]=Disable;
  }

  pass P1
  {
	VertexShaderConstant[4] = <vecBlurFactor1>;

	AlphaOp[0] = SelectArg1;
	AlphaArg1[0] = TFactor;

	AlphaBlendEnable=True;
	SrcBlend=SrcAlpha;
	DestBlend=InvSrcAlpha;

  }

  pass P2
  {
	VertexShaderConstant[4] = <vecBlurFactor2>;
  }

  pass P3
  {
	VertexShaderConstant[4] = <vecBlurFactor3>;
  }

}


