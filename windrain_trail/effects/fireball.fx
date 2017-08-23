texture tTX0;
texture tTX1;


vector _vecAppTime;

matrix matTotal; //matWorld*matView*matProj;

float timeSampleDist=0.3;

struct VS_OUTPUT 
{
   float4 Pos:   POSITION;
   float2 pos:   TEXCOORD0;
   float2 fPos:  TEXCOORD1;
   float2 pPos:  TEXCOORD2;
   float2 ppPos: TEXCOORD3;
   float4 vDiffuse : COLOR0;
};

VS_OUTPUT mainvs(float4 vPosition: POSITION, float2 vTexCoord0 : TEXCOORD0, float4 vDiffuse : COLOR0)
{
   VS_OUTPUT Out;
   
   Out.Pos = mul(vPosition, matTotal);
   
   Out.pos = vTexCoord0-float2(0.5,0.5);
   Out.pos *=-2 ;
   

  float time_0_X=_vecAppTime.x;

   // Current fire ball position
  Out.fPos=float2(0,0);
   //Out.fPos.x = 0.8 * sin(0.71 * time_0_X);
   //Out.fPos.y = 0.8 * cos(0.93 * time_0_X);

   // Fire ball position not too long ago
   time_0_X -= timeSampleDist;
   Out.pPos.x = 0.8 * sin(0.71 * time_0_X);
   Out.pPos.y = 0.8 * cos(0.93 * time_0_X);

   // Fire ball position some time ago
   time_0_X -= timeSampleDist;
   Out.ppPos.x = 0.8 * sin(0.71 * time_0_X);
   Out.ppPos.y = 0.8 * cos(0.93 * time_0_X);

   Out.vDiffuse=vDiffuse;

   return Out;
}



float colorDistribution=2.76;
float fade=2.4;
float flameSpeed=1;
float spread=0.5;
float flamability=1.74;


sampler Flame=sampler_state { Texture = <tTX0>; };
sampler Noise=sampler_state { Texture = <tTX1>; };


float4 mainps( float2 pos:   TEXCOORD0, 
             float2 fPos:  TEXCOORD1, 
             float2 pPos:  TEXCOORD2, 
             float2 ppPos: TEXCOORD3,
			 float4 vDiffuse : COLOR0) 
  : COLOR 
{
   // Distance to three points on the path, streches fire ball along the path
   float dist = distance(pos, fPos);// + 0.7 * distance(pos, pPos) + 0.5 * distance(pos, ppPos);

   // Grab some noise and make a flame
   float noisy = tex3D(Noise, float3(pos, spread * dist - flameSpeed * _vecAppTime.x));
   float flame = saturate(1 - fade * dist + flamability * noisy);

   // Map flame into a color
   return tex1D(Flame, pow(flame, colorDistribution))*vDiffuse;
}






technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_2_0 mainvs();
        PixelShader  = compile ps_2_0 mainps(); 
    }
}






