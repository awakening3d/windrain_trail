texture tTX0;
texture tTX1;


technique T0
{
  pass P0
  {
  Texture[0]=<tTX1>;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Diffuse;
  ColorOp[0] = SelectArg2;
  AlphaArg1[0] = Texture;
  AlphaOp[0] = SelectArg1;

  Texture[1]=<tTX0>;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;
  ColorOp[1] = Modulate;
  TexCoordIndex[1] = 0;


    SrcBlend = SrcAlpha;
    DestBlend = One;
	AlphaBlendEnable = True;

  }
}