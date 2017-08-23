texture tTX0;
texture tTX1;
texture tTX2;

matrix matProjInv; //Inverse Projection Matrix
matrix matViewInv; //Inverse View Matrix
matrix matWorldInv; //Inverse World Matrix

matrix matWorld; //World Matrix
matrix matWorldView; //matWorld*matView


matrix matTotal; //matWorld*matView*matProj;

matrix matView;
matrix matProj;

matrix matShadowViewProj;

vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)

vector _vecLight; // position of light0
vector _vecLightColor; // color of light0


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float2 uv1 : TEXCOORD1;
   float4 Diffuse    : COLOR0;
};


VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0)
{
	VS_OUTPUT Out;
  
	//position
	Out.Pos = mul(pos, matTotal);


	//uv	
	float4 uvp = mul(pos, matWorld);
	uvp = mul( uvp, matShadowViewProj );
	uvp/=uvp.w;
	uvp.x=uvp.x/2+0.5;
	uvp.y=-uvp.y/2+0.5;

	Out.uv = uvp.xy;
	Out.uv1 = uv;

	
	//normal
	n=normalize(n);

	float3 eye=mul(_vecEye,matWorldInv);
	float3 v2eye=eye-pos.xyz;
	//v2eye=normalize(v2eye);

	float ne=dot(n,v2eye);
	if (ne<0) n=-n;


	//light0
	float3 lpos=mul(_vecLight,matWorldInv);
	float3 v2l=lpos-pos.xyz;
	v2l=normalize(v2l);

	float nxl=dot(n,v2l);

	if (nxl<0) nxl*=-0.7; //pass from back face

	Out.Diffuse=nxl*_vecLightColor;

	return Out;
};



sampler shadowtex;

sampler texbase=sampler_state {
	Texture = <tTX0>;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};

PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;
	float4 shadow=tex2D(shadowtex,In.uv);
	float4 base=tex2D(texbase,In.uv1);

	Out.Color=shadow*In.Diffuse;
	Out.Color.a=base.a;

	return Out;
};


//pixel shader version
technique T0
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_1_1 mainvs();
        PixelShader  = compile ps_1_4 mainps();

		CullMode=None;

		AlphaTestEnable=True;
		AlphaRef=0x68;
		AlphaFunc=GreaterEqual;
    }
};



// no pixel shader
technique T1
{
    pass P0
    {          
        // Any other effect state can be set here.
        VertexShader = compile vs_1_1 mainvs();

		CullMode=None;

		Texture[1] = <tTX0>;
		ColorOp[1] = SelectArg2;
		ColorArg2[1] = Current;
		AlphaOp[1] = SelectArg1;
		AlphaArg1[1] = Texture;

		AlphaTestEnable=True;
		AlphaRef=0x68;
		AlphaFunc=GreaterEqual;
    }
};





