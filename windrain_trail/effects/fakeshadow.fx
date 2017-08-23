technique T0
{
  pass P0
  {
  AlphaArg2[0]=Texture;
  AlphaOp[0]=SelectArg2;
  SrcBlend = Zero;
  DestBlend = InvSrcColor;
  AlphaBlendEnable = True;
  }
}