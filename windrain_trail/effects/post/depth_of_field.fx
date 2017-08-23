#include "..\include\common.fx"


//texture tTX0;
texture tTX1;
texture tTX2;

sampler SourceTex=sampler_state {
 	AddressU = CLAMP;
	AddressV = CLAMP;
};

sampler BlurTex=sampler_state {
	Texture = <tTX1>;
 	AddressU = CLAMP;
	AddressV = CLAMP;
};

sampler DepthTex=sampler_state {
	Texture = <tTX2>;
 	AddressU = CLAMP;
	AddressV = CLAMP;
};


//float fFocusDepth=0.4;
//float fAperture=1.5;

vector __vFactor = {0.4,1.5,0,0}; //fFocusDepth, fAperture


float ComputeDepthBlur (float depth,float focus)
{
   float f;

   if (depth < focus) {
      f = (focus-depth )/(focus);
   } else {
      f = (depth - focus)/(1 - focus);
   }

   return f;
}


float4 DepthOfField(in float2 vScreenPosition : TEXCOORD0 ) : COLOR
{
    float4 sample=tex2D( SourceTex, vScreenPosition);
	float4 blurs=tex2D( BlurTex, vScreenPosition);

/*
	float w=_vecBackBufDesc.x;
	float h=_vecBackBufDesc.y;

	if (h<w) {
		vScreenPosition.y*=(h/w);
	} else {
		vScreenPosition.x*=(w/h);
	}
	*/

	float fdepth = decode_depth( tex2D( DepthTex, vScreenPosition) );


	float fofs=ComputeDepthBlur( fdepth,__vFactor.x);

	fofs*=__vFactor.y;
	fofs=saturate(fofs);

	sample=lerp(sample,blurs,fofs);

	//sample=blurs;
	
	return sample;
}



technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 DepthOfField(); 
  }
  
}


