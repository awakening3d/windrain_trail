-- game.lua
-- v0.24
require 'game_config'
require 'inventory'
require 'tempobj'

local mx, my=0,0;
local downx,downy=0,0
local wx,wy;


local cursortex = nil
local cursorinfo = nil
local hotspot=nil
local focusHotspotDistance = nil
local trackRay = ray.new()

local MsgOnCursor = ''

local no_mouse_move_timesum=0


g_inv=inventory.new()
g_inv.setArea(rect.new(0.1,0,0.9,0.12))
g_inv.setBackColor( ColortoDWORD(color.new(0.5,0.5,0.5,0.8)) )
g_inv.setItemOffset(16,8)
--g_inv.setBackImage(1)

local bMouseOnClient=true




function game_GetMouseXY()
	return mx,my;
end

function game_GetHotspotObj()
	return g_world.actived_hotspot
end

local function get_hostspot_on_ray( ray )

	if g_world.disable_all_hotspot or not g_config.vr_beam_visible then return nil end

	local hotspot=nil
	local hotspotm = nil

	local fDistance=99999999
	local pos=scene.getMobilesHead()
	while (pos) do
		local mov,typename
		mov,pos,typename=scene.getMobilesNext(pos)
		if (mov) then
			if (not mov.isHidden()) then
				local name=mov.getName()
				if not g_world.disabled_hotspots[name] then
					if ('hotspot_'==string.sub(name,1,8)) then
						local bInter, fDis = mov.intersectRay(ray,true)
						if (bInter and (fDis<fDistance) and (fDis<g_config.hotspotDistance) ) then
							fDistance=fDis
							hotspot=name
							hotspotm=mov
						end
					end
				end
			end
		end
	end

	return hotspot, hotspotm, fDistance
end

local function get_hotspot(x,y)
	
	if g_world.disable_all_hotspot then return nil end

	local hotspot = nil
	hotspot, g_world.actived_hotspot = get_hostspot_on_ray( GetRayFromPoint(x,y) )
	

	local pos=scene.getOverlaysHead()
	while (pos) do
		local over,typename
		over,pos,typename=scene.getOverlaysNext(pos)
		if (over) then
			if (not over.isHidden()) then
				local name=over.getName()
				if not g_world.disabled_hotspots[name] then
					if ('hotspot_'==string.sub(name,1,8)) then
						local overp=over.getPosition()
						local r=rect.new( overp.x, overp.y, overp.x + over.getWidth(), overp.y + over.getHeight() )

						local vpsx,vpsy=scene.getVPScale()
						
						if ( r.ptInRect( point.new(mx/vpsx,my/vpsy) ) ) then
							hotspot=name
							g_world.actived_hotspot=over
						end
					end
				end
			end
		end
	end

	return hotspot

end





function game_SetCursor(tex,info)
	cursortex=tex
	cursorinfo=info
end

function game_GetCursor()
	return cursortex,cursorinfo
end


local function setcursor_by_hotspot( hotspot )
	if (hotspot) then
		game_SetCursor(texturelist.addTexture(g_config.cursor_hand_open),g_config.cursor_hand_open_info)
		if ('portal_'==string.sub(hotspot,9,15)) then
			game_SetCursor(texturelist.addTexture(g_config.cursor_portal),g_config.cursor_portal_info)
		end

		MsgOnCursor=g_msg[hotspot]
	end

	local it=g_inv.getSelectedItem()
	if it then
		game_SetCursor(texturelist.addTexture(	it.getImage() ))
		if (hotspot) then
			hotspot = hotspot .. '_' .. it.getID()
		end
	end

	return hotspot
end


local lastmousetime=-1 
function game_OnMouseMove(x,y)
	
	if g_config.vr then return end

	mx=x
	my=y

	if (lastmousetime<0) then lastmousetime=GetAppTime() end 
	local nowtime=GetAppTime() 
	local timed=nowtime-lastmousetime 
	if (timed<0.1) then return end
	lastmousetime=nowtime

	MsgOnCursor=''

	game_SetCursor(texturelist.addTexture(g_config.cursor_arrow),g_config.cursor_arrow_info)

	hotspot=nil
	g_world.actived_hotspot=nil

	if g_inv.onMouseMove(x,y) then
		bMouseOnClient=false
	else
		bMouseOnClient=true
	end

	if (bMouseOnClient) then
		hotspot=get_hotspot(x,y)
	end

	hotspot = setcursor_by_hotspot( hotspot )

	if (cursortex) then
		wnd.ShowCursor(false)
	else
		wnd.ShowCursor(true)
	end

end


function game_OnLButtonDown(x,y)
	if g_config.vr then return end
	downx=x
	downy=y
	no_mouse_move_timesum = 0
	return g_inv.onLButtonDown(x,y)
end


local function do_hotspot_function( hotspot )
	if g_hotspot_function[hotspot] then
		g_hotspot_function[hotspot]()
	else
		DoScript(hotspot)
	end
end

function game_OnLButtonUp(x,y)
	if g_config.vr then return end

	local bDosomething=false;

	if x~= downx or y~= downy then bDosomething = true end

	local seleit=g_inv.getSelectedItem()
	if g_inv.onLButtonUp(x,y) then
		if (seleit) then seleit.hide(false) end
		if (g_inv.getSelectedItem()) then g_inv.getSelectedItem().hide(true) end
		return true
	else
		if (g_inv.isShow()) then
			if (seleit) then
				seleit.hide(false)
				bDosomething=true
			end
		end
	end
	
	if g_inv.getCoverImage() then
		g_inv.setCoverImage(nil)
		return true
	end

	if ( math.abs(downx-x)>2 or math.abs(downy-y)>2 ) then
		return bDosomething
	end

	--hotspot=get_hotspot(x,y)
	if (hotspot) then
		hotspot = do_hotspot_function( hotspot )
		bDosomething=true
	end

	return bDosomething
end


local _onControllerButtonPress = onControllerButtonPress
function onControllerButtonPress( deviceID, buttonid )
	if _onControllerButtonPress then
		if _onControllerButtonPress( deviceID, buttonid ) then return end
	end
	if deviceID == ControllerA.getDeviceID() then
		if buttonid == ControllerButtonID.Trigger then
			if (hotspot) then
				hotspot = do_hotspot_function( hotspot )
				return true
			end
		end
	end
end

function game_OnSize( type, cx, cy )
	wx,wy=cx,cy
	g_inv.onSize(type,cx,cy)
end


local blinding = nil
local overlayshowSave = nil
local disableAllHotspotSave = NULL

local lastRayHotspotTime = 0

local hidecursorx,hidecursory = 0,0
local lasttime=-1
function game_FrameMove()

	if (lasttime<0) then lasttime=GetAppTime() end
	local nowtime=GetAppTime()
	local timed=nowtime-lasttime
	lasttime=nowtime

	-- whether blinding
	if blind and andDWORD( blind.getColor(), toDWORD('ff000000') ) ~= NULL then -- blind is Script Variable defined in scene
		blinding = blind.getColor()
		if NULL==disableAllHotspotSave then disableAllHotspotSave = g_world.disable_all_hotspot end -- record disable all hotspot state
		g_world.disable_all_hotspot = true -- disable all hotspot when blinding
	else
		blinding = nil
		if NULL~=disableAllHotspotSave then	-- restore disable all hotspot state
			g_world.disable_all_hotspot = disableAllHotspotSave
			disableAllHotspotSave = NULL
		end
	end

	if g_config.vr then
		local w,h = winds3dvr.get_render_resolution()
		h = math.floor(w*0.75)
		if wx~=w or wy~=h then
			game_OnSize( SIZE_RESTORED, w, h )
		end
		if blinding then
			local oldstate = winds3dvr.overlay_show(0)
			if not overlayshowSave then overlayshowSave = oldstate end -- record overlay state
		else
			if overlayshowSave then
				winds3dvr.overlay_show(overlayshowSave) -- restore overlay state
				overlayshowSave=nil
			end
		end
	else
		-- show cursor if it move out of client
		local x,y=wnd.ScreenToClient(GetMainWnd(),wnd.GetCursorPos())
		if (x<0 or y<0) then
			wnd.ShowCursor(true)
		end

		if (g_config.hide_cursor_when_no_mouse_move) then
			if no_mouse_move_timesum < g_config.hide_cursor_when_no_mouse_move_time then
				no_mouse_move_timesum = no_mouse_move_timesum + timed;
				if no_mouse_move_timesum >= g_config.hide_cursor_when_no_mouse_move_time then
					hidecursorx, hidecursory = x, y
				end
			else
				if math.abs(hidecursorx-x)>8 or math.abs(hidecursory-y)>8 then no_mouse_move_timesum=0 end
			end
		end

		if ( mx~=x or my~=y ) then no_mouse_move_timesum=0 end

		mx, my = x, y
		if (mx<0) then mx = 0 end
		if (mx>=wx) then mx = wx-1 end
		if (my<0) then my = 0 end
		if (my>=wy) then my = wy-1 end
	end


	-- camera pan
	local bNoPlayingShot = true
	if IsPlayingShot() then
		local sh = GetPlayingShot()
		if sh then
			if andDWORD( sh.getStyle(), SHOTS_NOTAFFECTCAM ) == NULL then
				bNoPlayingShot = false
			end
		end
	end

	if (g_config.cameraPan and bMouseOnClient and bNoPlayingShot) then
		local ofsx,ofsy=0,0
		local step=g_config.cameraPanStep
		local rate=g_config.cameraPanBorderline
		
		local pan=(rate-mx/wx)
		if pan>0 then
			ofsx = -step*timed * pan
		end
		
		pan=rate - (wx-mx) / wx
		if pan>0 then
			ofsx = step*timed * pan
		end

		pan=rate - my/wy
		if pan>0 then
			ofsy = -step*timed * pan
		end

		pan=rate - (wy-my) / wy
		if pan>0 then
			ofsy = step*timed * pan
		end

		--camera.circlePoint(ofsx,ofsy,vec.new(0,0,0))
		local vrot=camera.getRotation()
		vrot.x=vrot.x+ofsy
		vrot.y=vrot.y+ofsx
		camera.setRotation(vrot)

	end

	-- limit the up and down so it doesn't go 360 vertically
	local rot=camera.getRotation()
	if (rot.x>80) then rot.x=80 end
	if (rot.x<-80) then rot.x=-80 end
	camera.setRotation(rot)


	----------- for vr -------------
	if g_config.vr then
		trackRay.setOrg( ControllerA.getPosition() )
		trackRay.setDir( ControllerA.getFront() )
		if (nowtime - lastRayHotspotTime > 0.1) then
			lastRayHotspotTime = nowtime
			hotspot, g_world.actived_hotspot, focusHotspotDistance = get_hostspot_on_ray( trackRay )
			if not hotspot then focusHotspotDistance=nil end
			hotspot = setcursor_by_hotspot( hotspot )
		end
	end

	-- temp objs framemove
	frameMoveTempObjs(timed)
end



function game_Render2D(draw)
	g_inv.draw(draw)
	
	if g_config.vr then return end

	if (g_config.showCursor and cursortex and no_mouse_move_timesum<g_config.hide_cursor_when_no_mouse_move_time) then
		-- draw.fillcircle(point.new(mx,my),8,8)
		draw.setbkcolor(COLOR_WHITE)

		local x,y,w,h=0,0,32,32
		if cursorinfo then
			x = -cursorinfo[1] or x
			y = -cursorinfo[2] or y
			w = cursorinfo[3] or w
			h = cursorinfo[4] or h
		end
		draw.stretchblt(rect.new(mx+x,my+y,mx+x+w,my+y+h),cursortex)
	end
	
	if (MsgOnCursor) then
		draw.setcolor(g_config.tipsColor)
		draw.textout(mx+g_config.tipsPosX,my+g_config.tipsPosY,MsgOnCursor)
	end
end

function game_Render3D(draw, mode)
	if g_config.vr then
		-- draw blind
		if 0==mode and blinding then
			draw.setbkcolor( blinding )
			local depth,width,height= 70,500,500
			local coner = finalcamera.getPosition() + finalcamera.getFront()*depth - finalcamera.getRight()*width + finalcamera.getUp()*height
			local ztestsave = draw.ztest( false ) -- save z state
			draw.fillrect( coner, finalcamera.getRight()*width*2, -finalcamera.getUp()*height*2 )
			draw.ztest( ztestsave ) -- restore z state
		end

		g_inv.draw3d(draw)
		------ draw 3d cursor -------
		if (g_config.showCursor and cursortex and focusHotspotDistance) then
			local cursordis = focusHotspotDistance -10;
			local corner = trackRay.getOrg() + trackRay.getDir() * cursordis
			local x,y,w,h=0,0,32,32
			if cursorinfo then
				x = -cursorinfo[1] or x
				y = -cursorinfo[2] or y
				w = cursorinfo[3] or w
				h = cursorinfo[4] or h
			end
			local vw = finalcamera.getRight()
			local vh = -finalcamera.getUp()

			local ztestsave = draw.ztest( false ) -- save z state
			cursordis = math.sqrt(cursordis)* g_config.vr_cursor_scale

			if (MsgOnCursor) then
				draw.setcolor(g_config.tipsColor)
				draw.textout( corner+vw*w*cursordis, vw, vh, MsgOnCursor, cursordis, cursordis )
			end
			draw.setbkcolor( COLOR_WHITE )
			draw.fillrect( corner + vw*x*g_config.vr_cursor_scale + vh*y*g_config.vr_cursor_scale, vw*w*cursordis, vh*h*cursordis, cursortex )
			draw.ztest( ztestsave ) -- restore z state
		end

		if g_inv.getCoverImage() then return end
		----- draw beam ----
		if g_config.vr_beam_visible then
			draw.setcolor( g_config.vr_beam_color )
			draw.setbkcolor( g_config.vr_beam_endcolor )
			draw.gradingmode( not focusHotspotDistance )
			local start = trackRay.getOrg()
			draw.moveto( start  )
			draw.lineto( start + trackRay.getDir() * (focusHotspotDistance or 500) )
			draw.gradingmode( false )
		end
	end
end


function game_OnSceneLoaded()
	for _,b in ipairs( g_config.scene_loaded_funs ) do
		if (b) then
			b()
		end
	end

	if wx then wnd.SetCursorPos( wnd.ClientToScreen(GetMainWnd(), wx/2,wy/2) ) end
	
	lastmousetime=0
	game_OnMouseMove(mx,my) -- ¼ÓÔØcursorÎÆÀí

	if g_config.vr then
		local FOV, NearPlane, FarPlane = FovViewDistance(0,0,0)
		FovViewDistance( FOV, NearPlane, FarPlane )
		winds3dvr.near_clip(NearPlane)
		winds3dvr.far_clip(FarPlane)
	end
end


function game_LoadScene( SceneName, ShotName )
	for _,b in ipairs( g_config.scene_onexit_funs ) do
		if (b) then
			b()
		end
	end

	clearTempObjs()

	return LoadScene( SceneName, ShotName )
end

---- utils ---

function getObjectOnRay( ray )

		local fDistance=99999999
		local obj=nil
		
		--mobiles
		local pos=scene.getMobilesHead()
		while (pos) do
			local mov,typename
			mov,pos,typename=scene.getMobilesNext(pos)
			if (mov) then
				if (not mov.isHidden()) then
						local bInter,fDis=mov.intersectRay(ray,true)
						if (bInter and fDis<fDistance) then
							fDistance=fDis
							obj=mov								
						end
				end
			end
		end
		
		--static meshs
		pos=scene.getStaticMeshHead()
		while (pos) do
			local smesh
			smesh,pos=scene.getStaticMeshNext(pos)
			if smesh then
				if (not smesh.isHidden()) then
					local bInter,fDis=smesh.intersectRay(ray,true)
					if (bInter and fDis<fDistance) then
						fDistance=fDis
						obj=smesh
					end
				end
			end
		end
		
		--surfaces
		pos=scene.getSurfacesHead()
		while (pos) do
			local smesh
			smesh,pos=scene.getSurfacesNext(pos)
			if smesh then
				if (not smesh.isHidden()) then
					local bInter,fDis=smesh.intersectRay(ray,true)
					if (bInter and fDis<fDistance) then
						fDistance=fDis
						obj=smesh
					end
				end
			end
		end

		--terrains
		pos=scene.getTerrainsHead()
		while (pos) do
			local smesh
			smesh,pos=scene.getTerrainsNext(pos)
			if smesh then
				if (not smesh.isHidden()) then
					local bInter,fDis=smesh.intersectRay(ray,true)
					if (bInter and fDis<fDistance) then
						fDistance=fDis
						obj=smesh
					end
				end
			end
		end
		
		return obj, ray.getOrg()+ray.getDir()*fDistance
end

function getObjectOnCursor(x,y, distance, noclipmask )
	distance=distance or 9999999

	local ray=GetRayFromPoint(x,y)

	local t=trace.new()
	t.pointed(true)
	t.setStart(ray.getOrg())
	t.setEnd(ray.getOrg()+ray.getDir()*distance);

	if (noclipmask) then 
		t.setNoClipMask( noclipmask )
	end
	
	scene.trace(t)

	local obj,type=t.getBlockObject()
	return obj, t.getStop(), type
end
