

local function new( baud )
	if (type(baud) ~= "userdata") then error("bones animation expected") end
	
	local getTimeLength	=	function()
								return baud:get_timelength()
							end
	local getFrameNum	=	function()
								return baud:get_framenum()
							end
	local getNumBones =		function()
								return baud:get_numbones()
							end
	local getIntialMatrix =	function(nbone)
								local handle=baud:get_intial_matrix(nbone)
								if (not handle or NULL==handle)	then return nil end
								return matrix.new(handle)
							end
	local getIntialMatrixInv =	function(nbone)
									local handle=baud:get_intial_matrixinv(nbone)
									if (not handle or NULL==handle)	then return nil end
									return matrix.new(handle)
								end
	local getMatrix =	function(nbone,ftime)
								local handle=baud:get_matrix(nbone,ftime)
								if (not handle or NULL==handle)	then return nil end
								return matrix.new(handle)
						end
	local loadAniFile = function(filename)
							return baud:load_ani_file(filename)
						end
	local getTimeAmp =	function()
							local handle=baud:get_time_amp()
							if (not handle or NULL==handle)	then return nil end
							return AmplifierFromHandle(handle)
						end
	local findBone	=	function(name)
					return baud:find_bone(name)
				end

	local timeToFrame =	function(time)
					return baud:time_to_frame(time)
				end
	local frameToTime =	function(frame)
					return baud:frame_to_time(frame)
				end


	local r=_new_resource_tb(baud)

	r.getTimeLength=getTimeLength
	r.getFrameNum=getFrameNum
	r.getNumBones=getNumBones
	r.getIntialMatrix=getIntialMatrix
	r.getIntialMatrixInv=getIntialMatrixInv
	r.getMatrix=getMatrix
	r.loadAniFile=loadAniFIle
	r.getTimeAmp=getTimeAmp
	r.findBone=findBone
	r.timeToFrame=timeToFrame
	r.frameToTime=frameToTime

	return r
end

-- export ----
_new_bonesani_tb=new

--styles--
BANIS_CIRCLE			= toDWORD('00000001') -- circle animation
