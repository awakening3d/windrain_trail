
local function NodeFromHandle(cloth,handle)

	local getPosition = function()
							return vec.new( cloth.get_node_position(handle) )
						end
	local setPosition =	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							return cloth.set_node_position(handle,v.x,v.y,v.z)
						end
	local getNormal =	function()
							return vec.new( cloth.get_node_normal(handle) )
						end
	local setNormal =	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							return cloth.set_node_normal(handle,v.x,v.y,v.z)
						end
	local getDir	=	function()
							return vec.new( cloth.get_node_dir(handle) )
						end
	local setDir =		function(v)
							if (type(v) ~= "table") then error("vec expected") end
							return cloth.set_node_dir(handle,v.x,v.y,v.z)
						end
	local isFixed =		function()
							return cloth.is_node_fixed(handle)
						end
	local setFixed =	function(bfixed)
							cloth.set_node_fixed(handle,bfixed)
						end


	local r={}
	r.getPosition=getPosition
	r.setPosition=setPosition
	r.getNormal=getNormal
	r.setNormal=setNormal
	r.getDir=getDir
	r.setDir=setDir
	r.isFixed=isFixed
	r.setFixed=setFixed

	return r	
end



local function new( cloth )
	if (type(cloth) ~= "userdata") then error("cloth expected") end
	
	local getTexture =	function()
							return cloth:get_texture()
						end
	local setTexture =	function( tex )
							cloth:set_texture(tex)
						end

	local getWidth =	function()
							return cloth:get_width()
						end
	local getHeight =	function()
							return cloth:get_height()
						end

	local setWidthHeight =	function( w, h )
								return cloth:set_width_height(w,h)
							end
	local getInterval = function()
							return cloth:get_interval()
						end
	local setInterval = function(fInterval)
							return cloth:set_interval(fInterval)
						end

	local getGravity =	function()
							return vec.new(cloth:get_gravity())
						end
	local setGravity =	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							cloth:set_gravity(v.x,v.y,v.z)
						end

	local getWind =	function()
							return vec.new(cloth:get_wind())
						end
	local setWind =	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							cloth:set_wind(v.x,v.y,v.z)
						end

	local isLocalSys =	function()
							return cloth:is_localsys()
						end
	local setLocalSys = function(bLocal)
							cloth:set_localsys(bLocal)
						end
	local isNoUpdate =	function()
							return cloth:is_noupdate()
						end
	local setNoUpdate = function(bNoUpdate)
							cloth:set_noupdate(bNoUpdate)
						end


	----- node ----
	local getNode	=	function(x,y)
							local handle=cloth:get_node(x,y)
							if (nil==handle) then return nil end
							return NodeFromHandle( cloth, handle )
						end

	---- planes ----
	local addPlane	=	function(plane)
							return cloth:add_plane(plane.getUD())
						end
	local delPlane	=	function(pos)
								return cloth:del_plane(pos)
						end
	local getPlanesHead =	function()
								return cloth:get_planes_head()
							end
	local getPlanesNext =	function(pos)
								local pplane,pos=cloth:get_planes_next(pos)
								return plane.new(pplane),pos
							end


	local r=_new_movable_tb(cloth)

	r.getTexture=getTexture
	r.setTexture=setTexture
	r.getWidth=getWidth
	r.getHeight=getHeight
	r.setWidthHeight=setWidthHeight
	r.getInterval=getInterval
	r.setInterval=setInterval
	r.getGravity=getGravity
	r.setGravity=setGravity
	r.getWind=getWind
	r.setWind=setWind
	r.isLocalSys=isLocalSys
	r.setLocalSys=setLocalSys
	r.isNoUpdate=isNoUpdate
	r.setNoUpdate=setNoUpdate

	---- node ----
	r.getNode=getNode

	---- planes ----
	r.addPlane=addPlane
	r.delPlane=delPlane
	r.getPlanesHead=getPlanesHead
	r.getPlanesNext=getPlanesNext

	return r
end

-- export ----
_new_cloth_tb=new
