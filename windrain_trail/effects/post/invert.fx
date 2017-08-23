
	PixelShader ps10=
	asm
	{
	ps.1.0
	tex t0
	sub r0, c0, t0
	};


technique T0
{
  pass P0
  {
	// pixel shader
	PixelShaderConstant[0] = {1.0f,1.0f,1.0f,1.0f};
	PixelShader = <ps10>;
  }
}
