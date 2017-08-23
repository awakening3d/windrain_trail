matrix matTotal; //matWorld*matView*matProj;
matrix matWorldView; //matWorld*matView
matrix matViewProj; //matView*matProj
matrix matView;
matrix matWorld;


bool _bInstancing; //instancing

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};



struct VS_INPUT {
	float4 pos    : POSITION;
	float4 vInstanceMatrix1 : TEXCOORD1;
	float4 vInstanceMatrix2 : TEXCOORD2;
	float4 vInstanceMatrix3 : TEXCOORD3;
};   
   
struct VS_OUTPUT
{
    float4	hpos   : POSITION;  // vertex position 
    float	dist    : TEXCOORD0; // distance from eye
};


VS_OUTPUT vsmain( const VS_INPUT v )
{
    VS_OUTPUT Output;
	
	float fNear=_vecBackBufDesc.z;
	float fFar=_vecBackBufDesc.w;

	if (_bInstancing) {
		// We've encoded the 4x3 world matrix in a 3x4, so do a quick transpose so we can use it in DX
		float4 row1 = float4(v.vInstanceMatrix1.x,v.vInstanceMatrix2.x,v.vInstanceMatrix3.x,0);
		float4 row2 = float4(v.vInstanceMatrix1.y,v.vInstanceMatrix2.y,v.vInstanceMatrix3.y,0);
		float4 row3 = float4(v.vInstanceMatrix1.z,v.vInstanceMatrix2.z,v.vInstanceMatrix3.z,0);
		float4 row4 = float4(v.vInstanceMatrix1.w,v.vInstanceMatrix2.w,v.vInstanceMatrix3.w,1);
		float4x4 mInstanceMatrix = float4x4(row1,row2,row3,row4);
		matWorld=mInstanceMatrix;
	}

    // Transform the vertex into projection space. 
	float4 pos=mul(float4(v.pos.xyz,1),matWorld); //pos in world space
	Output.hpos=mul(pos,matViewProj);
 
    Output.dist = mul( pos, matView).z;

	Output.dist = (Output.dist-fNear) / (fFar-fNear);

	Output.dist = saturate(Output.dist);
    
    return Output;
};



float4 psmain( VS_OUTPUT v ) : COLOR0
{
    float4 color = float4(v.dist,v.dist,v.dist,v.dist);
    return color;
}



technique T0
{
   pass P0
   {
   VertexShader = compile vs_2_0 vsmain(); 
   PixelShader  = compile ps_1_1 psmain();
   CullMode=None;
   }
}