//--- system variables, player feed value ----
#include "..\include\common.fx"
#include "..\include\shadow_common.fx"

//texture tTXn {n = 0..7}
texture tTX0;
texture tTX1;
texture tTX2;

bool _bBlendPass = false;

matrix matTotal; //matWorld*matView*matProj;
matrix matWorld; //World Matrix
matrix matView;  //View Matrix

//---- user variables ---
vector vecOffset={-0.03f, -0.03f, -0.03f, 1.0f};

float    g_fHeightMapScale = .05;         // Describes the useful range of values for the height field
float2   g_vTextureDims = { 512, 512 };    // Specifies texture dimensions for computation of mip level at render time (width, height)

int      g_nLODThreshold = 2;           // The mip level id for transitioning between the full computation
                                    // for parallax occlusion mapping and the bump mapping computation
int      g_nMinSamples = 8;             // The minimum number of samples for sampling the height field profile
int      g_nMaxSamples = 50;             // The maximum number of samples for sampling the height field profile


struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 uv : TEXCOORD0;
   float4 vViewWS : TEXCOORD1;
   float4 vViewTS : TEXCOORD2;
   float4 vLightTS : TEXCOORD3;
   float4 vL : TEXCOORD4; //vL of light1
   float4 vH : TEXCOORD5; //vH of light1
   float4 vParallaxOffsetTS : TEXCOORD6;   // Parallax offset vector in tangent space
   float3 pos : TEXCOORD7; // vertex position in world space

   float4 Diffuse    : COLOR0; //vL
   float4 Specular   : COLOR1; //vH
//	float4 vcolor; { vL.w, vH.w, vParallaxOffsetTS.zw }
};



VS_OUTPUT mainvs(float4 pos: POSITION, float4 vcolor: COLOR0, float3 n: NORMAL, float2 uv: TEXCOORD0, float3 bin: BINORMAL, float3 tan: TANGENT)
{
	VS_OUTPUT o;

	o.Pos = mul(pos, matTotal);
	o.uv.xy = uv;
	o.vL.w = vcolor.x;
	o.vH.w = vcolor.y;
	o.vParallaxOffsetTS.zw = vcolor.zw;
	
	tan =	normalize( mul(tan,(float3x3)matWorld) );
	bin =	normalize( mul(bin,(float3x3)matWorld) );
	n =	normalize( mul(n,(float3x3)matWorld) );
	o.vViewWS.w = n.x;
	o.vViewTS.w = n.y;
	o.vLightTS.w = n.z;

    // compute the 3x3 tranform from tangent space to world space; we will 
    //   use it "backwards" (vector = mul(matrix, vector) to go from world 
    //   space to tangent space, though.
    float3x3 matToTangentSpace;
    matToTangentSpace[0] = tan;
    matToTangentSpace[1] = bin;
    matToTangentSpace[2] = n;

	pos = mul(float4(pos.xyz,1),matWorld); //vertex pos in world space
	o.pos = pos;

	float3 v2eye=_vecEye-pos.xyz;
	o.vViewWS.xyz = v2eye;
	v2eye=normalize(v2eye);

	//light0
	float3 v2l =_vecLight-pos.xyz;
	v2l = normalize(v2l);

    // Propagate the view and the light vectors (in tangent space):
    o.vLightTS.xyz = mul( v2l, matToTangentSpace );
    o.vViewTS.xyz  = mul( matToTangentSpace, o.vViewWS.xyz  );
	
    // Compute initial parallax displacement direction:
    float2 vParallaxDirection = normalize(  o.vViewTS.xy );
       
    // The length of this vector determines the furthest amount of displacement:
    float fLength         = length( o.vViewTS.xyz );
    float fParallaxLength = sqrt( fLength * fLength - o.vViewTS.z * o.vViewTS.z ) / -o.vViewTS.z; 
       
    // Compute the actual reverse parallax displacement vector:
    o.vParallaxOffsetTS.xy = vParallaxDirection * fParallaxLength;
       
    // Need to scale the amount of displacement to account for different height ranges
    // in height maps. This is controlled by an artist-editable parameter:
    o.vParallaxOffsetTS.xy *= g_fHeightMapScale;



    o.Diffuse.xyz = normalize(mul(matToTangentSpace, v2l)); //light vector in texture space

	float3 h = v2eye+v2l;
	h=normalize(h);

    o.Specular.xyz = normalize(mul(matToTangentSpace, h)); //half vector in texture space


	//light1
	v2l=_vecLight1-pos.xyz;
	v2l = normalize(v2l);

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



sampler texbase=sampler_state {
	Texture = <tTX0>;
	MipFilter = Point;
};

sampler texnormal=sampler_state {
	Texture = <tTX1>;
	MipFilter = Point;
};



float4 mainps(VS_OUTPUT i, uniform bool bPS20=false, uniform bool bPS30=false) : COLOR0
{
   // Start the current sample located at the input texture coordinate, which would correspond
   // to computing a bump mapping result:
   float2 texSample = i.uv.xy;
   float3 vNormalWS = float3(i.vViewWS.w, i.vViewTS.w, i.vLightTS.w);
	
   float4 vcolor = float4( i.vL.w, i.vH.w, i.vParallaxOffsetTS.zw );

   if (bPS30) { // pom

	   //  Normalize the interpolated vectors:
	   float3 vViewTS   = normalize( i.vViewTS.xyz  );
	   float3 vViewWS   = normalize( i.vViewWS.xyz  );
	   float3 vLightTS  = normalize( i.vLightTS.xyz );

	   // Adaptive in-shader level-of-detail system implementation. Compute the 
	   // current mip level explicitly in the pixel shader and use this information 
	   // to transition between different levels of detail from the full effect to 
	   // simple bump mapping. See the above paper for more discussion of the approach
	   // and its benefits.
	   
	   // Compute the current gradients:
	   float2 fTexCoordsPerSize = i.uv.xy * g_vTextureDims;

	   // Compute all 4 derivatives in x and y in a single instruction to optimize:
	   float2 dxSize, dySize;
	   float2 dx, dy;

	   float4( dxSize, dx ) = ddx( float4( fTexCoordsPerSize, i.uv.xy ) );
	   float4( dySize, dy ) = ddy( float4( fTexCoordsPerSize, i.uv.xy ) );
					  
	   float  fMipLevel;      
	   float  fMipLevelInt;    // mip level integer portion
	   float  fMipLevelFrac;   // mip level fractional amount for blending in between levels

	   float  fMinTexCoordDelta;
	   float2 dTexCoords;

	   // Find min of change in u and v across quad: compute du and dv magnitude across quad
	   dTexCoords = dxSize * dxSize + dySize * dySize;

	   // Standard mipmapping uses max here
	   fMinTexCoordDelta = max( dTexCoords.x, dTexCoords.y );

	   // Compute the current mip level  (* 0.5 is effectively computing a square root before )
	   fMipLevel = max( 0.1 * log2( fMinTexCoordDelta ), 0 );
		


	   // Multiplier for visualizing the level of detail (see notes for 'nLODThreshold' variable
	   // for how that is done visually)
	   //float4 cLODColoring = float4( 1, 1, 3, 1 );

	   float fOcclusionShadow = 1.0;

	   if ( fMipLevel <= (float) g_nLODThreshold ) {
		  //===============================================//
		  // Parallax occlusion mapping offset computation //
		  //===============================================//

		  // Utilize dynamic flow control to change the number of samples per ray 
		  // depending on the viewing angle for the surface. Oblique angles require 
		  // smaller step sizes to achieve more accurate precision for computing displacement.
		  // We express the sampling rate as a linear function of the angle between 
		  // the geometric normal and the view direction ray:
		  int nNumSteps = (int) lerp( g_nMaxSamples, g_nMinSamples, dot( vViewWS, vNormalWS ) );

		  // Intersect the view ray with the height field profile along the direction of
		  // the parallax offset ray (computed in the vertex shader. Note that the code is
		  // designed specifically to take advantage of the dynamic flow control constructs
		  // in HLSL and is very sensitive to specific syntax. When converting to other examples,
		  // if still want to use dynamic flow control in the resulting assembly shader,
		  // care must be applied.
		  // 
		  // In the below steps we approximate the height field profile as piecewise linear
		  // curve. We find the pair of endpoints between which the intersection between the 
		  // height field profile and the view ray is found and then compute line segment
		  // intersection for the view ray and the line segment formed by the two endpoints.
		  // This intersection is the displacement offset from the original texture coordinate.
		  // See the above paper for more details about the process and derivation.
		  //

		  float fCurrHeight = 0.0;
		  float fStepSize   = 1.0 / (float) nNumSteps;
		  float fPrevHeight = 1.0;
		  float fNextHeight = 0.0;

		  int    nStepIndex = 0;
		  bool   bCondition = true;

		  float2 vTexOffsetPerStep = fStepSize * i.vParallaxOffsetTS.xy;
		  float2 vTexCurrentOffset = i.uv.xy;
		  float  fCurrentBound     = 1.0;
		  float  fParallaxAmount   = 0.0;

		  float2 pt1 = 0;
		  float2 pt2 = 0;
		   
		  float2 texOffset2 = 0;

		  while ( nStepIndex < nNumSteps )  {
			 vTexCurrentOffset -= vTexOffsetPerStep;

			 // Sample height map which in this case is stored in the alpha channel of the normal map:
			 fCurrHeight = tex2Dgrad( texnormal, vTexCurrentOffset, dx, dy ).a;

			 fCurrentBound -= fStepSize;

			 if ( fCurrHeight > fCurrentBound ) {
				pt1 = float2( fCurrentBound, fCurrHeight );
				pt2 = float2( fCurrentBound + fStepSize, fPrevHeight );

				texOffset2 = vTexCurrentOffset - vTexOffsetPerStep;

				nStepIndex = nNumSteps + 1;
				fPrevHeight = fCurrHeight;
			 } else {
				nStepIndex++;
				fPrevHeight = fCurrHeight;
			 }
		  }   

		  float fDelta2 = pt2.x - pt2.y;
		  float fDelta1 = pt1.x - pt1.y;
		  
		  float fDenominator = fDelta2 - fDelta1;
		  
		  // SM 3.0 requires a check for divide by zero, since that operation will generate
		  // an 'Inf' number instead of 0, as previous models (conveniently) did:
		  if ( fDenominator == 0.0f )
			 fParallaxAmount = 0.0f;
		  else
			 fParallaxAmount = (pt1.x * fDelta2 - pt2.x * fDelta1 ) / fDenominator;
		  
		  float2 vParallaxOffset = i.vParallaxOffsetTS.xy * (1 - fParallaxAmount );

		  // The computed texture offset for the displaced point on the pseudo-extruded surface:
		  float2 texSampleBase = i.uv.xy - vParallaxOffset;
		  texSample = texSampleBase;

		  // Lerp to bump mapping only if we are in between, transition section:
			
		  //cLODColoring = float4( 1, 1, 1, 1 ); 

		  if ( fMipLevel > (float)(g_nLODThreshold - 1) ) {
			 // Lerp based on the fractional part:
			 fMipLevelFrac = modf( fMipLevel, fMipLevelInt );

			// fMipLevelFrac = saturate( fMipLevelFrac*0.25 + 0.75 );

			 // Lerp the texture coordinate from parallax occlusion mapped coordinate to bump mapping
			 // smoothly based on the current mip level:
			 texSample = lerp( texSampleBase, i.uv.xy, fMipLevelFrac );
		  }  
	   }
   } // end of pom


	float4 bumpNormal;
	if (!bPS30) {
		bumpNormal = tex2D(texnormal, texSample);
		float height=vecOffset.x*bumpNormal.a;
		texSample += normalize(i.vViewTS.xyz).xy*height;
	}

	//fetch bump normal and unpack it to [-1..1] range
	bumpNormal = tex2D(texnormal, texSample);
	bumpNormal.xyz = bumpNormal.xyz * 2 - 1;

	float3 vL=i.Diffuse.xyz * 2 -1;
	float3 vH=i.Specular.xyz * 2 -1;

	float3 diffuseL = 0;
	float3 specularL = 0;

	lighting2lbump( bPS20, bPS30, diffuseL, specularL, i.pos, vNormalWS, bumpNormal.xyz, bumpNormal.a, vL, vH, i.vL, i.vH );


	if (_bBlendPass) {
		if (bPS30) if ( dot(diffuseL,1) < 0.01 && dot(specularL,1) < 0.01 ) discard;
	} else {
		diffuseL += vcolor + _vAmbientColor;
	}


	float4 base = tex2D(texbase,texSample);

	base.rgb = base.rgb * diffuseL + specularL;

	return base;
};


//---- T0 ---- ps 3.0
technique T0
{
  pass P1
  {
     VertexShader = compile vs_3_0 mainvs();
     PixelShader  = compile ps_3_0 mainps(true,true);
  }
} //of technique T0



//---- T1 ---- ps 2.0
technique T1
{
  pass P1
  {
     VertexShader = compile vs_2_0 mainvs();
     PixelShader  = compile ps_2_0 mainps(true);
  }
} //of technique T1

