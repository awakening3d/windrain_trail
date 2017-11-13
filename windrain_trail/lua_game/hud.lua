require 'setupui'
require 'optionsetting'
require 'showmessage'




local wincx,wincy = 0,0


local pplayer_draw2d = function( draw )
	if pplayer.zhengqi >= pplayer.max_zhengqi then return end

	local r = rect.new(8,0,16,wincy-40)
	r.top = r.bottom - 400 * pplayer.zhengqi/pplayer.max_zhengqi

	draw.setbkcolor(COLOR_LIGHTBLUE)
	draw.fillrect(r)
end



------------- export --------------
function HUD_OnSize( type, cx, cy )
	if SIZE_MAXIMIZED~=type and SIZE_RESTORED~=type then return end
	wincx, wincy = cx, cy
	message_OnSize(type, cx, cy )
	UI_OnSize( type, cx, cy )
end

function HUD_Render2D( draw )
	pplayer_draw2d( draw )
	message_Draw(draw)
end

local msgboxtime = 0
function HUD_MsgBox(time, szText, szCaption, uType, nIDYes, nIDNo )
	msgboxtime = time
	return msgBox( szText, szCaption, uType, nIDYes, nIDNo )
end

local lastx,lasty = 0,0
function HUD_FrameMove( AppTimeD )

	if g_config.vr then
		local w,h = winds3dvr.get_2dbuffer_resolution()
		if wincx~=w or wincy~=h then
			HUD_OnSize( SIZE_RESTORED, w, h )
		end

		mouse_message_by_ray( ControllerA, ray.new( ControllerA.getPosition(), ControllerA.getFront() ), w, h )

	end

	UI_OnFrameMove( AppTimeD )

	-- msgbox
	if msgboxtime>0 then
		if msgBoxIsVisible() then
			msgboxtime = msgboxtime - AppTimeD
			if msgboxtime<=0 then
				msgBoxClose() -- ��������HUD_MsgBox()�е�����box�ڱ��ֶ��رպ����û��������ֵ����µ�msgbox���ǹصĿ�������box
			end
		else
			msgboxtime = 0
		end
	end

	-- message
	message_FrameMove(AppTimeD)
	-- cursor
	if not ui_IsHidden() then
		local x,y=wnd.ScreenToClient(GetMainWnd(),wnd.GetCursorPos())
		if x~=lastx or y~=lasty then
			g_config.cameraPan = true
			if ui_GetLayerOnXY(x,y) then
				game_SetCursor(texturelist.addTexture(g_config.cursor_arrow),g_config.cursor_arrow_info)
				if y < wincy - 3 then g_config.cameraPan = false end
			end
		end
		lastx,lasty = x,y

		if g_config.vr then g_config.cameraPan = false end
	end
end


function HUD_OnRButtonUp(x,y)
	UI_OnRButtonUp(x,y)
end

function HUD_OnKeyDown(nChar)
	local c=string.char(nChar)
	--print(c, nChar)
	if (187==nChar or 107==nChar) then -- '='
		adjust_brightness(0.01)
	elseif (189==nChar or 109==nChar) then -- '_'
		adjust_brightness(-0.01)
	end

	if (219==nChar) then -- '['
		adjust_contrast(-0.02)
	elseif (221==nChar) then -- ']'
		adjust_contrast(0.02)
	end

	if 192==nChar then	-- '`'
		UIevent_OnButtonDown(0, ID_WEAPON ) -- ģ��������ť
	end

	if 81==nChar then	-- 'Q'
		UIevent_OnButtonDown(0, ID_INVENTORY ) -- ģ����Ʒ��ť
	end
end

function HUD_OnRestoreDevice()
	adjust_brightness(0)
	adjust_contrast(0)
	set_hue_saturation()
end