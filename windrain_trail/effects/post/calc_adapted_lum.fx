//Calculate Adapted Lum
// Desc: Calculate the luminance that the camera is current adapted to, using
//       the most recented adaptation level, the current scene luminance, and
//       the time elapsed since last calculated

// The user's adapted luminance level is simulated by closing the gap between
// adapted luminance and current luminance by 2% every frame, based on a
// 30 fps rate. This is not an accurate model of human adaptation, which can
// take longer than half an hour.


texture tTX0;
texture tTX1;

vector _vecAppTime; // app time ( FrameTime, ElapsedTimeFromLastFrame, 0, 0 )



//sampler texAdapted;
//sampler texSource;


sampler texAdapted=sampler_state {
	Texture = <tTX0>;
};

sampler texSource=sampler_state {
	Texture = <tTX1>;
};


float4 CalculateAdaptedLum( in float2 vScreenPosition : TEXCOORD0 ) : COLOR
{
	float fAdaptedLum = dot( tex2D(texAdapted, float2(0.5f, 0.5f)).rgb, float3( 0.2125f, 0.7154f, 0.0721f ) );
	float fCurrentLum = dot( tex2D(texSource, float2(0.5f, 0.5f)).rgb, float3( 0.2125f, 0.7154f, 0.0721f ) );

    // The user's adapted luminance level is simulated by closing the gap between
    // adapted luminance and current luminance by 2% every frame, based on a
    // 30 fps rate. This is not an accurate model of human adaptation, which can
    // take longer than half an hour.
	float fNewAdaptation = fAdaptedLum + (fCurrentLum - fAdaptedLum) * ( 1 - pow( 0.98f, 30 * _vecAppTime.y ) );
//	float fNewAdaptation = fAdaptedLum + (fCurrentLum - fAdaptedLum) * ( 0.02 * 30 * _vecAppTime.y );
    return float4(fNewAdaptation, fNewAdaptation, fNewAdaptation, 1.0f);
}


technique T0
{
    pass P0
    {
        PixelShader  = compile ps_2_0 CalculateAdaptedLum();
    }
}



	PixelShader ps14=
	asm
	{
	ps.1.4
	texld r0, t0 //adapted lum
	texld r1, t0 //current scene lum

	sub r2, r1, r0
	mul r1.x, c0.x, c1.y // 0.02 * 30 * ElapsedTime
	mad r0, r2, r1.x, r0
	};


technique T1
{
  pass P0
  {
	Texture[0] = <tTX0>;
	Texture[1] = <tTX1>;

	// pixel shader
	PixelShaderConstant[0] = {0.6f,0.25f,0.5f,1.0f}; // 0.6 = 0.02 * 30fps
	PixelShaderConstant[1] = <_vecAppTime>;
	PixelShaderConstant[3] = {0.2125f, 0.7154f, 0.0721f, 0.0f};
	PixelShader = <ps14>;
  }
}



technique T2
{
  pass P0
  {
  //stage 0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;
  Texture[0] = <tTX1>;

  //stage 1
  ColorOp[1] = Disable;
  }
}

