
//--- system variables, player feed value ----

vector _vecViewport;		// {X,Y,Width,Height}

matrix matViewProj; //matView*matProj
matrix matView; //View Matrix



texture tTX0;
texture tTX1;
texture tTX2;

sampler SourceTex=sampler_state { Texture = <tTX0>; };


/// Constants ////////////////////////////

float4 sunShafts_Params={0.08,1,1,1};
float4 SunShafts_SunPos={9999,9999,9999,1};


struct vtxOutSunShaftsGen
{
  float4 HPosition  : POSITION; 
  float2 baseTC       : TEXCOORD0;
  float4 sunPos       : TEXCOORD1;  
};


vtxOutSunShaftsGen SunShaftsGenVS(in float4 vPos : POSITION, in float2 vTc0 : TEXCOORD0 )
{
  vtxOutSunShaftsGen OUT = (vtxOutSunShaftsGen)0; 

  // Position in screen space.
  //vPos.xy+=0.5;
  vPos.xy/=_vecViewport.zw;
  vPos.xy = vPos.xy*2-float2(1,1);
  vPos.y=-vPos.y;


  OUT.HPosition = vPos;
  OUT.baseTC.xy = vTc0.xy;
 
 
  float4 SunPosH = mul(SunShafts_SunPos,matViewProj);

  OUT.sunPos.x = (SunPosH.x + SunPosH.w) * 0.5 ;
  OUT.sunPos.y = (-SunPosH.y + SunPosH.w) * 0.5 ;
  OUT.sunPos.z = SunPosH.w;

	float3 sunposview = mul(SunShafts_SunPos,matView);
	OUT.sunPos.w=normalize(sunposview).z;

  return OUT;
}



float4 SunShaftsGenPS(vtxOutSunShaftsGen IN) : COLOR
{
  float2 sunPosProj = ((IN.sunPos.xy / IN.sunPos.z));
  
  float fSign = saturate(IN.sunPos.w);
  
 
  float2 sunDir =  ( sunPosProj.xy - IN.baseTC.xy);
   
  //sunDir=normalize(sunDir)*0.2;


  half4 accum = 0; 
  sunDir.xy *= sunShafts_Params.x * fSign * fSign;
  
  for(int i=0; i<8; i++)
  {
    half4 depth = tex2D(SourceTex, (IN.baseTC.xy + sunDir.xy * i) );      
    accum += depth * (1.0-i/8.0);
  }
  
  accum /= 8.0;

	float4 Color = accum * 2 * fSign;
	//Color.w += 1-saturate(saturate(fSign*0.1+0.9));
    
  return Color;
}


technique T0
{

  pass P0
  {
  VertexShader = compile vs_2_0 SunShaftsGenVS();
  PixelShader  = compile ps_2_0 SunShaftsGenPS();
  }
  
}


