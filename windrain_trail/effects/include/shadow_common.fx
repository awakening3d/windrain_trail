#include "shadowdef.fx"



#ifdef SOFT_SHADOW
	vector _RandVecs[8] = {
		{-0.6684083f, -0.3661959f, 0,0},
		{-0.3149247f, -0.7854245f, 0,0},
		{-0.9606495f, 0.1416277f, 0,0},
		{-0.07181171f, -0.05079093f, 0,0},
		{-0.6062008f, 0.5075472f, 0,0},
		{0.2976687f, 0.7164272f, 0,0},
		{0.3207437f, -0.5179837f, 0,0},
		{0.5639988f, -0.05284024f, 0,0},
	};
#endif


texture tCubeDepth;

sampler texCubeDepth=sampler_state {
	Texture = <tCubeDepth>;
	MipFilter = None;
	MinFilter = Point;
	MagFilter = Point;
};


int _CubeShadowDepthChannel[4] = { -1, -1, -1, -1 };



vector _vecEye={0.0f,1000.0f,0.0f,1.0f};

vector _vecLight ={0.0f,0.0f,0.0f,1.0f};	// xyz: light position	w: shadow bias
vector _vecLightColor={1.0f,1.0f,1.0f,1.0f};
vector _vecLightParam; // parameters of light0 ( range*range, Attenuation0, Attenuation1, Attenuation2 )
vector _vecLightDir; // direction of light -- xyz: direction, w: CosPhi( <0: point, ==0: directional, >0: spot )
vector _qLightDir; // Quaternion of light


vector _vecLight1 ={0.0f,0.0f,0.0f,1.0f};
vector _vecLightColor1={1.0f,1.0f,1.0f,1.0f};
vector _vecLightParam1; // parameters of light1 ( range*range, Attenuation0, Attenuation1, Attenuation2 )
vector _vecLightDir1; // direction of light1
vector _qLightDir1; // Quaternion of light1


bool _bSpecularEnable=true;
float _fSpecularPower=8;
vector _vDiffuseColor={1.0f,1.0f,1.0f,1.0f};
vector _vSpecularColor={1.0f,1.0f,1.0f,1.0f};
vector _vAmbientColor={0,0,0,0};
vector _vEmissiveColor = {0,0,0,0};


void shadowsample(int nLight, float shadowbias, float dist, float3 lv, float2 rot, inout float color_density ) {

	//float distVL = dist * SHADOW_BIAS;
	float distVL = dist - shadowbias;
	distVL *= DEPTH_VALUE_SCALE;

#ifdef SOFT_SHADOW
	float2 roty = float2( -rot.y, rot.x );
	float3 ofs;

	float lensq = dist * 0.002f;
	float4 shadowMapVals;
	half fInvSamplNum = (1.0 / SOFT_SHADOW_SAMPLENUM);
	
	for (int s=0; s<SOFT_SHADOW_SAMPLENUM; s+=4) {

		ofs = float3( dot( _RandVecs[s+0].xy, rot ), dot( _RandVecs[s].xy, roty ), 0 ); ofs.z = ofs.x;
		shadowMapVals.r = texCUBE(texCubeDepth, lv + lensq * ofs)[_CubeShadowDepthChannel[nLight]];
		if (0==shadowMapVals.r) shadowMapVals.r = DEPTH_VALUE_MAX;

		ofs = float3( dot( _RandVecs[s+1].xy, rot ), dot( _RandVecs[s+1].xy, roty ), 0 ); ofs.z = ofs.y;
		shadowMapVals.g = texCUBE(texCubeDepth, lv + lensq * ofs)[_CubeShadowDepthChannel[nLight]];
		if (0==shadowMapVals.g) shadowMapVals.g = DEPTH_VALUE_MAX;

		ofs = float3( dot( _RandVecs[s+2].xy, rot ), dot( _RandVecs[s+2].xy, roty ), 0 ); ofs.z = ofs.x;
		shadowMapVals.b = texCUBE(texCubeDepth, lv + lensq * ofs)[_CubeShadowDepthChannel[nLight]];
		if (0==shadowMapVals.b) shadowMapVals.b = DEPTH_VALUE_MAX;

		ofs = float3( dot( _RandVecs[s+3].xy, rot ), dot( _RandVecs[s+3].xy, roty ), 0 ); ofs.z = ofs.y;
		shadowMapVals.a = texCUBE(texCubeDepth, lv + lensq * ofs)[_CubeShadowDepthChannel[nLight]];
		if (0==shadowMapVals.a) shadowMapVals.a = DEPTH_VALUE_MAX;
	
		float4 inLight = ( distVL < shadowMapVals );
		color_density += dot(inLight, fInvSamplNum);
	}

	color_density = saturate( color_density );
#else
	half fdepth = texCUBE(texCubeDepth, lv)[_CubeShadowDepthChannel[nLight]];
	if (0==fdepth) fdepth = DEPTH_VALUE_MAX;
	if ( distVL <= fdepth ) color_density = 1; // not in shadow
#endif

}




void _lighting2l(uniform bool bPS20, uniform bool bPS30, inout float3 diffuseL, inout float3 specularL, out float intensity0, out float intensity1,
	float3 pos, float3 normal, float Gloss, uniform bool bShadow = true )
{
	float3 lightvec = pos + normal * _vecLightColor.w - _vecLight.xyz;
	float distsq = dot( lightvec, lightvec );
	float dist = sqrt(distsq);


	float color_density = 1;
	
	float2 cossin;
	if (bShadow && bPS30) {
	   // generate random rotation angle for each fragment
	   float angle = randomAngle(pos, 16);
	   cossin = float2( cos(angle), sin(angle) );
	}

	//light0
	if (bPS30) {
		if ( bShadow && _CubeShadowDepthChannel[0] >=0 ) {
			color_density = SHADOW_STRENGTH_INV;

			float3 lv = lightvec;
			if (_vecLightDir.w > 0) { // spot light
				lv = Vec3Rotation(lv, _qLightDir); // to light view space
			}
			shadowsample(0, _vecLight.w, dist, lv, cossin, color_density );
		}

		if (_vecLightDir.w>0) { // spot light
			float fCosPhi = _vecLightDir.w;
			float fCosAngle = dot(normalize(lightvec.xyz), _vecLightDir.xyz );
			float falloff = saturate( (fCosAngle - fCosPhi) / (1 - fCosPhi) );
			color_density *= falloff;
		}
	}

	intensity0 = color_density;
	if ( color_density > 0 ) { // not in shadow area
		float3 vL= normalize( -lightvec );
		float3 vE= normalize( _vecEye.xyz - pos );
		float3 vH= normalize( vE + vL );

		float diffuse = saturate( dot(normal, vL) );

		diffuseL = _vecLightColor*diffuse;
		float fAtten = color_density;
		if (bPS20) {
			diffuseL *= _vDiffuseColor;
			fAtten *= saturate((_vecLightParam.x-distsq)/_vecLightParam.x);
			if (bPS30)
				fAtten /= ( _vecLightParam.y + _vecLightParam.z*dist + _vecLightParam.w*distsq );
			else
				fAtten /= ( _vecLightParam.y + _vecLightParam.z*dist );
		}
		diffuseL *= fAtten;
		
		if (_bSpecularEnable && bPS30) {
			float specular =  saturate( dot(normal, vH) );
			specular = pow( saturate(specular), _fSpecularPower );
			specularL = _vecLightColor*specular;
			if (bPS30) specularL *= _vSpecularColor;
			specularL *= fAtten * Gloss;
		}
	}
	
	//light1
	if (bPS20) {
		color_density = 1;
		float3 lightvec = pos + normal * _vecLightColor1.w - _vecLight1.xyz;
		float distsq = dot( lightvec, lightvec );
		float dist = sqrt(distsq);

 	   if (bPS30) {
			if ( bShadow && _CubeShadowDepthChannel[1] >=0 ) {
				color_density = SHADOW_STRENGTH_INV;
				float3 lv = lightvec;
				if (_vecLightDir1.w > 0) { // spot light
					lv = Vec3Rotation(lv, _qLightDir1); // to light view space
				}

				shadowsample(1, _vecLight1.w, dist, lv, cossin, color_density );
			}

			if (_vecLightDir1.w>0) { // spot light
				float fCosPhi = _vecLightDir1.w;
				float fCosAngle = dot(normalize(lightvec.xyz), _vecLightDir1.xyz);
				float falloff = saturate((fCosAngle - fCosPhi) / (1 - fCosPhi));
				color_density *= falloff;
			}

	   }

	   intensity1 = color_density;
	   if ( color_density > 0 ) { // not in shadow area
	   		float3 vL= normalize( -lightvec );
			float3 vE= normalize( _vecEye.xyz - pos );
			float3 vH= normalize( vE + vL );

			float diffuse = saturate( dot(normal, vL) );

			float3 diffuseL1 = _vecLightColor1*diffuse * _vDiffuseColor;

			float fAtten = color_density;
			fAtten *= saturate((_vecLightParam1.x-distsq)/_vecLightParam1.x);
			if (bPS30)
				fAtten /= ( _vecLightParam1.y + _vecLightParam1.z*dist + _vecLightParam1.w*distsq );
			else
				fAtten /= ( _vecLightParam1.y + _vecLightParam1.z*dist );

			diffuseL1 *= fAtten;
			diffuseL += diffuseL1;

			if (_bSpecularEnable && bPS30) {
				float specular =  saturate( dot(normal, vH) );
				specular = pow( saturate(specular), _fSpecularPower );

				float3 specularL1 = _vecLightColor1*specular;
				if (bPS30) specularL1 * _vSpecularColor;
				specularL1 *= fAtten * Gloss;
				specularL += specularL1;
			}
	   }
	}

}

void lighting2l(uniform bool bPS20, uniform bool bPS30, inout float3 diffuseL, inout float3 specularL,
	float3 pos, float3 normal, float Gloss, uniform bool bShadow = true )
{
	float intensity0, intensity1;
	_lighting2l(bPS20,bPS30,diffuseL,specularL,intensity0,intensity1,
		pos,normal,Gloss,bShadow );
}


void lighting2lbump(uniform bool bPS20, uniform bool bPS30, inout float3 diffuseL, inout float3 specularL,
	float3 pos, float3 normal, float3 tnormal, float Gloss, float3 vL, float3 vH, float3 vL1, float3 vH1, uniform bool bShadow = true )
{

	if (bPS30) {
		vL=normalize(vL);
		vH=normalize(vH);
	}


	float3 lightvec = pos + normal * _vecLightColor.w - _vecLight.xyz;
	float distsq = dot( lightvec, lightvec );
	float dist = sqrt(distsq);


	float color_density = 1;
	
	float2 cossin;
	if (bShadow && bPS30) {
	   // generate random rotation angle for each fragment
	   float angle = randomAngle(pos, 16);
	   cossin = float2( cos(angle), sin(angle) );
	}

	//light0
	if (bPS30) {
		if ( bShadow && _CubeShadowDepthChannel[0] >=0 ) {
			color_density = SHADOW_STRENGTH_INV;

			float3 lv = lightvec;
			if (_vecLightDir.w > 0) { // spot light
				lv = Vec3Rotation(lv, _qLightDir); // to light view space
			}

			shadowsample(0, _vecLight.w, dist, lv, cossin, color_density );
		}

		if (_vecLightDir.w>0) { // spot light
			float fCosPhi = _vecLightDir.w;
			float fCosAngle = dot(normalize(lightvec.xyz), _vecLightDir.xyz );
			float falloff = saturate( (fCosAngle - fCosPhi) / (1 - fCosPhi) );
			color_density *= falloff;
		}
	}

	if ( color_density > 0 ) { // not in shadow area
	
		float diffuse = saturate( dot(tnormal, vL) );

		diffuseL = _vecLightColor*diffuse;
		float fAtten = color_density;
		if (bPS20) {
			diffuseL *= _vDiffuseColor;
			fAtten *= saturate((_vecLightParam.x-distsq)/_vecLightParam.x);
			if (bPS30)
				fAtten /= ( _vecLightParam.y + _vecLightParam.z*dist + _vecLightParam.w*distsq );
			else
				fAtten /= ( _vecLightParam.y + _vecLightParam.z*dist );
		}
		diffuseL *= fAtten;

		if (_bSpecularEnable && bPS20) {
			float specular =  saturate( dot(tnormal, vH) );
			specular = pow( saturate(specular), _fSpecularPower );
			specularL = _vecLightColor*specular;
			if (bPS30) specularL *= _vSpecularColor;
			specularL *= fAtten * Gloss;
		}

	}

	
	//light1
	if (bPS20) {

		color_density = 1;
		float3 lightvec = pos + normal * _vecLightColor1.w - _vecLight1.xyz;
		float distsq = dot( lightvec, lightvec );
		float dist = sqrt(distsq);

		if (bPS30) {
			if ( bShadow && _CubeShadowDepthChannel[1] >=0 ) {
				color_density = SHADOW_STRENGTH_INV;
				float3 lv = lightvec;
				if (_vecLightDir1.w > 0) { // spot light
					lv = Vec3Rotation(lv, _qLightDir1); // to light view space
				}

				shadowsample(1, _vecLight1.w, dist, lv, cossin, color_density );
			}
			if (_vecLightDir1.w>0) { // spot light
				float fCosPhi = _vecLightDir1.w;
				float fCosAngle = dot(normalize(lightvec.xyz), _vecLightDir1.xyz);
				float falloff = saturate((fCosAngle - fCosPhi) / (1 - fCosPhi));
				color_density *= falloff;
			}
		}


		if (bPS30) {
			vL1 = normalize(vL1);
			vH1 = normalize(vH1);
		}

		float diffuse = saturate( dot(tnormal, vL1) );

		float3 diffuseL1 = _vecLightColor1*diffuse * _vDiffuseColor;

		float fAtten = color_density;
		fAtten *= saturate((_vecLightParam1.x-distsq)/_vecLightParam1.x);
		if (bPS30)
			fAtten /= ( _vecLightParam1.y + _vecLightParam1.z*dist + _vecLightParam1.w*distsq );
		else
			fAtten /= ( _vecLightParam1.y + _vecLightParam1.z*dist );

		diffuseL1 *= fAtten;
		diffuseL += diffuseL1;

		if (_bSpecularEnable) {
			float specular =  saturate( dot(tnormal, vH1) );
			specular = pow( saturate(specular), _fSpecularPower );

			float3 specularL1 = _vecLightColor1*specular;
			if (bPS30) specularL1 * _vSpecularColor;
			specularL1 *= fAtten * Gloss;
			specularL += specularL1;
		}

	}


}

/*
float edgetapsmooth( float3 lv, int s )
{
	lv *= 512;
	float xweight = 1;
	float yweight = 1;
	if (_RandVecMax.x == s)
		xweight = 1 - frac(lv.x);
	else if (_RandVecMax.y == s)
		xweight = frac(lv.x);

	if (_RandVecMax.z == s)
		yweight = 1 - frac(lv.y);
	else if (_RandVecMax.w == s)
		yweight = frac(lv.y);

	return xweight * yweight;
}
*/