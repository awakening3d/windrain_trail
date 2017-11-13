
local msg = {}
msg.new = function( _text, _txtcolor )
	local text = _text
	local txtcolor = _txtcolor
	local alpha = 1

	local function frameMove(timed)
		alpha = alpha - timed*0.1
	end

	local function getText()
		return text
	end

	local function getColor()
		local col = DWORDtoColor( txtcolor )
		col.a = alpha
		return ColortoDWORD( col )
	end

	local function getAlpha()
		return alpha
	end

	local r = {}
	r.frameMove = frameMove
	r.getText = getText
	r.getColor = getColor
	r.getAlpha = getAlpha
	return r
end


local msglist = array.new()


------- export --------
local wincx,wincy
function message_OnSize(type, cx, cy )
	wincx,wincy = cx,cy
end

function message_Push( text, txtcolor )
	if not text then return end
	txtcolor = txtcolor or COLOR_YELLOW
	local m = msg.new( text, txtcolor )
	msglist.add(m)
end

local lineheight = 20
local leftoffset = 8
local bottomoffset = 40
function message_Draw( draw )
	if g_config.vr then leftoffset = 180 end
	local y = wincy - bottomoffset - msglist.size()*lineheight

	for n=1,msglist.size() do
		local m = msglist[n]
		draw.setcolor( m.getColor() )
		draw.textout( leftoffset, y, m.getText() )
		y = y + lineheight
	end
end

function message_FrameMove( timed )

	local nochangelist = true -- 是否需要整理队列

	for n=1,msglist.size() do
		local m = msglist[n]
		m.frameMove(timed)
		if m.getAlpha()<=0 then
			nochangelist = false
		end
	end
	
	if nochangelist then return end

	-- 把不可见的message从队列里删除
	local tmplist = array.new()

	for n=1,msglist.size() do
		local m = msglist[n]
		if m.getAlpha()>0 then
			tmplist.add(m)
		end
	end

	msglist.clear()
	for n=1,tmplist.size() do
		msglist.add( tmplist[n] )
	end

end