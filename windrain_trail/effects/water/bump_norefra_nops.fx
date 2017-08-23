//no refration water

matrix matWorld; //World Matrix
matrix matView; //View Matrix
matrix matProj; //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv; //Inverse View Matrix

vector _vDiffuseColor={1.0f,1.0f,1.0f,1.0f};


texture tTX0;
texture tTX1;

vector commonConst = { 0.0f,  0.5f, 1.0f, 2.0f };

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecLight={0.0f,0.0f,0.0f,1.0f};

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};

vector _vecAppTime={0.0f,0.0f,0.0f,0.0f};


vector vecWaterNormal={0.0f,1.0f,0.0f,1.0f};
vector __vFactor = {0.1f, 0.0f, 0.0f, 0.0f}; // x: wave speed


     // Definition of the vertex shader, declarations then assembly
    VertexShader vsdiffuse =
    asm
    {
		vs_1_1
		dcl_position v0
		dcl_texcoord v1
         
         m4x4 r0, v0, c4
		 mov oPos,r0


		add r0.x, r0.w, r0.x // r0.x = (pos.w + pos.x) * 0.5
		mul r0.x, r0.x, c0.y

		add r0.y, r0.w, r0.y // r0.y = (pos.w + pos.y ) * 0.5
		mul r0.y, r0.y, c0.y

		 max r1.x, c8.x, c8.y //max of backbuf width and height
		 
		 rcp r1.y, r1.x

		 mul r2.x, c8.x, r1.y // width / max
		 mul r2.y, c8.y, r1.y // height / max

		 mul r0.xy, r0.xy, r2.xy
		
		 mov oT1, r0
		 //mov oT3, r0

		 mov r0, v1
		 mov r1, c1
		 mad r0, c9.x, r1.x, r0 //offset uv by wavespeed * timed
		 
		 mov oT0, r0
		 //mov oT2, r0

		 //mov oD0, c1.zzzz
		 mov r1, -c14 //c14 - view dir
		 //dp3 oD0, c2, r1 // c2 - water surface normal
		 mov r0, c10
		 dp3 r2.a, c2, r1
		 sub r0.a, r2.a, r0.a
		 mov oD0, r0

	};




technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = BumpEnvMap;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Current;
  Texture[0] = <tTX0>;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Texture;
  Texture[1] = <tTX1>;
  TextureTransformFlags[1] = Count3|Projected;
  AddressU[1] = Clamp;
  AddressV[1] = Clamp;
  MipFilter[1]=Point;

  AlphaOp[1] = SelectArg1;
  AlphaArg1[1] = Diffuse;

  // stage2
  ColorOp[2] = Disable;

  VertexShaderConstant[0] = <commonConst>;
  VertexShaderConstant[1] = <__vFactor>;
  VertexShaderConstant[2] = <vecWaterNormal>;
  VertexShaderConstant[4] = <matTotal>;   // World*View*Proj Matrix

  VertexShaderConstant[8] = <_vecBackBufDesc>;
  VertexShaderConstant[9] = <_vecAppTime>;
  VertexShaderConstant[10] = <_vDiffuseColor>;

  VertexShaderConstant[12] = <matView>;   // View Matrix
 

  VertexShader = <vsdiffuse>;

  //alphablend
	AlphaBlendEnable=true;
	SrcBlend = InvSrcAlpha;
	DestBlend = SrcAlpha;
	
  }
}



//--- T1 ---


    VertexShader vsdiffuse1 =
    asm
    {
		vs_1_1
		dcl_position v0
		dcl_texcoord v1
         
         m4x4 r0, v0, c4
		 mov oPos,r0


		add r0.x, r0.w, r0.x // r0.x = (pos.w + pos.x) * 0.5
		mul r0.x, r0.x, c0.y

		add r0.y, r0.w, r0.y // r0.y = (pos.w + pos.y ) * 0.5
		mul r0.y, r0.y, c0.y

		 max r1.x, c8.x, c8.y //max of backbuf width and height
		 
		 rcp r1.y, r1.x

		 mul r2.x, c8.x, r1.y // width / max
		 mul r2.y, c8.y, r1.y // height / max

		 mul r0.xy, r0.xy, r2.xy
		
		 mov oT0, r0
		 //mov oT1, r0

		 //mov r0, v1
		// mov r1, c1
		 //mad r0, c9.x, r1.x, r0 //offset uv by wavespeed * timed
		 
		 //mov oT0, r0
		// mov oT2, r0

		 //mov oD0, c1.zzzz
		 mov r1, -c14 //c14 - view dir
		 //dp3 oD0, c2, r1 // c2 - water surface normal
		 mov r0, c10
		 dp3 r2.a, c2, r1
		 sub r0.a, r2.a, r0.a
		 mov oD0, r0
	};




technique T1
{
  pass P0
  {
  // stage0
  ColorOp[0] = Modulate;
  ColorArg1[0] = Texture;
  Texture[0] = <tTX1>;
  TextureTransformFlags[0] = Count3|Projected;
  AddressU[0] = Clamp;
  AddressV[0] = Clamp;

  AlphaOp[0] = SelectArg1;
  AlphaArg1[0] = Diffuse;


  // stage1
  ColorOp[1] = Disable;

  VertexShaderConstant[0] = <commonConst>;
  VertexShaderConstant[1] = <__vFactor>;
  VertexShaderConstant[2] = <vecWaterNormal>;
  VertexShaderConstant[4] = <matTotal>;   // World*View*Proj Matrix

  VertexShaderConstant[8] = <_vecBackBufDesc>;
  VertexShaderConstant[9] = <_vecAppTime>;
  VertexShaderConstant[10] = <_vDiffuseColor>;

  VertexShaderConstant[12] = <matView>;   // View Matrix
 

  VertexShader = <vsdiffuse1>;

  //alphablend
	AlphaBlendEnable=true;
	SrcBlend = InvSrcAlpha;
	DestBlend = SrcAlpha;


  }
}

