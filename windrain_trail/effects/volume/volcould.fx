texture tTX0;
texture tTX1;


vector _vecAppTime;

matrix matWorld;
matrix matTotal; //matWorld*matView*matProj;
matrix matViewProj; //matView*matProj

matrix matView;

vector vecUVTrans={20000,20000,20000,0.01f}; // x,y,z : scale, w: offset speed
vector vecCouldColor={1.5f,1.5f,1.5f,1.0f}; // cloud color
vector vecAlphaFactor={6,1,0.5,1}; // clip the pixel if alpha < z; out alpha = pow(alpha,x) * y;

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float3 texCoord: TEXCOORD0;
};


VS_OUTPUT mainvs(float3 Pos: POSITION){
   VS_OUTPUT Out;
	
	Pos=mul(Pos,(float3x3)matWorld);
	//Pos=mul((float3x3)matView,Pos); //billboard transform
	Pos+=matWorld[3].xyz;

   Out.Pos = mul(float4(Pos,1),matViewProj);
   Out.texCoord = Pos/vecUVTrans.xyz + _vecAppTime.x*vecUVTrans.w;
   

   return Out;
}





sampler volNoise=sampler_state {
	Texture = <tTX0>;
 	AddressU = WRAP;
	AddressV = WRAP;
	AddressW = WRAP;
};


float4 mainps(VS_OUTPUT In) : COLOR {
	float4 col=tex3D(volNoise,In.texCoord);

	clip(col.x-vecAlphaFactor.z);
	col.a = pow(col.x,vecAlphaFactor.x) * vecAlphaFactor.y;
	col.rgb*=vecCouldColor.rgb;
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
        VertexShader = compile vs_1_1 mainvs();
        PixelShader  = compile ps_2_0 mainps();
    }
}






