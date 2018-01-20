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
	vr_controller_enable = false,
	vr_beam_enable = true,
	vr_beam_color = COLOR_YELLOW,
	vr_beam_endcolor = toDWORD('00fcfc54'),
	vr_teleport_time = 3,
	vr_action_time = 3,
	vr_focus_circle_color = toDWORD('88fcfc54'),
	vr_focus_circle_radius = 10,
	vr_cursor_scale = 0.001,

	cover_area_width = 100,
	cover_area_height = 75,
	cover_area_depth = 150,

	elevation_angle_for_inventory = 30, -- the camera elevation angle for opening inventory window

	item_area_width = 100,
	item_area_height = 75,
	item_area_depth = 150,
	item_icon_width	= 20,
	item_icon_height = 20,
	item_icon_gap	= 2,
	item_frame_color = COLOR_YELLOW,

}

g_world = {
	actived_hotspot=nil,
	disabled_hotspots={},
}

g_msg = {
}