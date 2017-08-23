technique T0
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