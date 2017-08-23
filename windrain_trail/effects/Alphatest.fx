technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = Modulate;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Diffuse;
  AlphaOp[0] = Modulate;
  AlphaArg1[0] = Texture;
  AlphaArg2[0] = Diffuse;
  
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