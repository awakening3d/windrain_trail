texture tTX0;
texture tTX1;


technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = BumpEnvMap;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Current;
  Texture[0] = <tTX1>;
  MipFilter[0]=None;
  
  // stage1
  ColorOp[1] = SelectArg1;
  ColorArg1[1] = Texture;
  Texture[1] = <tTX0>;
  MipFilter[1]=None;
  TexCoordIndex[1]=CameraSpaceReflectionVector;
  }
}


technique T1
{
  pass P0
  {
  // stage0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;
  TexCoordIndex[0]=CameraSpaceReflectionVector;
  MipFilter[0]=None;
  }
}