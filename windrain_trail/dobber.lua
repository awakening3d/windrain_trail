-- dobber  浮标

require 'tempobj'
require 'lipper'

local function new_dobber_material(name)
	local mater=scene.createMaterial()
	if (not mater) then return end
	mater.setName(name)
	mater.setD3DEffect('\\windrain\\scattering_mobile.fx')
	mater.setAmbient( DWORDtoColor(COLOR_DARKGRAY) );
	return mater
end

local function _new()
	local t=tempobj.new(scene.createMovTar())
	t.pointed(true)
	t.setLifeTime(9999999)

	t.setNoClipMask( orDWORD( t.getNoClipMask(), NOCLIPMASK_blockers ) )

	local mov=scene.createMobile('\\dobber.tri')
	if (mov) then		
		local mater=find_material('mater_dobber')
		if (not mater) then
			mater=new_dobber_material('mater_dobber')
			add_to_list( g_world.atmomaterlist, mater )
			OnRestoreDevice()
		end
		mov.bumpEnable(true);
		mov.setMaterial(mater)
		mov.setTexture( texturelist.addTexture("\\dobber.dds") )
		mov.setStyle( orDWORD(mov.getStyle(),MOVS_NOCLIP) )
	end

	local waiteattime = 999999
	local noeattime = 0
	local eatcount = 0
	local lasteatmsgtime = 0
	local function eat()	-- 啄食
		local p = t.getPosition()		
		local deep = g_world.water_level - g_world.terrain.getAlt( p.x, p.z )
		if deep < 150 then return end -- 水太浅

		local ran = math.random();
		t.setVelocity( t.getVelocity() + vec.new( 0, ran*20-40, 0 ) )
		if GetAppTime() - lasteatmsgtime > 3 then -- 避免提示过于频繁
			message_Push('鱼儿来啄食了，注意啊。', g_config.sysmsgcolor )

			g_ripple_position= t.getPosition()
			g_ripple_uvscale = 10 - (1-ran)*5

			lasteatmsgtime=GetAppTime()
		end
	end

	local function eatwhole()	-- 吞食

		local p = t.getPosition()		
		local deep = g_world.water_level - g_world.terrain.getAlt( p.x, p.z )
		if deep < 150 then return end -- 水太浅

		t.setVelocity( t.getVelocity() + vec.new( 0, math.random(-60,-20), 0) )
	end
	
	t.isEatWhole = function()
		return t.getPosition().y - g_world.water_level < -50
	end



	local _frameMove = t.frameMove
	t.frameMove	=	function(timed)
		local ret=_frameMove(timed)
		
		if t.getPosition().y<g_world.water_level then
			t.setVelocity( t.getVelocity() + vec.new(0, 64*timed,0) )
		else
			if t.getGravityScale()<0.5 then
				local p = t.getPosition()
				p.y = g_world.water_level
				t.setPosition(p)
			end
		end
		
		noeattime = noeattime + timed
		if noeattime > waiteattime then
			noeattime = 0
			if math.random() < 0.3 then
				eat()
				eatcount = eatcount + 1
			end
		end

		if eatcount > 2 then -- 如果啄食达到一定次数
			eatcount=0
			if math.random() < 0.3 then	-- 有机会吞食
				eatwhole()
			end
		end

		if (mov) then mov.setPosition( t.getPosition() ) end
		return ret
	end

	t.OnCollide = function(ptrace)
		local tr=trace.new(ptrace)
		
		local obj, type = tr.getBlockObject()
		if 'ocean' == type then
			Play3DSound('\\shell_hit_water.wav',tr.getStop(),2)
			t.setGravityScale(0.05)
			t.setVelocity(vec.new())
			t.setNoClipMask( orDWORD( t.getNoClipMask(), NOCLIPMASK_water ) )
			t.OnCollide = nil

			local p = t.getPosition()		
			local deep = g_world.water_level - g_world.terrain.getAlt( p.x, p.z )
			deep = (deep - 150) / 400	 -- map 150~550 deep water to 0 ~ 1
			if deep < 0 then
				waiteattime = 999999
			else
				if deep > 1 then deep = 1 end
				waiteattime = (1-deep) * 10 + 5
			end

			-- ripple
			--g_ripple_position= t.getPosition()
			--g_ripple_uvscale = 5
			lipper.new( t.getPosition() + vec.new(0,0.1,0), 3, 0.5, 4 )
--[[
			-- spray
			local par=scene.createParticles()
			if (par) then
				par.setPosition(tr.getStop())
				par.setType(PARTICLES_TYPE_EXPLODE)
				par.setStyle( andDWORD(par.getStyle(), notDWORD(PARS_CYCLE)) )
				par.setVelocity(vec.new(28,0,0))
				par.setTexture(texturelist.addTexture("\\spray.bmp"))
				par.setColor(toDWORD('ff8888aa'))
				par.setSize(4)
				par.setBox(vec.new(400,400,400))
				par.setAmount(64)
				par.setLifeTime(3)
			end			
--]]
		end
	end

	
	local _deleteThis	=	t.deleteThis
	local deleteThis	=	function()
		if (mov) then scene.deleteMobile(mov) end
		scene.deleteMovTar(t)
		return _deleteThis()
	end

	t.deleteThis=deleteThis

	return t
end

-- export ----
dobber	=	{
	new	= _new
}
