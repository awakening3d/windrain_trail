matrix matTotal; //matWorld*matView*matProj;
matrix matWorld; //matWorld

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};


#define MAX_LIGHTNUM 4

int _nShadowLightNum=MAX_LIGHTNUM;

vector _vShadowLightPos[MAX_LIGHTNUM]; //{ x,y,z, range }
vector _vShadowColor={0,0,0,0};


struct VS_INPUT {
  float4 pos    : POSITION;
};   
   
struct VS_OUTPUT
{
    float4	hpos   : POSITION;  // vertex position 
	float3  lightvec[MAX_LIGHTNUM] : TEXCOORD0;
    float4	dist     : TEXCOORD7; // distance from vertex to light
};


VS_OUTPUT vsmain( const VS_INPUT v )
{
    VS_OUTPUT o;
	
	float fNear=_vecBackBufDesc.z;
	float fFar=_vecBackBufDesc.w;

    // Transform the vertex into projection space. 
    o.hpos = mul( v.pos, matTotal );
	float3 verpos = mul( v.pos, matWorld);
	//o.dist=1;
	for (int i = 0; i < _nShadowLightNum; i++) {
		 o.lightvec[i] = verpos-_vShadowLightPos[i].xyz;
		 float len=length(o.lightvec[i]);

		 //o.lightvec[i]/=len;

		 len = (len-fNear) / (fFar-fNear);
		 o.dist[i] = len-0.01f;
	}
    return o;
};


sampler cubeShadowMap;

float4 psmain( VS_OUTPUT i ) : COLOR0
{
	float col=1;
	for (int n = 0; n < _nShadowLightNum; n++) {
		float depth=texCUBE(cubeShadowMap, i.lightvec[n])[n];
		if ( i.dist[n] > depth ) { //ÔÚÒõÓ°Çø
			col-=0.25f;
		}
	}
	
//return texCUBE(cubeShadowMap, i.lightvec[0])[0];

	if (col>=1) discard;
	return _vShadowColor*(col+0.5);
}



technique T0
{
   pass P0
   {
   VertexShader = compile vs_3_0 vsmain(); 
   PixelShader  = compile ps_3_0 psmain();

   ALPHABLENDENABLE=True;
   SRCBLEND=Zero;
   DESTBLEND=SRCCOLOR;
   }
}