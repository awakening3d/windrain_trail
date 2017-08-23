function add_to_list(list, item)
	table.insert(list,item)
end

function find_in_list(list, item)
	local num=#list
	for i=1,num do
		if (list[i]==item) then
			return i
		end
	end
end

function remove_from_list(list, item)
	local i=find_in_list(list,item)
	if (i) then table.remove(list,i) end
end


function get_scene_table()
	if (not _G[_SCENE_]) then
		_G[_SCENE_]={}
	end
	return _G[_SCENE_]
end

function clear_scene_table()
	_G[_SCENE_]=nil
end

function Play3DSound(name,pos,scale)
	local fLen = (camera.getPosition()-pos).length()
	fLen=fLen/100 -- convert to meter
	if (fLen>100) then return end --over 100 meters
	scale=scale or 1
	local volume = -100 * fLen * scale
	PlaySound(name,volume)
end

local _PlaySound = PlaySound
function PlaySound( name, vol, bmusic )
	if g_config.bSoundOff and not bmusic then return end
	if g_config.bMusicOff and bmusic  then return end
	return _PlaySound( name, vol, bmusic )
end


function find_material(name)
	local pos=scene.getMaterialsHead()
	while (pos) do
		local mater
		mater,pos=scene.getMaterialsNext(pos)
		if (mater.getName()==name) then return mater end
	end
end

-- 初始化lua随机数
math.randomseed(os.time())
math.random() -- randomseed后第一次执行是个固定值
