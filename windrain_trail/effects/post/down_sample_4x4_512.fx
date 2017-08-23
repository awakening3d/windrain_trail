
texture tTX0;

sampler SourceTex=sampler_state { Texture = <tTX0>; };


static const int    MAX_SAMPLES            = 16;    // Maximum texture grabs
float2 g_avSampleOffsets[MAX_SAMPLES]={
-0.0029296875,-0.0029296875,
-0.0009765625,-0.0029296875,
0.0009765625,-0.0029296875,
0.0029296875,-0.0029296875,
-0.0029296875,-0.0009765625,
-0.0009765625,-0.0009765625,
0.0009765625,-0.0009765625,
0.0029296875,-0.0009765625,
-0.0029296875,0.0009765625,
-0.0009765625,0.0009765625,
0.0009765625,0.0009765625,
0.0029296875,0.0009765625,
-0.0029296875,0.0029296875,
-0.0009765625,0.0029296875,
0.0009765625,0.0029296875,
0.0029296875,0.0029296875,
};

/*
-- lua codes to generate SampleOffsets
local width=512
local height=512
local fn='e:\\tmp\\1.txt'

local file=io.open(fn,'w')

local tu=1/width
local tv=1/height

for y=0,3 do
	for x=0,3 do
		local u=(x-1.5)*tu
		local v=(y-1.5)*tv
		file:write( u, ',', v, ',', '\n')
	end
end

file:close()
*/

//-----------------------------------------------------------------------------
// Name: DownScale4x4
// Type: Pixel shader                                      
// Desc: Scale the source texture down to 1/16 scale
//-----------------------------------------------------------------------------
float4 DownScale4x4(in float2 vScreenPosition : TEXCOORD0  ) : COLOR
{

    float4 sample = 0.0f;

	for( int i=0; i < 16; i++ )
	{
		sample += tex2D( SourceTex, vScreenPosition + g_avSampleOffsets[i] );
	}
    
	return sample / 16;
}


technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 DownScale4x4(); 
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