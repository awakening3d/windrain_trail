// down sample 2x2 for 128 x 128 image

texture tTX0;


vector	vUVOffset   = { -0.00390625, -0.00390625, 0, 0 };
vector	vUVOffset1   = { 0.00390625, -0.00390625, 0, 0 };
vector	vUVOffset2   = { -0.00390625, 0.00390625, 0, 0 };
vector	vUVOffset3   = { 0.00390625, 0.00390625, 0, 0 };


/*
-- lua codes to generate SampleOffsets
local width=128
local height=128
local fn='e:\\tmp\\1.txt'

local file=io.open(fn,'w')

local tu=1/width
local tv=1/height

for y=0,1 do
	for x=0,1 do
		local u=(x-0.5)*tu
		local v=(y-0.5)*tv
		file:write( u, ',', v, ',', '\n')
	end
end

file:close()

*/

	PixelShader ps14=
	asm
	{
	ps.1.4
    texcrd r0.xyz, t0
    add r1.xyz, r0, c0
    add r2.xyz, r0, c1
    add r3.xyz, r0, c2
    add r4.xyz, r0, c3
    phase
    texld r0, r1
    texld r1, r2
    texld r2, r3
    texld r3, r4
    add r0, r0, r1
    add r0, r2, r0
    add_d4 r0, r3, r0
	};

technique T0
{

  pass P0
  {
	AddressU[0] = Clamp; AddressV[0] = Clamp;
	AddressU[1] = Clamp; AddressV[1] = Clamp;
	AddressU[2] = Clamp; AddressV[2] = Clamp;
	AddressU[3] = Clamp; AddressV[3] = Clamp;

	Texture[0] = <tTX0>;
	Texture[1] = <tTX0>;
	Texture[2] = <tTX0>;
	Texture[3] = <tTX0>;
	
	// pixel shader constant
	PixelShaderConstant[0] = <vUVOffset>;
	PixelShaderConstant[1] = <vUVOffset1>;
	PixelShaderConstant[2] = <vUVOffset2>;
	PixelShaderConstant[3] = <vUVOffset3>;

	PixelShader = <ps14>;

  }

 }

technique T1
{
  pass P0
  {
  // stage0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;
  Texture[0] = <tTX0>;

  // stage1
  ColorOp[1] = Disable;

  }
}
