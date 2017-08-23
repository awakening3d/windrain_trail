

local function new( tpud )
	if (type(tpud) ~= "userdata") then error("texture play expected") end
	
	local clear		=	function()
							tpud:clear()
						end
	local addTexture =	function(tex)
							tpud:add_texture(tex)
						end
	local delTexture =	function(tex)
							tpud:del_texture(tex)
						end
	local getCurTexture =	function()
								return tpud:get_current_texture()
							end
	local getFrameCount	=	function()
								return tpud:get_frame_count()
							end
	local getCurFrame	=	function()
								return tpud:get_cur_frame()
							end
	local setCurFrame	=	function(nframe)
								tpud:set_cur_frame(nframe)
							end
	local getFrameTime	=	function()
								return tpud:get_frame_time()
							end
	local setFrameTime	=	function(ft)
								tpud:set_frame_time(ft)
							end


	local r=_new_resource_tb(tpud)

	r.clear=clear
	r.addTexture=addTexture
	r.delTexture=delTexture
	r.getCurTexture=getCurTexture
	r.getFrameCount=getFrameCount
	r.getCurFrame=getCurFrame
	r.setCurFrame=setCurFrame
	r.getFrameTime=getFrameTime
	r.setFrameTime=setFrameTime

	return r
end

-- export ----
_new_textureplay_tb=new

--style

TPS_NOTCIRCLE			=toDWORD('00000001') --not circle
