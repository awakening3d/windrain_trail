#include "..\include\atmosphere.fx"

//--- system variables, player feed value ----

//texture tTXn (n = 0..7)

texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;
texture tTX4;
texture tTX5;
texture tTX6;
texture tTX7;


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


float fBaseUV=64;
float fLayer1UV=512;
float fLayer2UV=256;
float fLayer3UV=256;
float fLayer4UV=256;
float fNormalUV=1024;




struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : TEXCOORD6;     // vertex diffuse color
	float3 Specular   : TEXCOORD7;     // vertex specular color

	float2 uv		: TEXCOORD0;
	float2 uv1		: TEXCOORD1;
	float2 uv2		: TEXCOORD2;
	float3 l		: TEXCOORD3; //light vector in texture space
    float3 h		: TEXCOORD4; //half vector in texture space
	float4 up		: TEXCOORD5; //up vector in texture space
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0, float3 n: NORMAL, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT o;

	ATMO_VS_OUTPUT atmo=atmosphere(vPosition,_vecEye,matView);
	o.Diffuse=atmo.colorE;
	o.Specular=atmo.colorI;


   o.Pos = mul(float4(vPosition,1), matTotal);

	o.uv=uv;
	o.uv1=uv;
	o.uv2=uv;


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


	o.up.xyz = n;
	o.up.w = n.y; //顶点法向量斜率
	


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
};

//mask map
sampler texMask=sampler_state {
	Texture = <tTX1>;
	AddressU=Clamp;
	AddressV=Clamp;
};

// decal map 1
sampler texLayer1=sampler_state {
	Texture = <tTX2>;
	AddressU=Wrap;
	AddressV=Wrap;
};

// decal map 2
sampler texLayer2=sampler_state {
	Texture = <tTX3>;
	AddressU=Wrap;
	AddressV=Wrap;
};

// decal map 3
sampler texLayer3=sampler_state {
	Texture = <tTX4>;
	AddressU=Wrap;
	AddressV=Wrap;
};

// decal map 4
sampler texLayer4=sampler_state {
	Texture = <tTX5>;
	AddressU=Wrap;
	AddressV=Wrap;
};


//normal map
sampler texNormal=sampler_state {
	Texture = <tTX6>;
	AddressU=Wrap;
	AddressV=Wrap;
	MIPFILTER=Point;
};

//light map
sampler texLightmap=sampler_state {
	Texture = <tTX7>;
	AddressU=Clamp;
	AddressV=Clamp;
};


PS_OUTPUT mainps(VS_OUTPUT i, uniform float fSpecularPower=8, uniform bool bPS20=false)
{
	PS_OUTPUT Out;

	float3 curColor;
	float3 rgbLayer;
	float fMask;

	//---- public maps ----
	float4 maskmap	= tex2D(texMask,i.uv);
	float3 lightmap = tex2D(texLightmap,i.uv);
	//normal map
    float3 bumpNormal = tex2D(texNormal, i.uv*fNormalUV);
	bumpNormal.xyz = bumpNormal.xyz * 2 - 1;


	//---- base layer ----
	float3 rgbBase = tex2D(texBase, i.uv*fBaseUV);


    //float diffuse = saturate( dot(i.up.xyz, vSunDir) );

    float diffuse = saturate( dot(bumpNormal, i.l) );
	float specular = 0;

	if (_bSpecularEnable && bPS20) {
		specular =  saturate( dot(bumpNormal, i.h) );
		specular = pow( specular, fSpecularPower );
	}


	curColor = rgbBase*2;

	//---- layer 1 ----
	rgbLayer = tex2D( texLayer1, i.uv * fLayer1UV);
	fMask = saturate(i.up.w*i.up.w); //maskmap.r;
	curColor = lerp( curColor, rgbLayer, fMask );

	//---- layer 2 ----
	rgbLayer = tex2D( texLayer2, i.uv * fLayer2UV);
	fMask=maskmap.g;
	curColor = lerp( curColor, rgbLayer, fMask );
/*
	//---- layer 3 ----
	rgbLayer = tex2D( texLayer3, i.uv * fLayer3UV);
	fMask=maskmap.b;
	curColor = lerp( curColor, rgbLayer, fMask );

	//---- layer 4 ----
	rgbLayer = tex2D( texLayer4, i.uv * fLayer4UV);
	fMask=maskmap.a;
	curColor = lerp( curColor, rgbLayer, fMask );
*/

	//lighting
	curColor = curColor * diffuse + specular;

	curColor *= lightmap.rgb;


	//---- atmosphere ----
	curColor*=i.Diffuse; 
	curColor+=i.Specular;


	//------ final color ----
	Out.Color.rgb = curColor;
	Out.Color.a=1;

	//Out.Color.rgb = lightmap.rgb;

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
