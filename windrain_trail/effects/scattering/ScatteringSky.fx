//--- system variables, player feed value ----

//texture tTXn (n = 0..7)

texture tTX1;
texture tTX2;

matrix matWorld; //World Matrix
matrix matView;  //View Matrix
matrix matProj;  //Projection Matrix
matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matViewInv;  //Inverse View Matrix

vector appConst = {0.25f, 0.5f, 0.75f, 1.0f};

vector _vecEye={0.0f,1000.0f,0.0f,1.0f};

vector vBeta1Beta2 = {0.000196834f,0.000309775f,0.000594052f,1};
vector vTerrainRef = {0.0138f,0.0113f,0.008f,1};
vector vHG = {0.36f,1.8f,1.6f,1};
vector vBetaDash1 = {0.0000083f,0.000014f,0.000029f,1};
vector vBetaDash2 = {0.000013f,0.000017f,0.000024f,1};
vector vOneOverBeta = {5080.43f,3228.15f,1683.35f,1};
vector vTermMulti = {1,0.3f,0,0};
vector vSunColor = {1,1,1,30.0f};
vector vSunDir = {-0.0471744f, 0.799484f, 0.598423f,1};

vector vSunny = {0.25f, 1.0f, 1.0f, 0.0f}; //x - brighter sky near horizen, y - distance scale, z - distance adjust for sky



struct VS_OUTPUT {
	float4 Pos: POSITION;
	float3 Diffuse    : COLOR0;     // vertex diffuse color
	float3 Specular   : COLOR1;     // vertex specular color
};



VS_OUTPUT mainvs(float3 vPosition: POSITION, float2 uv: TEXCOORD0)
{
	VS_OUTPUT Out;

   Out.Pos = mul(float4(vPosition,1), matTotal);
   float3 V = normalize( vPosition-_vecEye.xyz ); // V = position-eye

	// Angle (theta) between sun direction (L) and view direction (V).
	float VdotL=  saturate( dot(V,vSunDir) ); // [cos(theta)] = V.L
	float fTheta= 1 + VdotL*VdotL; // [1+cos^2(theta)] = Phase1(theta)

	// Distance (s)
	float fDistance=mul(float4(vPosition,1), matView).z;
	fDistance*=vSunny.y*vSunny.z;

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

	//brighter sky near horizen
	float3 vPosN=normalize(vPosition);
	float fHori=(1-vPosN.y); // 1 - y
	fHori*=fHori;
	float3 vHori=vSunColor*fHori; // intensity * sun color
	vHori*=vSunny.x;
	vI+=vHori; // add to inscattering
	
	// Outputs.
	Out.Diffuse=vI+vTermMulti.w; //Inscattering TNT2 doesn't support Specular arg, so output inscattering to Diffuse
	Out.Specular=vE;                            // Extinction

	return Out;
};



float4 mainps(VS_OUTPUT In) : COLOR 
{
	return float4(In.Diffuse,1);
};


technique T0
{
  pass P0
  {

    VertexShader = compile vs_1_1 mainvs();
    PixelShader  = compile ps_2_0 mainps();

	CullMode=None;
	//ZWriteEnable=False;

  } // of pass0
}



technique T1
{
  pass P0
  {

    VertexShader = compile vs_1_1 mainvs();

	// stage0
	ColorOp[0] = SelectArg2;
	ColorArg2[0] = Diffuse;

	// stage1
	ColorOp[1] = Disable;

	CullMode=None;
	//ZWriteEnable=False;

  } // of pass0
}
