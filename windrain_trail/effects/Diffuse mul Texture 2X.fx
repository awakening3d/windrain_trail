technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = Modulate2X;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Diffuse;
  // stage1
  ColorOp[1] = Disable;
  }

}