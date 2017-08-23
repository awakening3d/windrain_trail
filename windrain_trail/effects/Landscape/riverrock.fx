//--- system variables, player feed value ----
#include "..\include\common.fx"
#include "..\include\atmosphere.fx"

//texture tTXn {n = 0..7}
texture tTX0;
texture tTX1;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};

vector _vecLight={0.0f,0.0f,0.0f,1.0f};
vector _vecLightColor={1.0f,1.0f,1.0f,1.0f};
dword _dwLightColor=0xffffffff;
vector _vecLightParam; // parameters of light0 ( range*range, 0, 0, 0 )

vector _vecLight1={0.0f,0.0f,0.0f,1.0f};
vector _vecLightColor1={1.0f,1.0f,1.0f,1.0f};
dword _dwLightColor1=0xffffffff;
vector _vecLightParam1; // parameters of light1 ( range*range, 0, 0, 0 )


bool _bSpecularEnable=true;
float _fSpecularPower=8;
vector _vDiffuseColor={1.0f,1.0f,1.0f,1.0f};
vector _vSpecularColor={1.0f,1.0f,1.0f,1.0f};


//---- user variables ---
vector vecOffset={-0.03f, -0.03f, -0.03f, 1.0f};
bool bNormalizeLV = false; //whether normalize lighting vector 在模型纹理拉伸接缝处归一化后光照错误明显
vector vecWaterParam = { -595, 0.1, 0, 0 }; // 水面高度，干湿过渡系数


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0; // u,v, 
   float3 vAtmoE : TEXCOORD1;
   float3 vAtmoI : TEXCOORD2;
   float4 vL : TEXCOORD3; //vL of light1
   float4 vH : TEXCOORD4; //vH of light1
   float3 vDistSq : TEXCOORD5; // x - distsq of light0; y -  distsq of light1; world space pos's y
   float4 Diffuse    : COLOR0; //vL
   float4 Specular   : COLOR1; //vH
};


VS_OUTPUT mainvs(float4 pos: POSITION, float4 vVerColor: COLOR0, float3 n: NORMAL, float2 uv: TEXCOORD0, float3 bin: BINORMAL, float3 tan: TANGENT, uniform bool bVS20=false)
{
	VS_OUTPUT o;
  
	o.Pos = mul(pos, matTotal);
	o.uv.xy = uv;
	
	tan =	normalize( mul(tan,(float3x3)matWorld) );
	bin =	normalize( mul(bin,(float3x3)matWorld) );
	n =		normalize( mul(n,(float3x3)matWorld) );

    // compute the 3x3 tranform from tangent space to world space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from world 
    //   space to tangent space, though.
    float3x3 matToTangentSpace;
    matToTangentSpace[0] = tan;
    matToTangentSpace[1] = bin;
    matToTangentSpace[2] = n;

	pos=mul(float4(pos.xyz,1),matWorld); //vertex pos in world space
	o.vDistSq.z = pos.y;

	ATMO_VS_OUTPUT atmo=atmosphere(pos,_vecEye,matView);
	if (bVS20) {
		o.vAtmoE=atmo.colorE*vVerColor.rgb;
		o.vAtmoI=atmo.colorI;
	} else {
		o.vAtmoE=vVerColor.rgb;
		o.vAtmoI=0;
	}

	float3 v2eye=_vecEye-pos.xyz;
	v2eye=normalize(v2eye);
	v2eye=normalize( mul(matToTangentSpace,v2eye) );
	o.vL.w = v2eye.x*0.2;
	o.vH.w = v2eye.y*0.2;

	//light0
	float3 v2l=_vecLight-pos.xyz;
	o.vDistSq.x=dot(v2l,v2l);
	v2l=normalize(v2l);

    o.Diffuse.xyz = normalize(mul(matToTangentSpace, v2l)); //light vector in texture space

	float3 h=v2eye+v2l;
	h=normalize(h);

    o.Specular.xyz = normalize(mul(matToTangentSpace, h)); //half vector in texture space


	//light1
	if (bVS20) {
		v2l=_vecLight1-pos.xyz;
		o.vDistSq.y=dot(v2l,v2l);
		v2l=normalize(v2l);
		o.vL.xyz = normalize(mul(matToTangentSpace, v2l)); //light vector in texture space
		h=v2eye+v2l;
		h=normalize(h);
		o.vH.xyz = normalize(mul(matToTangentSpace, h)); //half vector in texture space
	} else {
		o.vDistSq.y = 0;
		o.vL.xyz=0;
		o.vH.xyz=0;
	}

	o.Diffuse.xyz = o.Diffuse.xyz * .5 + .5; // map -1, 1 to 0, 1
	o.Diffuse.w=1;

	o.Specular.xyz = o.Specular.xyz * .5 + .5; // map -1, 1 to 0, 1
	o.Specular.w=1;

	return o;
};



sampler texbase=sampler_state {
	Texture = <tTX0>;
	MipFilter = Point;
};

sampler texnormal=sampler_state {
	Texture = <tTX1>;
	MipFilter = Point;
};




float4 mainps(VS_OUTPUT i, uniform float fSpecularPower=8, uniform bool bPS20=false) : COLOR0
{
    float4 bumpNormal = tex2D(texnormal, i.uv);

	float height=vecOffset.x*bumpNormal.a;
	if (bPS20) i.uv.xy+= float2(i.vL.w, i.vH.w)*height;

	float4 base=tex2D(texbase,i.uv);
    //fetch bump normal and unpack it to [-1..1] range
	bumpNormal = tex2D(texnormal, i.uv);
	bumpNormal.xyz = bumpNormal.xyz * 2 - 1;

	float3 vL=i.Diffuse.xyz * 2 -1;
	float3 vH=i.Specular.xyz * 2 -1;

	if (bNormalizeLV && bPS20) {
		vL=normalize(vL);
		vH=normalize(vH);
	}

	//light0
	float4 lightdif = 0;
	float4 lightspec = 0;

	float diffuse = saturate( dot(bumpNormal, vL) );
	float fAtten =1;
	if (bPS20) {
		fAtten=saturate((_vecLightParam.x-i.vDistSq.x)/_vecLightParam.x);
		diffuse *= fAtten;
	}
	
	lightdif += _vecLightColor*diffuse;

	if (_bSpecularEnable && bPS20) {
		float specular =  saturate( dot(bumpNormal, vH) );
		specular = pow( saturate(specular), fSpecularPower );
		specular *= fAtten;
		specular *= base.a;  // specular map
		lightspec += _vecLightColor*specular;
	}
	
	//light1
	if (bPS20) {

		if (bNormalizeLV) {
			i.vL=normalize(i.vL);
			i.vH=normalize(i.vH);
		}

		diffuse = saturate( dot(bumpNormal, i.vL) );

		fAtten=saturate((_vecLightParam1.x-i.vDistSq.y)/_vecLightParam1.x);
		diffuse *= fAtten;
		lightdif += _vecLightColor1*diffuse;
		
		if (_bSpecularEnable) {
			float specular =  saturate( dot(bumpNormal, i.vH) ) * bumpNormal.a;
			specular = pow( saturate(specular), fSpecularPower );
			specular *= fAtten;
			specular *= base.a;  // specular map
			lightspec += _vecLightColor1*specular;
		}
	}

	float fwet = saturate( (i.vDistSq.z - vecWaterParam.x) * vecWaterParam.y );
	lightdif *= (fwet*0.5+0.5);
	fwet = 1.0 - fwet;
	lightspec *= fwet;
	
	float4 color = base * lightdif/**_vDiffuseColor*/ + lightspec;//*_vSpecularColor;

	if (bPS20) {
		color.rgb *= i.vAtmoE;
		color.rgb +=i.vAtmoI;
	}


	color.a=1;
	return color;
};


//---- T0 ---- ps 2.0
technique T0
{
  pass P1
  {
     VertexShader = compile vs_2_0 mainvs(true);
     PixelShader  = compile ps_2_0 mainps(_fSpecularPower,true);
  }
} //of technique T0


//----- T1 --- ps 1.4
technique T1
{
  pass P1
  {
     VertexShader = compile vs_1_1 mainvs();
     PixelShader  = compile ps_1_4 mainps();
  }
} //of technique T1


//--- T2 ---- no ps
technique T2
{
  pass P2 //diffuse x texture
  {
  SpecularEnable=False;

  TextureFactor = <_dwLightColor>;

  // stage0
  ColorOp[0] = DotProduct3;
  Texture[0] = <tTX1>;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;

  Texture[1] = <tTX0>;

  // stage 2
  ColorOp[2] = Modulate;
  ColorArg1[2] = TFactor;
  ColorArg2[2] = Current;

  // stage3
  ColorOp[3] = Disable;

	// vertex shader
	// vertex shader constant
	VertexShader = compile vs_1_1 mainvs();

  } // of pass2

} //of technique T2