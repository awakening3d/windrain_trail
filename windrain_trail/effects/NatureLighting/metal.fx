texture tTX1;
texture tTX2;


sampler basemap;
sampler cubemap=sampler_state { Texture = <tTX1>; };
sampler cubemapdiffuse=sampler_state { Texture = <tTX2>; };

matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matWorld; //World Matrix
matrix matWorldView;  //matWorld*matView

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
   
   m4x4 r0, v0, c12 //vertex pos in world space
   m3x3 r1, v1, c12 //vertex normal in world space
   
	// normalize vector in r1
	dp3  r1.w, r1, r1		// r1.w = |r1|^2
	rsq  r1.w, r1.w			// r1.w = 1/sqrt(r1.w) = 1/|r1|
	mul  r1.xyz, r1, r1.w
   
   sub r2, r0, c8 // Vi = pos - eye

   dp3 r2.w, r2, r1		// Vo = Vi - 2 * (Vi.N) *N
   add r2.w, r2.w, r2.w
   mul r3, r2.w, r1
   sub r4, r2, r3
   
   mov oT0, v2 //for base map
   mov oT1, r4 //for reflection cubemap
   mov oT2, r1 //vertex normal
   };



float glossScale=1.8;
float glossBias=-1.0;
float reflectionStrength=1.0;


float4 mainps (float4 tc0 : TEXCOORD0, float4 tc1 : TEXCOORD1, float4 tc2 : TEXCOORD2) : COLOR
{
	float4 base = tex2D(basemap,tc0);

	float refscale = base.a * glossScale + glossBias;
	refscale*=refscale;
	refscale*=reflectionStrength;

	float fny=saturate( (tc2.y+1)/2 );
	float3 vref=lerp( float3(tc2.x,tc2.y,tc2.z), normalize( float3(tc1.x,tc1.y,tc1.z) ),fny);
	float4 reflection = texCUBE(cubemap, vref);
	reflection*=refscale;
	
	float4 diffuse = texCUBE(cubemapdiffuse, tc2)*0.5+0.5;

	return diffuse*(base/4+reflection);
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






