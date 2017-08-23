
texture tTX0;

sampler SourceTex=sampler_state { Texture = <tTX0>; };


static const int    MAX_SAMPLES            = 13;    // Maximum texture grabs
float2 g_avSampleOffsets[MAX_SAMPLES]={
-0.015625,0,
-0.0078125,-0.0078125,
-0.0078125,0,
-0.0078125,0.0078125,
0,-0.015625,
0,-0.0078125,
0,0,
0,0.0078125,
0,0.015625,
0.0078125,-0.0078125,
0.0078125,0,
0.0078125,0.0078125,
0.015625,0,
};

float g_avSampleWeights[MAX_SAMPLES]={
0.024882465600967,
0.067637555301189,
0.11151547729969,
0.067637555301189,
0.024882465600967,
0.11151547729969,
0.18385794758797,
0.11151547729969,
0.024882465600967,
0.067637555301189,
0.11151547729969,
0.067637555301189,
0.024882465600967,
};


/*
-- lua codes to generate SampleOffsets

local width=128
local height=128
local fn='e:\\tmp\\1.txt'


-------------------------------------------------------------------------------
-- Name: GaussianDistribution
-- Desc: Helper function for GetSampleOffsets function to compute the 
--       2 parameter Gaussian distrubution using the given standard deviation
--       rho
-------------------------------------------------------------------------------
function GaussianDistribution( x, y, rho )
    local g = 1.0 / math.sqrt( 2.0 * 3.141592654 * rho * rho );
    g = g*math.exp( -(x*x + y*y)/(2*rho*rho) );
    return g;
end



local file=io.open(fn,'w')

local tu=1/width
local tv=1/height
local avSampleWeight={}

local totalWeight = 0.0;
local index=0;
for x=-2,2 do
	for y=-2,2 do
            -- Exclude pixels with a block distance greater than 2. This will
            -- create a kernel which approximates a 5x5 kernel using only 13
            -- sample points instead of 25; this is necessary since 2.0 shaders
            -- only support 16 texture grabs.
            if ( math. abs(x) + math.abs(y) <= 2 ) then
	            --Get the unscaled Gaussian intensity for this offset
            
				local u=x*tu
				local v=y*tv;
				file:write( u, ',', v, ',', '\n')
	            
				avSampleWeight[index] = GaussianDistribution( x, y, 1.0 );
				totalWeight = totalWeight+avSampleWeight[index];

				index=index+1;
			end
	end
end

-- Divide the current weight by the total weight of all the samples; Gaussian
-- blur kernels add to 1.0f to ensure that the intensity of the image isn't
-- changed when the blur occurs. An optional multiplier variable is used to
-- add or remove image intensity during the blur.

file:write( 'avSampleWeights:\n')

index=index-1
for i=0,index do
    avSampleWeight[i] = avSampleWeight[i]/totalWeight;
    file:write(avSampleWeight[i], ',' , '\n')
end


file:close()

*/

//-----------------------------------------------------------------------------
// Name: GaussBlur5x5
// Type: Pixel shader                                      
// Desc: Simulate a 5x5 kernel gaussian blur by sampling the 12 points closest
//       to the center point.
//-----------------------------------------------------------------------------
float4 GaussBlur5x5(in float2 vScreenPosition : TEXCOORD0 ) : COLOR
{
    float4 sample = 0.0f;

	for( int i=0; i < MAX_SAMPLES; i++ )
	{
		sample += g_avSampleWeights[i] * tex2D( SourceTex, vScreenPosition + g_avSampleOffsets[i] );
	}
	
	return sample;
}



technique T0
{

  pass P0
  {
  PixelShader  = compile ps_2_0 GaussBlur5x5(); 
  }
  
}


