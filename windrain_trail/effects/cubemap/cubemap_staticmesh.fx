texture tTX0;
texture tTX1;

sampler texbase=sampler_state {	Texture = <tTX0>; };
sampler cubemap=sampler_state { Texture = <tTX1>; };


matrix matTotal; //matWorld*matView*matProj;


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};


struct VS_OUTPUT
{
   float4 Pos       : POSITION;
   float4 Diffuse : COLOR0;
   float3 uv : TEXCOORD0;
   float3 uvcube : TEXCOORD1;
};



VS_OUTPUT mainvs (float4 vPosition: POSITION, float3 n: NORMAL, float3 vTexCoord0 : TEXCOORD0, float4 vDiffuse: COLOR0, float3 bin: BINORMAL, float3 tan: TANGENT )
{
   VS_OUTPUT Out = (VS_OUTPUT) 0; 

   // Align quad with the screen
   Out.Pos = mul(vPosition, matTotal);
   Out.Diffuse = vDiffuse;
   // Output TexCoord0 directly
   Out.uv = vTexCoord0;

   float3 p = vPosition.xyz; //vertex pos in world space
   p = p - _vecEye;

   n = normalize(n);

   Out.uvcube = reflect( p, n);

   return Out;
}



float4 mainps (VS_OUTPUT i) : COLOR
{
   float4 base = tex2D(texbase,i.uv);
   float gray = dot(base, float3(0.299f,0.587f,0.114f));
   float4 specular = texCUBE(cubemap, i.uvcube);
//   gray = clamp( gray+0.3, 0, 1 );
   gray*=0.4f;
   return base*i.Diffuse + specular*gray;
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






