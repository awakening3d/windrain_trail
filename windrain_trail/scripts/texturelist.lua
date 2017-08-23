
local function new( tl )
	if (type(tl) ~= "userdata") then error("texture list expected") end
	
	local addTexture = function(filename)
							if (''==filename) then return end;
							return tl:add_texture(filename)
						end
	local addBumpTexture = function(filename)
							if (''==filename) then return end;
							return tl:add_bump_texture(filename)
						end
	local addCubeTexture = function(filename)
							if (''==filename) then return end;
							return tl:add_cube_texture(filename)
						end
	local addCubeTexture64 = function(filename)
							if (''==filename) then return end;
							return tl:add_cube_texture64(filename)
						end
	local addVideoTexture = function(filename)
							if (''==filename) then return end;
							return tl:add_video_texture(filename)
						end
	local addRenderTexture = function(filename,style,widthscale)
							if (''==filename) then return end;
							return tl:add_render_texture(filename,style,widthscale)
						end
	local addRenderTexture64 = function(filename,style,widthscale)
							if (''==filename) then return end;
							return tl:add_render_texture64(filename,style,widthscale)
						end
	local addCubeRenderTexture = function(filename)
							if (''==filename) then return end;
							return tl:add_cuberender_texture(filename)
						end
	local addVolumeTexture = function(filename)
							if (''==filename) then return end;
							return tl:add_volume_texture(filename)
						end

	local removeTexture =	function(ntex)
								return tl:remove_texture(ntex)
							end
	local replaceTexture =	function(ntex,filename)
								return tl:replace_texture(ntex,filename)
							end
	local getTextureFileName =	function(ntex)
									return tl:get_texture_filename(ntex)
								end
	local getTextureID		=	function(filename)
									return tl:get_texture_id(filename)
								end
	local getTextureSurface	=	function(ntex,nsurfidx)
									local psurf=tl:get_texture_surface(ntex,nsurfidx)
									if nil==psurf then return nil end
									return _new_d3dsurface_tb( _new_d3dsurface_ud( psurf ) )
								end

	local clearAll			=	function()
									return tl:clear_all()
								end
	
	local r=_new_udhead_tb(tl)

	r.addTexture=addTexture
	r.addBumpTexture=addBumpTexture
	r.addCubeTexture=addCubeTexture
	r.addVideoTexture=addVideoTexture
	r.addRenderTexture=addRenderTexture
	r.addRenderTexture64=addRenderTexture64
	r.addCubeRenderTexture=addCubeRenderTexture
	r.addCubeRenderTexture64=addCubeRenderTexture64
	r.addVolumeTexture=addVolumeTexture
	r.removeTexture=removeTexture
	r.replaceTexture=replaceTexture
	r.getTextureFileName=getTextureFileName
	r.getTextureID=getTextureID
	r.getTextureSurface=getTextureSurface
	r.clearAll=clearAll

	return r
end

-- export ----
_new_texturelist_tb=new

--styles--
TS_BB_ALIGNED		= toDWORD('00000001') --back buffer size aligned
