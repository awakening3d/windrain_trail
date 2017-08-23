technique T0
{
  pass P0
  {
  AlphaArg2[0]=Diffuse;
  AlphaOp[0]=SelectArg2;
  SrcBlend = SrcAlpha;
  DestBlend = InvSrcAlpha;
  AlphaBlendEnable = True;
  }
}