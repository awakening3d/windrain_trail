#include "..\include\atmosphere.fx"

texture tTX0;
texture tTX1;

matrix matProjInv; //Inverse Projection Matrix
matrix matViewInv; //Inverse View Matrix
matrix matWorldInv; //Inverse World Matrix

matrix matWorld; //World Matrix
matrix matWorldView; //matWorld*matView


matrix matTotal; //matWorld*matView*matProj;

matrix matView;
matrix matProj;

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};

vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)

vector _vecLight; // position of light0
vector _vecLightColor; // color of light0

vector _vecLight1; // position of light1
vector _vecLightColor1; // color of light1


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float3 n : TEXCOORD1;

   float3 l : TEXCOORD2; //light vector in texture space
   float3 h : TEXCOORD3; //half vector in texture space

   float3 l1 : TEXCOORD4; //light vector in texture space
   //float3 h1 : TEXCOORD5; //half vector in texture space

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
	tan=mul(tan,(float3x3)matWorld);
	tan=normalize(tan);
	bin=mul(bin,(float3x3)matWorld);
	bin=normalize(bin);


    // compute the 3x3 tranform from tangent space to object space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from object 
    //   space to tangent space, though.
    float3x3 objToTangentSpace;
    objToTangentSpace[0] = tan;
    objToTangentSpace[1] = bin;
    objToTangentSpace[2] = n;


	float3 v2eye=_vecEye-posWorld.xyz;
	v2eye=normalize(v2eye);

	float ne=dot(n,v2eye);
	if (ne<0) n=-n;

	o.n = n;

	//light0
	float3 v2l=vSunDir;
    o.l = normalize(mul(objToTangentSpace, v2l)); //light vector in texture space

	float3 h=v2eye+v2l;
	h=normalize(h);

	o.h = normalize(mul(objToTangentSpace, h)); //half vector in texture space


	//light1
	v2l=float3(0,1,0);
    o.l1 = normalize(mul(objToTangentSpace, v2l)); //light vector in texture space

	//h=v2eye+v2l;
	//h=normalize(h);
	//o.h1 = normalize(mul(objToTangentSpace, h)); //half vector in texture space


	return o;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};


sampler texbase=sampler_state {
	Texture = <tTX0>;
	MIPFILTER=None;
};

sampler texnormal=sampler_state {
	Texture = <tTX1>;
	MIPFILTER=None;
};



float4 ambient=0.1;

PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;
	float4 base=tex2D(texbase,In.uv);
    float3 bumpNormal = 2 * tex2D(texnormal, In.uv) - 1;

    float diffuse = dot(bumpNormal, In.l);
	float specular =  dot(bumpNormal, normalize(In.h))*.5;
	specular = pow( saturate(specular), 16);

	diffuse += dot(bumpNormal, In.l1);

	float4 lightdif=_vecLightColor*diffuse*.5;
	float4 lightspec= _vecLightColor*specular;


	//lightdif += In.Diffuse;
	//lightspec += In.Specular;


	Out.Color=base*lightdif+lightspec;//+ambient;

	Out.Color.xyz*=In.Diffuse;
	Out.Color.xyz+=In.Specular;

	//Out.Color.xyz=In.Specular;
	
	Out.Color.a=base.a;

	return Out;
};



technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_2_0 mainvs();
        PixelShader  = compile ps_2_0 mainps();

    }
};

