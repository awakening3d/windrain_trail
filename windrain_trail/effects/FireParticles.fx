texture tTX0;
texture tTX1;


vector _vecAppTime;

matrix matWorld;
matrix matTotal; //matWorld*matView*matProj;
matrix matViewProj; //matView*matProj

matrix matView;
float particleSystemShape = 1;
float particleSpread = 20;
float particleSpeed = 0.48;
float particleSystemHeight = 80;
float particleSize = 7.8;
// The model for the particle system consists of a hundred quads.
// These quads are simple (-1,-1) to (1,1) quads where each quad
// has a z ranging from 0 to 1. The z will be used to differenciate
// between different particles

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};

VS_OUTPUT mainvs(float4 Pos: POSITION,float2 vTexCoord0 : TEXCOORD0){
   VS_OUTPUT Out;

   // Loop particles
   float t = frac(Pos.z + particleSpeed * _vecAppTime.x);
   // Determine the shape of the system
   float s = pow(t, particleSystemShape);

   float3 pos;
   // Spread particles in a semi-random fashion
   pos.x = particleSpread * s * cos(62 * Pos.z);
   pos.z = particleSpread * s * sin(163 * Pos.z);
   // Particles goes up
   pos.y = particleSystemHeight * t;
   

	float3 vRight = {matView[0].x,matView[1].x,matView[2].x,};
	float3 vUp = {matView[0].y,matView[1].y,matView[2].y,};
   // Billboard the quads.
   // The view matrix gives us our right and up vectors.
   pos += particleSize * (Pos.x * vRight + Pos.y * vUp);
   // And put the system into place
   float3 particleSystemPosition = matWorld[3];
   pos += particleSystemPosition;

   Out.Pos = mul(float4(pos,1),matViewProj);
   Out.texCoord = Pos.xy;
   Out.color = 1 - t;
   

   return Out;
}








sampler Flame=sampler_state { Texture = <tTX0>; };

float particleShape=0.37;

float4 mainps(float2 texCoord: TEXCOORD0, float color: TEXCOORD1) : COLOR {
   // Fade the particle to a circular shape
   float fade = pow(dot(texCoord, texCoord), particleShape);
   return (1 - fade) * tex2D(Flame, float2(color,0.5f));
}






technique T0
{
    pass P0
    {          
		ZWriteEnable=False;
		CullMode=None;
		AlphaBlendEnable=True;
		SrcBlend=One;
		DestBlend=One;
        // Any other effect state can be set here.
        VertexShader = compile vs_1_1 mainvs();
        PixelShader  = compile ps_2_0 mainps();
    }
}






