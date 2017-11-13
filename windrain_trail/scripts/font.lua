

local function new( fontud )
	if (type(fontud) ~= "userdata") then error("font expected") end
	
	local getFontName	= function()
					return fontud:get_fontname()
				  end


	local r=_new_resource_tb(fontud)

	r.getFontName=getFontName

	return r
end

-- export ----
_new_font_tb=new
