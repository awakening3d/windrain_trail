require 'game_config'

local brightcont=nil
local fsb = nil
local fsbpost = nil

local function optionsetting_onSceneLoaded()
	-- 亮度对比度调节
	brightcont = scene.createMaterial()
	brightcont.setD3DEffect('\\post\\brightness_contrast.fx')
	local brightcontpost = scene.createPost()
	brightcontpost.setMaterial(brightcont)

	g_config.brightness_rectification=0
	g_config.contrast_rectification=0
	
	-- 色相饱和度调节
	fsb = scene.createMaterial()
	fsb.setD3DEffect('\\post\\hue_saturation.fx')
	fsbpost = scene.createPost()
	fsbpost.setMaterial(fsb)
	fsbpost.setStyle( orDWORD( fsbpost.getStyle(), POSTS_DISABLE ) ) -- default disable fsb
end

table.insert( g_config.scene_loaded_funs,  optionsetting_onSceneLoaded )


g_config.sysmsgcolor = COLOR_LIGHTBLUE

local Brightness=0	--	-0.5 ~ 0.5
local Contrast=1	--	0 ~ 2

local Hue = 0 --	-1 ~ 1
local Saturation = 0 --	-1 ~ 1
local Colorful = {1,1,1,1}

--- export ---
function set_brightness_contrast( bright, contrast )
	Brightness = bright
	Contrast = contrast

	bright = Brightness + g_config.brightness_rectification
	contrast = Contrast + g_config.contrast_rectification
	if bright>0.5 then bright=0.5 end
	if bright<-0.5 then bright=-0.5 end
	if contrast<0 then contrast=0 end
	if contrast>2 then contrast=2 end
	post_setBrightnessContrast( brightcont, bright,contrast )
end

function adjust_brightness(step)
	Brightness=Brightness+step
	if Brightness>0.5 then Brightness=0.5 end
	if Brightness<-0.5 then Brightness=-0.5 end
	set_brightness_contrast( Brightness,Contrast )
	if (OnBrightnessContrastChanged) then
		OnBrightnessContrastChanged( Brightness, Contrast )
	end
end

function adjust_contrast(step)
	Contrast=Contrast+step
	if Contrast<0 then Contrast=0 end
	if Contrast>2 then Contrast=2 end
	set_brightness_contrast( Brightness,Contrast )
	if (OnBrightnessContrastChanged) then
		OnBrightnessContrastChanged( Brightness, Contrast )
	end
end

function set_hue_saturation( hue, saturation, colorful )
	if hue then Hue = hue end
	if saturation then Saturation = saturation end
	if colorful then Colorful = colorful end

	fsb.setEffectVector( 'vecFactor', vec4.new( Hue, Saturation, 0, 1 ) )
	fsb.setEffectVector( 'vecColorful', vec4.new( Colorful[1], Colorful[2], Colorful[3], Colorful[4] ) )

	if math.abs(Hue) > 0.01 or math.abs(Saturation) > 0.01 or Colorful[1]~=1 or Colorful[2]~=1 or Colorful[3]~=1 or Colorful[4]~=1 then
		fsbpost.setStyle( andDWORD( fsbpost.getStyle(), notDWORD(POSTS_DISABLE)  ) ) -- enable fsb
	else
		fsbpost.setStyle( orDWORD( fsbpost.getStyle(), POSTS_DISABLE ) ) -- disable fsb
	end
end