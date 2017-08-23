texture tTX0;

technique T0
{
  pass P0
  {
  // stage0
  // stage1
  Texture[1] = <tTX0>;
  ColorOp[1] = SelectArg2;
  ColorArg2[1] = Current;
  AlphaOp[1] = SelectArg1;
  AlphaArg1[1] = Texture;
  TexCoordIndex[1]=0;
  AddressV[1] = Clamp;

  AlphaTestEnable=True;
  AlphaRef=0x08;
  AlphaFunc=GreaterEqual;

  }
}

