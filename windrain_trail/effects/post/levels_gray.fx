texture tTX1;
	

	PixelShader ps14=
	asm
	{
	ps.1.4
	
	texld  r0, t0
	mul r1, r0, c0
	add r0.r, r1.r, r1.g
	add r0.r, r0.r, r1.b
	phase
	texld r1, r0
	mov r0, r1
	};



technique T0
{
  pass P0
  {
	Texture[1] = <tTX1>;
	AddressU[1] = Clamp; AddressV[1] = Clamp;

	// pixel shader
	PixelShaderConstant[0] = {0.299f,0.587f,0.114f,1.0f};
	PixelShader = <ps14>;
  }
}
