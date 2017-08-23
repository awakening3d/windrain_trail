//expose

vector vecFactor = {.5,0.0f,0.0f,0.0f};

texture tTX1;

/*
sampler texOrg : register(s0);

sampler texLum = sampler_state {
	Texture = <tTX1>;
};



float4 ExposeByLum( in float2 vScreenPosition : TEXCOORD0 ) : COLOR
{
    float4 vSample = tex2D(texOrg, vScreenPosition);
    float fAdaptedLum = dot( tex2D(texLum, float2(0.5f, 0.5f)).rgb, float3( 0.2125f, 0.7154f, 0.0721f ) );
    vSample.rgb *= vecFactor.x/( fAdaptedLum*1.5 + 0.5 );
    return vSample;
}


technique T0
{
    pass P0
    {
        PixelShader  = compile ps_2_0 ExposeByLum();
    }
}
*/



	PixelShader ps14=
	asm
	{
	ps.1.4
	texld r0, t0
	texld r1, t0

	mul r0, r0, c1.x // vSample *= vecFactor.x
	add r1.w, c0.z, c0.w // r1.w = 1.5
	mad r1.x, r1.x, r1.w, c0.z // fAdaptedLum = fAdaptedLum*1.5 + 0.5, r1.x
	
	cnd r1.x, r1.x, r1.x, c0.z // if r1.x < 0.5 then r1.x = 0.5

	mad r1.x, r1.x, c3.x, c3.y // map 0.5 ~ 2 to 0 ~ 1
	add r1.w, c0.w, c0.w	// r1.w = 2
	lrp r1.x, r1.x, c0.z, r1.w // map 0~1 to 2, .5
	mul r0, r0, r1.x // vSample *= r1.x
	};



technique T1
{
  pass P0
  {
	Texture[1] = <tTX1>;

	// pixel shader
	PixelShaderConstant[0] = {0.0f,0.25f, .5, 1};
	PixelShaderConstant[1] = <vecFactor>;
	PixelShaderConstant[3] = { .667, -.333, -1, 0.01};
	PixelShader = <ps14>;
  }
}



technique T2
{
  pass P0
  {
  TextureFactor=0x40404040;
  //stage 0
  ColorOp[0] = AddSigned2x;
  ColorArg1[0] = Texture;
  ColorArg2[0] = TFactor;
  //stage 1
  ColorOp[1] = Disable;
  }
}

