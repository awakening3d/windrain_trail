#include "..\include\common.fx"

texture tTX0;
texture tTX1;
texture tTX2;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix
matrix matViewProj; //matView*matProj
bool _bInstancing; //instancing


vector appConst = {0.25f, 0.5f, 0.75f, 1.0f};

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};
vector _vecObjParam; //  ( Radius of mobile's bounding sphere, Distance to light, Distance to eye, 0 )

vector vBeta1Beta2 = {0.000196834f,0.000309775f,0.000594052,1};
vector vTerrainRef = {0.0138f,0.0138f,0.0138f,1};
vector vHG = {0.36f,1.8f,1.6f,1};
vector vBetaDash1 = {0.0000083f,0.000014f,0.000029f,1};
vector vBetaDash2 = {0.000013f,0.000017f,0.000024f,1};
vector vOneOverBeta = {5080.43f,3228.15f,1683.35f,1};
vector vTermMulti = {1,0.3,0,1};
vector vSunColor = {1,1,1,30.0f};
vector vSunDir = {-0.0471744f, 0.799484f, 0.598423f,1};

vector vSunny = {0.25f, 1.0f, 0.0f, 0.0f}; //x - brighter sky near horizen, y - distance scale


vector vSunDirNM = {0.0471744f,0.598423f,0.799484f,1};
DWORD dwSunDir=0xff85cbe5;

vector maxBright={0.3f,0.3f,0.3f,1};

bool _bSpecularEnable=true;
float _fSpecularPower=8;


struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : COLOR0;     // vertex diffuse color
	float3 Specular   : COLOR1;     // vertex specular color
	float2 uv		: TEXCOORD0;
	float2 uv1		: TEXCOORD1;
	float3 l		: TEXCOORD2; //light vector in texture space
	float3 h		: TEXCOORD3; //half vector in texture space
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0, float3 n: NORMAL, float3 bin: BINORMAL, float3 tan: TANGENT,
                         float4 vInstanceMatrix1 : TEXCOORD1,
                         float4 vInstanceMatrix2 : TEXCOORD2,
                         float4 vInstanceMatrix3 : TEXCOORD3 )

{
	VS_OUTPUT Out;

	
	if (_bInstancing) {
		// We've encoded the 4x3 world matrix in a 3x4, so do a quick transpose so we can use it in DX
		float4 row1 = float4(vInstanceMatrix1.x,vInstanceMatrix2.x,vInstanceMatrix3.x,0);
		float4 row2 = float4(vInstanceMatrix1.y,vInstanceMatrix2.y,vInstanceMatrix3.y,0);
		float4 row3 = float4(vInstanceMatrix1.z,vInstanceMatrix2.z,vInstanceMatrix3.z,0);
		float4 row4 = float4(vInstanceMatrix1.w,vInstanceMatrix2.w,vInstanceMatrix3.w,1);
		float4x4 mInstanceMatrix = float4x4(row1,row2,row3,row4);

		matWorld=mInstanceMatrix;
	}

	float4 pos=mul(float4(vPosition,1),matWorld);

	Out.Pos=mul(pos,matViewProj);

   float3 V = normalize( pos.xyz-_vecEye.xyz ); // V = position-eye

	// Angle (theta) between sun direction (L) and view direction (V).
	float VdotL=  saturate( dot(V,vSunDir) ); // [cos(theta)] = V.L
	float fTheta= 1 + VdotL*VdotL; // [1+cos^2(theta)] = Phase1(theta)

	// Distance (s)
	float fDistance=mul(float4(pos.xyz,1), matView).z;
	fDistance*=vSunny.y;

	// Terms used in the scattering equation.
	// r0 = [cos(theta), 1+cos^2(theta), s] 
	//float3 r0(VdotL,fTheta,fDistance);

	// Extinction term E
	float3 E1 = exp( -(vBeta1Beta2.xyz * fDistance) );  // e^(-(beta_1 + beta_2) * s) = E1

	// Apply Reflectance to E to get total net effective E
	float3 vE = E1*vTerrainRef; //E (Total extinction) 

	// Phase2(theta) = (1-g^2)/(1+g-2g*cos(theta))^(3/2)
	// theta is 180 - actual theta (this corrects for sign)
	// c[CV_HG] = [1-g^2, 1+g, 2g]
	float fTheta2 = vHG.x / pow( vHG.y - vHG.z*VdotL, 1.5);

	// Inscattering (I) = (Beta'_1 * Phase_1(theta) + Beta'_2 * Phase_2(theta)) * 
	//        [1-exp(-Beta_1*s).exp(-Beta_2*s)] / (Beta_1 + Beta_2)
	float3 vI=( vBetaDash1*fTheta + vBetaDash2*fTheta2 ) * ( 1-E1 ) * vOneOverBeta;


	// Apply Inscattering contribution factors.
	vI = vI*vTermMulti.y;

	// Scale with Sun color & intesity.
	vI*=vSunColor.xyz;
	vI*=vSunColor.w;

	vE*=vSunColor.xyz;
	vE*=vSunColor.w;

	Out.Specular= vI; //Inscattering TNT2 doesn't support Specular arg, so output inscattering to Diffuse
	Out.Diffuse= vE;                            // Extinction

	Out.uv=uv;
	Out.uv1=uv;

	n =		normalize( mul(n,(float3x3)matWorld) );
	tan =	normalize( mul(tan,(float3x3)matWorld) );
	bin =	normalize( mul(bin,(float3x3)matWorld) );


    // compute the 3x3 tranform from tangent space to world space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from world 
    //   space to tangent space, though.
    float3x3 matToTangentSpace;
    matToTangentSpace[0] = tan;
    matToTangentSpace[1] = bin;
    matToTangentSpace[2] = n;

    Out.l = mul(matToTangentSpace, float3(-0.0471744f, 0.799484f, 0.598423) );//vSunDir ); //light vector in texture space

	float3 v2eye=-V;
	float3 h=v2eye+vSunDir;
    Out.h = normalize(mul(matToTangentSpace, h)); //half vector in texture space


	return Out;
};



sampler texnormal;

sampler texbase=sampler_state {
	Texture = <tTX1>;
};



float4 mainps(VS_OUTPUT i) : COLOR
{
	float4 color=1;

	float4 base=tex2D(texbase,i.uv);

	//float fDistToEye=_vecObjParam.z;
	//if (!_bInstancing && fDistToEye>5000) {
	//	color.xyz=base.xyz*i.Diffuse+i.Specular;
	//} else {
		//fetch bump normal and unpack it to [-1..1] range
		float3 normal = 2 * tex2D(texnormal, i.uv) - 1;

		//vector l=dot3lightingPS(normal.xyz,i.l,i.h,_fSpecularPower,_bSpecularEnable);
		vector l;
		l.y= dot(normal.xyz,i.l);
		l.z= dot(normal.xyz,i.h);
	
		float3 lightdif=  l.y * i.Diffuse + i.Diffuse;
		float3 lightspec= l.z * i.Diffuse + i.Specular;

		color.xyz=base.xyz*lightdif+lightspec;//+ambient;
	//}
	return color;
};


technique T0
{
  pass P0
  {
	// vertex shader
    VertexShader = compile vs_2_0 mainvs();
    PixelShader  = compile ps_2_0 mainps();
  } // of pass0
}


technique T1
{
  pass P0
  {
	// vertex shader
    VertexShader = compile vs_2_0 mainvs();

	TextureFactor = <dwSunDir>;
    SpecularEnable=False;


	  // stage0
	  ColorOp[0] = Modulate;
	  ColorArg1[0] = Diffuse; //Extinction
	  ColorArg2[0] = Texture;
	  Texture[0] = <tTX1>;

	  // stage1
	  ColorOp[1] = Add;
	  ColorArg1[1] = Specular; //Inscattering
	  ColorArg2[1] = Current;

	  // state2
	  ColorOp[2] = Disable;
  } // of pass0
}
