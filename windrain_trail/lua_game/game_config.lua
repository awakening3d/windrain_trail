g_wincfg = {
	winTitle='风雨江湖',	-- title of window
	winTitleHeight=20,		-- height of window title bar
	winTitleTextImageWidth = 180, -- width of title text image
	winTitleTextImageHeight = 40, -- height of title text image
	is_full_drag = false, -- 全窗口点击拖放
}

g_config = {
	cameraPan=true,
	cameraPanStep=512,
	cameraPanBorderline=0.1,
	tipsColor=COLOR_WHITE,
	tipsPosX=20,
	tipsPosY=24,

	showCursor=true,
	cursor_arrow='\\cursor_arrow.png',
	cursor_hand_open='\\cursor_hand_open.png',
	cursor_portal='\\cursor_portal.png',
	--cursor_arrow_info={0,0,32,32}, -- { xHotSpot, yHotSpot, nWidth, nHeight }
	--cursor_hand_open_info={0,0,32,32},
	--cursor_portal_info={0,0,32,32},

	hotspotDistance = 300,
	hide_cursor_when_no_mouse_move=true,
	hide_cursor_when_no_mouse_move_time=3,

	scene_loaded_funs = {},
	scene_onexit_funs = {},

	brightness_rectification	= 0,
	contrast_rectification = 0,

}

g_world = {
	actived_hotspot=nil,
	disabled_hotspots={},
}

g_msg = {
}

g_hotspot_function = {
	
}

g_soundconfig = {
	
	music_list = {},
	music_time_interval_min = 60,
	music_time_interval_max = 300,

	sound_stream = {
		sound_list = { '\\waterwave0.wav', '\\waterwave1.wav', '\\waterwave2.wav' },
	},
	sound_jungle0 = {
		sound_list = {'\\jungle0.wav','\\jungle1.wav','\\jungle2.wav'},
		time_interval_min = 3,
		volume_scale = 1.5,
	},
	sound_bamboos = {
		sound_list = {'\\wind.wav'},
		time_interval_min = 3,
		time_interval_max = 6,
		volume_scale = 1.2,
	},
	sound_fire = {
		sound_list = {'\\fire.wav'},
		time_interval_min = 3,
		volume_scale = 0.7,
	},
	sound_dropwater = {
		sound_list = {'\\drop_water_cave.wav'},
		time_interval_min = 4,
		volume_scale = 1,
	},

}