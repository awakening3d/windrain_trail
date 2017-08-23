-- game.lua
-- v0.24

require 'game_config'
require 'inventory'

local mx, my=0,0;
local downx,downy=0,0
local wx,wy=0,0;


local cursortex = nil
local cursorinfo = nil
local hotspot=nil

local MsgOnCursor = ''



g_inv=inventory.new()
g_inv.setArea(rect.new(0.1,0,0.9,0.12))
g_inv.setBackColor( ColortoDWORD(color.new(0.5,0.5,0.5,0.8)) )
g_inv.setItemOffset(16,8)
--g_inv.setBackImage(1)

local bMouseOnClient=true



local function get_hotspot(x,y)

	local hotspot=nil

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
						local ray=GetRayFromPoint(x,y)
						local bInter, fDis = mov.intersectRay(ray,true)
						if (bInter and (fDis<fDistance) ) then
							fDistance=fDis
							hotspot=name
							g_world.actived_hotspot=mov
						end
					end
				end
			end
		end
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

	return hotspot

end





function game_SetCursor(tex,info)
	cursortex=tex
	cursorinfo=info
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

	hotspot=get_hotspot(x,y)
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


end


function game_Render2D(draw)
	g_inv.draw(draw)
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



---- utils ---
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


--[[
function getObjectOnCursor(x,y)
		local ray=GetRayFromPoint(x,y)
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
--]]