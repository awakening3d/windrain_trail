
//do gray threshold effect by a threshod value.

vector vecLightColor={1.0f,1.0f,1.0f,1.0f};
vector vecDarkColor={0.0f,0.0f,0.0f,0.0f};
vector vecThreshold={0.299f,0.587f,0.114f, 0.3f }; //the last number {0.3} is the threshold value, you can change it within [0..1]


	PixelShader ps14=
	asm
	{
	ps.1.4
	texld  r0, t0

	mul r1, r0, c0
	add r0.a, r1.r, r1.g
	add r0.a, r0.a, r1.b

	sub r0.a, r0.a, c0.a
	cmp r0, r0.a, c1, c2
	};


technique T0
{
  pass P0
  {
	// pixel shader
	PixelShaderConstant[0] = <vecThreshold>;
	PixelShaderConstant[1] = <vecLightColor>;
	PixelShaderConstant[2] = <vecDarkColor>;
	PixelShader = <ps14>;
  }
}
