technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = SelectArg2;
  ColorArg2[0] = TFactor;
  //TextureFactor = 0xffffffff;

  // stage1
  ColorOp[1] = Disable;

  AlphaTestEnable=True;
  AlphaRef=0x08;
  AlphaFunc=GreaterEqual;

  SrcBlend = SrcAlpha;
  DestBlend = InvSrcAlpha;
  AlphaBlendEnable = True;

  CullMode=None;
  }
}