//hue_saturation_brightnees adjust
sampler texOrg : register(s0);

vector vecFactor = { 0.1f, 0.5f, 0, 1.0f }; // hue(-1~1), saturation(-1~1),  brightness(-1~1)
vector vecColorful = { 1, 1, 1, 1 }; // modulate color


float MinRGB(float3 rgba)     
{     
    float t = (rgba.x < rgba.y) ? rgba.x : rgba.y;     
    t = ( t < rgba.z) ? t : rgba.z;     
    return t;     
}     
                                               
float MaxRGB(float3 rgba)     
{     
    float t = (rgba.x > rgba.y) ? rgba.x : rgba.y;     
    t = ( t > rgba.z) ? t : rgba.z;     
    return t;     
}     
                                              
float3 RGBtoHSL(float3 rgb)     
{     
    float Max = MaxRGB(rgb);     
    float Min = MinRGB(rgb);     
                                              
    float sum = Max + Min;     
    float L = sum / 2.0;     
    float H = 0.0;     
    float S = 0.0;     
                                              
    if( Max != Min ) {     
        float delta = Max - Min;     
        if( L < 0.5 )     
            S = delta / sum;     
        else
            S = delta / ( 2.0 - sum);     
                                              
        if( rgb.r == Max )     
            H = ( rgb.g - rgb.b ) / delta;     
        else if( rgb.g == Max )     
            H = 2.0 + ( rgb.b - rgb.r ) / delta;     
        else
            H = 4.0 + ( rgb.r - rgb.g ) / delta;     
    }     
                                              
    H *= 60.0;     
                                              
    float t = vecFactor.x*180.0;     
                                              
    H += t;     
                                              
    if( H < 0.0 )     
        H += 360.0;     
    else if( H > 360.0 )     
        H -= 360.0;     
                                              
    float3 HSL = float3(H,S,L);     
    return HSL;     
}     
                                              
float3 HSLtoRGB(float3 HSL)     
{     
    float H = HSL.x;     
    float S = HSL.y;     
    float L = HSL.z;     
    float R = L;     
    float G = L;     
    float B = L;     
                                              
    if( S != 0.0 ) {     
        float q = 0.0;     
        if( L < 0.5 )     
            q = L * ( 1 + S );     
        else
            q = L + ( 1 - L ) * S;     
        float p = 2.0 * L - q;     
        H /= 360.0;     
        float tc[3];     
        tc[0] = H + 1.0/3.0;     
        tc[1] = H;     
        tc[2] = H - 1.0/3.0;     
        for(int i = 0; i < 3; i++) {     
            if( tc[i] < 0.0 )     
                tc[i] += 1.0;     
            if( tc[i] > 1.0 )     
                tc[i] -= 1.0;     
            if( tc[i] * 6.0  < 1.0 )     
                tc[i] = p + (( q - p ) * 6.0 * tc[i]);     
            else if( tc[i] * 2.0 < 1.0 )     
                tc[i] = q;     
            else if( tc[i] * 3.0 < 2.0 )     
                tc[i] = p + ( q - p ) * (( 2.0 / 3.0 ) - tc[i]) * 6.0;     
            else
                tc[i] = p;     
        }     
                                              
        R = tc[0];     
        G = tc[1];     
        B = tc[2];     
    }     
                                              
    float3 RGB = float3(R,G,B);     
                                              
    float t = vecFactor.y;     
    if( t > 0.0 ) {     
        if( S > 0.0 ) {     
            t = t + S >= 1 ? S : 1 - t;     
            t = 1/t - 1;     
        }     
    }     

    RGB += ( RGB - L ) * t;     
    RGB.r = RGB.r > 1.0 ? 1.0 : RGB.r < 0.0 ? 0.0 : RGB.r;     
    RGB.g = RGB.g > 1.0 ? 1.0 : RGB.g < 0.0 ? 0.0 : RGB.g;     
    RGB.b = RGB.b > 1.0 ? 1.0 : RGB.b < 0.0 ? 0.0 : RGB.b;     
                                              
    return RGB;     
}     
                                              

float4 FSB( in float2 vScreenPosition : TEXCOORD0 ) : COLOR
{
	float4 color = tex2D(texOrg, vScreenPosition);

	if (0!=vecFactor.x || 0!=vecFactor.y) {
		float3 hsl = RGBtoHSL(color.rgb);     
		float3 rgb = HSLtoRGB(hsl);     
	      
		/*
		// 明度调整
		if( vecFactor.z > 0 )
		rgb = rgb + ( 1.0 - rgb ) * vecFactor.z;     
		else
		rgb = rgb + rgb * vecFactor.z;     
		*/

		color.rgb = rgb;
	}

	color *= vecColorful;
	return color;
}

technique T0
{
    pass P0
    {
        PixelShader  = compile ps_3_0 FSB();
    }
}

/* // post shader 加载失败应该会被跳过渲染，跟没有处理一样
technique T1
{
  pass P0
  {
  // stage0
  ColorOp[0] = SelectArg1;
  ColorArg1[0] = Texture;
  
  // stage1
  ColorOp[1] = Disable;
  }
}
*/