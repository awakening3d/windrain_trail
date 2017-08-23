#include "..\include\common.fx"

texture tTX1;

matrix matProjInv; //Inverse Projection Matrix
matrix matViewInv; //Inverse View Matrix
matrix matWorldInv; //Inverse World Matrix

matrix matWorld; //World Matrix
matrix matWorldView; //matWorld*matView


matrix matTotal; //matWorld*matView*matProj;

matrix matView;
matrix matProj;
matrix matViewProj; //matView*matProj

bool _bInstancing; //instancing

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};

vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)

bool _bSpecularEnable=true;
float _fSpecularPower=8;

vector _vecLight; // position of light0
vector _vecLightColor; // color of light0

vector _vecLight1; // position of light1
vector _vecLightColor1; // color of light1

dword _dwLightColor=0xffffffff;



struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float4 Diffuse    : COLOR0;
   float4 Specular   : COLOR1;
   float3 vL		 : TEXCOORD1;
   float3 vH		 : TEXCOORD2;
};


VS_OUTPUT InstancedVS( float3 vPos : POSITION, float3 n: NORMAL, float2 uv: TEXCOORD0,
					  	float3 tan : TANGENT, float3 bin : BINORMAL,
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
								
	float4 pos=mul(float4(vPos,1),matWorld);
	o.Pos=mul(pos,matViewProj);
	o.uv=uv;

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

	float3 vE=_vecEye.xyz-pos;
	vE=normalize(mul(matToTangentSpace, vE));

	//light0
	float3 vL=_vecLight.xyz-pos;
	// transform light vector to tangent space
	vL=normalize(mul(matToTangentSpace, vL));
	float3 vH = normalize(vE+vL);

    //and pack into [0..1] range
    o.Diffuse.xyz = vL * 0.5 + 0.5.xxx;
	o.Diffuse.w = 1.0f;

    o.Specular.xyz = vH * 0.5 + 0.5.xxx;
	o.Specular.w = 1.0f;

	//light1
	vL=_vecLight1.xyz-pos;
	// transform light vector to tangent space
	o.vL = normalize(mul(matToTangentSpace, vL));
	o.vH = normalize(vE+o.vL);

	return o;
}


sampler texnormal;

sampler texbase=sampler_state {
	Texture = <tTX1>;
};


float4 mainps( VS_OUTPUT i ) : COLOR0
{
	float4 base=tex2D(texbase,i.uv);
	float4 normal=tex2D(texnormal,i.uv)*2-1;

	vector l =dot3lightingPS(normal.xyz,i.Diffuse.xyz*2-1,i.Specular.xyz*2-1,_fSpecularPower,_bSpecularEnable);
	vector l1=dot3lightingPS(normal.xyz,i.vL,i.vH,_fSpecularPower,_bSpecularEnable);

	float4 lightdif=_vecLightColor*l.y;
	float4 lightspec=_vecLightColor*l.z;

	lightdif+=_vecLightColor1*l1.y;
	lightspec+=_vecLightColor1*l1.z;

	float4 color=base*lightdif+lightspec;
	color.a=base.a;
/*
	l =dot3lightingPS(normal.xyz,i.Diffuse.xyz*2-1,i.Specular.xyz*2-1);
	l1=dot3lightingPS(normal.xyz,i.vL,i.vH);
	color=l.y+l1.y;
*/
	return color;
};




technique T0
{
    pass P0
    {          
        VertexShader = compile vs_2_0 InstancedVS();
		PixelShader  = compile ps_2_0 mainps();
    }
};


//////////////////////////////////////
// Techniques specs follow
//////////////////////////////////////
technique t1
{

  pass P1 // specular
  {
  SpecularEnable=False;

  TextureFactor = <_dwLightColor>;

  // stage0
  ColorArg2[0] = Specular;
  ColorOp[0] = DotProduct3;

  // stage1
  ColorOp[1] = Modulate;
  ColorArg1[1] = Current;
  ColorArg2[1] = Current;

  // stage2
  ColorOp[2] = Modulate;
  ColorArg1[2] = Current;
  ColorArg2[2] = Current;

  // stage 3
  ColorOp[3] = Modulate;
  ColorArg1[3] = TFactor;
  ColorArg2[3] = Current;

  // stage4
  ColorOp[4] = Disable;



	VertexShader = compile vs_2_0 InstancedVS();

  } // of pass1


  pass P2 //diffuse x texture
  {
  TextureFactor = <_dwLightColor>;

  // stage0
  ColorArg2[0] = Diffuse;
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


  // alpha blend
  SrcBlend = One;
  DestBlend = One;
  AlphaBlendEnable = True;
  ZWriteEnable = False;
  //VertexShader = compile vs_2_0 InstancedVS();

  } // of pass2

}

