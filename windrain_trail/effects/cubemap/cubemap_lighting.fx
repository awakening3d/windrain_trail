texture tTX0;

sampler cubemap=sampler_state { Texture = <tTX0>; };

matrix matTotal; //matWorld*matView*matProj;


struct VS_OUTPUT
{
   float4 Pos       : POSITION;
   float3 TexCoord0 : TEXCOORD0;
   float3 TexCoord1 : TEXCOORD1;
};



VS_OUTPUT mainvs (float4 vPosition: POSITION, float3 vNormal: NORMAL, float3 vTexCoord0 : TEXCOORD0)
{
   VS_OUTPUT Out = (VS_OUTPUT) 0; 

   // Align quad with the screen
   Out.Pos = mul(vPosition, matTotal);

   // Output TexCoord0 directly
   Out.TexCoord0 = vTexCoord0;
   Out.TexCoord1 = vNormal;
   return Out;
}





float4 mainps (float4 tc0 : TEXCOORD0, float4 tc1 : TEXCOORD1  ) : COLOR
{
   // Sample noise map three times with different texture coordinates
   float4 diffuse = texCUBE(cubemap, tc1);

   return diffuse;
   //return base * diffuse;
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






