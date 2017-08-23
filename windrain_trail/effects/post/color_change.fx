
// red,blue,green = [0..255]

// dwARGB = { 255, red, blue, green }
dword dwARGB=0xffffaa47; //r=255, b=170, c=71


technique T0
{
  pass P0
  {
  TextureFactor=<dwARGB>;
  //stage 0
  ColorOp[0] = Modulate;
  ColorArg1[0] = Texture;
  ColorArg2[0] = TFactor;
  //stage 1
  ColorOp[1] = Disable;
  }
}

