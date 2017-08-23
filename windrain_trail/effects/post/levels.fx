texture tTX1;
texture tTX2;
texture tTX3;
	

	PixelShader ps14=
	asm
	{
	ps.1.4

	texld  r0, t0
	mov r1, r0.r
	mov r2, r0.g
	mov r3, r0.b

	phase

	texld r1, r1
	texld r2, r2
	texld r3, r3

	mov r0.r, r1
	mov r0.g, r2
	mov r0.b, r3
	mov r0.a, r1.a
	};


technique T0
{
  pass P0
  {
	Texture[1] = <tTX1>;
	Texture[2] = <tTX2>;
	Texture[3] = <tTX3>;

	AddressU[1] = Clamp; AddressV[1] = Clamp;
	AddressU[2] = Clamp; AddressV[2] = Clamp;
	AddressU[3] = Clamp; AddressV[3] = Clamp;

	// pixel shader
	PixelShader = <ps14>;
  }
}
