
#define DEPTH_VALUE_SCALE	0.001
#define DEPTH_VALUE_MAX			9999999

vector _vecBackBufDesc={800.0f,600.0f,0.0f,1.0f};


int _nDepthMode = 0; // 0: shadow mapping 1: near~far


float4 encode_depth( float dist ) {
	if ( 0 == _nDepthMode ) {
		return dist * DEPTH_VALUE_SCALE; // for shadow mapping
	} else {
		float fNear=_vecBackBufDesc.z;
		float fFar=_vecBackBufDesc.w;

		dist = (dist-fNear) / (fFar-fNear);
		dist = saturate(dist);
	
		return float4( floor(dist*255)/255, fmod(dist*255,1), 0, 1 );
	}
}

float decode_depth( float4 depth ) {
	return depth.r + depth.g/255;
}


float4x4 matrixconvert(float4x3 m)
{
	return float4x4(	float4( m[0].x, m[0].y, m[0].z, 0),
						float4( m[1].x, m[1].y, m[1].z, 0),
						float4( m[2].x, m[2].y, m[2].z, 0),
						float4( m[3].x, m[3].y, m[3].z, 1)	);
}


//dot3 lighting calculating, return (1, diffuse, specular, 1)
vector dot3lighting(float3 vLightPos, float3 vPosition, float3 vNormal, float3 vEye, float fPower=8,bool bSpecular=true)
{
	float3 v2l=vLightPos-vPosition;
	v2l=normalize(v2l);

	float nxl= dot(vNormal,v2l);
	float nxh= 0;

	if (bSpecular) {
		float3 v2eye=vEye-vPosition;
		v2eye=normalize(v2eye);
		float3 h=v2eye+v2l;
		h=normalize(h);
		nxh= dot(vNormal,h);
	}

	return lit(nxl,nxh,fPower);
}

//only diffuse lighting, return (1, diffuse, specular, 1)
vector dot3lighting(float3 vLightPos, float3 vPosition, float3 vNormal)
{
	return dot3lighting(vLightPos,vPosition,vNormal,float3(0,0,0),1,false);
}

//dot3 lighting calculating for pixel shader, return (1, diffuse, specular, 1)
vector dot3lightingPS(float3 vN, float3 vL, float3 vH,float fPower=8,bool bSpecular=true)
{
	float nxl= dot(vN,vL);
	float nxh=0;
	if (bSpecular) nxh=dot(vN,vH);

	return lit(nxl,nxh,fPower); //lit() needs ps_2_0

	/*
	nxl= max(nxl,0);
	
	if (nxl<0 || nxh<0)
		nxh=0;
	else
		nxh=pow(nxh,fPower);

	return vector(1,nxl,nxh,1);
	*/
}


// generates pseudorandom number in [0, 1]
// seed - world space position of a fragemnt
// freq - modifier for seed. The bigger, the faster
// the pseudorandom numbers will change with change of world space position
float random(in float3 seed, in float freq)
{
   // project seed on random constant vector
   float dt = dot(floor(seed * freq), float3(53.1215, 21.1352, 9.1322));
   // return only fractional part
   return frac(sin(dt) * 2105.2354);
}

// returns random angle
float randomAngle(in float3 seed, in float freq)
{
	return random(seed, freq) * 6.283285;
}

// xy should be a integer position (e.g. pixel position on the screen)
// similar to a texture lookup but is only ALU
float PseudoRandom(float2 xy)
{
	float2 pos = frac(xy / 128.0f) * 128.0f + float2(-64.340622f, -72.465622f);

	// found by experimentation
	return frac(dot(pos.xyx * pos.xyy, float3(20.390625f, 60.703125f, 2.4281209f)));
}


// rotate a vector by quaternion	用四元组旋转向量
float3 Vec3Rotation(float3 v, float4 Q)
{
	float3 uv = cross(Q.xyz, v);
	float3 uuv = cross(Q.xyz, uv);

	uv *= (2.0f * Q.w);
	uuv *= 2.0f;

	return v + uv + uuv;
}
