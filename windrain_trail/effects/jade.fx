matrix matWorld;
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldView; //matWorld*matView
matrix matWorldInv; //Inverse World Matrix


matrix matLightView;
//matrix matproj;

vector diffusecolor={1,1,1,1};
vector specularcolor={1,1,1,1};

vector vFactor={1,1,0.2,0}; //exp factor1, exp factor2, diffuse weight(0~1)

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecLight={0.0f,0.0f,0.0f,1.0f};
vector _vecObjParam; //(ObjRadius,DistanceToLight,0,0)

sampler decalmap;

struct VS_INPUT {
  float4 pos    : POSITION;
  float3 normal : NORMAL;
  float2 uv		: TEXCOORD0;
};   
   
struct VS_OUTPUT
{
    float4	hpos   : POSITION;  // vertex position
    float4	uv    : TEXCOORD0;
    float4 worldpos : TEXCOORD1;
    float	dist    : TEXCOORD2; // distance from light
};


VS_OUTPUT vsmain( const VS_INPUT v )
{
    VS_OUTPUT Output;
	
    // Transform the vertex into projection space. 
    Output.hpos = mul( v.pos, matTotal );
    
    float4 p=mul( v.pos, matWorld );
    
    Output.worldpos=p;
    Output.dist = length(mul(p,matLightView));

    
    //p=mul(p,matLightView);
    //p=mul(p,matproj);
    //p.x = p.x*0.5 + 0.5*p.w;
    //p.y = p.y*-0.5 + 0.5*p.w;
    
   
    vector lightpos=mul(_vecLight,matWorldInv);
	float3 ldir = normalize(float3(lightpos.x,lightpos.y,lightpos.z)-float3(v.pos.x,v.pos.y,v.pos.z));
		
	//diffuse
	p.z=dot(ldir,v.normal);
	p.z=abs(p.z)*vFactor.z+(1-vFactor.z);
	
	vector eyepos=mul(_vecEye,matWorldInv);
	float3 edir = normalize(float3(eyepos.x,eyepos.y,eyepos.z)-float3(v.pos.x,v.pos.y,v.pos.z));
	
	float3 halfvec=normalize(ldir+edir); //half vector
	//specluar
	p.w=dot(halfvec,v.normal);
	p.w=clamp(p.w,0,1);
	p.w = pow(p.w, specularcolor.w); 
      
      
    p.x=v.uv.x;
    p.y=v.uv.y;
    
    Output.uv = p;
    
    return Output;
};



float4 psmain( VS_OUTPUT v ) : COLOR0
{
	float4 base = tex2D(decalmap,v.uv);
	//return base;
	
	float dist=length( mul(v.worldpos,matLightView) );
	dist-=(_vecObjParam.y-_vecObjParam.x); //distance to light
	dist/=_vecObjParam.x; //object size
	
	float c=(dist-1);
	c=exp(-c*vFactor.x)*vFactor.y;
	
	c=c*v.uv.z;
	
	return base*diffusecolor*c+specularcolor*v.uv.w;
}




technique T0
{
   pass P0
   {
   VertexShader = compile vs_2_0 vsmain(); 
   PixelShader  = compile ps_2_0 psmain(); 
   }
}