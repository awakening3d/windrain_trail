texture tTX0;
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
  Texture[0] = <tTX0>;
  TextureTransform[0] = <mENV>;
  TextureTransformFlags[0] = Count2;
  TexCoordIndex[0]=CameraSpaceNormal;
  }
}