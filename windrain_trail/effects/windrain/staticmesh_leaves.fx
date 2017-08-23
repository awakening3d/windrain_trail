technique T0
{
  pass P0
  {
  // stage0
  //ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;

  // stage1
  ColorOp[1] = Disable;

  AlphaTestEnable=True;
  AlphaRef=0x40;
  AlphaFunc=GreaterEqual;

  SrcBlend = SrcAlpha;
  DestBlend = InvSrcAlpha;
  //AlphaBlendEnable = True;


  CullMode=None;

  }
}