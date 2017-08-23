--post processing util

-- global function --

function post_setBrightnessContrast(m,brightness,contrast)
	local c=contrast-1
	m.setEffectVector('vecC',vec4.new(c,c,c,c))

	local b=brightness-0.5*contrast + 0.5
	m.setEffectVector('vecB',vec4.new(b,b,b,b))
end

function post_setDesaturate(m,desaturate)
	m.setFactor(desaturate,0,0,0)
end


function post_setBlur(m,factor)
	m.setEffectVector('vecBlurFactor',vec4.new(factor,0,0,0))
	m.setEffectVector('vecBlurFactor1',vec4.new(-factor,0,0,0))
	m.setEffectVector('vecBlurFactor2',vec4.new(0,factor,0,0))
	m.setEffectVector('vecBlurFactor3',vec4.new(0,-factor,0,0))
end

function post_setBlur2x(m,factor1,factor2)
	m.setEffectVector('vecBlurFactor',vec4.new(factor1,0,0,0))
	m.setEffectVector('vecBlurFactor1',vec4.new(factor2,0,0,0))
end

function post_setBlur4x(m,factor1,factor2,factor3,factor4)
	m.setEffectVector('vecBlurFactor',vec4.new(factor1,0,0,0))
	m.setEffectVector('vecBlurFactor1',vec4.new(factor2,0,0,0))
	m.setEffectVector('vecBlurFactor2',vec4.new(factor3,0,0,0))
	m.setEffectVector('vecBlurFactor3',vec4.new(factor4,0,0,0))
end

function post_setThresholdFlexible(m,threshold,lightcolor,darkcolor)
	m.setEffectVector('vecThreshold',vec4.new(0.299,0.587,0.114, threshold ))
	if (lightcolor) then m.setEffectVector('vecLightColor',lightcolor) end
	if (darkcolor) then m.setEffectVector('vecDarkColor',darkcolor) end
end

function post_setBrightPass(m,threshold,darkcolor)
	m.setEffectVector('vecThreshold',vec4.new(0.2125, 0.7154, 0.0721, threshold ))
	if (darkcolor) then m.setEffectVector('vecDarkColor',darkcolor) end
end

function post_setGlow(m,blur,weight,threshold)
	m.setEffectVector('vecBlurFactor', vec4.new(blur,0,-blur,0))
	m.setEffectVector('vecBlurFactor1', vec4.new(blur*2,0,-blur*2,0))
	m.setEffectVector('vecBlurFactor2', vec4.new(blur*3,0,-blur*3,0))
	m.setEffectVector('vecBlurFactor3', vec4.new(blur*4,0,-blur*4,0))
	m.setEffectVector('vecBlurFactor4', vec4.new(blur*5,0,-blur*5,0))
	m.setEffectVector('vecBlurFactor5', vec4.new(blur*6,0,-blur*6,0))
	m.setEffectVector('vecBlurFactor6', vec4.new(blur*7,0,-blur*7,0))
	m.setEffectVector('vecBlurFactor7', vec4.new(blur*8,0,-blur*8,0))

	m.setEffectVector('vecWeight', vec4.new(weight*9,weight*9,weight*9,0.5))
	m.setEffectVector('vecWeight1', vec4.new(weight*8,weight*8,weight*8,0.5))
	m.setEffectVector('vecWeight2', vec4.new(weight*7,weight*7,weight*7,0.5))
	m.setEffectVector('vecWeight3', vec4.new(weight*6,weight*6,weight*6,0.5))
	m.setEffectVector('vecWeight4', vec4.new(weight*5,weight*5,weight*5,0.5))
	m.setEffectVector('vecWeight5', vec4.new(weight*4,weight*4,weight*4,0.5))
	m.setEffectVector('vecWeight6', vec4.new(weight*3,weight*3,weight*3,0.5))
	m.setEffectVector('vecWeight7', vec4.new(weight*2,weight*2,weight*2,0.5))

	if (threshold) then
		m.setEffectVector('vecThreshold', vec4.new(0.299,0.587,0.114, threshold))
	end
end


function post_setBlur2x2(m,width,height)
	m.setEffectVector( 'vUVOffset', vec4.new(-0.5/width,-0.5/height,0,0) )
	m.setEffectVector( 'vUVOffset1', vec4.new( 0.5/width,-0.5/height,0,0) )
	m.setEffectVector( 'vUVOffset2', vec4.new(-0.5/width, 0.5/height,0,0) )
	m.setEffectVector( 'vUVOffset3', vec4.new( 0.5/width, 0.5/height,0,0) )
end
