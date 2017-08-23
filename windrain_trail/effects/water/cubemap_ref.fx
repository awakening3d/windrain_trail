texture tTX0;
texture tTX1;
texture tTX2;

sampler texbase=sampler_state {	Texture = <tTX0>; };
sampler cubemap=sampler_state { Texture = <tTX1>; };
sampler texnormal=sampler_state { Texture = <tTX2>; };


matrix matWorld;
matrix matTotal; //matWorld*matView*matProj;


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecAppTime={0.0f,0.0f,0.0f,0.0f};


struct VS_OUTPUT
{
   float4 Pos       : POSITION;
   float3 uv : TEXCOORD0;

   float3 i : TEXCOORD1; // eye to vertex pos in world space
   float3 p : TEXCOORD2; // vertex posiion in object space
};



VS_OUTPUT mainvs (float4 vPosition: POSITION, float3 vTexCoord0 : TEXCOORD0)
{
   VS_OUTPUT Out = (VS_OUTPUT) 0; 

   // Align quad with the screen
   Out.Pos = mul(vPosition, matTotal);
   // Output TexCoord0 directly
   Out.uv = vTexCoord0;


   float3 p = mul(float4(vPosition.xyz,1),matWorld); //vertex pos in world space
   Out.i = p - _vecEye;

   Out.p = vPosition;

   return Out;
}


float waveflat = 99;
float waveflat2 = 99;

float wavescale = 0.2;
float wavespeed = 8;

vector vOffset = {0,0,0,1};
vector vOffset2 = {0,0,0,1};

float3 calc_water_normal(float x, float z, float _waveflat)
{
   float3 n = normalize( float3(x,0,z) );

   float d = sqrt( x * x + z * z );
	
   float h = sin(d * wavescale - wavespeed*_vecAppTime.x);

   n.x *= h; n.y = 8*(1 - abs(h)) + _waveflat; n.z*=h;

   n = normalize(n);

   return n;
}


float4 mainps (VS_OUTPUT i, uniform bool bWave2 = false ) : COLOR
{
   float3 n = calc_water_normal( i.p.x + vOffset.x, i.p.z + vOffset.z, waveflat);
   if (bWave2) {
      float3 n2 = calc_water_normal( i.p.x + vOffset2.x, i.p.z + vOffset2.z, waveflat2);
      n = normalize( n + n2 );
   }

   float3 r = reflect(i.i, n );

   float4 reflect = texCUBE(cubemap, r); // reflect color

   r = refract(-i.i, n, 1.333);
   float4 refract = texCUBE(cubemap, r); // refract color

   float dnv=dot( normalize(-i.i), n); //vE.waternormal
   float3 refref = lerp(reflect,refract,dnv);


   float4 base = tex2D(texbase,i.uv);
   base.rgb += refref * base.a;

   return base;
}



technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_3_0 mainvs();
        PixelShader  = compile ps_3_0 mainps(true);
    }
}

technique T1
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_1_1 mainvs();
        PixelShader  = compile ps_2_0 mainps();
    }
}




