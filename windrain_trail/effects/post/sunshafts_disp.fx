
//--- system variables, player feed value ----
matrix matViewProj; //matView*matProj

texture tTX0;
texture tTX1;
texture tTX2;

sampler SourceTex;//=sampler_state { Texture = <tTX0>; };
sampler ShaftsTex=sampler_state { Texture = <tTX1>; };



/// Constants ////////////////////////////
float SunShafts_Intensity=0.6;
float4 SunShafts_SunColor={1,1,1,1};



float4 blendSoftLight(float4 a, float4 b)
{
  float4 c = 2 * a * b + a * a * (1 - 2 * b);
  float4 d = sqrt(a) * (2 * b - 1) + 2 * a * (1 - b);
  
  return ( b < 0.5 )? c : d;
}



float4 SunShaftsDisplayPS(in float2 baseTC : TEXCOORD0) : COLOR
{
  half4 cScreen = tex2D(SourceTex, baseTC.xy);      
  half4 cSunShafts = tex2D(ShaftsTex, baseTC.xy);

  half fShaftsMask = saturate(1.00001- cSunShafts.w) * SunShafts_Intensity * 2.0;
        
  // Apply "very" subtle (but always visible) sun shafts mask 
  float fBlend = cSunShafts.w;
  
  // normalize sun color (dont wanna huge values in here)
  float4 sunColor = 1;
  sunColor.xyz = normalize(SunShafts_SunColor.xyz);
  
  float4 Color=1;
  Color =  cScreen + cSunShafts.xyzz * SunShafts_Intensity * sunColor * ( 1 - cScreen );
  Color = blendSoftLight(Color, sunColor * fShaftsMask *0.5+0.5);
   
	return Color;
}


technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 SunShaftsDisplayPS();
  }
  
}


