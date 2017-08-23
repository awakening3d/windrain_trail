technique T0
{
  pass P0
  {
  AlphaArg1[0] = Texture;
  AlphaOp[0] = SelectArg1;

	SrcBlend = SrcAlpha;
	DestBlend = One;
	AlphaBlendEnable = True;
  }
}