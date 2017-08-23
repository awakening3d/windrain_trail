require 'game_config'

--- vars define ---

local bIsWeb3D=IsWeb3D() -- whether playing in web page

local winHandle=nil	-- handle of window, if playing in web page, set it to nil, to avoid MoveWindow, ShowWindow, etc.
if (not bIsWeb3D) then winHandle=GetMainWnd() end

local winTitleTextWidth=nil		-- extent of title text
local wincx=0		-- width of window
local wincy=0		-- height of window

local fyjh_dds, titlebar_dds, titlebut_dds;

local function winstyle_onSceneLoaded()
	fyjh_dds = texturelist.addTexture('\\ui\\fyjh.dds')
	titlebar_dds = texturelist.addTexture('\\ui\\titlebar.dds')
	titlebut_dds = texturelist.addTexture('\\ui\\titlebut.dds')

	wnd.SetWindowText(winHandle,g_wincfg.winTitle)	-- set window title text
end

table.insert( g_config.scene_loaded_funs,  winstyle_onSceneLoaded )


local windrag={
	bDragging=false,	-- whether is dragging window
	pos=point.new(),	-- the position of begin drag
	r=rect.new(),	-- rect of window
}



-- begin drag window
local function begindrag(x,y)

	if  g_wincfg.is_full_drag or (y< g_wincfg.winTitleHeight and x<wincx- g_wincfg.winTitleHeight *3) then
		windrag.bDragging=true
		windrag.pos=point.new(wnd.GetCursorPos())
		windrag.r=rect.new(wnd.GetWindowRect(winHandle))	-- rect of window
		return true
	end

	return false
end


-- draging window
local function dragging(x,y)

	if (windrag.bDragging) then
		local ofs=point.new(wnd.GetCursorPos())-windrag.pos

		if (not IsFullScreen()) then
			local winr=windrag.r.clone()
			winr.offset(ofs.x,ofs.y)
			wnd.MoveWindow(winHandle,winr.left,winr.top,winr.width(),winr.height())
		end
	end
end


-- end drag window
local function enddrag()
	windrag.bDragging=false
end






local function winstyle_OnKillFocus()
	enddrag()
end

local function winstyle_OnSetFocus()
end



--- Mouse Input Messages ---

local function winstyle_OnMouseMove(x,y)
	if IsFullScreen() then return end
	dragging(x,y)
end



local bcapture = false

local function winstyle_OnLButtonDown(x,y)
	if IsFullScreen() then return end
	local drag = begindrag(x,y)
	if (drag or y< g_wincfg.winTitleHeight ) then
		wnd.SetCapture(winHandle)
		bcapture = true
		return 1
	end	-- in title area
end

local function winstyle_OnLButtonUp(x,y)
	
	if bcapture then wnd.ReleaseCapture() end

	enddrag()

	if IsFullScreen() then return end
	
	if (y>=0 and y< g_wincfg.winTitleHeight and x>=0 and x<wincx) then	-- in title area
		local ofs=wincx-x
		if (ofs<= g_wincfg.winTitleHeight ) then		-- on close button
			Exit()
		elseif (ofs<= g_wincfg.winTitleHeight *2) then	-- on maximize button
			wnd.ShowWindow(winHandle,SW_MAXIMIZE)
		elseif (ofs<= g_wincfg.winTitleHeight *3) then	-- on minimize button
			if (IsFullScreen()) then
				wnd.ShowWindow(winHandle,SW_MAXIMIZE)
			end
			wnd.ShowWindow(winHandle,SW_MINIMIZE)
		end
	end

	if (y< g_wincfg.winTitleHeight ) then return 1 end		-- in title area
end




------------ output functios -------------


function winstyle_OnSize( type, cx, cy )
	wincx=cx
	wincy=cy
end


function winstyle_Render2D(draw)

	if IsFullScreen() then return end

	--- title bar ---
	draw.setbkcolor(COLOR_WHITE)
	local r=rect.new(0,0,wincx, g_wincfg.winTitleHeight )
	if titlebar_dds then draw.stretchblt(r,titlebar_dds) end

	-- title text --
	--if (not winTitleTextWidth) then winTitleTextWidth=draw.getTextExtent(g_wincfg.winTitle) end
	--local x=(wincx-winTitleTextWidth)/2
	--draw.setcolor(COLOR_DARKGRAY)
	--draw.textout(x,2,g_wincfg.winTitle)

	-- title text image
	local x = (wincx - g_wincfg.winTitleTextImageWidth) /2
	r = rect.new(  x, 0, x + g_wincfg.winTitleTextImageWidth, g_wincfg.winTitleTextImageHeight )
	if fyjh_dds then draw.stretchblt(r,fyjh_dds) end

	-- title buttons --
	draw.setcolor(COLOR_BLACK)
	local x=wincx- g_wincfg.winTitleHeight *3+5
	local y=10
	draw.rect(rect.new(x,y,x+7,y+1))
	x=wincx- g_wincfg.winTitleHeight *2+5
	y=6
	draw.rect(rect.new(x,y,x+7,y+7))
	x=wincx- g_wincfg.winTitleHeight *1+5
	y=6
	draw.moveto(x,y) draw.lineto(x+6,y+6)
	draw.moveto(x+6,y) draw.lineto(x,y+6)

	if titlebut_dds then
		draw.setbkcolor(toDWORD('88ffffff'))
		draw.blt(wincx- g_wincfg.winTitleHeight *1,2,titlebut_dds)
		draw.blt(wincx- g_wincfg.winTitleHeight *2,2,titlebut_dds)
		draw.blt(wincx- g_wincfg.winTitleHeight *3,2,titlebut_dds)
	end
end



local WM_MOUSEMOVE                    = 512
local WM_LBUTTONDOWN		      = 513
local WM_LBUTTONUP                    = 514

local WM_SETFOCUS                     = 7
local WM_KILLFOCUS                    = 8

local function LOHIWORD( p )
	local xstr = string.format('%08x',p) -- 转 number 成十六进制字符串
	local loword = string.sub( xstr, -4 )
	local hiword = string.sub( xstr, 1, 4 )
	return tonumber(loword,16), tonumber(hiword,16)
end

function _AppMsgProc( msg, wParam, lParam, hWnd )
	if WM_MOUSEMOVE == msg then
		winstyle_OnMouseMove( LOHIWORD(lParam) )
	elseif WM_LBUTTONDOWN == msg then
		return winstyle_OnLButtonDown( LOHIWORD(lParam) )
	elseif WM_LBUTTONUP == msg then
		return winstyle_OnLButtonUp( LOHIWORD(lParam) )
	elseif WM_SETFOCUS == msg then
		winstyle_OnSetFocus()
	elseif WM_KILLFOCUS == msg then
		winstyle_OnKillFocus()
	end
end