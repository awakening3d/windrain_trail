texture tTX0;

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

DWORD dwAlphaRef=0x68;


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float3 n : TEXCOORD1;
   float4 Diffuse    : COLOR0;
   float4 Specular   : COLOR1;
};


VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0)
{
	VS_OUTPUT Out;
  
	Out.Pos = mul(pos, matTotal);
	Out.uv = uv;
	
	n=normalize(n);

	float3 eye=mul(_vecEye,matWorldInv);
	float3 v2eye=eye-pos.xyz;
	v2eye=normalize(v2eye);

	float ne=dot(n,v2eye);
	if (ne<0) n=-n;

	Out.n = n;


	//light0
	float3 lpos=mul(_vecLight,matWorldInv);
	float3 v2l=lpos-pos.xyz;
	v2l=normalize(v2l);

	float nxl=dot(n,v2l);

	float3 h=v2eye+v2l;
	h=normalize(h);

	float nxh= dot(n,h);
	nxh = pow( saturate(nxh), 8 );

	if (nxl<0) nxl*=-0.7;

	Out.Diffuse=nxl*_vecLightColor;
	Out.Specular=nxh*_vecLightColor;


	//light1
	lpos=mul(_vecLight1,matWorldInv);
	v2l=lpos-pos.xyz;
	v2l=normalize(v2l);

	nxl=dot(n,v2l);

	h=v2eye+v2l;
	h=normalize(h);

	nxh=dot(n,h);
	nxh = pow( saturate(nxh), 8 );

	if (nxl<0) nxl*=-0.7;

	Out.Diffuse+=nxl*_vecLightColor1;
	Out.Specular+=nxh*_vecLightColor1;

	return Out;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};


sampler texbase=sampler_state {
	Texture = <tTX0>;
};



float4 ambient=0.1;

PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;
	float4 base=tex2D(texbase,In.uv);

	Out.Color=base*In.Diffuse+In.Specular/2+ambient;
	
	Out.Color.a=base.a;

	return Out;
};



technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_1_1 mainvs();
        PixelShader  = compile ps_1_1 mainps();

		CullMode=None;

		AlphaTestEnable=True;
		AlphaRef=<dwAlphaRef>;
		AlphaFunc=GreaterEqual;

		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
		AlphaBlendEnable = True;
    }
};

