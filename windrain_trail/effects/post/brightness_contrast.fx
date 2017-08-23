//brightness/contrast

// contrast = [0..2]

// vecC.xyzw = contrast -1
vector vecC={0.5f,0.5f,0.5f,0.5f};		// contrast = 1.5

// brightness = [ -0.5 .. 0.5 ]

// vecB.xyzw = brightness - 0.5 * contrast + 0.5
vector vecB={-0.25f,-0.25f,-0.25f,-0.25f};		// brightness = 0
//vector vecB={-0.05f,-0.05f,-0.05f,-0.05f};		// brightness = 0.2


	PixelShader ps10=
	asm
	{
	ps.1.0
	tex t0
	add r1, c1, c0.a // map [-1..1] to [0..2]
	mad r0, t0, r1, c2
	};


technique T0
{
  pass P0
  {
	// pixel shader
	PixelShaderConstant[0] = {0.0f,0.25f,0.5f,1.0f};
	PixelShaderConstant[1] = <vecC>;
	PixelShaderConstant[2] = <vecB>;
	PixelShader = <ps10>;
  }
}



technique T1
{
  pass P0
  {
  TextureFactor=0x40404040;
  //stage 0
  ColorOp[0] = AddSigned2x;
  ColorArg1[0] = Texture;
  ColorArg2[0] = TFactor;
  //stage 1
  ColorOp[1] = Disable;
  }
}

