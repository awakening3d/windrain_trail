//--- system variables, player feed value ----
vector _vecViewport;		// {X,Y,Width,Height}


//---- user variables --------

vector vecBlurFactor = {0.001f,0.0f,0.0f,0.0f};
vector vecBlurFactor1 = {0.002f,0.0f,0.0f,0.0f};



    VertexShader vsdiffuse=
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
	add  oT1.xy, v7, c4.xy
	add  oT2.xy, v7, -c4.yx
	add  oT3.xy, v7, c4.yx
	};




	PixelShader psdiffuse=
	asm
	{
	ps.1.0

	tex t0
	tex t1
	tex t2
	tex t3
	mul r0, t0, c0 
	mad r0, t1, c0, r0
	mad r0, t2, c0, r0
	mad r0, t3, c0, r0
	mov r0.a, c0.a
	};



technique T0
{

  pass P0
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
	PixelShaderConstant[0] = {0.25f,0.25f,0.25f,0.5f};
	PixelShader = <psdiffuse>;

  }

  pass P1
  {
	VertexShaderConstant[4] = <vecBlurFactor1>;

	AlphaBlendEnable=True;
	SrcBlend=SrcAlpha;
	DestBlend=InvSrcAlpha;
  }
 
}