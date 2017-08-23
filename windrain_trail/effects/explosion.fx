texture tTX0;
texture tTX1;


vector _vecAppTime;

matrix matTotal; //matWorld*matView*matProj;



struct VS_OUTPUT 
{
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
};

VS_OUTPUT mainvs(float4 vPosition: POSITION, float2 vTexCoord0 : TEXCOORD0)
{
   VS_OUTPUT Out;

   Out.Pos = mul(vPosition, matTotal);
   
   Out.texCoord = vTexCoord0-float2(0.5,0.5);
   Out.texCoord *=-2 ;

   return Out;
}







sampler Flame=sampler_state { Texture = <tTX0>; };
sampler Noise=sampler_state { Texture = <tTX1>; };


float flamability=0.34;
float pressure=0.6;
float powerBoost=0.16;
float intensity=1;
float speed=0.15;
float noisiness=0.5;
float explositivity=0.44955;


float4 mainps(float2 texCoord: TEXCOORD0) : COLOR 
{
   float t = frac(_vecAppTime.x * speed);

   // Alter the timing
   t = pow(t, explositivity);

   // The function f(t) = 6.75 * t * (t * (t - 2) + 1)
   // is a basic third degree pulse function with these properties:
   // f(0)  = 0
   // f(1)  = 0
   // f'(1) = 0
   // max(f(t)) = 1, where 0 < t < 1
   // 
   // The basic idea of this function is a quick rise at the
   // beginning and then a slow smooth decline towards zero
   float size = intensity * 6.75 * t * (t * (t - 2) + 1);

   float dist = length(texCoord) / (0.1 + size);

   // Higher flamability => quicker move away from center
   // Higher pressure => tighter packing
   float n = tex3D(Noise, float3(noisiness * texCoord, flamability * _vecAppTime.x - pressure * dist));

   float4 flame = tex1D(Flame, size * powerBoost + size * (2 * n - dist));

   return flame;
}






technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_1_1 mainvs();
        PixelShader  = compile ps_2_0 mainps(); 
    }
}






