
vector __vFactor={1.0f,0.0f,0.0f,0.0f}; // x: -1..1 - color..gray
	
	PixelShader ps14=
	asm
	{
	ps.1.4
	texld  r0, t0
	dp3 r1, r0, c0
	lrp r0, c1.x, r1, r0
	};


technique T0
{
  pass P0
  {
	// pixel shader
	PixelShaderConstant[0] = {0.299f,0.587f,0.114f,1.0f};
	PixelShaderConstant[1] = <__vFactor>;
	PixelShader = <ps14>;
  }
}
