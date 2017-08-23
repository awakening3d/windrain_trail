//--- system variables, player feed value ----
#include "..\include\common.fx"
#include "..\include\shadow_common.fx"

//#include "..\include\atmosphere.fx"


bool _bBlendPass = false;

//texture tTXn {n = 0..7}
texture tTX0;
texture tTX1;
texture tTX2;
texture tTX3;

matrix matTotal; //matWorld*matView*matProj;
matrix matWorld; //World Matrix
matrix matView;  //View Matrix


// terrain
vector _decal_tile_param = { 512, 512, 0, 0 }; // nTileW, nTileH


//---- user variables ---
vector vecOffset={-0.06f, -0.03f, -0.03f, 1.0f};


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float4 uv : TEXCOORD0;
//   float3 atmoE : TEXCOORD1;
//   float3 atmoI : TEXCOORD2;
   float4 vE : TEXCOORD3;
   float3 vL : TEXCOORD4; //vL of light1
   float3 vH : TEXCOORD5; //vH of light1
   float2 vDistSq : TEXCOORD6; // x - distsq of light0; y -  distsq of light1
   float3 pos : TEXCOORD7; // vertex position in world space
   float4 Diffuse    : COLOR0; //vL
   float4 Specular   : COLOR1; //vH
};


VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT o;

//	ATMO_VS_OUTPUT atmo=atmosphere(pos,_vecEye,matView);
//	o.atmoE=atmo.colorE;
//	o.atmoI=atmo.colorI;

  
	o.Pos = mul(pos, matTotal);
	o.uv.xy = uv;
	
	tan =	normalize( mul(tan,(float3x3)matWorld) );
	bin =	normalize( mul(bin,(float3x3)matWorld) );
	n =		normalize( mul(n,(float3x3)matWorld) );

	o.uv.zw = n.xy;
	o.vE.w = n.z;

    // compute the 3x3 tranform from tangent space to world space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from world 
    //   space to tangent space, though.
    float3x3 matToTangentSpace;
    matToTangentSpace[0] = tan;
    matToTangentSpace[1] = bin;
    matToTangentSpace[2] = n;

	pos = mul(float4(pos.xyz,1),matWorld); //vertex pos in world space
	o.pos = pos;


	float3 v2eye=_vecEye-pos.xyz;
	v2eye=normalize(v2eye);
	o.vE.xyz = normalize( mul(matToTangentSpace,v2eye) );

	//light0
	float3 v2l=_vecLight-pos.xyz;
	o.vDistSq.x=dot(v2l,v2l);
	v2l=normalize(v2l);

    o.Diffuse.xyz = normalize(mul(matToTangentSpace, v2l)); //light vector in texture space

	float3 h=v2eye+v2l;
	h=normalize(h);

    o.Specular.xyz = normalize(mul(matToTangentSpace, h)); //half vector in texture space


	//light1
	v2l=_vecLight1-pos.xyz;
	o.vDistSq.y=dot(v2l,v2l);
	v2l=normalize(v2l);
	o.vL.xyz = normalize(mul(matToTangentSpace, v2l)); //light vector in texture space

	h=v2eye+v2l;
	h=normalize(h);
	o.vH.xyz = normalize(mul(matToTangentSpace, h)); //half vector in texture space

	o.Diffuse.xyz = o.Diffuse.xyz * .5 + .5; // map -1, 1 to 0, 1
	o.Diffuse.w=1;

	o.Specular.xyz = o.Specular.xyz * .5 + .5; // map -1, 1 to 0, 1
	o.Specular.w=1;

	return o;
};

sampler texalpha=sampler_state {
	Texture = <tTX0>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
	MIPFILTER = None;
};

sampler texbase=sampler_state {
	Texture = <tTX1>;
	ADDRESSU=Wrap;
	ADDRESSV=Wrap;
	MipFilter = Linear;
};

sampler texnormal=sampler_state {
	Texture = <tTX2>;
	ADDRESSU=Wrap;
	ADDRESSV=Wrap;
	MipFilter = Linear;
};

sampler texlightmap=sampler_state {
	Texture = <tTX3>;
	ADDRESSU=Clamp;
	ADDRESSV=Clamp;
};



float4 mainps(VS_OUTPUT i, uniform bool bPS20=false, uniform bool bPS30=false) : COLOR0
{
	float4 alphacol = tex2D(texalpha, i.uv.xy);
	float2 uv = i.uv.xy;
	uv.x *= _decal_tile_param.x;
	uv.y *= _decal_tile_param.y;


    float4 bumpNormal = tex2D(texnormal, uv);


	float height=vecOffset.x*bumpNormal.a;
	uv+=i.vE.xy*height;

    //fetch bump normal and unpack it to [-1..1] range
	bumpNormal = tex2D(texnormal, uv);
	bumpNormal.xyz = bumpNormal.xyz * 2 - 1;


	float3 vL=i.Diffuse.xyz * 2 -1;
	float3 vH=i.Specular.xyz * 2 -1;

	float3 diffuseL = 0;
	float3 specularL = 0;

	float3 normal = float3( i.uv.zw, i.vE.w );

	lighting2lbump( bPS20, bPS30, diffuseL, specularL, i.pos, normal, bumpNormal.xyz, bumpNormal.a, vL, vH, i.vL, i.vH );


	if (_bBlendPass) {
		if (bPS30) if ( dot(diffuseL,1) < 0.01 && dot(specularL,1) < 0.01 ) discard;
	} else {
		diffuseL += tex2D(texlightmap, i.uv.xy) + _vAmbientColor;
	}

	float4 base = tex2D(texbase,uv);
	base.rgb = base.rgb * diffuseL + specularL;
	base.a = alphacol.a;

	if (_bBlendPass) base.rgb *= alphacol.a;

	return base;
};


//---- T0 ---- ps 3.0
technique T1
{
  pass P1
  {
     VertexShader = compile vs_3_0 mainvs();
     PixelShader  = compile ps_3_0 mainps(true,true);
  }
} //of technique T0


//---- T1 ---- ps 2.0
technique T1
{
  pass P1
  {
     VertexShader = compile vs_2_0 mainvs();
     PixelShader  = compile ps_2_0 mainps(true);
  }
} //of technique T1
