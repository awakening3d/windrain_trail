-- game.lua
-- v0.31

require 'game_config'
require 'inventory'

local mx, my=0,0;
local downx,downy=0,0
local wx,wy=0,0;


local cursortex = nil
local cursorinfo = nil
local hotspot=nil

local MsgOnCursor = nil

local trackRay = ray.new()
local lastRayHotspotTime = 0
local lastCameraRotation = vec.new(0,0,0)
local cameraStayTime = 0
local startFocusHotspotTime = nil
local focusHotspotDistance = nil

local lastInventoryActivingTime = 999999

local coverimg_last = nil
local coverimg_time = 0


g_inv=inventory.new()
g_inv.setArea(rect.new(0.1,0,0.9,0.12))
g_inv.setBackColor( ColortoDWORD(color.new(0.5,0.5,0.5,0.8)) )
g_inv.setItemOffset(16,8)
--g_inv.setBackImage(1)


local bMouseOnClient=true



function getHotspotOnRay( ray )
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
						if (bInter and (fDis<fDistance) ) then
							fDistance=fDis
							hotspotm=mov
						end
					end
				end
			end
		end
	end

	return hotspotm, fDistance
end



function game_SetCursor(tex,info)
	cursortex=tex
	cursorinfo=info
end



local function hotspot_cursor()

	MsgOnCursor=nil

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
end


local lasttime=-1 

function game_OnMouseMove(x,y)

	mx=x
	my=y

	if (lasttime<0) then lasttime=GetAppTime() end 
	local nowtime=GetAppTime() 
	local timed=nowtime-lasttime 
	if (timed<0.1) then return end
	lasttime=nowtime

	if (not g_config.vr) then
		game_SetCursor(texturelist.addTexture(g_config.cursor_arrow),g_config.cursor_arrow_info)
	end

	hotspot=nil
	g_world.actived_hotspot=nil

	if g_inv.onMouseMove(x,y) then
		bMouseOnClient=false
	else
		bMouseOnClient=true
	end


	if (bMouseOnClient) then

		local hotspotm = getHotspotOnRay( GetRayFromPoint(x,y) )
		if hotspotm then
			hotspot = hotspotm.getName()
			g_world.actived_hotspot= hotspotm
		end


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

	end

	-- change cursor by hotspot
	hotspot_cursor()

	if (cursortex) then
		wnd.ShowCursor(false)
	else
		wnd.ShowCursor(true)
	end

end


function game_OnLButtonDown(x,y)
	downx=x
	downy=y

	return g_inv.onLButtonDown(x,y)
end


function game_OnLButtonUp(x,y)
	
	local bDosomething=false;

	local seleit=g_inv.getSelectedItem()
	if g_inv.onLButtonUp(x,y) then
		return true
	else
		if g_inv.isShow() and seleit then
			bDosomething=true
		end
	end
	
	if g_inv.getCoverImage() then
		g_inv.setCoverImage(nil)
		return true
	end


	if ( math.abs(downx-x)>16 or math.abs(downy-y)>16 ) then
		return bDosomething
	end

	if (hotspot) then
		DoScript(hotspot)
		bDosomething=true
	end

	return bDosomething
end

function game_OnSize( type, cx, cy )
	wx,wy=cx,cy
	g_inv.onSize(type,cx,cy)
end


local lasttime=-1


function game_FrameMove()

	if (lasttime<0) then lasttime=GetAppTime() end
	local nowtime=GetAppTime()
	local timed=nowtime-lasttime
	lasttime=nowtime

	-- show cursor if it move out of client
	local x,y=wnd.ScreenToClient(GetMainWnd(),wnd.GetCursorPos())
	if (x<0 or y<0) then
		wnd.ShowCursor(true)
	end

	-- camera pan

	if (g_config.cameraPan and bMouseOnClient) then
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

	--limit the up and down so it doesn't go 360 vertically
	local rot=camera.getRotation()
	if (rot.x>80) then rot.x=80 end
	if (rot.x<-80) then rot.x=-80 end
	camera.setRotation(rot)

	----------- for vr -------------
	if (not g_config.vr) then return end
	if g_config.vr_controller_enable then
		trackRay.setOrg( ControllerA.getPosition() )
		trackRay.setDir( ControllerA.getFront() )
	else
		trackRay.setOrg( finalcamera.getPosition() + vec.new(0,25,0) )
		trackRay.setDir( finalcamera.getFront() )
	end

	if (lastCameraRotation-finalcamera.getRotation()).lengthsq() < 9 then
		cameraStayTime = cameraStayTime + timed
	else
		cameraStayTime = 0
		lastCameraRotation = finalcamera.getRotation()
	end

	if g_inv.getCoverImage() then
		if g_inv.getCoverImage() ~= coverimg_last then
			coverimg_last = g_inv.getCoverImage()
			coverimg_time = 3
		else
			if cameraStayTime < 4 then
				coverimg_time = coverimg_time - timed
			end
			if coverimg_time < 0 then
				g_inv.setCoverImage(nil)
				coverimg_last = nil
			end
		end

		MsgOnCursor = nil
		return true
	end

	if g_config.vr_beam_enable and g_inv.isShow() then
		local currentitem, t = g_inv.onRayMove( trackRay )
		if t then
			lastInventoryActivingTime = nowtime
			if not startFocusHotspotTime then startFocusHotspotTime = nowtime end
			focusHotspotDistance = t
			g_world.actived_hotspot = nil
		else
			startFocusHotspotTime = nil
			focusHotspotDistance = nil
		end

		if startFocusHotspotTime and nowtime - startFocusHotspotTime > g_config.vr_action_time then
			startFocusHotspotTime = nil
			focusHotspotDistance=nil
			g_inv.selectItem( currentitem )
		end


		if nowtime - lastInventoryActivingTime > 3 then
			g_inv.show( false )
		end

		MsgOnCursor = nil
		return true
	end


	if g_config.vr_beam_enable and (nowtime - lastRayHotspotTime > 0.1) then
		lastRayHotspotTime = nowtime
		
		----- check camera elevation angle for opening inventory window
		if not g_inv.isShow() and finalcamera.getFront().y > math.sin( math.rad(g_config.elevation_angle_for_inventory) ) then
			g_inv.show( true )
			g_inv.selectItem()
			lastInventoryActivingTime = nowtime
		end
		-----------------------------------------------------------


		g_world.actived_hotspot = nil
		local hotspotm
		hotspotm, focusHotspotDistance = getHotspotOnRay( trackRay )
		if hotspotm then
			hotspot = hotspotm.getName()
			g_world.actived_hotspot= hotspotm
			if not startFocusHotspotTime then startFocusHotspotTime = nowtime end
		else
			startFocusHotspotTime = nil
			focusHotspotDistance=nil
		end

		if not g_config.vr_controller_enable and cameraStayTime < 2 then
			startFocusHotspotTime = nil
		end

		-- change cursor by hotspot
		hotspot_cursor()
	end

	if startFocusHotspotTime and nowtime - startFocusHotspotTime > g_config.vr_action_time then
		startFocusHotspotTime = nil
		focusHotspotDistance=nil
		lastRayHotspotTime = nowtime+2

		if (hotspot) then
			DoScript(hotspot)
		end
	end

	return startFocusHotspotTime
end


function game_Render2D(draw)
	
	g_inv.draw(draw)
	
	if g_config.vr then return end

	if (g_config.showCursor and cursortex) then
		--draw.fillcircle(point.new(mx,my),8,8)
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

function game_Render3D(draw)
	if g_config.vr then
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
			cursordis = cursordis* g_config.vr_cursor_scale

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
		if g_config.vr_beam_enable then
			draw.setcolor( g_config.vr_beam_color )
			draw.setbkcolor( g_config.vr_beam_endcolor )
			draw.gradingmode( not focusHotspotDistance )
			local start = trackRay.getOrg()
			draw.moveto( start  )
			draw.lineto( start + trackRay.getDir() * (focusHotspotDistance or 500) )
			draw.gradingmode( false )
		end

		------- draw focus circle ------
		if startFocusHotspotTime then
			draw.setbkcolor( g_config.vr_focus_circle_color )
			local corner = trackRay.getOrg() + trackRay.getDir() * (focusHotspotDistance-10)
			local ztestsave = draw.ztest( false ) -- save z state
			draw.fillcircle( corner, -trackRay.getDir(), g_config.vr_focus_circle_radius, 128, true, 128*(GetAppTime()-startFocusHotspotTime)/g_config.vr_action_time )
			draw.ztest( ztestsave ) -- restore z state
		end


	end
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

function getObjectOnCursor(x,y, distance)
	distance=distance or 9999999

	local ray=GetRayFromPoint(x,y)

	local t=trace.new()
	t.pointed(true)
	t.setStart(ray.getOrg())
	t.setEnd(ray.getOrg()+ray.getDir()*distance);

	scene.trace(t)

	local obj,type=t.getBlockObject()
	return obj, t.getStop()
end


local _onControllerButtonPress = onControllerButtonPress
function onControllerButtonPress( deviceID, buttonid )
	if _onControllerButtonPress then _onControllerButtonPress( deviceID, buttonid ) end

	if not g_config.vr_controller_enable then return end

	if deviceID == ControllerA.getDeviceID() then
		if buttonid == ControllerButtonID.ApplicationMenu then
			g_inv.show( not g_inv.isShow() )
			if g_inv.isShow() then
				g_inv.selectItem()
				lastInventoryActivingTime = GetAppTime()
			end
		elseif buttonid == ControllerButtonID.Trigger then
			if startFocusHotspotTime then
				startFocusHotspotTime = GetAppTime() - g_config.vr_action_time
			end
		end
	end
end