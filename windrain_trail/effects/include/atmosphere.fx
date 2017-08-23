//--- system variables, player feed value ----

vector vBeta1Beta2 = {0.000196834f,0.000309775f,0.000594052f,1};
vector vTerrainRef = {0.01f,0.01f,0.01f,1};
vector vHG = {0.36f,1.8f,1.6f,1};
vector vBetaDash1 = {0.0000083f,0.000014f,0.000029f,1};
vector vBetaDash2 = {0.000013f,0.000017f,0.000024f,1};
vector vOneOverBeta = {5080.43f,3228.15f,1683.35f,1};
vector vTermMulti = {1,0.3f,0,0};
vector vSunColor = {1,1,1,30.0f};
vector vSunDir = {-0.0471744f, 0.799484f, 0.598423f,1};

vector vSunny = {0.25f, 1.0f, 1.0f, 0.0f}; //x - brighter sky near horizen, y - distance scale, z - distance adjust for sky

vector vHeightFog = { 1,1,1, 1500 };


struct ATMO_VS_OUTPUT {
	float3 colorE;     // Extinction color
	float3 colorI;     // Inscattering color
};



ATMO_VS_OUTPUT atmosphere(float3 vPosition, float3 vEye, matrix matView,bool bTerrain=true)
{
	ATMO_VS_OUTPUT Out;

   float3 V = normalize( vPosition-vEye.xyz ); // V = position-eye

	// Angle (theta) between sun direction (L) and view direction (V).
	float VdotL=  saturate( dot(V,vSunDir) ); // [cos(theta)] = V.L
	float fTheta= 1 + VdotL*VdotL; // [1+cos^2(theta)] = Phase1(theta)

	// Distance (s)
	//float fDistance=mul(float4(vPosition,1), matView).z;
	float fDistance = length( vEye - vPosition );

	fDistance*=vSunny.y;
	if (!bTerrain) fDistance*=vSunny.z;

	float3 E1 = exp( -(vBeta1Beta2.xyz * fDistance) );  // e^(-(beta_1 + beta_2) * s) = E1
	
	float3 vE =1;
	
	if (bTerrain) {
		// Extinction term E
		// Apply Reflectance to E to get total net effective E
		vE=E1*vTerrainRef*vTermMulti.x; //E (Total extinction) 

		vE*=vSunColor.xyz;
		vE*=vSunColor.w;
	}


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

	//brighter sky near horizen
	if (!bTerrain) {
		float3 vPosN=normalize(vPosition);
		float fHori=(1-vPosN.y); // 1 - y
		fHori*=fHori;
		float3 vHori=vSunColor*fHori; // intensity * sun color
		vHori*=vSunny.x;
		vI+=vHori; // add to inscattering
	}


	// Outputs.
	Out.colorE=vE+vTermMulti.z;
	Out.colorI=vI+vTermMulti.w;


	// height fog

	float fAlt = vPosition.y;
	if (!bTerrain) fAlt/=4;

	float fog = saturate( (vHeightFog.w - fAlt ) / 1000 );

	float fDisEft = saturate( fDistance*0.0004f );
	fDisEft *= fDisEft;
	fog *= fDisEft;

	Out.colorE *= (1-fog);
	Out.colorI *= (1-fog);
	Out.colorI += fog;

	return Out;
};