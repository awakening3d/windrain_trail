//post processing - distortion effect
texture tTX0;

float  bumpScale=0.1;

technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = BumpEnvMap;
  ColorArg1[0] = Texture;
  ColorArg2[0] = Current;
  Texture[0] = <tTX0>;
  AddressU[0] = Clamp; AddressV[0] = Clamp;
  // [ bumpScale, 0 ]
  // [ 0, bumpScale ]
  
  BumpEnvMat00[0] = <bumpScale>;
  BumpEnvMat01[0] = 0;
  BumpEnvMat10[0] = 0;
  BumpEnvMat11[0] = <bumpScale>;

  
  // stage1
  ColorOp[1] = SelectArg1;
  ColorArg1[1] = Texture;
  TexCoordIndex[1]=0;
  AddressU[1] = Clamp; AddressV[1] = Clamp;

  // stage2
  ColorOp[2] = Disable;
  }
}