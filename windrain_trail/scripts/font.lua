

local function new( fontud )
	if (type(fontud) ~= "userdata") then error("font expected") end
	
	local getFontName	= function()
					return fontud:get_fontname()
				  end
	local getMaxChars	= function()
					return fontud:get_maxchars()
				  end
	local getCharSize	= function()
					return fontud:get_char_size()
				  end
	local getSpaceScale	= function()
					return fontud:get_space_scale()
				  end
	local setSpaceScale	= function( spaceScale )
					return fontud:set_space_scale( spaceScale )
				  end
	local getTextExtent	= function( text )
					return fontud:get_text_extent( text )
				  end
	


	local r=_new_resource_tb(fontud)

	r.getFontName = getFontName
	r.getMaxChars = getMaxChars
	r.getCharSize = getCharSize
	r.getSpaceScale = getSpaceScale
	r.setSpaceScale = setSpaceScale
	r.getTextExtent = getTextExtent

	return r
end

-- export ----
_new_font_tb=new
