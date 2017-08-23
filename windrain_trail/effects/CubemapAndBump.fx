texture tTX0;
texture tTX1;
texture tTX2;

sampler texbase=sampler_state {	Texture = <tTX0>; };
sampler cubemap=sampler_state { Texture = <tTX1>; };
sampler texnormal=sampler_state { Texture = <tTX2>; };


matrix matWorld;
matrix matTotal; //matWorld*matView*matProj;


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};


struct VS_OUTPUT
{
   float4 Pos       : POSITION;
   float4 Diffuse : COLOR0;
   float3 uv : TEXCOORD0;

   float3 i : TEXCOORD1; // eye to vertex pos in world space
  
  // world space tbn
   float3 tan : TEXCOORD2;
   float3 bin : TEXCOORD3;
   float3 n : TEXCOORD4;
 
};



VS_OUTPUT mainvs (float4 vPosition: POSITION, float3 n: NORMAL, float3 vTexCoord0 : TEXCOORD0, float4 vDiffuse: COLOR0, float3 bin: BINORMAL, float3 tan: TANGENT )
{
   VS_OUTPUT Out = (VS_OUTPUT) 0; 

   // Align quad with the screen
   Out.Pos = mul(vPosition, matTotal);
   Out.Diffuse = vDiffuse;
   // Output TexCoord0 directly
   Out.uv = vTexCoord0;


   float3 p = mul(float4(vPosition.xyz,1),matWorld); //vertex pos in world space
   Out.i = p - _vecEye;

   Out.tan =	normalize( mul(tan,(float3x3)matWorld) );
   Out.bin =	normalize( mul(bin,(float3x3)matWorld) );
   Out.n =	normalize( mul(n,(float3x3)matWorld) );

   return Out;
}



float4 mainps (VS_OUTPUT i) : COLOR
{
   // compute the 3x3 tranform from tangent space to world space; ( vector = mul(vector, matrix) )
   // if use it "backwards" ( vector = mul(matrix, vector) ), then will transform from world space to tangent space;
   float3x3 TBN;
   TBN[0] = i.tan;
   TBN[1] = i.bin;
   TBN[2] = i.n;

   float4 bumpNormal = tex2D(texnormal, i.uv);
   bumpNormal.xyz = bumpNormal.xyz * 2 - 1;

   float3 n = normalize( mul(bumpNormal.xyz,TBN) ); // world space normal

   float3 r = reflect(i.i, n );

   float4 base = tex2D(texbase,i.uv);
//   float gray = dot(base, float3(0.299f,0.587f,0.114f));
//   gray = saturate( gray+0.3 );
 //  gray*=0.1f;

   float4 specular = texCUBE(cubemap, r);
   return base*i.Diffuse + specular*base.a;
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






