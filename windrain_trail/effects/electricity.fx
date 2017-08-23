texture tTX0;


vector _vecAppTime;

matrix matTotal; //matWorld*matView*matProj;


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD;
};


VS_OUTPUT mainvs(float4 vPosition: POSITION, float2 vTexCoord0 : TEXCOORD0)
{
   VS_OUTPUT Out;
   
   Out.Pos = mul(vPosition, matTotal);
   Out.texCoord = sign(vTexCoord0-0.5);

   return Out;
};




float4 color=float4(0.68,0.48,1,1);
float glowStrength=144;
float height=0.44;
float glowFallOff=0.024;
float speed=1.86;
float sampleDist=0.0076;
float ambientGlow=0.5;
float ambientGlowHeightScale=1.68;
float vertNoise=0.78;

sampler Noise=sampler_state {
	Texture = <tTX0>;
 	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
	
};

float4 mainps(float2 texCoord: TEXCOORD) : COLOR {
	
   float2 t = float2(speed * _vecAppTime.x * 0.5871 - vertNoise * abs(texCoord.y), speed * _vecAppTime.x);

   // Sample at three positions for some horizontal blur
   // The shader should blur fine by itself in vertical direction
   float xs0 = texCoord.x - sampleDist;
   float xs1 = texCoord.x;
   float xs2 = texCoord.x + sampleDist;

   // Noise for the three samples
   float noise0 = tex3D(Noise, float3(xs0, t));
   float noise1 = tex3D(Noise, float3(xs1, t));
   float noise2 = tex3D(Noise, float3(xs2, t));

   // The position of the flash
   float mid0 = height * (noise0 * 2 - 1) * (1 - xs0 * xs0);
   float mid1 = height * (noise1 * 2 - 1) * (1 - xs1 * xs1);
   float mid2 = height * (noise2 * 2 - 1) * (1 - xs2 * xs2);

   // Distance to flash
   float dist0 = abs(texCoord.y - mid0);
   float dist1 = abs(texCoord.y - mid1);
   float dist2 = abs(texCoord.y - mid2);

   // Glow according to distance to flash
   float glow = 1.0 - pow(0.25 * (dist0 + 2 * dist1 + dist2), glowFallOff);

   // Add some ambient glow to get some power in the air feeling
   float ambGlow = ambientGlow * (1 - xs1 * xs1) * (1 - abs(ambientGlowHeightScale * texCoord.y));

  return (glowStrength * glow * glow + ambGlow) * color;
   

};





technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_1_1 mainvs();
        PixelShader  = compile ps_2_0 mainps();
    }
}






