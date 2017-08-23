
vector _vecAppTime;


sampler tex[6];





float4 FinalScenePass
    (
    in float2 uv0 : TEXCOORD0,
    in float2 uv1 : TEXCOORD1
    ) : COLOR
{

   float4 vDecal=tex2D(tex[0], uv0);
   float4 vLM=tex2D(tex[1], uv1);
   vLM*=0.5;

//   return vLM;
    return vDecal*vLM;
}



technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 FinalScenePass(); 
  }
  
}

