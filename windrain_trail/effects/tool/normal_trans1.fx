
texture tTX0;

sampler SourceTex=sampler_state {
	Texture = <tTX0>;
	AddressU = CLAMP;
	AddressV = CLAMP;
};



float4 mainps(in float2 vScreenPosition : TEXCOORD0  ) : COLOR
{
    float4 c = tex2D( SourceTex, vScreenPosition );
    float4 cc;
    float r = c.r*2-1;
    float g = c.g*2-1;
    float b = c.b*2-1;

    r= (-r+1)*0.5f;
    g= (-g+1)*0.5f;
    b= (b+1)*0.5f;

    cc.r  = r;
    cc.g = g;
    cc.b = b;

    cc.a = c.a;
    return cc;
}


technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 mainps(); 
  }
  
}


