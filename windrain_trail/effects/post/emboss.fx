vector _vecViewport; // viewport description ( vp.X, vp.Y, vp.Width, vp.Height )

sampler tex;


float4 emboss( in float2 texCoord : TEXCOORD0 ) : COLOR
{
	float2  upLeftUV = float2(texCoord.x - 1.0/_vecViewport.z , texCoord.y - 1.0/_vecViewport.w);
	float4  bkColor = float4(0.5 , 0.5 , 0.5 , 1.0);
	float4  curColor    =  tex2D( tex, texCoord );
	float4  upLeftColor =  tex2D( tex, upLeftUV );
	//相减得到颜色的差
	float4  delColor = curColor - upLeftColor;
	//需要把这个颜色的差设置
	float  h = 0.3 * delColor.x + 0.59 * delColor.y + 0.11* delColor.z;
	float4  _outColor =  float4(h,h,h,0.0)+ bkColor;
	return  _outColor;	
 }



technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 emboss(); 
  }
  
}

