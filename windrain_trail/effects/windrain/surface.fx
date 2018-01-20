#include "..\include\atmosphere.fx"

//--- system variables, player feed value ----

//texture tTXn (n = 0..7)

texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;
texture tTX4;
texture tTX5;




matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};

bool _bSpecularEnable=true;
float _fSpecularPower=8;
vector _vDiffuseColor={1.0f,1.0f,1.0f,1.0f};
vector _vSpecularColor={1.0f,1.0f,1.0f,1.0f};



struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : TEXCOORD6;     // vertex diffuse color
	float3 Specular   : TEXCOORD7;     // vertex specular color

	float2 uv		: TEXCOORD0;
	float2 uv1		: TEXCOORD1;
	float2 uv2		: TEXCOORD2;
	float3 l		: TEXCOORD3; //light vector in texture space
    float3 h		: TEXCOORD4; //half vector in texture space
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0, float2 uv1: TEXCOORD1,float3 n: NORMAL, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT o;

	ATMO_VS_OUTPUT atmo=atmosphere(vPosition,_vecEye,matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;


   o.Pos = mul(float4(vPosition,1), matTotal);

	o.uv=uv;
	o.uv1=uv;
	o.uv2=uv1;


	n=normalize(n);

    // compute the 3x3 tranform from tangent space to object space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from object 
    //   space to tangent space, though.
    float3x3 objToTangentSpace;
    objToTangentSpace[0] = tan;
    objToTangentSpace[1] = bin;
    objToTangentSpace[2] = n;

    o.l = normalize(mul(objToTangentSpace, vSunDir)); //light vector in texture space

	float3 v2eye=_vecEye-vPosition.xyz;
	v2eye=normalize(v2eye);

	float3 h=v2eye+vSunDir;
	h=normalize(h);

    o.h = normalize(mul(objToTangentSpace, h)); //half vector in texture space


	return o;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};

//base decal map
sampler texBase=sampler_state {
	Texture = <tTX0>;
	AddressU=Wrap;
	AddressV=Wrap;
	MIPFILTER=Point;
};

//normal map
sampler texNormal=sampler_state {
	Texture = <tTX1>;
	AddressU=Wrap;
	AddressV=Wrap;
	MIPFILTER=Point;
};


//light map
sampler texLightmap=sampler_state {
	Texture = <tTX2>;
	AddressU=Clamp;
	AddressV=Clamp;
	MIPFILTER=Point;
};




PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;

	float3 curColor;
	//---- base layer ----
	float3 rgbBase = tex2D(texBase, In.uv);
	// lightmap
	float3 rgbLightmap = tex2D(texLightmap, In.uv2);


	float specular = 0;

	if (_bSpecularEnable) {
		//specular=saturate( dot(bumpNormal.xyz, In.h) );
		//specular = pow( specular, _fSpecularPower );
		//specular *= fSpecularMap;
	}


	curColor = rgbBase;

	//lighting
	//curColor = curColor * diffuse + specular;
	curColor *= rgbLightmap;


	//---- atmosphere ----
	curColor*=In.Diffuse; 
	curColor+=In.Specular;


	//------ final color ----
	Out.Color.rgb = curColor;
	Out.Color.a=1;

	return Out;
};




technique T0
{
  pass P0
  {
    VertexShader = compile vs_2_0 mainvs();
    PixelShader  = compile ps_2_0 mainps();

  } // of pass0
}
