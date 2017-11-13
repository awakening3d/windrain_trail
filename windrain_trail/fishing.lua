---- fishing -----
require 'dobber'

--goodsPick(goodsID.diaogan)
--for n=1,16 do goodsPick(goodsID.qiuyin) end



g_hotspot_function[ 'hotspot_diaogan'] = function() -- 点击钓竿
	goodsPick( goodsID.diaogan )
	hotspot_diaogan.hide(true)
	if hotspot_diaogan.dobber then
		if hotspot_diaogan.dobber.isEatWhole() then
			if math.random() < 0.3 then
				msgBox('运气不好，脱钩了。', '风雨江湖')				
			else
				local id = goodsID.nianyu
				local num = math.random(1,4)
				if num<2 then
					id = goodsID.jiyu
				elseif num<3 then
					id = goodsID.qingyu
				elseif num<4 then
					id = goodsID.liyu
				end
				goodsPick(id)
				local desc = goodsGetItem(id)
				msgBox('恭喜！钓获一条 ' .. desc .. ' 。', '风雨江湖')
			end
		end
		hotspot_diaogan.dobber.setLifeTime(0)
		hotspot_diaogan.dobber=nil
	end
end

--- 使用钓竿 ---
goodsUseFunction[ goodsID.diaogan ] = function()
	if IsPlayingShot() then return end

	local x,y=wnd.ScreenToClient(GetMainWnd(),wnd.GetCursorPos())

	local ry
	if g_config.vr then
		ry = ray.new( ControllerA.getPosition(), ControllerA.getFront() )
	else
		ry = GetRayFromPoint( x,y )
	end

	local fDistance=99999999

	local pos = GetSelectionHead( 'waterblockers' )
	while (pos) do
	    local root,cid
	    root,pos,cid = GetSelectionNext(pos)
	    if UD_SURFACE==cid then
		root = ObjectFromClassID( cid, root )
	    else
		root = nil
	    end

	    if (root) then
		local bInter, fDis = root.intersectRay(ry,true,true)
		if bInter and fDis<fDistance then
			fDistance=fDis
		end
	    end
	end

	if fDistance > 500 then
		msgBox('你得在河边面对着水才能钓鱼啊。','风雨江湖',MB_OK)
		return
	end -- 距离水边太远

	local desc, amount, img = goodsGetItem( goodsID.qiuyin )
	if not amount then
		msgBox('只有钓竿没鱼饵，还是钓不了啊。','风雨江湖',MB_OK)
		return
	end


	local p = pplayer.getPosition() + vec.new(80,0,80)
	p.y = g_world.terrain.getAlt( p.x, p.z ) + 120


	local t=trace.new()
	t.pointed(false)
	local bb = pplayer.getBoundingBox()
	bb.offset( -pplayer.getPosition())
	t.setBoundingBox(bb)
	t.setStart( pplayer.getPosition() + vec.new(0,20,0) )
	t.setEnd( p + vec.new(0,-100,0) )

	t.setNoClipMask( orDWORD( t.getNoClipMask(), NOCLIPMASK_blockers,NOCLIPMASK_water ) )
	scene.trace(t)
	if (t.getFraction()<1) then
		msgBox('这里有点窄，找个空点的地吧。', '风雨江湖', MB_OK)
		--print( t.getBlockObject() )
		return
	end


	hotspot_diaogan.setPosition( p )
	hotspot_diaogan.hide(false)

	
	goodsDrop(goodsID.diaogan,true)
	goodsConsume(goodsID.qiuyin) -- 消耗蚯蚓

	-- 扔浮标
	hotspot_diaogan.dobber = dobber.new()
	hotspot_diaogan.dobber.setPosition( finalcamera.getPosition() + vec.new( 0, 50, 0 ) )
	hotspot_diaogan.dobber.setVelocity( finalcamera.getFront() * 1000 )
	if math.random()>0.5 then
		PlaySound('\\throw.wav',-2000)
	else
		PlaySound('\\throw1.wav',-2000)
	end
end