texture tTX0;
texture tTX1;
texture tTX2;


matrix mSCA=
{ 30,  0.0, 0.0, 0.0,
  0.0,  30, 0.0, 0.0,
  0.0,  0.0,   1.0, 0.0,
  0.0,  0.0, 0.0, 1.0 };

technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = BumpEnvMap;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Current;
  Texture[0] = <tTX0>;
  TextureTransform[0] = <mSCA>;
  TextureTransformFlags[0] = Count2;
  TexCoordIndex[0] = 0;
  MipFilter[0]=None;

  
  // stage1
  ColorOp[1] = SelectArg1;
  ColorArg1[1] = Texture;
  Texture[1] = <tTX1>;
  TexCoordIndex[1]=0;

  AlphaOp[1] = SelectArg1;
  AlphaArg1[1] = TFactor;

  AlphaBlendEnable = True;
  TextureFactor = 0xccaaaaaa;
  SrcBlend = SrcAlpha;
  DestBlend = InvSrcAlpha;
  }
}