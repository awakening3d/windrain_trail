texture tTX1;
texture tTX2;


sampler basemap;
sampler cubemap=sampler_state { Texture = <tTX1>; };
sampler cubemapdiffuse=sampler_state { Texture = <tTX2>; };


matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matWorld; //World Matrix

vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)



   // Definition of the vertex shader, declarations then assembly
   VertexShader vsdiffuse =
   asm
   {
   vs_1_1
   
	dcl_position	v0
	dcl_normal		v1
	dcl_texcoord	v2


   // c0-c3 contains composite transform matrix
   m4x4 oPos, v0, c0   // transform vertices by view/projection matrix

   mov r0, c8
   m4x4 r1, r0, c4		//eye pos in object space
   sub r2, v0, r1		// Vi = vertex - eye

	mov oT3, -r2 //view dir

   dp3 r2.w, r2, v1		// Vo = Vi - 2 * (Vi.N) *N
   add r2.w, r2.w, r2.w
   mul r3, r2.w, v1
   sub r1, r2, r3

	mov r2, r1
	m3x3 r1, r2, c12

   mov oT0, v2 //for base map
   mov oT1, r1 //for reflection cubemap
   mov oT2, v1 //vertex normal
   };



float glossScale=1.8;
float glossBias=-1;
float reflectionStrength=1;


float4 mainps (float4 tc0 : TEXCOORD0, float4 tc1 : TEXCOORD1, float4 tc2 : TEXCOORD2, float4 tc3 : TEXCOORD3) : COLOR
{
	float4 base = tex2D(basemap,tc0);
	float4 reflection = texCUBE(cubemap, tc1);

	vector v=normalize(tc3); // view dir
	vector n=normalize(tc2); // normal
	
	float f = 1 - dot(n,v); //Fresnel effect
	
	float refscale = base.r * glossScale + glossBias;
	refscale*=refscale;
	refscale*=f;
	refscale*=reflectionStrength;
	
	reflection *= refscale;
	
	reflection -= 0.1;
	reflection = saturate(reflection);
	
	float4 diffuse = texCUBE(cubemapdiffuse, n);

	return diffuse*base/2+reflection;
}



technique T0
{
    pass P0
    {          
		VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
		VertexShaderConstant[4] = <matWorldInv>;
		VertexShaderConstant[8] = <_vecEye>;
		VertexShaderConstant[12] = <matWorld>;
		VertexShader = <vsdiffuse>;
        
        PixelShader  = compile ps_2_0 mainps(); 
    }
}






