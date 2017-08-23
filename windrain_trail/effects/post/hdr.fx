//#include "hdrformats.fx"

texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;

//vector _vecAppTime;


sampler tex[6];
sampler AvgLumTex = sampler_state { Texture = <tTX1>; };


// The per-color weighting to be used for luminance calculations in RGB order.
static const float3 LUMINANCE_VECTOR  = float3(0.2125f, 0.7154f, 0.0721f);

// The per-color weighting to be used for blue shift under low light.
static const float3 BLUE_SHIFT_VECTOR = float3(1.05f, 0.97f, 1.27f); 


bool g_bEnableBlueShift=false;
bool g_bEnableToneMap=false;
float  g_fMiddleGray=0.5f;       // The middle gray key value


/*
float3 CEToneMapping(float3 color, float adapted_lum) 
{
    return 1 - exp(-adapted_lum * color);
}

float3 ACESToneMapping(float3 color, float adapted_lum)
{
    const float A = 2.51f;
    const float B = 0.03f;
    const float C = 2.43f;
    const float D = 0.59f;
    const float E = 0.14f;
    color *= adapted_lum;
    return (color * (A * color + B)) / (color * (C * color + D) + E);
}
*/

float4 FinalScenePass
    (
    in float2 vScreenPosition : TEXCOORD0
    ) : COLOR
{

	float4 vSample=tex2D(tex[0], vScreenPosition);
	float fAdaptedLum = dot( tex2D(AvgLumTex, float2(0.5f, 0.5f)).rgb, LUMINANCE_VECTOR );

	// For very low light conditions, the rods will dominate the perception
    // of light, and therefore color will be desaturated and shifted
    // towards blue.
    if( g_bEnableBlueShift )
    {
		// Define a linear blending from -1.5 to 2.6 (log scale) which
		// determines the lerp amount for blue shift
        float fBlueShiftCoefficient = 1.0f - (fAdaptedLum + 1.5)/4.1;
        fBlueShiftCoefficient = saturate(fBlueShiftCoefficient);

		// Lerp between current color and blue, desaturated copy
        float3 vRodColor = dot( (float3)vSample, LUMINANCE_VECTOR ) * BLUE_SHIFT_VECTOR;
        vSample.rgb = lerp( (float3)vSample, vRodColor, fBlueShiftCoefficient );
    }
	
    // Map the high range of color values into a range appropriate for
    // display, taking into account the user's adaptation level, and selected
    // values for for middle gray and white cutoff.

	vSample.rgb *= g_fMiddleGray/( fAdaptedLum + 0.001f);

	if( g_bEnableToneMap ) vSample.rgb /= (1.0f+vSample);
    

    return vSample;
}



technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 FinalScenePass(); 
  }
  
}

