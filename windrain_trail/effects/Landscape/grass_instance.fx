#include "..\include\common.fx"
#include "..\include\atmosphere.fx"

texture tTX0;

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

vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)

bool _bSpecularEnable=true;
float _fSpecularPower=8;

vector _vecLight; // position of light0
vector _vecLightColor; // color of light0

vector _vecLight1; // position of light1
vector _vecLightColor1; // color of light1



struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float4 Diffuse    : COLOR0;
   float4 Specular   : COLOR1;
};


VS_OUTPUT InstancedVS( float3 vPos : POSITION, float4 vDiffuse: COLOR0, float3 n: NORMAL, float2 uv: TEXCOORD0,
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

	ATMO_VS_OUTPUT atmo=atmosphere(pos,_vecEye,matView);
	o.Diffuse = float4(atmo.colorE,1) * vDiffuse;
	o.Specular = float4(atmo.colorI,0);


	o.Pos=mul(pos,matViewProj);
	o.uv=uv;

	n=mul(n,(float3x3)matWorld);
    // normalize normals
    n = normalize(n);

	return o;
}


sampler texbase=sampler_state {
	Texture = <tTX0>;
	//MipFilter = None;
	MipMapLodBias = -2;
};


float4 mainps( VS_OUTPUT i ) : COLOR0
{
	float4 col = tex2D(texbase,i.uv);
	return col*i.Diffuse + i.Specular;
}

technique T0
{
    pass P0
    {          
        VertexShader = compile vs_2_0 InstancedVS();
	PixelShader  = compile ps_2_0 mainps();

	  AlphaTestEnable=True;
	  AlphaRef=0x08;
	  AlphaFunc=GreaterEqual;
	CullMode=None;

    }
};

