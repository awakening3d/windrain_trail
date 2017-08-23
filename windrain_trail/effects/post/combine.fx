
float blur=0.7;

texture tTX0;
texture tTX1;

sampler RT;//=sampler_state { Texture = <tTX0>; };
sampler Sum=sampler_state { Texture = <tTX1>; };




float4 psmain(float2 texCoord: TEXCOORD0) : COLOR 
{
   float4 render = tex2D(RT, texCoord);
   float4 sum = tex2D(Sum, texCoord);

   return lerp(render, sum, blur);
}


technique T0
{

  pass P0
  {
  PixelShader  = compile ps_1_4 psmain(); 
  }
  
}


