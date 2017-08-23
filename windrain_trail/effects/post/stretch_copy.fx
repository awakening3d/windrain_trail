texture tTX0;

technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;
  Texture[0] = <tTX0>;

  // stage1
  ColorOp[1] = Disable;

  }
}

