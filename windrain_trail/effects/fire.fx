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


float sideFade=18.6;
float sideFadeSharpness=0.05;
float wobbleScale=0.03;
float burnSpeed=0.57;
float randomnessRate=0.24;
float yFade=0.6;
float xScale=1.5;
float yScale=0.6;


float4 mainps(float2 texCoord: TEXCOORD0) : COLOR 
{
   // Wobble for the noise to get a more realistic appearance
   float wobbX = 2 * cos(6 * texCoord.x + _vecAppTime.x);
   float wobbY = 7 * (1 - texCoord.y) * (1 - texCoord.y);
   float wobble = sin(_vecAppTime.x + wobbX + wobbY);
   // Alternative approach
   //   float wobble = 9 * (2 * tex3D(Noise, float3(texCoord * 0.4, 0.2 * _vecAppTime.x)) - 1);

   float3 coord;
   // Wobble more in the flames than at the base
   coord.x = xScale * texCoord.x + wobbleScale * (texCoord.y + 1) * wobble;
   // Create an upwards movement
   coord.y = yScale * texCoord.y - burnSpeed * _vecAppTime.x;
   // Move in Z to get some randomness
   coord.z = randomnessRate * _vecAppTime.x;
   float noisy = tex3D(Noise, coord);

   // Define the shape of the fire
   float t = sideFadeSharpness * (1 - sideFade * texCoord.x * texCoord.x);

   // Get the color out of it all
   float heat = saturate(t + noisy - yFade * texCoord.y);
   float4 flame = tex1D(Flame, heat);

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






