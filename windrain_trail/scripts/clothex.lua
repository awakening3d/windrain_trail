
local function new( cloth )
	if (type(cloth) ~= "userdata") then error("clothex expected") end
	
	local getTexture =	function()
							return cloth:get_texture()
						end
	local setTexture =	function( tex )
							cloth:set_texture(tex)
						end


	local isNoUpdate =	function() return cloth:is_noupdate() end
	local setNoUpdate = function(bNoUpdate)	cloth:set_noupdate(bNoUpdate) end
	local isPlayCache = function() return cloth:is_playcache() end
	local setPlayCache = function(bPlay) cloth:set_playcache(bPlay) end 

	local saveCache = function( filename )
							return cloth:save_cache(filename)
						end

	local loadCache = function( filename )
							return cloth:load_cache(filename)
						end

	local r=_new_movable_tb(cloth)

	r.getTexture=getTexture
	r.setTexture=setTexture
	r.isNoUpdate=isNoUpdate
	r.setNoUpdate=setNoUpdate
	r.isPlayCache=isPlayCache
	r.setPlayCache=setPlayCache
	r.saveCache=saveCache;
	r.loadCache=loadCache;
	return r
end

-- export ----
_new_clothex_tb=new
