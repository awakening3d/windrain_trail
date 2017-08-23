

local mIDList=array.new()
local mtTableList={}


_MovTars = {}
_MovTars._OnCollide = function(id, htrace)
	local mt=mtTableList[id];
	if (mt and mt.OnCollide) then
		return mt.OnCollide(htrace)
	end
end


local function new( movtar )
	if (type(movtar) ~= "userdata") then error("movetarget expected") end

	local getPointer =	function()
							return movtar:get_pointer()
						end
	local getID =		function()
							return movtar:get_id()
						end

	local getName	=	function()
							return movtar:get_name()
						end
	local setName	=	function(name)
							movtar:set_name(name)
						end

	
	local getPosition = function()
							return vec.new(movtar:get_position())
						end
	local setPosition = function(pos)
							if (type(pos) ~= "table") then error("vec expected") end
							movtar:set_position(pos.x,pos.y,pos.z)
						end
	local getVelocity = function()
							return vec.new(movtar:get_velocity())
						end
	local setVelocity = function(vel)
							if (type(vel) ~= "table") then error("vec expected") end
							movtar:set_velocity(vel.x,vel.y,vel.z)
						end
	local getLastPosition = function()
								return vec.new(movtar:get_last_position())
							end
	local getLastVelocity = function()
								return vec.new(movtar:get_last_velocity())
							end
	local getMass	=	function()
							return movtar:get_mass()
						end
	local setMass	=	function(f)
							movtar:set_mass(f)
						end
	local getResistance	=	function()
								return movtar:get_resistance()
							end
	local setResistance	=	function(f)
								movtar:set_resistance(f)
							end
	local getAccel = function()
							return vec.new(movtar:get_accel())
						end
	local setAccel = function(vel)
							if (type(vel) ~= "table") then error("vec expected") end
							movtar:set_accel(vel.x,vel.y,vel.z)
						end
	local getBoundingBox =	function()
								local handle=movtar:get_bbox()
								if (NULL==handle) then return nil end
								return bbox.new(handle)
							end
	local setBoundingBox =	function(bb)
								if (type(bb) ~= "table") then error("bounding box expected") end
								movtar:set_bbox(bb.getUD())
							end
	local getGravityScale =	function()
								return movtar:get_gravity_scale()
							end
	local setGravityScale = function(gs)
								movtar:set_gravity_scale(gs)
							end
	local getStrideHeight =	function()
								return movtar:get_stride_height()
							end
	local setStrideHeight = function(sh)
								movtar:set_stride_height(sh)
							end
	local getGradientLimit=	function()
								return movtar:get_gradient_limit()	
							end
	local setGradientLimit=	function(gl)
								movtar:set_gradient_limit(gl)
							end
	local getOverBounce =	function()
								return movtar:get_over_bounce()
							end
	local setOverBounce =	function(ob)
								movtar:set_over_bounce(ob)
							end
	local getBounceAtten =	function()
								return movtar:get_bounce_atten()
							end
	local setBounceAtten =	function(ba)
								movtar:set_bounce_atten(ba)
							end
	local isFreezing	=	function()
								return movtar:is_freezing()
							end
	local freezing		=	function(bfreezing)
								movtar:freezing(bfreezing)
							end
	local isPoint		=	function()
								return movtar:is_point()
							end
	local pointed		=	function(p)
								movtar:pointed(p)
							end
	local getRadius		=	function()
								return movtar:get_radius()
							end
	local setRadius		=	function(radius)
								movtar:set_radius(radius)
							end
	local isStrideBlock	=	function()
								return movtar:is_stride_block()
							end
	local setStrideBlock =	function(sb)
								movtar:set_stride_block(sb)
							end
	local isRebound		=	function()
								return movtar:is_rebound()
							end
	local setRebound	=	function(rb)
								movtar:set_rebound(rb)
							end
	local isNoBounce	=	function()
								return movtar:is_nobounce()
							end
	local setNoBounce	=	function(nb)
								movtar:set_nobounce(nb)
							end
	local getNoClipMask =	function()
								return movtar:get_noclip_mask()
							end
	local setNoClipMask =	function(mask)
								movtar:set_noclip_mask(mask)
							end
	local getStyle =	function()
								return movtar:get_style()
							end
	local setStyle =	function(mask)
								movtar:set_style(mask)
							end


	local idx=mIDList.find(getID()) --已经有这个movtar
	if (idx) then
		local r=mtTableList[ getID() ];
		return r
	end
	

	local r=_new_udhead_tb(movtar)

	r.getPointer=getPointer
	r.getID=getID
	r.getName=getName
	r.setName=setName

	r.getPosition=getPosition
	r.setPosition=setPosition
	r.getVelocity=getVelocity
	r.setVelocity=setVelocity
	r.getLastPosition=getLastPosition
	r.getLastVelocity=getLastVelocity
	r.getMass=getMass
	r.setMass=setMass
	r.getResistance=getResistance
	r.setResistance=setResistance
	r.getAccel=getAccel
	r.setAccel=setAccel
	r.getBoundingBox=getBoundingBox
	r.setBoundingBox=setBoundingBox
	r.getGravityScale=getGravityScale
	r.setGravityScale=setGravityScale
	r.getStrideHeight=getStrideHeight
	r.setStrideHeight=setStrideHeight
	r.getGradientLimit=getGradientLimit
	r.setGradientLimit=setGradientLimit
	r.getOverBounce=getOverBounce
	r.setOverBounce=setOverBounce
	r.getBounceAtten=getBounceAtten
	r.setBounceAtten=setBounceAtten
	r.isFreezing=isFreezing
	r.freezing=freezing
	r.isPoint=isPoint
	r.pointed=pointed
	r.getRadius=getRadius
	r.setRadius=setRadius
	r.isStrideBlock=isStrideBlock
	r.setStrideBlock=setStrideBlock
	r.isRebound=isRebound
	r.setRebound=setRebound
	r.isNoBounce=isNoBounce
	r.setNoBounce=setNoBounce
	r.getNoClipMask=getNoClipMask
	r.setNoClipMask=setNoClipMask
	r.getStyle=getStyle
	r.setStyle=setStyle

	mIDList.add(getID())
	mtTableList[getID()]=r

	r._clear = function()
		local i=mIDList.find(getID())
		if i then
			mIDList.remove(i)
		end
		mtTableList[getID()]=nil
	end


	return r
end

-- export ----
_new_movtar_tb=new
