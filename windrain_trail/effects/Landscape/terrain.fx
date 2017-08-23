#include "..\include\atmosphere.fx"

//--- system variables, player feed value ----

//texture tTXn (n = 0..7)

texture tTX0;
texture tTX1;
texture tTX2;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix


vector _vecEye={0.0f,1000.0f,0.0f,1.0f};


	float3 vGreenColor={0.3,1,0.3};
	float3 vStoneColor={.25,.21,.22};
	float fGreenUV=256;
	float fStoneUV=8;






struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : TEXCOORD6;     // vertex diffuse color
	float3 Specular   : TEXCOORD7;     // vertex specular color

	float2 uv		: TEXCOORD0;
	float2 uv1		: TEXCOORD1;
	float2 uv2		: TEXCOORD2;
	float3 l		: TEXCOORD3; //light vector in texture space
    float3 h		: TEXCOORD4; //half vector in texture space
	float3 up		: TEXCOORD5; //up vector in texture space
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


	o.up = normalize(mul(objToTangentSpace, float3(0,1,0))); //up vector in texture space
	o.up *= (1-step(vPosition.y,500)); //under water check
	


	return o;
};


struct PS_OUTPUT
{
    float4 Color : COLOR;
};


sampler texDecal=sampler_state {
	Texture = <tTX0>;
};

sampler texNormal=sampler_state {
	Texture = <tTX1>;
};



PS_OUTPUT mainps(VS_OUTPUT In)
{
	PS_OUTPUT Out;
	
    //fetch bump normal and unpack it to [-1..1] range
    float3 stoneNormal = tex2D(texNormal, In.uv*fStoneUV);
	float3 greenNormal = tex2D(texDecal, In.uv*fGreenUV);
	//float shadow=tex2D(texNormal, In.uv).a;
	stoneNormal = 2 * stoneNormal - 1;
	greenNormal = 2 * greenNormal - 1;

    float diffuse = saturate( dot(stoneNormal.xyz, In.l) ); //*shadow;
	float diffuse2 = saturate( dot(greenNormal.xyz, In.l) ); //*shadow;

	float col =  saturate( dot(stoneNormal.xyz, float3(-0.05f, 0.8f, 0.6f)) );
	//vStoneColor=lerp(vStoneColor,float3(1,1,1),pow(col,4));
	vStoneColor*=pow(col,4)*4;

	float specular =  saturate( dot(stoneNormal.xyz, In.h) );
	specular = pow( specular, 32 );


	float up=saturate( dot(stoneNormal.xyz, In.up) );
	specular*=(1-up);

	float3 greencolor=vGreenColor*diffuse2; //*greenNormal.a;
	float3 stonecolor=vStoneColor*diffuse+specular;
	float3 decal=lerp(stonecolor,greencolor,up);

	Out.Color.xyz=decal;
	Out.Color.xyz*=In.Diffuse;
	Out.Color.xyz+=In.Specular;

	//Out.Color.xyz=In.Specular;

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
