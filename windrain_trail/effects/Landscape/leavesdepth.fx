
texture tTX0;


matrix matTotal; //matWorld*matView*matProj;
matrix matWorldView; //matWorld*matView
matrix matWorld;

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};

vector _vecEye;


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

	float fNear=_vecBackBufDesc.z;
	float fFar=_vecBackBufDesc.w;
	
    // Transform the vertex into projection space. 
    Output.hpos = mul( v.pos, matTotal );

	Output.uv = v.uv;
    
	Output.dist = length( mul(v.pos,matWorld).xyz - _vecEye.xyz );

	Output.dist = (Output.dist-fNear) / (fFar-fNear);

	Output.dist = saturate(Output.dist);
    
    return Output;
};


sampler texbase=sampler_state {
	Texture = <tTX0>;
};



float4 psmain( VS_OUTPUT v ) : COLOR0
{
	float4 base=tex2D(texbase,v.uv);

	float4 color = float4( floor(v.dist*255)/255, fmod(v.dist*255,1), 0, base.a );

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
  AlphaRef=0x88;
  AlphaFunc=GreaterEqual;

   }
}