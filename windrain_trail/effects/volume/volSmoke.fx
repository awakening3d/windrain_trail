texture tTX0;
texture tTX1;


vector _vecAppTime;
vector _vDiffuseColor; // materials' diffuse color


matrix matWorld;
matrix matTotal; //matWorld*matView*matProj;
matrix matViewProj; //matView*matProj

matrix matView;

vector vecUVTrans={200,200,200,0.04f}; // x,y,z : scale, w: offset speed
vector vecCouldColor={1.5f,1.5f,1.5f,1.0f}; // cloud color
vector vecAlphaFactor={6,1,0.5,1}; // clip the pixel if alpha < z; out alpha = pow(alpha,x) * y;

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv0: TEXCOORD0;
   float3 texCoord: TEXCOORD1;
};


VS_OUTPUT mainvs(float3 Pos: POSITION, float2 tc0 : TEXCOORD0){
   VS_OUTPUT Out;
	
   Out.texCoord = Pos/vecUVTrans.xyz + _vecAppTime.x*vecUVTrans.w;

	Pos=mul(Pos,(float3x3)matWorld);
	//Pos=mul((float3x3)matView,Pos); //billboard transform
	Pos+=matWorld[3].xyz;

   Out.Pos = mul(float4(Pos,1),matViewProj);

   Out.uv0=tc0;
   
   return Out;
}





sampler volNoise=sampler_state {
	Texture = <tTX0>;
 	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
};

sampler texMask=sampler_state {
	Texture = <tTX1>;
 	AddressU = CLAMP;
	AddressV = CLAMP;
};


float4 mainps(VS_OUTPUT In) : COLOR {
	float4 col=tex3D(volNoise,In.texCoord);

	float4 mask=tex2D(texMask,In.uv0);

	clip(col.x-vecAlphaFactor.z);
	col.a = pow(col.x,vecAlphaFactor.x) * vecAlphaFactor.y;
	col.rgb*=vecCouldColor.rgb;

	col.a *= mask.r;
	col.a *= _vDiffuseColor.a;

	return col;
}






technique T0
{
    pass P0
    {          
		ZWriteEnable=False;
		CullMode=None;
		AlphaBlendEnable=True;
		SrcBlend=SrcAlpha;
		DestBlend=InvSrcAlpha;

        // Any other effect state can be set here.
        VertexShader = compile vs_2_0 mainvs();
        PixelShader  = compile ps_2_0 mainps();
    }
}






