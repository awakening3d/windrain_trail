//--- system variables, player feed value ----

//texture tTXn (n = 0..7)

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
vector vTerrainRef = {0.0138f,0.0113f,0.008f,1};
vector vHG = {0.36f,1.8f,1.6f,1};
vector vBetaDash1 = {0.0000083f,0.000014f,0.000029f,1};
vector vBetaDash2 = {0.000013f,0.000017f,0.000024f,1};
vector vOneOverBeta = {5080.43f,3228.15f,1683.35f,1};
vector vTermMulti = {1,0.3,0,0};
vector vSunColor = {1,1,1,30.0f};
vector vSunDir = {-0.0471744f, 0.799484f, 0.598423f,1};

vector vSunny = {0.25f, 1.0f, 0.0f, 0.0f}; //x - brighter sky near horizen, y - distance scale


vector vSunDirNM = {0.0471744f,0.598423f,0.799484f,1};
DWORD dwSunDir=0xff85cbe5;


     // Definition of the vertex shader, declarations then assembly
    VertexShader vsdiffuse =
    asm
    {
	vs_1_1

	dcl_position v0
	dcl_color v1
	dcl_texcoord v2


	// c0-c3 contains composite transform matrix
	m4x4 oPos, v0, c0   // transform vertices by view/projection matrix

	// Calculate V
	sub r1, c6, v0	        // V = eye - position

	dp3 r1.w, r1, r1            // Normalize V
	rsq r1.w, r1.w							
	mul r1, r1, r1.w

	mov r8,r1 //store V to r8


	// Angle (theta) between sun direction (L) and view direction (V).
	dp3 r0.x, r1, c4       // r0.x = [cos(theta)] = V.L
	mad r0.y, r0.x, r0.x, c8.x	// r0.y = [1+cos^2(theta)] = Phase1(theta)

	// Distance (s)
	m4x4 r1, v0, c20           // r1.z = s
	mov r0.z, r1.z			// store in r0.z for future use.

	// Terms used in the scattering equation.
	// r0 = [cos(theta), 1+cos^2(theta), s] 

	// Extinction term E

	mul r1, c9, -r0.z       // -(beta_1+beta_2) * s
	mul r1, r1, c8.y           // -(beta_1+beta_2) * s * log_2 e
	exp r1.x, r1.x					
	exp r1.y, r1.y					
	exp r1.z, r1.z                          // r1 = e^(-(beta_1 + beta_2) * s) = E1

	// Apply Reflectance to E to get total net effective E
	mul r3, r1, c10  //r3 = E (Total extinction) 

	// Phase2(theta) = (1-g^2)/(1+g-2g*cos(theta))^(3/2)
	// theta is 180 - actual theta (this corrects for sign)
	// c[CV_HG] = [1-g^2, 1+g, 2g]
	mad r4.x, c11.z, r0.x, c11.y; 

	rsq r4.x, r4.x						
	mul r4.y, r4.x, r4.x			
	mul r4.x, r4.y, r4.x;
	mul r0.w, r4.x, c11.x              ; r0.w = Phase2(theta)


	// Inscattering (I) = (Beta'_1 * Phase_1(theta) + Beta'_2 * Phase_2(theta)) * 
	//        [1-exp(-Beta_1*s).exp(-Beta_2*s)] / (Beta_1 + Beta_2)

	mul r4, c12, r0.y 
	mul r5, c13, r0.w  
	sub r6, c8.x, r1
	mov r7, c9

	add r4, r4, r5
	mul r4, r4, r6
	mul r4, r4, c14	// r4 = I (inscattering)


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


	//brighter sky near horizen
	//add r1.x, c17.w, r8.y // 1 - y
	//mul r1.x, r1.x, r1.x
	//mul r1, r1.x, c16 // intensity * sun color
	//mad r4, c18.x, r1, r4 // add to inscattering


	// Outputs.
	//mov oD0, r3                             ; Extinction
	mad oD0, r3, v1, c15.z
	add oD1, r4, c15.w                             ; Inscattering

	mov oT0, v2
	mov oT1, v2
	mov oT2, v2
	};



    PixelShader psdiffuse =
    asm
    {
	ps_1_0

	tex t0		// texture terrain color
	tex t1		// Texture Normal_horizon_map
	//tex t2		// texture cloud later
	

	dp3_sat	r0.rgb, c1, t1_bx2	// Lighting (N.L)
	mul r0.rgb, r0, t0				// apply Terrain texture
	+sub_sat r0.a, c1.a, t1.a		// Shadow term (from Horizon angle)
	mul r0, r0, 1-r0.a				// apply Shadow.				
	//mul r0, r0, 1-t2				// apply cloud covering
	mul r0, r0, v0					// Apply extinction
	add r0, r0, v1					// Final color= add inscattering		

	};



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
	VertexShader = <vsdiffuse>;

	// pixel shader
	PixelShaderConstant[1] = <vSunDirNM>;
	PixelShader = <psdiffuse>;
    Texture[0] = <tTX0>;
	Texture[1] = <tTX1>;


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
	VertexShader = <vsdiffuse>;



   TextureFactor = <dwSunDir>;

  	  // stage0
	  ColorOp[0] = DotProduct3;
	  ColorArg1[0] = Texture;
	  ColorArg2[0] = TFactor;
	  Texture[0] = <tTX1>;

	  // stage1
	  ColorOp[1] = Modulate;
	  ColorArg1[1] = Diffuse; //Extinction
	  ColorArg2[1] = Current;

	  // stage2
	  ColorOp[2] = Modulate;
	  ColorArg1[2] = Texture;
	  ColorArg2[2] = Current;
	  Texture[2] = <tTX0>;
 	  
	  // stage3
	  ColorOp[3] = Add;
	  ColorArg1[3] = Specular; //Inscattering
	  ColorArg2[3] = Current;

	  // state4
	  ColorOp[4] = Disable;

  } // of pass0
}



technique T2 //can run on Geforce
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
	VertexShader = <vsdiffuse>;


   TextureFactor = <dwSunDir>;

  	  // stage0
	  ColorOp[0] = DotProduct3;
	  ColorArg1[0] = Texture;
	  ColorArg2[0] = TFactor;
	  Texture[0] = <tTX1>;

	  // stage1
	  ColorOp[1] = Modulate;
	  ColorArg1[1] = Diffuse; //Extinction
	  ColorArg2[1] = Current;

	  // stage2
	  ColorOp[2] = Disable;

  } // of pass0

  pass P1
  {
	  // stage0
	  ColorOp[0] = SelectArg1;
	  ColorArg1[0] = Texture;
	  ColorArg2[0] = Current;
	  Texture[0] = <tTX0>;

	  // state1
	  ColorOp[1] = Disable;

	  SrcBlend = Zero;
	  DestBlend = SrcColor;
	  AlphaBlendEnable = True;

  } // of pass1


  pass P2
  {
	  // stage0
	  ColorOp[0] = SelectArg1;
	  ColorArg1[0] = Specular; //Inscattering
	  // state1
	  ColorOp[1] = Disable;

	  SrcBlend = One;
	  DestBlend = One;
	
  } // of pass2

}



technique T3 //can run on Geforce (fast)
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
	VertexShader = <vsdiffuse>;

	  // stage0
	  ColorOp[0] = Modulate;
	  ColorArg1[0] = Texture;
	  ColorArg2[0] = Diffuse; //Extinction
 	  
	  // stage1
	  ColorOp[1] = Add;
	  ColorArg1[1] = Specular; //Inscattering
	  ColorArg2[1] = Current;

	  // state2
	  ColorOp[2] = Disable;

  } // of pass0
}

