float fAlpha=1;

sampler texBase;


float4 mainps(float2 texCoord: TEXCOORD0) : COLOR 
{
	clip(fAlpha-0.01f);
	float4 col=tex2D(texBase, texCoord);
	return col*fAlpha;

}

technique T0
{
  pass P0
  {
   PixelShader  = compile ps_2_0 mainps();
  
  
  SrcBlend = One;
  DestBlend = One;
  AlphaBlendEnable = True;
  
  CullMode=None;
  ZWriteEnable=False;
	DepthBias=-0.00002f; //0xb7a7c5ac;
  }
}