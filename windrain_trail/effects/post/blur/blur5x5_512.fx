
texture tTX0;

sampler SourceTex=sampler_state { Texture = <tTX0>; };


static const int    MAX_SAMPLES            = 13;    // Maximum texture grabs
float2 g_avSampleOffsets[MAX_SAMPLES]={
-0.00390625,0,
-0.001953125,-0.001953125,
-0.001953125,0,
-0.001953125,0.001953125,
0,-0.00390625,
0,-0.001953125,
0,0,
0,0.001953125,
0,0.00390625,
0.001953125,-0.001953125,
0.001953125,0,
0.001953125,0.001953125,
0.00390625,0,
};


//-----------------------------------------------------------------------------
// Name: GaussBlur5x5
// Type: Pixel shader                                      
// Desc: Simulate a 5x5 kernel gaussian blur by sampling the 12 points closest
//       to the center point.
//-----------------------------------------------------------------------------
float4 GaussBlur5x5(in float2 vScreenPosition : TEXCOORD0 ) : COLOR
{
    float4 sample = 0.0f;

	for( int i=0; i < MAX_SAMPLES; i++ )
	{
		sample += tex2D( SourceTex, vScreenPosition + g_avSampleOffsets[i] );
	}
	
	return sample/MAX_SAMPLES;
}



technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 GaussBlur5x5(); 
  }
  
}


