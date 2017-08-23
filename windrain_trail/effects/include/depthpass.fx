#include ".\common.fx"

matrix matTotal; //matWorld*matView*matProj;
matrix matWorld; //World Matrix
matrix matViewProj; //matView*matProj

bool _bInstancing = false; //instancing

vector _vecEye;

  
struct VS_OUTPUT
{
    float4	Pos   : POSITION;  // vertex position
	float3	pos   : TEXCOORD0; // vertex position in world space
};


VS_OUTPUT mainvs(float4 pos: POSITION, //float3 n: NORMAL, float2 uv: TEXCOORD0,
                         float4 vInstanceMatrix1 : TEXCOORD1,
                         float4 vInstanceMatrix2 : TEXCOORD2,
                         float4 vInstanceMatrix3 : TEXCOORD3 )
{
	VS_OUTPUT o;
  
	if (_bInstancing) {
		// We've encoded the 4x3 world matrix in a 3x4, so do a quick transpose so we can use it in DX
		float4 row1 = float4(vInstanceMatrix1.x,vInstanceMatrix2.x,vInstanceMatrix3.x,0);
		float4 row2 = float4(vInstanceMatrix1.y,vInstanceMatrix2.y,vInstanceMatrix3.y,0);
		float4 row3 = float4(vInstanceMatrix1.z,vInstanceMatrix2.z,vInstanceMatrix3.z,0);
		float4 row4 = float4(vInstanceMatrix1.w,vInstanceMatrix2.w,vInstanceMatrix3.w,1);
		matWorld = float4x4(row1,row2,row3,row4);

		o.pos = mul(pos, matWorld); //vertex pos in world space
		o.Pos = mul( float4(o.pos,1), matViewProj);
	} else {
		o.pos = mul(pos, matWorld); //vertex pos in world space
		o.Pos = mul(pos, matTotal);
	}

    return o;
};



float4 mainps( VS_OUTPUT i ) : COLOR0
{	
	float dist = length( i.pos.xyz - _vecEye.xyz );
	return encode_depth(dist);
}



technique T0
{
   pass P0
   {
   VertexShader = compile vs_3_0 mainvs(); 
   PixelShader  = compile ps_3_0 mainps();
   CullMode=None;
   }
}

technique T1
{
   pass P0
   {
   VertexShader = compile vs_2_0 mainvs(); 
   PixelShader  = compile ps_2_0 mainps();
   CullMode=None;
   }
}