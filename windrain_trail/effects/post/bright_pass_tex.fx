//bright-pass filter
//do threshold effect by a threshod value.
texture tTX0;


vector vecDarkColor={0.0f,0.0f,0.0f,0.0f};
vector vecThreshold={0.2125f, 0.7154f, 0.0721f, 0.7f }; //the last number (0.7) is the threshold value, you can change it within [0..1]


	PixelShader ps14=
	asm
	{
	ps.1.4
	texld  r0, t0
	dp3 r2.x, r0, c0 // calc Lum

	sub r2.x, r2.x, c0.a
	cmp r0, r2.x, r0, c2
	};


technique T0
{
  pass P0
  {
    Texture[0] = <tTX0>;
  	// pixel shader
	PixelShaderConstant[0] = <vecThreshold>;
	PixelShaderConstant[2] = <vecDarkColor>;

	PixelShader = <ps14>;
  }
}


technique T1
{
  pass P0
  {
  Texture[0] = <tTX0>;
  // stage0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;

  // stage1
  ColorOp[1] = Disable;
  }
}
