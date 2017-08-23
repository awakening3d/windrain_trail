// auto-contrast

dword dwARGB=0x40404040;

technique T1
{
  pass P0
  {
  TextureFactor=<dwARGB>;
  //stage 0
  ColorOp[0] = AddSigned2x;
  ColorArg1[0] = Texture;
  ColorArg2[0] = TFactor;
  //stage 1
  ColorOp[1] = Disable;
  }
}

