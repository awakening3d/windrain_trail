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

   dp3 r2.w, r2, v1		// Vo = Vi - 2 * (Vi.N) *N
   add r2.w, r2.w, r2.w
   mul r3, r2.w, v1
   sub r1, r2, r3

	mov r2, r1
	m3x3 r1, r2, c12

	// normalize vector in r1
	//dp3  r1.w, r1, r1		// r1.w = |r1|^2
	//rsq  r1.w, r1.w			// r1.w = 1/sqrt(r1.w) = 1/|r1|
	//mul  r1.xyz, r1, r1.w
	// 归一化反而会有扭曲效果

   mov oT0, r1
   };


technique T0
{
   pass P0
   {
   // stage0
   ColorOp[0] = SelectArg1;
   ColorArg1[0] = Texture;
   // stage1
   ColorOp[1] = Disable;

   MipFilter[0]=None;

   VertexShaderConstant[0] = <matTotal>;   // World*View*Proj Matrix
   VertexShaderConstant[4] = <matWorldInv>;
   VertexShaderConstant[8] = <_vecEye>;
   VertexShaderConstant[12] = <matWorld>;
   VertexShader = <vsdiffuse>;
   }
}

