
local function new( scene )
	if (type(scene) ~= "userdata") then error("scene expected") end
	
	local getBkColor =	function()
							return _GetBackgroundColor()
						end
	local setBkColor =	function(dwcolor)
							_SetBackgroundColor(dwcolor)
						end
	local getBkImage =	function()
							return scene:get_bk_image()
						end
	local setBkImage =	function(ntex)
							scene:set_bk_image(ntex)
						end
	local getAmbientColor = function()
								return scene:get_ambient_color()
							end
	local setAmbientColor = function(dwcolor)
								if (type(dwcolor) ~= "userdata") then error("dwcolor expected") end
								scene:set_ambient_color(dwcolor)
							end
	local exposeLightmap = function( fExposure, cBrightRectify )
								return scene:expose_lightmap( fExposure, cBrightRectify )
							end
	local getFogColor =		function()
								return scene:get_fog_color()
							end
	local setFogColor =		function(dwcolor)
								if (type(dwcolor) ~= "userdata") then error("dwcolor expected") end
								scene:set_fog_color(dwcolor)
							end
	local getFogMode =		function()
								return scene:get_fog_mode()
							end
	local setFogMode =		function(mode)
								scene:set_fog_mode(mode)
							end
	local getFogParams =	function()
								return scene:get_fog_params()
							end
	local setFogParams =	function(fogstart, fogend, density)
								scene:set_fog_params(fogstart,fogend,density)
							end
	local getVPScale	=	function()
						return scene:get_vpscale()
					end


	local createLight = function()
							local handle=scene:create_light()
							if (nil==handle) then return nil end -- create failed
							return LightFromHandle(handle)
						end
	local deleteLight = function(light)
							local bret=scene:delete_light(light.getPointer())
							if bret then
								_InvalidateUserdata(light.getUD())
							end
							return bret
						end
	local getLightsHead =	function()
								return scene:get_lights_head()
							end
	local getLightsNext =	function(pos)
								local plight,pos=scene:get_lights_next(pos)
								return LightFromHandle(plight),pos
							end

	local createMobile	=	function(modelfn)
								local handle=scene:create_mobile(modelfn)
								if (nil==handle) then return nil end -- create failed
								return MobileFromHandle(handle)
							end
	local createSkinMesh	=	function(modelfn)
									local handle=scene:create_skinmesh(modelfn)
									if (nil==handle) then return nil end -- create failed
									return SkinMeshFromHandle(handle)
								end
	local createCloth		=	function()
									local handle=scene:create_cloth()
									if (nil==handle) then return nil end -- create failed
									return ClothFromHandle(handle)
								end

	--local deleteMobile =	function(mov)
	local function deleteMobile(mov)
								
								if (mov.getClassID()==UD_MOVGROUP) then
									local pos=mov.getChildrenHead()
									while (pos) do
										local m,typename
										m,pos,typename=mov.getChildrenNext(pos)
										if (m) then
											deleteMobile(m)
										end
									end						
								end

								local bret=scene:delete_mobile(mov.getPointer())
								if bret then
									_InvalidateUserdata(mov.getUD())
								end
								return bret
							end

	local getMobilesHead =	function()
								return scene:get_mobiles_head()
							end
	local getMobilesNext =	function(pos)
								local pmov,pos,type=scene:get_mobiles_next(pos)
								local mov=nil
								if ('mobile'==type) then
									mov=MobileFromHandle(pmov)
								elseif ('skinmesh'==type) then
									mov=SkinMeshFromHandle(pmov)
								elseif ('cloth'==type) then
									mov=ClothFromHandle(pmov)
								elseif ('clothex'==type) then
									mov=ClothExFromHandle(pmov)
								elseif ('group'==type) then
									mov=MovGroupFromHandle(pmov)
								end
								return mov,pos,type
							end
	local createText2D = function()
							local handle=scene:create_text2d()
							if (nil==handle) then return nil end -- create failed
							return Text2DFromHandle(handle)
						end
	local createImage2D = function()
							local handle=scene:create_image2d()
							if (nil==handle) then return nil end -- create failed
							return Image2DFromHandle(handle)
						end
	local deleteOverlay =	function(over)
								local bret=scene:delete_overlay(over.getPointer())
								if bret then
									_InvalidateUserdata(over.getUD())
								end
								return bret
							end
	local getOverlaysHead =	function()
								return scene:get_overlays_head()
							end
	local getOverlaysNext =	function(pos)
								local pover,pos,type=scene:get_overlays_next(pos)
								local over=nil
								if ('text2d'==type) then
									over=Text2DFromHandle(pover)
								elseif ('image2d'==type) then
									over=Image2DFromHandle(pover)
								end
								return over,pos,type
							end
	local createBillboard = function()
								local handle=scene:create_billboard()
								if (nil==handle) then return nil end -- create failed
								return BillboardFromHandle(handle)
							end
	local createParticles = function()
								local handle=scene:create_particles()
								if (nil==handle) then return nil end -- create failed
								return ParticlesFromHandle(handle)
							end
	local buildSpot		=	function(surf,vOfs,fRadius,dwColor,bLightmap,fEmboss)
								local handle=scene:build_spot(surf.getPointer(),vOfs.x,vOfs.y,vOfs.z,fRadius,dwColor,bLightmap,fEmboss)
								if (nil==handle) then return nil end -- create failed
								return SpotFromHandle(handle)
							end
	local deleteEffect =	function(eff)
								local bret=scene:delete_effect(eff.getPointer())
								if bret then
									_InvalidateUserdata(eff.getUD())
								end
								return bret
							end
	local getEffectsHead =	function()
								return scene:get_effects_head()
							end
	local getEffectsNext =	function(pos)
								local peff,pos,type=scene:get_effects_next(pos)
								local eff=nil
								if ('billboard'==type) then
									eff=BillboardFromHandle(peff)
								elseif ('particles'==type) then
									eff=ParticlesFromHandle(peff)
								elseif ('spot'==type) then
									eff=SpotFromHandle(peff)
								end
								return eff,pos,type
							end

	local getStaticMeshHead =	function()
								return scene:get_staticmesh_head()
							end
	local getStaticMeshNext =	function(pos)
								local psmesh,pos=scene:get_staticmesh_next(pos)
								return StaticMeshFromHandle(psmesh),pos
							end


	local getSurfacesHead =	function()
								return scene:get_surfaces_head()
							end
	local getSurfacesNext =	function(pos)
								local psurf,pos=scene:get_surfaces_next(pos)
								return SurfaceFromHandle(psurf),pos
							end

	local createTerrain	=	function()
								local handle=scene:create_terrain()
								if (nil==handle) then return nil end -- create failed
								return TerrainFromHandle(handle)
							end
	local getTerrainsHead = function()
								return scene:get_terrains_head()
							end
	local getTerrainsNext = function(pos)
								local pter,pos=scene:get_terrains_next(pos)
								return TerrainFromHandle(pter),pos
							end


	local createOcean	=	function()
								local handle=scene:create_ocean()
								if (nil==handle) then return nil end -- create failed
								return OceanFromHandle(handle)
							end
	local getOceansHead = function()
								return scene:get_oceans_head()
							end
	local getOceansNext = function(pos)
								local pocean,pos=scene:get_oceans_next(pos)
								return OceanFromHandle(pocean),pos
							end


	local createMaterial =	function(name)
								local handle=scene:create_material()
								if (nil==handle) then return nil end -- create failed
								local mater = MaterialFromHandle(handle)
								if name and mater then mater.setName(name) end
								return mater
							end
	local deleteMaterial =	function(mater)
								local bret=scene:delete_material(mater.getPointer())
								if bret then
									_InvalidateUserdata(mater.getUD())
								end
								return bret
							end
	local getMaterialsHead =function()
								return scene:get_materials_head()
							end
	local getMaterialsNext =function(pos)
								local pmater,pos=scene:get_materials_next(pos)
								return MaterialFromHandle(pmater),pos
							end

	local createBonesAni =	function(fn)
								local handle=scene:create_bonesani(fn)
								if (nil==handle) then return nil end -- create failed
								return BonesAniFromHandle(handle)
							end
	local deleteBonesAni =	function(ba)
								local bret=scene:delete_bonesani(ba.getPointer())
								if bret then
									_InvalidateUserdata(ba.getUD())
								end
								return bret
							end
	local getBonesAniHead = function()
								return scene:get_bonesani_head()
							end
	local getBonesAniNext = function(pos)
								local pba,pos=scene:get_bonesani_next(pos)
								return BonesAniFromHandle(pba),pos
							end


	local createTexturePlay =	function(fn)
									local handle=scene:create_textureplay(fn)
									if (nil==handle) then return nil end -- create failed
									return TexturePlayFromHandle(handle)
								end
	local deleteTexturePlay =	function(tp)
								local bret=scene:delete_textureplay(tp.getPointer())
								if bret then
									_InvalidateUserdata(tp.getUD())
								end
								return bret
							end
	local getTexturePlayHead = function()
								return scene:get_textureplay_head()
							end
	local getTexturePlayNext = function(pos)
								local ptp,pos=scene:get_textureplay_next(pos)
								return TexturePlayFromHandle(ptp),pos
							end


	local createMovTar =	function(noclip)
								local handle=scene:create_movtar(noclip)
								if (nil==handle) then return nil end -- create failed
								return MovTarFromHandle(handle)
							end
	local deleteMovTar =	function(movt)
								local bret=scene:delete_movtar(movt.getPointer())
								if bret then
									movt._clear()
									_InvalidateUserdata(movt.getUD())
								end
								return bret
							end
	local getMovTarHead = function()
								return scene:get_movtar_head()
							end
	local getMovTarNext = function(pos)
								local pmt,pos=scene:get_movtar_next(pos)
								return MovTarFromHandle(pmt),pos
							end

	local trace			=	function(t)
								return scene:trace(t.getPointer())
							end


	local createPost =	function(name)
								local handle=scene:create_post(name)
								if (nil==handle) then return nil end -- create failed
								return PostFromHandle(handle)
							end
	local deletePost =	function(post)
								local bret=scene:delete_post(post.getPointer())
								if bret then
									_InvalidateUserdata(post.getUD())
								end
								return bret
							end
	local getPostsHead = function()
							return scene:get_posts_head()
						end
	local getPostsNext = function(pos)
							local ppost,pos=scene:get_posts_next(pos)
							return PostFromHandle(ppost),pos
						end


	local createShot =	function(name)
								local handle=scene:create_shot(name)
								if (nil==handle) then return nil end -- create failed
								return ShotFromHandle(handle)
							end

	local getShotsHead = function()
							return scene:get_shots_head()
						end
	local getShotsNext = function(pos)
							local pshot,pos=scene:get_shots_next(pos)
							return ShotFromHandle(pshot),pos
						end


	local r=_new_udhead_tb(scene)

	r.getBkColor=getBkColor
	r.setBkColor=setBkColor
	r.getBkImage=getBkImage
	r.setBkImage=setBkImage
	r.getAmbientColor=getAmbientColor
	r.setAmbientColor=setAmbientColor
	r.exposeLightmap=exposeLightmap
	r.getFogColor=getFogColor
	r.setFogColor=setFogColor
	r.getFogMode=getFogMode
	r.setFogMode=setFogMode
	r.getFogParams=getFogParams
	r.setFogParams=setFogParams
	r.getVPScale=getVPScale

	r.createLight=createLight
	r.deleteLight=deleteLight
	r.getLightsHead=getLightsHead
	r.getLightsNext=getLightsNext

	r.createMobile=createMobile
	r.createSkinMesh=createSkinMesh
	r.createCloth=createCloth
	r.deleteMobile=deleteMobile
	r.getMobilesHead=getMobilesHead
	r.getMobilesNext=getMobilesNext

	r.createText2D=createText2D
	r.createImage2D=createImage2D
	r.deleteOverlay=deleteOverlay
	r.getOverlaysHead=getOverlaysHead
	r.getOverlaysNext=getOverlaysNext

	r.createBillboard=createBillboard
	r.createParticles=createParticles
	r.buildSpot=buildSpot
	r.deleteEffect=deleteEffect
	r.getEffectsHead=getEffectsHead
	r.getEffectsNext=getEffectsNext

	r.getStaticMeshHead=getStaticMeshHead
	r.getStaticMeshNext=getStaticMeshNext

	r.getSurfacesHead=getSurfacesHead
	r.getSurfacesNext=getSurfacesNext

	r.createTerrain=createTerrain
	r.getTerrainsHead=getTerrainsHead
	r.getTerrainsNext=getTerrainsNext

	r.createOcean=createOcean
	r.getOceansHead=getOceansHead
	r.getOceansNext=getOceansNext

	r.createMaterial=createMaterial
	r.deleteMaterial=deleteMaterial
	r.getMaterialsHead=getMaterialsHead
	r.getMaterialsNext=getMaterialsNext

	r.createBonesAni=createBonesAni
	r.deleteBonesAni=deleteBonesAni
	r.getBonesAniHead=getBonesAniHead
	r.getBonesAniNext=getBonesAniNext

	r.createTexturePlay=createTexturePlay
	r.deleteTexturePlay=deleteTexturePlay
	r.getTexturePlayHead=getTexturePlayHead
	r.getTexturePlayNext=getTexturePlayNext

	r.createMovTar=createMovTar
	r.deleteMovTar=deleteMovTar
	r.getMovTarHead=getMovTarHead
	r.getMovTarNext=getMovTarNext

	r.trace=trace

	r.createPost=createPost
	r.deletePost=deletePost
	r.getPostsHead=getPostsHead
	r.getPostsNext=getPostsNext

	r.createShot = createShot
	r.getShotsHead=getShotsHead
	r.getShotsNext=getShotsNext

	return r
end

-- export ----
_new_scene_tb=new


-- fog mode
FOG_NONE                 = 0
FOG_EXP                  = 1
FOG_EXP2                 = 2
FOG_LINEAR               = 3
