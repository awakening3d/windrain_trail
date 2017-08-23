texture tTX1;
texture tTX2;


matrix mENV=
{ 0.5,  0.0, 0.0, 0.0,
  0.0, -0.5, 0.0, 0.0,
  0.0,  0.0, 1.0, 0.0,
  0.5,  0.5, 0.0, 1.0 };

technique T0
{
  pass P0
  {
  // stage0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;
  TexCoordIndex[0] = 0;

  // stage1
  ColorOp[1] = BumpEnvMap;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;
  Texture[1] = <tTX1>;
  TexCoordIndex[1] = 0;

//  BumpEnvMat00[1] = 1;
//  BumpEnvMat01[1] = 0;
//  BumpEnvMat10[1] = 0;
//  BumpEnvMat11[1] = 1;
  
  // stage2
  ColorOp[2] = Add;
  Texture[2] = <tTX2>;

  TextureTransform[2] = <mENV>;
  TextureTransformFlags[2] = Count2;
  TexCoordIndex[2]=CameraSpaceNormal;
 
  }
}


technique T1
{
  pass P0
  {
  // stage0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;
  TexCoordIndex[0] = 0;

  // stage1
  ColorOp[1] = Add;
  Texture[1] = <tTX2>;

  TextureTransform[1] = <mENV>;
  TextureTransformFlags[1] = Count2;
  TexCoordIndex[1]=CameraSpaceNormal;
  }
}
