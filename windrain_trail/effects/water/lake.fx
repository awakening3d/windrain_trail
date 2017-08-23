#include "..\include\common.fx"

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


vector _vecAppTime={0.0f,0.0f,0.0f,0.0f};

vector _vDiffuseColor={.1,.4,.4,1};

vector vecWaterNormal={0.0f,1.0f,0.0f,1.0f};

vector __vFactor = {0.1f, 1.0f, 0.0f, 1.0f}; // x: wave speed, y: depth power, z: depth offset, w: bump


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float4 uv : TEXCOORD0;
   float2 uv1 : TEXCOORD1;
   float	dist    : TEXCOORD2; // distance from eye
   float3	vE    : TEXCOORD3; // vertex to eye vector
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0)
{
	VS_OUTPUT Out;

	//float time=_vecAppTime.x*4;
	//vPosition.y+= ( sin(vPosition.x/10+time) + sin(vPosition.z/10+time) ) *4;

    Out.Pos = mul(float4(vPosition,1), matTotal);

	Out.vE=_vecEye.xyz-vPosition;
	//Out.vE=normalize(Out.vE); //要在pixelshader里做，不然靠近水面会出现裂缝


   Out.uv = Out.Pos;//Out.Pos.w;
   Out.uv.x=Out.uv.x*0.5+0.5*Out.Pos.w;
   Out.uv.y=-Out.uv.y*0.5+0.5*Out.Pos.w;

	//float3 vUVOfs = mul( vecWaterNormal.xyz, (float3x3)matView ); //water normal in view space
	//vUVOfs=normalize(vUVOfs);


	//Out.uv.x += -vUVOfs.x*2/_vecBackBufDesc.x * (1-Out.dnv);
	//Out.uv.y += -vUVOfs.y*2/_vecBackBufDesc.y * (1-Out.dnv);


   Out.uv1=uv;


    Out.dist = length( Out.vE );

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


float4 mainps(VS_OUTPUT In) : COLOR0
{

	float fNear=_vecBackBufDesc.z;
	float fFar=_vecBackBufDesc.w;
	In.dist = (In.dist-fNear) / (fFar-fNear);
	In.dist = saturate(In.dist);

	float fdepth = decode_depth( tex2Dproj(texDepth,In.uv) );
	float fWaterDepth = fdepth  -In.dist;


	float dnv=dot( normalize(In.vE), vecWaterNormal); //vE.waternormal


	float4 bump=tex2D(texBump,In.uv1+_vecAppTime.x*__vFactor.x)*0.1;

	float2 uvofs=(bump.xy * __vFactor.w) * saturate( (1-In.dist*8) );

	fWaterDepth *= _vDiffuseColor.a*100;
	fWaterDepth -= __vFactor.z;
	fWaterDepth = saturate( fWaterDepth );
	fWaterDepth = pow( fWaterDepth,  __vFactor.y );
	
	float2 uv = In.uv.xy/In.uv.w;
	if (dnv>=0) uv.y=1-uv.y; //above water
	uv+=uvofs*fWaterDepth;

	float4 refract=tex2D(texRefract,uv);
	float4 reflect=tex2D(texReflect,uv);



	float4 watercolor = _vDiffuseColor;
	
	float4 outcolor;

	if (dnv>0) { //在水面上
		refract=lerp(refract,watercolor,fWaterDepth);
		outcolor=lerp(reflect,refract,dnv);
	} else {
		outcolor=refract;
	}


//Out.Color=dnv;
	outcolor.a=1;

	return outcolor;
};




technique T0
{
  pass P0
  {
	VertexShader = compile vs_2_0 mainvs();
    PixelShader  = compile ps_2_0 mainps();
	CullMode=None;
  }
}


