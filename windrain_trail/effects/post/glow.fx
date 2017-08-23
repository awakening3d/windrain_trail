
//--- system variables, player feed value ----
vector _vecViewport;		// {X,Y,Width,Height}


//---- user variables --------

vector vecBlurFactor =  {0.003f,0.0f,-0.003f,0.0f};
vector vecBlurFactor1 = {0.006f,0.0f,-0.006f,0.0f};
vector vecBlurFactor2 = {0.009f,0.0f,-0.009f,0.0f};
vector vecBlurFactor3 = {0.012f,0.0f,-0.012f,0.0f};
vector vecBlurFactor4 = {0.015f,0.0f,-0.015f,0.0f};
vector vecBlurFactor5 = {0.018f,0.0f,-0.018f,0.0f};
vector vecBlurFactor6 = {0.021f,0.0f,-0.021f,0.0f};
vector vecBlurFactor7 = {0.024f,0.0f,-0.024f,0.0f};


vector vecWeight =  {0.045f,0.045f,0.045f,0.5f};
vector vecWeight1 = {0.04f,0.04f,0.04f,0.5f};
vector vecWeight2 = {0.035f,0.035f,0.035f,0.5f};
vector vecWeight3 = {0.03f,0.03f,0.03f,0.5f};
vector vecWeight4 = {0.025f,0.025f,0.025f,0.5f};
vector vecWeight5 = {0.02f,0.02f,0.02f,0.5f};
vector vecWeight6 = {0.015f,0.015f,0.015f,0.5f};
vector vecWeight7 = {0.01f,0.01f,0.01f,0.5f};

vector vecThreshold={0.299f,0.587f,0.114f, 0.8f }; //the last number {0.8} is the threshold value, you can change it within [0..1]


    VertexShader vsdiffuse=
        
    asm
    {
   	vs_1_1
 
	dcl_position v0.xyzw
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

	add  oT0.xy, v7.xy, c4.zz
	add  oT1.xy, v7.xy, c4.zx
	add  oT2.xy, v7.xy, c4.xx
	add  oT3.xy, v7.xy, c4.xz
	mov  oT4.xy, v7.xy
	
	
	};





    VertexShader vsdiffuse2=
    
    asm
    {
   	vs_1_1
 
	dcl_position v0.xyzw
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

	add  oT0.xy, v7.xy, -c4.xy
	add  oT1.xy, v7.xy, c4.xy
	add  oT2.xy, v7.xy, -c4.yx
	add  oT3.xy, v7.xy, c4.yx
	mov  oT4.xy, v7.xy
	
	
	};



	PixelShader ps14=
	asm
	{
	ps.1.4
	texld  r0, t0
	texld  r1, t1

	//--- 0 pixel
	sub r0.a, r0.r, c0.a
	cmp r5, r0.a, c1, c2

	mul r0, r0, r5	

	//--- 1 pixel
	sub r0.a, r1.r, c0.a
	cmp r5, r0.a, c1, c2
	
	mad r0, r1, r5, r0

	mov r0.a, c1.a

	phase

	//--- 2 pixel
	texld  r2, t2
	texld  r3, t3
	texld  r4, t4

	sub r0.a, r2.r, c0.a
	cmp r5, r0.a, c1, c2

	mad r0, r2, r5, r0

	//--- 3 pixel
	sub r0.a, r3.r, c0.a
	cmp r5, r0.a, c1, c2

	mad r0, r3, r5, r0

	//mov r0.a, c1.a
	//add r0, r0, r4

	};


technique T0
{
  pass P0
  {
  ColorOp[0] = SelectArg1;
  ColorOp[1] = Disable;
  }

  pass P1
  {

	AddressU[0] = Clamp; AddressV[0] = Clamp;
	AddressU[1] = Clamp; AddressV[1] = Clamp;
	AddressU[2] = Clamp; AddressV[2] = Clamp;
	AddressU[3] = Clamp; AddressV[3] = Clamp;
	
	// vertex shader constant
	VertexShaderConstant[0] = { 0.0f, 0.5f, 1.0f, 2.0f };
	VertexShaderConstant[1] = <_vecViewport>;
	VertexShaderConstant[4] = <vecBlurFactor>;

	VertexShader = <vsdiffuse>;

	// pixel shader
	PixelShaderConstant[0] = <vecThreshold>;
	PixelShaderConstant[1] = <vecWeight>;
	PixelShaderConstant[2] = {0.0f,0.0f,0.0f,0.0f};
	PixelShaderConstant[3] = {1.0f,1.0f,1.0f,0.0f};
	PixelShader = <ps14>;


	AlphaBlendEnable=True;
	SrcBlend=One;
	DestBlend=One;
  }


  pass P2
  {
	VertexShader = <vsdiffuse2>;
	VertexShaderConstant[4] = <vecBlurFactor1>;
	PixelShaderConstant[1] = <vecWeight1>;
  }

  pass P3
  {
	VertexShader = <vsdiffuse>;
	VertexShaderConstant[4] = <vecBlurFactor2>;
	PixelShaderConstant[1] = <vecWeight2>;
  }

  pass P4
  {
	VertexShader = <vsdiffuse2>;
	VertexShaderConstant[4] = <vecBlurFactor3>;
	PixelShaderConstant[1] = <vecWeight3>;
  }

  pass P5
  {
	VertexShader = <vsdiffuse>;
	VertexShaderConstant[4] = <vecBlurFactor4>;
	PixelShaderConstant[1] = <vecWeight4>;
  }

  pass P6
  {
	VertexShader = <vsdiffuse2>;
	VertexShaderConstant[4] = <vecBlurFactor5>;
	PixelShaderConstant[1] = <vecWeight5>;
  }

  pass P7
  {
	VertexShader = <vsdiffuse>;
	VertexShaderConstant[4] = <vecBlurFactor6>;
	PixelShaderConstant[1] = <vecWeight6>;
  }

  pass P8
  {
	VertexShader = <vsdiffuse2>;
	VertexShaderConstant[4] = <vecBlurFactor7>;
	PixelShaderConstant[1] = <vecWeight7>;
  }


}
