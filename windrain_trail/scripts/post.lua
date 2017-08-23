

local function new( post )
	if (type(post) ~= "userdata") then error("post expected") end

	local getMaterial = function()
							local handle=post:get_material()
							if (NULL==handle)	then return nil end
							return MaterialFromHandle(handle)
						end
	local setMaterial = function(mater)
							if (nil==mater) then return post:set_material(_new_material_ud(nil)) end
							if (type(mater) ~= "table") then error("material expected") end
							post:set_material(mater.getUD())
						end



	local r=_new_resource_tb(post)

	r.getMaterial=getMaterial
	r.setMaterial=setMaterial

	return r
end

-- export ----
_new_post_tb=new

--styles--
POSTS_DISABLE	= toDWORD('00000001') -- disable

