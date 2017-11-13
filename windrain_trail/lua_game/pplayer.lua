require 'game_config'
require 'lipper'
require 'weapon'
require 'sword'
require 'goods'

NOCLIPMASK_water	= toDWORD('00000001')
NOCLIPMASK_blockers	= toDWORD('00000002')

local handweapon = nil -- 主手武器
local handweaponid = nil -- 武器对应物品id，只在切换场景时使用

local function pplayer_onSceneExit()
	if handweapon then	-- 退出场景前保存武器到背包
		handweaponid = handweapon.getType()
		pplayer.takeoffWeapon()
	else
		handweaponid = nil
	end
end


local function pplayer_onSceneLoaded()
	pplayer = player

	g_world.water_level = nil -- no water
	g_world.terrain=nil
	if scene.getTerrainsHead() then
		g_world.terrain = scene.getTerrainsNext( scene.getTerrainsHead() )
	end

	g_world.char_targetPos=nil

	GameMode(true);

	local fMoveStep, fRotateStep = CameraMoveRotateStep(0,0) -- retrieves move/rotate step
	CameraMoveRotateStep(fMoveStep,fRotateStep)

	local target_arrow = scene.createSkinMesh("\\target_arrow.tri");
	local arrow_ani = scene.createBonesAni("\\arrow.ani");
	target_arrow.setBonesAni(arrow_ani);
	target_arrow.setScale(vec.new(0.2,0.2,0.2));
	local tamater = scene.createMaterial();
	tamater.setAmbient( DWORDtoColor(COLOR_YELLOW) );
	tamater.setD3DEffect("\\windrain\\color_skin.fx")
	target_arrow.setMaterial(tamater);
	target_arrow.setTexture( texturelist.getTextureID('\\none.bmp') )
	target_arrow.bumpEnable(true);


	--- export ---
	pplayer.max_zhengqi = 3 -- 最大真气值
	pplayer.zhengqi = pplayer.max_zhengqi

	player.getMovTar().setNoClipMask( orDWORD( player.getMovTar().getNoClipMask(), NOCLIPMASK_water ) )


	pplayer.isFreezing = function()
		return player.bfreezing
	end

	pplayer.freezing = function( freezing )
		player.bfreezing = freezing
		return player.getMovTar().freezing( freezing )
	end

	pplayer.takeoffWeapon = function()
		if (not handweapon) then return end
		handweapon.takeoff()
		handweapon = nil
	end

	pplayer.setWeapon = function( wp )
		pplayer.takeoffWeapon()
		handweapon = wp
	end

	pplayer.getWeapon = function()
		return handweapon
	end


	local timesum = 0

	local lippertime = 0
	pplayer.frameMove = function( AppTimeD )

		if pplayer.isFreezing() then return end

		--- weapon ---
		if handweapon then
			handweapon.frameMove( AppTimeD )
			g_config.vr_beam_visible = false
		else
			g_config.vr_beam_visible = true
		end
		
		timesum = timesum + AppTimeD
		if timesum < 0.033 then return end
		AppTimeD = timesum
		timesum = 0


		--- player movment---
		player.setJumpmoveStep(1)
		local plymt=player.getMovTar()
		plymt.setStrideHeight(41)

		plymt.setGravityScale(1)
		plymt.setResistance(0.5)
		if player.getGround() then
			plymt.setResistance(4)
			local vel=plymt.getVelocity()
			local hvlensq=vel.x*vel.x+vel.z*vel.z
			if hvlensq<10000 then
				plymt.setGravityScale(0)
			end
		end
		
		-- move player in vr mode
		if g_config.vr then
			local x,y = ControllerA.getAxis()
			if x and y and (x~=0 or y~=0) then
				if y>0 or not ControllerA.isButtonPressed( ControllerButtonID.Touchpad ) then
				   local vel = (ControllerA.getFront() * y + ControllerA.getRight() * x) * AppTimeD * fMoveStep * 16
				   vel.y = 0
				   player.go( vel )
				end
			end
		end

		--- move to target pos ---
		if (g_world.char_targetPos) then
			local vDir=g_world.char_targetPos-player.getPosition()
			local horzdir = vDir
			horzdir.y=0
			local fDirLen=horzdir.length()
			if (fDirLen <80) then -- reach the target
				g_world.char_targetPos=nil
				target_arrow.hide(true)
				player.getMovTar().setVelocity(player.getMovTar().getVelocity()*0.3)
			else
				vDir = vDir / fDirLen * fMoveStep * 0.3
				player.go(vDir*AppTimeD*32)
			end
			
			
			if ( GetAppTime() - g_world.char_startTime > 1 ) then
				if ( player.getPosition() - g_world.char_startPos ).lengthsq() < 900 then	-- 1秒内移动距离小于.3米
					g_world.char_targetPos=nil
					target_arrow.hide(true)
				else
					g_world.char_startPos = player.getPosition()
					g_world.char_startTime = GetAppTime()
				end
			end
		end

		
		local qingong = wnd.IsKeyDown(VK_SHIFT)
		if g_config.vr then qingong = ControllerA.isButtonPressed( ControllerButtonID.Grip ) end

		if qingong then -- 轻功
			if pplayer.zhengqi>0 then
				pplayer.go( vec.new(0,600 * pplayer.zhengqi * AppTimeD,0) )
				pplayer.zhengqi = pplayer.zhengqi - AppTimeD
			end
		else
			pplayer.zhengqi = pplayer.zhengqi + AppTimeD
			if pplayer.zhengqi > pplayer.max_zhengqi then
				pplayer.zhengqi = pplayer.max_zhengqi
			end
		end

		-- lipper for walk in water
		if g_world.water_level then
			lippertime = lippertime + AppTimeD
			if lippertime > .5 then
				lippertime = 0
				local p = player.getPosition()
				if p.y <= g_world.water_level then -- player under water
					local vel = player.getMovTar().getVelocity()
					if vel.length()>15 then
						p.y = g_world.water_level
						lipper.new( p + vec.new(0,0.1,0), 3, math.random()*0.3 + 0.2 )
					end
				end
			end
		end

		-- water level check
		--if g_world.water_level then
		if false then
			local m = player.getMovTar()

			local v = m.getVelocity()
			v.normalize()

			local t = trace.new()

			t.pointed(false)
			t.setBoundingBox( m.getBoundingBox() )
			t.setStart( m.getPosition() )
			t.setEnd( m.getPosition() + v * 100 )
			--t.setNoClipMask( )
			
			scene.trace(t)

			local p = t.getStop()

			if p.y < g_world.water_level then
				player.getMovTar().setVelocity(vec.new(0,0,0))
			end
		end

	end


	pplayer.OnLButtonUp = function(x,y)
		
		if pplayer.isFreezing() then return end

		if ( texturelist.getTextureID(g_config.cursor_arrow) ~= game_GetCursor() ) then return end
		
		--- weapon ---
		if handweapon then
			handweapon.attack()
			return
		end
		
		local obj,pos, type =getObjectOnCursor(x,y,nil,orDWORD( NOCLIPMASK_STATICMESH, NOCLIPMASK_MOBILE, NOCLIPMASK_MOVTAR, NOCLIPMASK_BLOCKEDGE, NOCLIPMASK_blockers) )
		if (obj and (player.getPosition()-pos).length()<3200 ) then
			g_world.char_targetPos=pos
			g_world.char_startPos = player.getPosition()
			g_world.char_startTime = GetAppTime()
			target_arrow.setPosition(g_world.char_targetPos)
			target_arrow.hide(false)

			-- ripple --
			if g_world.water_level and 'ocean'==type then
				local p = g_world.char_targetPos
				p.y = g_world.water_level
				lipper.new( p + vec.new(0,0.1,0), 3, 0.5, 2 )
			end
		end
	end

	pplayer.UpdateUserInput = function( userinput )

		if ( wnd.IsKeyDown( VK_SPACE ) ) then
			userinput.setJump(true)
		elseif ( wnd.IsKeyDown( VK_CONTROL ) ) then
			userinput.setDuck(true)
		end

		if gDuckInput then
			userinput.setDuck(true)
		elseif gJumpInput then
			userinput.setJump(true)
		end


		if pplayer.isFreezing() then
			userinput.clear()
		end
	end



	if (handweaponid) then -- 如果先前有武器，则从背包取出保存的武器
		goodsUse( handweaponid, true )
	end


end

table.insert( g_config.scene_loaded_funs,  pplayer_onSceneLoaded )

table.insert( g_config.scene_onexit_funs, pplayer_onSceneExit )