
texture tTX0;


matrix matTotal; //matWorld*matView*matProj;
matrix matWorldView; //matWorld*matView
float fNear=10;
float fFar=900;


DWORD dwAlphaRef=0x68;


struct VS_INPUT {
	float4 pos    : POSITION;
	float2	uv		: TEXCOORD0;
};   
   
struct VS_OUTPUT
{
    float4	hpos   : POSITION;  // vertex position 
	float2	uv		: TEXCOORD0;
    float	dist    : TEXCOORD1; // distance from light
};


VS_OUTPUT vsmain( const VS_INPUT v )
{
    VS_OUTPUT Output;
	
    // Transform the vertex into projection space. 
    Output.hpos = mul( v.pos, matTotal );

	Output.uv = v.uv;
    
    Output.dist = mul( v.pos, matWorldView).z;

	Output.dist = (Output.dist-fNear) / (fFar-fNear);

	Output.dist = clamp(Output.dist,0,1);
    
    return Output;
};


sampler texbase=sampler_state {
	Texture = <tTX0>;
};



float4 psmain( VS_OUTPUT v ) : COLOR0
{
	float4 base=tex2D(texbase,v.uv);

    float4 color = float4(v.dist,v.dist,v.dist,base.a);
    return color;
}



technique T0
{
   pass P0
   {
   VertexShader = compile vs_1_1 vsmain(); 
   PixelShader  = compile ps_2_0 psmain();
   CullMode=None;

		AlphaTestEnable=True;
		AlphaRef=<dwAlphaRef>;
		AlphaFunc=GreaterEqual;

		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
		AlphaBlendEnable = True;

   }
}