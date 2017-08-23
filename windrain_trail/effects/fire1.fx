texture tTX0;
texture tTX1;
texture tTX2;



float distortion_amount2=0.0723;
float4 height_attenuation={0.44,0.29,0,1};
float distortion_amount1=0.091;
float distortion_amount0=0.123;

sampler fire_base=sampler_state { Texture = <tTX0>; };
sampler fire_distortion=sampler_state { Texture = <tTX1>; };
sampler fire_opacity=sampler_state { Texture = <tTX2>; };


float4 layer_speed={0.68,0.52,0.75,1};

vector _vecAppTime;


matrix matTotal; //matWorld*matView*matProj;


struct VS_OUTPUT
{
   float4 Pos       : POSITION;
   float3 TexCoord0 : TEXCOORD0;
   float3 TexCoord1 : TEXCOORD1;
   float3 TexCoord2 : TEXCOORD2;
   float3 TexCoord3 : TEXCOORD3;
};



VS_OUTPUT mainvs (float4 vPosition: POSITION, int dwColor : COLOR, float3 vTexCoord0 : TEXCOORD0)
{
   VS_OUTPUT Out = (VS_OUTPUT) 0; 

   // Align quad with the screen
   Out.Pos = mul(vPosition, matTotal);

   // Output TexCoord0 directly
   Out.TexCoord0 = vTexCoord0;

	float ftime=_vecAppTime.x;
	
   // Base texture coordinates plus scaled time
   Out.TexCoord1.x = vTexCoord0.x;
   Out.TexCoord1.y = vTexCoord0.y + layer_speed.x * ftime;

   // Base texture coordinates plus scaled time
   Out.TexCoord2.x = vTexCoord0.x;
   Out.TexCoord2.y = vTexCoord0.y + layer_speed.y * ftime;

   // Base texture coordinates plus scaled time
   Out.TexCoord3.x = vTexCoord0.x;
   Out.TexCoord3.y = vTexCoord0.y + layer_speed.z * ftime;

   return Out;
}





// Bias and double a value to take it from 0..1 range to -1..1 range
float4 bx2(float x)
{
   return 2.0f * x - 1.0f;
}

float4 mainps (float4 tc0 : TEXCOORD0, float4 tc1 : TEXCOORD1,
             float4 tc2 : TEXCOORD2, float4 tc3 : TEXCOORD3) : COLOR
{
   // Sample noise map three times with different texture coordinates
   float4 noise0 = tex2D(fire_distortion, tc1);
   float4 noise1 = tex2D(fire_distortion, tc2);
   float4 noise2 = tex2D(fire_distortion, tc3);

   // Weighted sum of signed noise
   float4 noiseSum = bx2(noise0) * distortion_amount0 + bx2(noise1) * distortion_amount1 + bx2(noise2) * distortion_amount2;

   // Perturb base coordinates in direction of noiseSum as function of height (y)
   float4 perturbedBaseCoords = tc0 + noiseSum * (tc0.y * height_attenuation.x + height_attenuation.y);
   
   if (perturbedBaseCoords.y<0) perturbedBaseCoords.y=0;

   // Sample base and opacity maps with perturbed coordinates
   float4 base = tex2D(fire_base, perturbedBaseCoords);
   float4 opacity = tex2D(fire_opacity, perturbedBaseCoords);

   return base * opacity;
}



technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
       
       
        VertexShader = compile vs_1_1 mainvs();
        PixelShader  = compile ps_1_4 mainps(); 
    }
}






