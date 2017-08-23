

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};


//texture tTX0;
texture tTX1;
texture tTX2;

sampler SourceTex=sampler_state {
 	AddressU = CLAMP;
	AddressV = CLAMP;
};

sampler DepthTex=sampler_state {
	Texture = <tTX1>;
 	AddressU = CLAMP;
	AddressV = CLAMP;
};


float4 SunShaftsMaskGen(in float2 vScreenPosition : TEXCOORD0 ) : COLOR
{
    float4 scene=tex2D( SourceTex, vScreenPosition);

/*
	float w=_vecBackBufDesc.x;
	float h=_vecBackBufDesc.y;

	if (h<w) {
		vScreenPosition.y*=(h/w);
	} else {
		vScreenPosition.x*=(w/h);
	}

*/
	float sceneDepth=tex2D( DepthTex, vScreenPosition).r;

	float fShaftsMask = (1 - sceneDepth);
	
	//return float4( float3(1,1,1)*saturate(sceneDepth), fShaftsMask );

	return float4( scene.xyz * saturate(sceneDepth), fShaftsMask );
}



technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 SunShaftsMaskGen(); 
  }
  
}


