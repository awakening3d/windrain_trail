matrix matWorld;
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldView; //matWorld*matView
matrix matWorldInv; //Inverse World Matrix


matrix matLightView;
//matrix matproj;

bool _bSpecularEnable; // whether enable specular lighting
float _fSpecularPower; // specifying the sharpness of specular highlights
vector _vSpecularColor; // material's specular color
vector _vDiffuseColor; // material's diffuse color


vector vFactor={1,1,0.2,0}; //exp factor1, exp factor2, diffuse weight(0~1)

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecLight={0.0f,0.0f,0.0f,1.0f};
vector _vecLightColor; // color of light0


sampler decalmap;

struct VS_INPUT {
  float4 pos    : POSITION;
  float3 normal : NORMAL;
  float4 diffuse: COLOR0;
  float2 uv		: TEXCOORD0;
};   
   
struct VS_OUTPUT
{
	float4	hpos   : POSITION;  // vertex position
	float4	diffuse: COLOR0;
	float4	uv    : TEXCOORD0;
	float3	n    : TEXCOORD1;
	float3 halfvec : TEXCOORD2;
};


VS_OUTPUT vsmain( const VS_INPUT v )
{
    VS_OUTPUT Output;
	
    // Transform the vertex into projection space. 
    Output.hpos = mul( v.pos, matTotal );
    
    float4 p=mul( v.pos, matWorld );
    
    vector lightpos=mul(_vecLight,matWorldInv);
	float3 ldir = normalize(float3(lightpos.x,lightpos.y,lightpos.z)-float3(v.pos.x,v.pos.y,v.pos.z));
		
	//diffuse
	p.z=dot(ldir,v.normal);
	p.z=abs(p.z)*vFactor.z+(1-vFactor.z);
	
	if (_bSpecularEnable) {
		vector eyepos=mul(_vecEye,matWorldInv);
		float3 edir = normalize(float3(eyepos.x,eyepos.y,eyepos.z)-float3(v.pos.x,v.pos.y,v.pos.z));
		
		Output.halfvec=normalize(ldir+edir); //half vector
		Output.n = v.normal;
		//specluar
		//p.w=dot(halfvec,v.normal);
		//p.w=clamp(p.w,0,1);
		//p.w = pow(p.w, _fSpecularPower); 
	}
      
    p.x=v.uv.x;
    p.y=v.uv.y;
    
    Output.uv = p;
    Output.diffuse = v.diffuse;
    
    return Output;
};



float4 psmain( VS_OUTPUT v ) : COLOR0
{
	float4 base = tex2D(decalmap,v.uv);
	//return base;
	//c=c*v.uv.z;
	base = base*_vDiffuseColor * v.diffuse;

	if (_bSpecularEnable) {
		float fspecular = dot( v.halfvec, v.n);
		fspecular=clamp(fspecular,0,1);
		fspecular = pow(fspecular, _fSpecularPower); 

		base += _vSpecularColor*fspecular*_vecLightColor;
	}
	return base;
}




technique T0
{
   pass P0
   {
   VertexShader = compile vs_2_0 vsmain(); 
   PixelShader  = compile ps_2_0 psmain(); 
   }
}