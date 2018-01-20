texture tTX1;

matrix matTotal; //matWorld*matView*matProj;
vector _vecAppTime;
vector vecUVParam = {8, 0.0f, 8, 0.0f}; // x - wave speed


     // Definition of the vertex shader, declarations then assembly
    VertexShader vsdiffuse =
	/*
    decl
    {
	stream 0;
	float v0[3];       // Position
	float v1[3];		// normal
	float v2[2];       // Texture Coord0
    }
	*/
    asm
    {
	vs.1.1
	dcl_position v0
	dcl_normal	 v1
	dcl_texcoord v2


	// c0-c3 contains composite transform matrix
	m4x4 oPos, v0, c0   // transform vertices by view/projection matrix

	mul r0, v2, c5.z
	mov r1, c4
	mad r0, c5.x, r1.x, r0 //offset uv by wavespeed * timed

	mov oT0, v2
	mov oT1, r0

    };


technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;

  // stage1
  ColorOp[1] = Add;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;
  Texture[1] = <tTX1>;

  // stage2
  ColorOp[2] = Disable;

	// vertex shader
	VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
	VertexShaderConstant[4] = <_vecAppTime>;
	VertexShaderConstant[5] = <vecUVParam>;

	VertexShader = <vsdiffuse>;

  }
}

