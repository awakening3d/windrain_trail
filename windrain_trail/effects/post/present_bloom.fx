
//present bloom effect
// tTX1 is the bloom image

texture tTX1;


// dwARGB = { 255, red, blue, green }
dword dwARGB=0xffe0e0e0; //r=224, b=224, c=224

technique T0
{
  pass P0
  {
	AddressU[0] = Clamp; AddressV[0] = Clamp;
	AddressU[1] = Clamp; AddressV[1] = Clamp;
	AddressU[2] = Clamp; AddressV[2] = Clamp;
	AddressU[3] = Clamp; AddressV[3] = Clamp;

  TextureFactor=<dwARGB>;

  //stage 0
  ColorOp[0] = Modulate;
  ColorArg1[0] = Texture;
  ColorArg2[0] = TFactor;
  Texture[0] = <tTX1>;


  // stage1
  ColorOp[1] = Add;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;

  // stage2
  ColorOp[2] = Disable;
  }
}

