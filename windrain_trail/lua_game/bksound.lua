require 'game_config'
require 'soundsource'

local sndsrclist = array.new()

local bkmusictime = nil

local function bksound_onSceneLoaded()

	g_soundconfig.music_list = nil
	bkmusictime = nil

	sndsrclist.clear()
	local pos=scene.getLightsHead()
	while (pos) do
		local lig;
		lig,pos = scene.getLightsNext(pos)
		if (lig) then
			if (not lig.isHidden()) then
				local name = lig.getName()
				if ('sound_'==string.sub(name,1,6)) then
					local cfg = g_soundconfig[name]
					if not cfg then
						print('warning: no found config for bksound:',name)
					else
						local snd = soundsource.new( cfg.sound_list )
						snd.setDesc(name)
						snd.setPosition( lig.getPosition() )
						snd.setRange( lig.getRange() )

						if cfg.time_interval_min then
							snd.setTimeInterval( cfg.time_interval_min, cfg.time_interval_max )
						end

						if cfg.volume_scale then
							snd.setVolumeScale(cfg.volume_scale)
						end

						sndsrclist.add(snd)
					end
				end
			end
		end
	end
end

table.insert( g_config.scene_loaded_funs,  bksound_onSceneLoaded )



function bksound_PlayMusic( idx )
	if not g_soundconfig.music_list then return end
	if IsPlayingMusic()  then return end
	local musicfiles  = g_soundconfig.music_list
	local musicnum = #musicfiles
	if musicnum<1 then return end

	idx = idx or math.random(1,musicnum)
	PlaySound( musicfiles[idx], -100, true )
	return idx
end

function bksound_FrameMove( timed )
	for i=1, sndsrclist.size() do
		sndsrclist[i].frameMove( timed )
	end

	--- bk music ---
	if not bkmusictime then bkmusictime = g_soundconfig.music_time_interval_min end

	bkmusictime = bkmusictime - timed
	if bkmusictime<0 then
		bksound_PlayMusic()
		bkmusictime = math.random(g_soundconfig.music_time_interval_min,g_soundconfig.music_time_interval_max)
	end

end

function bksound_Add( sndsrc )
	sndsrclist.add(sndsrc)
end

function bksound_Del( sndsrc )
	local idx = sndsrclist.find( sndsrc )
	if not idx then return end
	sndsrclist.remove(idx)
end

