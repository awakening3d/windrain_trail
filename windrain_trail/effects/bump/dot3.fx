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
   float4 Diffuse    : COLOR0;
   float4 Specular   : COLOR1;
};


VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT Out;
  
	Out.Pos = mul(pos, matTotal);
	Out.uv = uv;
	
	n=normalize(n);

    // compute the 3x3 tranform from tangent space to object space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from object 
    //   space to tangent space, though.
    float3x3 objToTangentSpace;
    objToTangentSpace[0] = tan;
    objToTangentSpace[1] = bin;
    objToTangentSpace[2] = n;


	float3 eye=mul(_vecEye,matWorldInv);
	float3 v2eye=eye-pos.xyz;
	v2eye=normalize(v2eye);

	//Out.e = normalize(mul(objToTangentSpace, v2eye)); //eye vector in texture space

	float ne=dot(n,v2eye);
	if (ne<0) n=-n;

	Out.n = n;


	//light0
	float3 lpos=mul(_vecLight,matWorldInv);
	float3 v2l=lpos-pos.xyz;
	v2l=normalize(v2l);

    Out.l = normalize(mul(objToTangentSpace, v2l)); //light vector in texture space

	float nxl=dot(n,v2l);

	float3 h=v2eye+v2l;
	h=normalize(h);

    Out.h = normalize(mul(objToTangentSpace, h)); //half vector in texture space

	float nxh= dot(n,h);
	nxh = pow( saturate(nxh), 4 );

	if (nxl<0) nxl*=-0.7;

	//Out.Diffuse=nxl*_vecLightColor;
	//Out.Specular=nxh*_vecLightColor;


	//light1
	lpos=mul(_vecLight1,matWorldInv);
	v2l=lpos-pos.xyz;
	v2l=normalize(v2l);

	nxl=dot(n,v2l);

	h=v2eye+v2l;
	h=normalize(h);

	nxh=dot(n,h);
	nxh = pow( saturate(nxh), 4 );

	if (nxl<0) nxl*=-0.7;

	Out.Diffuse=nxl*_vecLightColor1;
	Out.Specular=nxh*_vecLightColor1;

	return Out;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};


sampler texbase=sampler_state {
	Texture = <tTX0>;
};

sampler texspec=sampler_state {
	Texture = <tTX1>;
};

sampler texnormal=sampler_state {
	Texture = <tTX2>;
};



float4 ambient=0.1;

PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;
	float4 base=tex2D(texbase,In.uv);
	float4 spec=tex2D(texspec,In.uv);


    //fetch bump normal and unpack it to [-1..1] range
    float3 bumpNormal = 2 * tex2D(texnormal, In.uv) - 1;

	float3 bn=bumpNormal;
	bumpNormal.x=-bn.x;
	bumpNormal.y=-bn.y;
	bumpNormal.z=bn.z;

    float diffuse = dot(bumpNormal, In.l);
	float specular =  dot(bumpNormal, normalize(In.h));

	//specular = dot( reflect(-In.e,bumpNormal), In.l );

	if (diffuse<0) diffuse*=-0.7;
	specular = pow( saturate(specular), 4 );

	float4 lightdif=_vecLightColor*diffuse;
	float4 lightspec= _vecLightColor*specular;

	lightdif += In.Diffuse;
	lightspec += In.Specular;

	lightdif=(lightdif);
	lightspec=(lightspec);

	Out.Color=base*lightdif+0.8*lightspec*spec+ambient;

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

		CullMode=None;

		AlphaTestEnable=True;
		AlphaRef=0x68;
		AlphaFunc=GreaterEqual;

		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
		AlphaBlendEnable = True;
    }
};







