texture tTX1;

sampler basemap;
sampler cubemap=sampler_state { Texture = <tTX1>; };

matrix matTotal; //matWorld*matView*matProj;
matrix matWorldInv; //Inverse World Matrix
matrix matWorld; //World Matrix
matrix matWorldView;  //matWorld*matView

vector _vecEye; // the Eye Position (eye.x, eye.y, eye.z, 1)


//float glossScale=1.8;
//float glossBias=-1.0;
float reflectionStrength=1.4;
float refractionStrength=1.4;


vector vRefractiveCoeff={-0.2, -0.2, -0.2, 0.0};
vector vConst={0.0, 0.5, 1.0, 2.0};


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
   mov oT3, -r2 //view dir


   dp3 r10.w, r2, r1		// Vo = Vi - 2 * (Vi.N) *N
   mul r5, r10.w, r1
   mad r4, r5, -c10.w, r2

   mov oT0, v2 //for base map
   mov oT1, r4 //for reflection cubemap
   mov oT2, r1 //vertex normal
   
   
	// normalize vector in r2
	dp3  r2.w, r2, r2		// r1.w = |r1|^2
	rsq  r2.w, r2.w			// r1.w = 1/sqrt(r1.w) = 1/|r1|
	mul  r2.xyz, r2, r2.w
   
   
	//reflect view vector around shortened view vector to fake snells law (air to glass)
	mul  r6, r1, c9        //Nr (normal used for refaction vector calc)
	dp3  r10.w, r6, -r2     //Nr.V
	mul  r5, r10.w, r6     // Nr(Nr.V)
	mad  r5, r5, c10.w, r2 //Rg = 2Nr(Nr.V) - V (refraction vector inside glass)
   
    dp3  r10.x, r5, r5     //vector mag squared
    rsq  r10.y, r10.x      // 1/ vector mag squared
    mul  r5, r5, r10.y     //refraction vector Rg

    //reflect negative normal N around refraction vector Rg to get antipode vector A
    dp3  r10.z, -r1, r5    //-N.Rg
    mul  r7, r10.z, r5     // Rg(N.Rg)
    mad  r7, r7, c10.w, r1  //A = 2*Rg(-N.Rg)- -N (Antipode vector A (normalized) )

    //add shortened antipode to refracticn vector Rg to fake snells law (glass to air interface)
    mul  r8, r10.w, r7     //A(Nr.V)     //Nr.V is original Shortening factor
    mad  r8, r8, c10.w, r1  //Rf = Rg + 2*A(Nr.V)  (Rf is refraction vector outside of glass)
    
    mov oT4, -r8; //for refraction map
   };






float4 mainps (float4 tc0 : TEXCOORD0, float4 tc1 : TEXCOORD1, float4 tc2 : TEXCOORD2, float4 tc3 : TEXCOORD3, float4 tc4 : TEXCOORD4) : COLOR
{
	float4 base = tex2D(basemap,tc0);

	float3 v=normalize(float3(tc3.x,tc3.y,tc3.z)); // view dir
	float3 n=tc2; // normal
	
	float f = 1 - dot(n,v); //Fresnel effect
		
	//float refscale = base.a * glossScale + glossBias;
	//refscale*=refscale;

	float fny=saturate( (n.y+1)/2 );
	float3 vref=lerp(n,normalize( float3(tc1.x,tc1.y,tc1.z) ),fny);
	float4 reflection = texCUBE(cubemap, vref);
	reflection*= f*reflectionStrength;
	
	float4 refraction = texCUBE(cubemap, tc4);
	refraction *= (1-f) * refractionStrength;

	return reflection/2 + base*reflection/2 +refraction*base;
}



technique T0
{
    pass P0
    {          
		VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
		VertexShaderConstant[4] = <matWorldInv>;
		VertexShaderConstant[8] = <_vecEye>;
		VertexShaderConstant[9] = <vRefractiveCoeff>;
		VertexShaderConstant[10] = <vConst>;
		VertexShaderConstant[12] = <matWorld>;
		VertexShader = <vsdiffuse>;
        
        PixelShader  = compile ps_2_0 mainps(); 
    }
}






