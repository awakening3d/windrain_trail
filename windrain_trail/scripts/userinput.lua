

local function new( uiud )
	if (type(uiud) ~= "userdata") then error("userinput expected") end
	
	local clear				=	function() return uiud:clear() end
	local getAxisRotateUD	=	function() return uiud:get_fAxisRotateUD() end
	local setAxisRotateUD	=	function(n) uiud:set_fAxisRotateUD(n) end
	local getAxisRotateLR	=	function() return uiud:get_fAxisRotateLR() end
	local setAxisRotateLR	=	function(n) uiud:set_fAxisRotateLR(n) end
	local getAxisRotateRoll	=	function() return uiud:get_fAxisRotateRoll() end
	local setAxisRotateRoll	=	function(n) uiud:set_fAxisRotateRoll(n) end

	local getAxisMoveFB	=	function() return uiud:get_fAxisMoveFB() end
	local setAxisMoveFB	=	function(n) uiud:set_fAxisMoveFB(n) end
	local getAxisMoveLR	=	function() return uiud:get_fAxisMoveLR() end
	local setAxisMoveLR	=	function(n) uiud:set_fAxisMoveLR(n) end
	local getAxisMoveUD	=	function() return uiud:get_fAxisMoveUD() end
	local setAxisMoveUD	=	function(n) uiud:set_fAxisMoveUD(n) end


	local getResetCamera	=	function() return uiud:get_bResetCamera() end
	local setResetCamera	=	function(b) uiud:set_bResetCamera(b) end
	local getHorizonCamera	=	function() return uiud:get_bHorizonCamera() end
	local setHorizonCamera	=	function(b) uiud:set_bHorizonCamera(b) end

	local getJump			=	function() return uiud:get_bJump() end
	local setJump			=	function(b) uiud:set_bJump(b) end
	local getDuck			=	function() return uiud:get_bDuck() end
	local setDuck			=	function(b) uiud:set_bDuck(b) end


	local r=_new_udhead_tb(uiud)

	r.clear = clear
	r.getAxisRotateUD=getAxisRotateUD
	r.setAxisRotateUD=setAxisRotateUD
	r.getAxisRotateLR=getAxisRotateLR
	r.setAxisRotateLR=setAxisRotateLR
	r.getAxisRotateRoll=getAxisRotateRoll
	r.setAxisRotateRoll=setAxisRotateRoll

	r.getAxisMoveFB=getAxisMoveFB
	r.setAxisMoveFB=setAxisMoveFB
	r.getAxisMoveLR=getAxisMoveLR
	r.setAxisMoveLR=setAxisMoveLR
	r.getAxisMoveUD=getAxisMoveUD
	r.setAxisMoveUD=setAxisMoveUD

	r.getResetCamera=getResetCamera
	r.setResetCamera=setResetCamera
	r.getHorizonCamera=getHorizonCamera
	r.setHorizonCamera=setHorizonCamera
	r.getJump=getJump
	r.setJump=setJump
	r.getDuck=getDuck
	r.setDuck=setDuck

	return r
end

-- export ----
--_new_userinput_tb=new


---- user input ----
function _UpdateUserInput(a,b,c, pUserInput)
	if (UpdateUserInput) then
		UpdateUserInput( new( _new_userinput_ud(pUserInput) ) )
	end
end
