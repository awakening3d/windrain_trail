//--- system variables, player feed value ----

//texture tTXn {n = 0..7}

texture tTX0;
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

vector vBeta1Beta2 = {0.000196834f,0.000309775f,0.000594052,1};
//vector vTerrainRef = {0.0138f,0.0113f,0.008f,1};
vector vTerrainRef = {0.0138f,0.0138f,0.0138f,1};
vector vHG = {0.36f,1.8f,1.6f,1};
vector vBetaDash1 = {0.0000083f,0.000014f,0.000029f,1};
vector vBetaDash2 = {0.000013f,0.000017f,0.000024f,1};
vector vOneOverBeta = {5080.43f,3228.15f,1683.35f,1};
vector vTermMulti = {1,0.3,0,1};
vector vSunColor = {1,1,1,40.0f};
vector vSunDir = {-0.0471744f, 0.799484f, 0.598423f,1};

vector vSunny = {0.5f, 1.0f, 0.0f, 0.0f}; //x - brighter sky near horizen, y - dark sky opposite to sun


vector vSunDirNM = {0.0471744f,0.598423f,0.799484f,1};
dword dwSunDir=0xff85cbe5;


vector vTexCoordScale = {128,1,1,1};

     // Definition of the vertex shader, declarations then assembly
    VertexShader vsdiffuse =
    asm
    {
   	vs_1_1
 
	dcl_position v0
	dcl_normal	 v1
	dcl_texcoord v2


	// c0-c3 contains composite transform matrix
	m4x4 oPos, v0, c0   // transform vertices by view/projection matrix

	// Calculate V
	sub r1, c6, v0	        // V = eye - position

	dp3 r1.w, r1, r1            // Normalize V
	rsq r1.w, r1.w							
	mul r1, r1, r1.w

	mov r8,r1 //store V to r8


	// Angle {theta} between sun direction {L} and view direction {V}.
	dp3 r0.x, r1, c4       // r0.x = [cos{theta}] = V.L
	mad r0.y, r0.x, r0.x, c8.x	// r0.y = [1+cos^2{theta}] = Phase1{theta}

	// Distance {s}
	m4x4 r1, v0, c20           // r1.z = s
	mov r0.z, r1.z			// store in r0.z for future use.

	// Terms used in the scattering equation.
	// r0 = [cos{theta}, 1+cos^2{theta}, s] 

	// Extinction term E

	mul r1, c9, -r0.z       // -{beta_1+beta_2} * s
	mul r1, r1, c8.y           // -{beta_1+beta_2} * s * log_2 e
	exp r1.x, r1.x					
	exp r1.y, r1.y					
	exp r1.z, r1.z                          // r1 = e^{-{beta_1 + beta_2} * s} = E1

	// Apply Reflectance to E to get total net effective E
	mul r3, r1, c10  //r3 = E {Total extinction} 

	// Phase2{theta} = {1-g^2}/{1+g-2g*cos{theta}}^{3/2}
	// theta is 180 - actual theta {this corrects for sign}
	// c[CV_HG] = [1-g^2, 1+g, 2g]
	mad r4.x, c11.z, r0.x, c11.y; 

	rsq r4.x, r4.x						
	mul r4.y, r4.x, r4.x			
	mul r4.x, r4.y, r4.x;
	mul r0.w, r4.x, c11.x              ; r0.w = Phase2{theta}


	// Inscattering {I} = {Beta'_1 * Phase_1{theta} + Beta'_2 * Phase_2{theta}} * 
	//        [1-exp{-Beta_1*s}.exp{-Beta_2*s}] / {Beta_1 + Beta_2}

	mul r4, c12, r0.y 
	mul r5, c13, r0.w  
	sub r6, c8.x, r1
	mov r7, c9

	add r4, r4, r5
	mul r4, r4, r6
	mul r4, r4, c14	// r4 = I {inscattering}


	// Apply Inscattering contribution factors.
	mul r4, r4, c15.y


	//dark sky opposite to sun
	mov r1, v0
	dp3 r1.w, r1, r1            // Normalize pos
	rsq r1.w, r1.w							
	mul r1, r1, r1.w

	dp3 r2.x, r1, c4
	//mad r2.x,r2.x,c17.x,c17.z // *0.25 + 0.75 , map [-1,1] to [0.5,1]
	mad r2.x,r2.x,-c17.x, c17.x // *-0.25 + 0.25 , map [-1,1] to [0.5,0]
	mul r2.x, r2.x, c18.y // * dark factor
	
	add r2.x, c17.w, -r2.x // 1-x
	mul r4, r4, r2.x //weaken inscattering


	// Scale with Sun color & intesity.
	mul r4, r4, c16		
	mul r4, r4, c16.w	

	mul r3, r3, c16		
	mul r3, r3, c16.w	

/*

//---- dot3 -----
	// v8 Tangent,  x
	// v9 Binormal, y
	// v1 normal,   z
	// c4 sun direction {L}

	// matrix for object space to surface space
	// { Tan.x  Tan.y  Tan.z } = { v3.x v3.y v3.z }   { L.x }
	// { Bin.x  Bin.y  Bin.z } = { v4.x v4.y v4.z } * { L.y }
	// { nor.x  nor.y  nor.z } = { v1.x v1.y v1.z }   { L.z }
	dp3  r1.y, v8, c4
	dp3  r1.x, v9, -c4
	dp3  r1.z, v1, c4

	// r1 L vector in texture space

	// normalize vector in r1
	dp3  r1.w, r1, r1		// r1.w = |r1|^2
	rsq  r1.w, r1.w			// r1.w = 1/sqrt{r0.w} = 1/|r1|
	mul  r1.xyz, r1, r1.w	// r1 - normalized L vector in texture space
*/


	// Outputs.
	mov oD0, r3                             ; Extinction
	//mul oD0, r3, v1
	mov oD1, r4                             ; Inscattering

	mul oT0, v2, c24.x
	mov oT1, v2
	mov oT2, v2

	mov oT3, r1
	};



sampler texgrass=sampler_state {
	Texture = <tTX0>;
};

sampler texbase=sampler_state {
	Texture = <tTX1>;
};

sampler texlightmap=sampler_state {
	Texture = <tTX2>;
};


float4 mainps(float4 pos: POSITION, float3 n: NORMAL, 
			  float2 uv0: TEXCOORD0, float2 uv1: TEXCOORD1, float2 uv2: TEXCOORD2,
			  float3 diffuse : COLOR0, float3 specular : COLOR1 ) : COLOR0
{

	float4 grass=tex2D(texgrass,uv0);
	float4 base=tex2D(texbase,uv1);
	float4 lightmap=tex2D(texlightmap,uv2);

	float3 color=lerp(base,grass,base.a);
	color*=diffuse;
	color*=lightmap;
	color*=(2-base.a);
	color+=specular;

    return float4(color,1);
}


technique T0
{
  pass P0
  {
	// vertex shader
	VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
	VertexShaderConstant[4] = <vSunDir>;
	VertexShaderConstant[5] = {0.5f,0.5f,0.5f,0.5f};
	VertexShaderConstant[6] = <_vecEye>;
	VertexShaderConstant[8] = {1,1.4427f,0.5f,0}; //cv constons
	VertexShaderConstant[9] = <vBeta1Beta2>; //CV_BETA_1_PLUS_2
	VertexShaderConstant[10] = <vTerrainRef>;
	VertexShaderConstant[11] = <vHG>;
	VertexShaderConstant[12] = <vBetaDash1>;
	VertexShaderConstant[13] = <vBetaDash2>;
	VertexShaderConstant[14] = <vOneOverBeta>;
	VertexShaderConstant[15] = <vTermMulti>;
	VertexShaderConstant[16] = <vSunColor>;
	VertexShaderConstant[17] = <appConst>;
	VertexShaderConstant[18] = <vSunny>;

	VertexShaderConstant[20] = <matView>;

	VertexShaderConstant[24] = <vTexCoordScale>;
	
	VertexShader = <vsdiffuse>;
    PixelShader  = compile ps_2_0 mainps();
  } // of pass0
}




technique T1
{
  pass P0
  {
	// vertex shader
	VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
	VertexShaderConstant[4] = <vSunDir>;
	VertexShaderConstant[5] = {0.5f,0.5f,0.5f,0.5f};
	VertexShaderConstant[6] = <_vecEye>;
	VertexShaderConstant[8] = {1,1.4427f,0.5f,0}; //cv constons
	VertexShaderConstant[9] = <vBeta1Beta2>; //CV_BETA_1_PLUS_2
	VertexShaderConstant[10] = <vTerrainRef>;
	VertexShaderConstant[11] = <vHG>;
	VertexShaderConstant[12] = <vBetaDash1>;
	VertexShaderConstant[13] = <vBetaDash2>;
	VertexShaderConstant[14] = <vOneOverBeta>;
	VertexShaderConstant[15] = <vTermMulti>;
	VertexShaderConstant[16] = <vSunColor>;
	VertexShaderConstant[17] = <appConst>;
	VertexShaderConstant[18] = <vSunny>;

	VertexShaderConstant[20] = <matView>;

	VertexShaderConstant[24] = <vTexCoordScale>;
	
	VertexShader = <vsdiffuse>;


		// stage0
		ColorOp[0] = SelectArg1;
		ColorArg1[0] = Texture;
		Texture[0] = <tTX0>;

		// stage1
		ColorOp[1] = BlendTextureAlpha;
		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		Texture[1] = <tTX1>;

		// stage2
		ColorOp[2] = Modulate;
		Texture[2] = <tTX2>;

		// stage3
		ColorOp[3] = Modulate;
		ColorArg1[3] = Diffuse; //Extinction
		ColorArg2[3] = Current;

		// stage4
		ColorOp[4] = Add;
		ColorArg1[4] = Specular;  //Inscattering
		ColorArg2[4] = Current;

		// state5
		ColorOp[5] = Disable;

  } // of pass0
}



technique T2
{
  pass P0
  {
	// vertex shader
	VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
	VertexShaderConstant[4] = <vSunDir>;
	VertexShaderConstant[5] = {0.5f,0.5f,0.5f,0.5f};
	VertexShaderConstant[6] = <_vecEye>;
	VertexShaderConstant[8] = {1,1.4427f,0.5f,0}; //cv constons
	VertexShaderConstant[9] = <vBeta1Beta2>; //CV_BETA_1_PLUS_2
	VertexShaderConstant[10] = <vTerrainRef>;
	VertexShaderConstant[11] = <vHG>;
	VertexShaderConstant[12] = <vBetaDash1>;
	VertexShaderConstant[13] = <vBetaDash2>;
	VertexShaderConstant[14] = <vOneOverBeta>;
	VertexShaderConstant[15] = <vTermMulti>;
	VertexShaderConstant[16] = <vSunColor>;
	VertexShaderConstant[17] = <appConst>;
	VertexShaderConstant[18] = <vSunny>;

	VertexShaderConstant[20] = <matView>;

	VertexShaderConstant[24] = <vTexCoordScale>;
	
	VertexShader = <vsdiffuse>;

		// stage0
		ColorOp[0] = SelectArg1;
		ColorArg1[0] = Texture;
		Texture[0] = <tTX0>;

		// stage1
		ColorOp[1] = BlendTextureAlpha;
		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		Texture[1] = <tTX1>;

		// stage2
		ColorOp[2] = Disable;
  } // of pass0


	pass P1
	{
		SrcBlend = Zero;
		DestBlend = SrcColor;
		AlphaBlendEnable = True;

		// stage0
		ColorOp[0] = SelectArg1;
		ColorArg1[0] = Diffuse; //Extinction

		// stage1
		ColorOp[1] = Disable;
	}

	pass P2
	{
		SrcBlend = One;
		DestBlend = One;
		AlphaBlendEnable = True;

		// stage0
		ColorOp[0] = SelectArg1;
		ColorArg1[0] = Specular;  //Inscattering

		// stage1
		ColorOp[1] = Disable;
	}

}

