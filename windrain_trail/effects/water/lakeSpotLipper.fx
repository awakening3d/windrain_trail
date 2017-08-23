#include "..\include\atmosphere.fx"

matrix matWorld; //World Matrix
matrix matView; //View Matrix
matrix matProj; //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv; //Inverse View Matrix
matrix matWorldView; //matWorld*matView


texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;
texture tTX4;


vector commonConst = { 0.0f,  0.5f, 1.0f, 2.0f };

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecLight={0.0f,0.0f,0.0f,1.0f};

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};

vector _vecAppTime={0.0f,0.0f,0.0f,0.0f};

vector vecWaterColor={.1,.2,.1,1};

vector vecWaterNormal={0.0f,1.0f,0.0f,1.0f};
vector vecWaterParam = {0.1f, 9.0f, 0.5f, 0.0f}; // x - wave speed, y - bump, z - bump uv scale

vector vecOceanPos = {0,0,0,100}; // xyz: ocean position, w: ocean UV Scale

vector _vecUserData = {0,0,0,0}; // userdata from root
float fRippleStrength = 0.7;

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float4 uv : TEXCOORD0;
   float4 uv1 : TEXCOORD1;
   float	dist    : TEXCOORD2; // distance from eye
   float3	vE    : TEXCOORD3; // vertex to eye vector

	float3 Diffuse    : TEXCOORD6;     // scatting E
	float3 Specular   : TEXCOORD7;     // scatting I

};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0)
{
	VS_OUTPUT Out;

	Out.Pos = mul(float4(vPosition,1), matTotal);

	vPosition = mul(float4(vPosition,1), matWorld).xyz;

	Out.uv1.zw = uv;

	//根据ocean的position和UV Scale计算bump贴图uv坐标
	float3 result = vPosition - vecOceanPos.xyz;
	float fUVScale = vecOceanPos.w;
	uv.x = (result.x)*fUVScale/10000;
	uv.y = -(result.z)*fUVScale/10000;

	ATMO_VS_OUTPUT atmo=atmosphere(vPosition,_vecEye,matView);
	Out.Diffuse=atmo.colorE;
	Out.Specular=atmo.colorI;

	Out.vE=_vecEye.xyz-vPosition;
	//Out.vE=normalize(Out.vE); //要在pixelshader里做，不然靠近水面会出现裂缝

   Out.uv = Out.Pos;//Out.Pos.w;
   Out.uv.x=Out.uv.x*0.5+0.5*Out.Pos.w;
   Out.uv.y=-Out.uv.y*0.5+0.5*Out.Pos.w;

	//float3 vUVOfs = mul( vecWaterNormal.xyz, (float3x3)matView ); //water normal in view space
	//vUVOfs=normalize(vUVOfs);


	//Out.uv.x += -vUVOfs.x*2/_vecBackBufDesc.x * (1-Out.dnv);
	//Out.uv.y += -vUVOfs.y*2/_vecBackBufDesc.y * (1-Out.dnv);

   float fMaxWH=max(_vecBackBufDesc.x,_vecBackBufDesc.y);

   Out.uv1.xy = uv * vecWaterParam.z;


	Out.dist = length( vPosition - _vecEye.xyz );

//    Out.dist = mul( float4(vPosition,1), matWorldView).z;

	//float fNear=_vecBackBufDesc.z;
	//float fFar=_vecBackBufDesc.w;
	//Out.dist = (Out.dist-fNear) / (fFar-fNear); //除法要在pixelshader里做，不然靠近水面会出现裂缝
	//Out.dist = saturate(Out.dist);


   return Out;
};

sampler texReflect=sampler_state {
	Texture = <tTX0>;
 	AddressU = CLAMP;
	AddressV = CLAMP;
};

sampler texRefract=sampler_state {
	Texture = <tTX1>;
 	AddressU = CLAMP;
	AddressV = CLAMP;
};

sampler texDepth=sampler_state {
	Texture = <tTX2>;
 	AddressU = CLAMP;
	AddressV = CLAMP;
};

sampler texBump=sampler_state {
	Texture = <tTX3>;
	MIPFILTER=None;
};

sampler texRipple=sampler_state {
	Texture = <tTX4>;
 	AddressU = CLAMP;
	AddressV = CLAMP;
	MIPFILTER=None;
};

float4 mainps(VS_OUTPUT In) : COLOR0
{
	float4 OutColor;

	float fNear=_vecBackBufDesc.z;
	float fFar=_vecBackBufDesc.w;
	In.dist = (In.dist-fNear) / (fFar-fNear);
	In.dist = saturate(In.dist);

	float4 depthcol=tex2Dproj(texDepth,In.uv);

	//float depth = (depthcol.r*255*256 + depthcol.g*255)/65535;
	float depth = depthcol.r + depthcol.g/255;

	float fWaterDepth=depth-In.dist;

	float dnv=dot( normalize(In.vE), vecWaterNormal); //vE.waternormal

	float4 bump=tex2D(texBump,In.uv1.xy+_vecAppTime.x*vecWaterParam.x)*0.1;
	float4 ripple= tex2D(texRipple,In.uv1.zw);
	ripple.xy *= fRippleStrength * _vecUserData.x;

	float2 uvofs=(bump.xy*vecWaterParam.y) * saturate( (1-In.dist*8) );

	depth=fWaterDepth;
	depth*=32;
	depth-=0.1;
	depth=saturate(depth);
	depth*=depth;
	//depth*=depth;


	float2 uv = In.uv.xy/In.uv.w;
	if (dnv>=0) uv.y=1-uv.y; //above water
	uv+=uvofs*depth;
	uv+= ripple.xy;

	float4 refract=tex2D(texRefract,uv);
	float4 reflect=tex2D(texReflect,uv);

	float4 watercolor = vecWaterColor * vecWaterColor.a;

	watercolor.xyz*=In.Diffuse;
	watercolor.xyz+=In.Specular;
	
	if (dnv>0) { //在水面上
		refract=lerp(refract,watercolor,depth);
		OutColor=lerp(refract,reflect, (1-dnv)*depth);
	} else {
		OutColor=refract;
	}


//Out.Color=dnv;
//	fWaterDepth = fWaterDepth*64;
//	fWaterDepth *= 	fWaterDepth;
//	fWaterDepth = saturate(fWaterDepth);

	//OutColor = depth;
	OutColor.a= (ripple.x+ripple.y)/0.5+0.05;


	return OutColor;
};




technique T0
{
  pass P0
  {
	VertexShader = compile vs_3_0 mainvs();
	PixelShader  = compile ps_3_0 mainps();
	CullMode=None;
	ZWriteEnable = False;
	DepthBias=-0.00002f; //0xb7a7c5ac;

	AlphaTestEnable=True;
	AlphaRef=0x08;
	AlphaFunc=GreaterEqual;

	//SrcBlend = SrcAlpha;
	//DestBlend = InvSrcAlpha;
	//AlphaBlendEnable = True;
  }
}


