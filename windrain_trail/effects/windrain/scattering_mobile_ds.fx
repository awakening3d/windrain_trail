#include "..\include\atmosphere.fx"

matrix matWorld; //World Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matView;

vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)

vector _vAmbientColor; // material's ambient color

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;

   float3 Diffuse    : COLOR0;
   float3 Specular   : COLOR1;
};


VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT o;
  
	float3 posWorld=mul(pos,matWorld);

	ATMO_VS_OUTPUT atmo=atmosphere( posWorld.xyz, _vecEye, matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;

	o.Pos = mul(pos, matTotal);
	o.uv = uv;
	
	n=mul(n,(float3x3)matWorld);
	n=normalize(n);

	float3 v2eye=_vecEye-posWorld.xyz;
	v2eye=normalize(v2eye);

	float ne=dot(n,v2eye);
	if (ne<0) n=-n;

	//light0
	float3 v2l=vSunDir;
	float diffuse = dot(n, v2l);

	float3 h=v2eye+v2l;
	h=normalize(h);
	float specular =  dot(n, h)*.5;
	specular = pow( saturate(specular), 16);

	//light1
	v2l=float3(0,1,0);
	diffuse += dot(n,v2l);

	o.Diffuse *= diffuse*.5;
	o.Specular += specular;
	return o;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};


sampler texbase;


PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;
	float4 base=tex2D(texbase,In.uv);

	Out.Color = base;
	Out.Color.xyz*= (In.Diffuse+_vAmbientColor);
	Out.Color.xyz+=In.Specular;
	return Out;
};



technique T0
{
    pass P0
    {
	  AlphaTestEnable=True;
	  AlphaRef=0x40;
	  AlphaFunc=GreaterEqual;

	CullMode=None;

        // Any other effect state can be set here.
        VertexShader = compile vs_2_0 mainvs();
        PixelShader  = compile ps_2_0 mainps();

    }
};

