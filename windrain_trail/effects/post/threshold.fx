
//do threshold effect by the fixed threshod value 0.5

vector vecLightColor={1.0f,1.0f,1.0f,1.0f};
vector vecDarkColor={0.0f,0.0f,0.0f,0.0f};

	PixelShader ps14=
	asm
	{
	ps.1.4
	texld  r0, t0
	cnd r0, r0, c0, c1
	};


technique T0
{
  pass P0
  {
	// pixel shader
	PixelShaderConstant[0] = <vecLightColor>;
	PixelShaderConstant[1] = <vecDarkColor>;
	PixelShader = <ps14>;
  }
}
