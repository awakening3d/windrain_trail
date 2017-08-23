//--- system variables, player feed value ----
#include "..\include\common.fx"

//texture tTXn {n = 0..7}
texture tTX0;
texture tTX1;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matViewProj; //matView*matProj
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
vector _vAmbientColor={0,0,0,0};


bool _bInstancing; //instancing


//---- user variables ---
vector vecOffset={-0.03f, -0.03f, -0.03f, 1.0f};



struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float2 uv1 : TEXCOORD1;
   //float3 vE : TEXCOORD2;
   float3 vL : TEXCOORD3; //vL of light1
   float3 vH : TEXCOORD4; //vH of light1
   float2 vDistSq : TEXCOORD5; // x - distsq of light0; y -  distsq of light1
   float4 Diffuse    : COLOR0; //vL
   float4 Specular   : COLOR1; //vH
};


VS_OUTPUT mainvs(float4 pos: POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0, float3 bin: BINORMAL, float3 tan: TANGENT,
                         float4 vInstanceMatrix1 : TEXCOORD1,
                         float4 vInstanceMatrix2 : TEXCOORD2,
                         float4 vInstanceMatrix3 : TEXCOORD3 )

{
	VS_OUTPUT o;
  
	if (_bInstancing) {
		// We've encoded the 4x3 world matrix in a 3x4, so do a quick transpose so we can use it in DX
		float4 row1 = float4(vInstanceMatrix1.x,vInstanceMatrix2.x,vInstanceMatrix3.x,0);
		float4 row2 = float4(vInstanceMatrix1.y,vInstanceMatrix2.y,vInstanceMatrix3.y,0);
		float4 row3 = float4(vInstanceMatrix1.z,vInstanceMatrix2.z,vInstanceMatrix3.z,0);
		float4 row4 = float4(vInstanceMatrix1.w,vInstanceMatrix2.w,vInstanceMatrix3.w,1);
		float4x4 mInstanceMatrix = float4x4(row1,row2,row3,row4);

		matWorld=mInstanceMatrix;
	}

	float4 worldpos = mul( pos ,matWorld);
	o.Pos= mul( worldpos, matViewProj );
	//o.Pos = mul(pos, matTotal);
	o.uv = uv;
	o.uv1 = uv;
	
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

	float3 v2eye=_vecEye-pos.xyz;
	v2eye=normalize(v2eye);
	//o.vE=normalize( mul(matToTangentSpace,v2eye) );

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



sampler texnormal=sampler_state {
	Texture = <tTX0>;
};

sampler texbase=sampler_state {
	Texture = <tTX1>;
};



float4 mainps(VS_OUTPUT i, uniform float fSpecularPower=8, uniform bool bPS20=false) : COLOR0
{
    float4 bumpNormal = tex2D(texnormal, i.uv);

	//float height=vecOffset.x*bumpNormal.a;
	//i.uv+=i.vE.xy*height;

	float4 base=tex2D(texbase,i.uv);
    //fetch bump normal and unpack it to [-1..1] range
	//bumpNormal = tex2D(texnormal, i.uv);
	bumpNormal.xyz = bumpNormal.xyz * 2 - 1;


	float3 vL=i.Diffuse.xyz * 2 -1;
	float3 vH=i.Specular.xyz * 2 -1;

	//light0
    float diffuse = saturate( dot(bumpNormal, vL) );

	float4 lightdif=_vecLightColor*diffuse;
	float fAtten=1;
	if (bPS20) {
		lightdif*=_vDiffuseColor;
		//fAtten = saturate((_vecLightParam.x-i.vDistSq.x)/_vecLightParam.x) / _vecLightParam.y;
		float D = sqrt(i.vDistSq.x);
		fAtten = 1.0f / (_vecLightParam.y + D*_vecLightParam.z + i.vDistSq.x*_vecLightParam.w);;
	}
	float4 color = base * (lightdif*fAtten + _vAmbientColor);

	if (_bSpecularEnable) {
		float specular =  saturate( dot(bumpNormal, vH) );
		specular = pow( saturate(specular), fSpecularPower );
		float4 lightspec= _vecLightColor*specular;
		if (bPS20) lightspec*=_vSpecularColor;
		color+=lightspec*fAtten;
	}
	
	//light1
	if (bPS20) {
		diffuse = saturate( dot(bumpNormal, i.vL) );

		lightdif=_vecLightColor1*diffuse * _vDiffuseColor;
		//fAtten = saturate((_vecLightParam1.x-i.vDistSq.y)/_vecLightParam1.x) / _vecLightParam.y;
		float D = sqrt(i.vDistSq.y);
		fAtten = 1.0f / (_vecLightParam1.y + D*_vecLightParam1.z + i.vDistSq.y*_vecLightParam1.w);;


		color+= base* (lightdif*fAtten + _vAmbientColor);

		if (_bSpecularEnable) {
			float specular =  saturate( dot(bumpNormal, i.vH) );
			specular = pow( saturate(specular), fSpecularPower );
			float4 lightspec= _vecLightColor1*specular * _vSpecularColor;
			color+=lightspec*fAtten;
		}
	}

	color.a=bumpNormal.a;

	return color;
};


//---- T0 ---- ps 2.0
technique T0
{
  pass P1
  {
     VertexShader = compile vs_2_0 mainvs();
     PixelShader  = compile ps_2_0 mainps(_fSpecularPower,true);

	AlphaTestEnable=True;
	AlphaRef=0x08;
	AlphaFunc=GreaterEqual;

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

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Texture;
  ColorArg2[1] = Current;

  Texture[1] = <tTX1>;

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