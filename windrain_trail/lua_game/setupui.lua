require 'game_config'
require 'uilayer'
require 'optionsetting'
require 'goods'

g_config.cursor_arrow='\\ui\\cursor_sword.png'
g_config.cursor_hand_open='\\ui\\cursor_action.png'
g_config.cursor_hand_open_info={13,0}

local function setupui_OnSceneLoaded()
	-- disable windsplayer's accelerator keys
	EnableAccel(false)
	-- enable w, s ,a, d controls
	SetInputStyle( ModifyStyle(GetInputStyle(), orDWORD(INPUT_STYLE_EX,INPUT_STYLE_CONFIG), INPUT_STYLE_WSAD) )
end

table.insert( g_config.scene_loaded_funs,  setupui_OnSceneLoaded )

ID_YES_enter_secretroom = 9979
ID_YES_exit_secretroom = 9980
ID_YES_enter_dungeon = 9981
ID_YES_exit_dungeon = 9982
ID_YES_sleep = 9983
ID_YES_exit_stream	= 9984
ID_YES_delitem		= 9985
ID_YES_bambooraft = 9986
ID_YES_igo	=	9987
ID_YES_exit	=	9988
ID_NO		=	9989


local ID_QUIT			= 11000
local ID_FULLSCREEN	= 11001

local ID_ADJUSTBRIGHT	= 11002

local ID_CHAT			= 11009

      ID_INVENTORY		= 11011
local ID_OPTION		= 11012

      ID_WEAPON		= 11013


local ID_BRIGHTNESS		= 11050
local ID_BRIGHTNESS_DEFAULT	 = 11051
local ID_CONTRAST			= 11052
local ID_CONTRAST_DEFAULT	= 11053


local ID_HUE			= 11054
local ID_HUE_DEFAULT	= 11055
local ID_SATURATION	= 11056
local ID_SATURATION_DEFAULT = 11057

local ID_PICTURE_STYLE	= 11058


local ID_MODELIST		= 11062

local ID_SOUND	=	11073
local ID_MUSIC	 	=	11074


local ID_USEITEM		= 11100
local ID_DELITEM		= 11101

local wx,wy=0,0;

local baselayer = nil
local optionlayer = nil
local inventorylayer = nil


local optionW =	200
local optionH = 400

local inventoryW = 200
local inventoryH = 500


local function resizeUI()
	local r = rect.new(0,wy - 35, wx, wy)
	if baselayer then baselayer.setRect( r ) end
	if g_config.vr then baselayer.setBackgroundColor() end -- completely transparent 

	local xofs = 0
	if g_config.vr then xofs = 150 end
	local br = baselayer.butOption.getRect()
	br.offset( r.right-45-xofs - br.left, 0 )
	baselayer.butOption.setRect( br )

	br = baselayer.butInventory.getRect()
	br.offset( r.right-90-xofs - br.left, 0 )
	baselayer.butInventory.setRect( br )

	br = baselayer.butWeapon.getRect()
	br.offset( r.right-140-xofs - br.left, 0 )
	baselayer.butWeapon.setRect( br )

	r = rect.new(wx-20 - optionW, wy - optionH - 40, wx-20, wy - 40 )
	if g_config.vr then r.offset( -200, -50 ) end
	if optionlayer then optionlayer.setRect( r ) end
	r = rect.new(wx - inventoryW - 100, wy - inventoryH - 35, wx - 100, wy - 35 )
	if g_config.vr then r.offset( -200, 0 ) end
	if r.top<0 then r.top = 0 end
	if (inventorylayer) then inventorylayer.setRect( r ) end

	if g_config.vr then
		local r = baselayer.txtChat.getRect()
		r.offset(40-r.left,0)
		baselayer.txtChat.setRect(r)

		r = baselayer.editChat.getRect()
		r.offset(80-r.left,0)
		baselayer.editChat.setRect(r)
	end
end

local function setupBaseUI()
	if baselayer then return end
	baselayer = uilayer.new(1)

	baselayer.txtChat = baselayer.addStatic( 0, '聊天：', 0,0,40,32 )
	baselayer.editChat = baselayer.addIMEEditBox(  ID_CHAT, '你好吗', 40, 0, 200, 32 )

	baselayer.butWeapon = baselayer.addButton( ID_WEAPON, '武 器', 660, 6, 40, 20)
	baselayer.butInventory = baselayer.addButton( ID_INVENTORY, '物 品', 710, 6, 40, 20)
	baselayer.butOption = baselayer.addButton( ID_OPTION, '选 项', 755, 6, 40, 20 )

	baselayer.butWeapon.setVisible(false)

	resizeUI()
end


local function setupOptionUI()
	if optionlayer then return end
	optionlayer = uilayer.new(2)

	optionlayer.addStatic( ID_BRIGHTNESS_DEFAULT, '亮  度', 4,4,40,32 )
	optionlayer.sliderBrightness = optionlayer.addSlider( ID_BRIGHTNESS, 50, 10, 140, 20 )
	optionlayer.addStatic( ID_CONTRAST_DEFAULT, '对比度', 4,40,40,32 )
	optionlayer.sliderContrast = optionlayer.addSlider( ID_CONTRAST, 50, 45, 140, 20 )

	optionlayer.addStatic( ID_HUE_DEFAULT, '色  相', 4, 80, 40, 32 )
	optionlayer.sliderHue = optionlayer.addSlider( ID_HUE, 50, 85, 140, 20 )
	optionlayer.addStatic( ID_SATURATION_DEFAULT, '饱和度', 4, 115, 40, 32 )
	optionlayer.sliderSaturation = optionlayer.addSlider( ID_SATURATION, 50, 120, 140, 20 )

	optionlayer.addStatic( 0, '画 面 风 格：', 4, 155, 80, 32 )
	optionlayer.picstyles = optionlayer.addComboBox( ID_PICTURE_STYLE, 80, 155, 120, 32 )
	optionlayer.picstyles.styleparamlist = {}
	optionlayer.picstyles.addItem('自然原味')
	optionlayer.picstyles.styleparamlist[1] = { hue = 50, saturation = 50, colorful = {1,1,1,1}, }
	optionlayer.picstyles.addItem('温馨暖黄')
	optionlayer.picstyles.styleparamlist[2] = { colorful = {1,0.8,0.7,1}, }
	optionlayer.picstyles.addItem('清新蓝调')
	optionlayer.picstyles.styleparamlist[3] = { colorful = {0.8,0.9,1,1}, }
	optionlayer.picstyles.addItem('魅艳冷紫')
	optionlayer.picstyles.styleparamlist[4] = { colorful = {0.8,0.7,1,1}, }
	optionlayer.picstyles.addItem('绿衣少女')
	optionlayer.picstyles.styleparamlist[5] = { colorful = {0.8,1,0.8,1}, }
	optionlayer.picstyles.addItem('红粉知己')
	optionlayer.picstyles.styleparamlist[6] = { colorful = {1,0.8,0.9,1}, }
	optionlayer.picstyles.addItem('亮丽人生')
	optionlayer.picstyles.styleparamlist[7] = { hue = 50, saturation = 75, }
	optionlayer.picstyles.addItem('怀旧复古')
	optionlayer.picstyles.styleparamlist[8] = { hue = 50, saturation = 25, }
	optionlayer.picstyles.addItem('黑白世界')
	optionlayer.picstyles.styleparamlist[9] = { hue = 50, saturation = 0, colorful = {1,1,1,1} }
	optionlayer.picstyles.setDropHeight(130)


	optionlayer.addStatic( 0, '全屏分辨率：', 4, 200, 80, 32 )
	optionlayer.modelist = optionlayer.addComboBox( ID_MODELIST, 80, 200, 120, 32 )
	optionlayer.checksound = optionlayer.addCheckBox(ID_SOUND,'音  效', 10, 245, 40, 16, true )
	optionlayer.checkmusic = optionlayer.addCheckBox(ID_MUSIC,'背景音乐', 80, 245, 40, 16, true )

	optionlayer.addButton( ID_FULLSCREEN, '全屏 / 窗口',  optionW - 85*2, optionH - 25, 80, 20 )
	optionlayer.addButton( ID_QUIT,'退 出 游 戏', optionW - 85, optionH - 25, 80, 20 )
	resizeUI()

	-- update slider
	adjust_brightness(0)
	adjust_contrast(0)
	-- update modelist
	optionlayer.modelist.wlist={}
	optionlayer.modelist.hlist={}
	local w, h = GetFullScreenMode(0) -- get current display mode
	local curmode = 0
	for i=1,GetFullScreenMode() do
		local width, height = GetFullScreenMode(i)
		local txt = string.format( "%d x %d", width, height )
		local idx = optionlayer.modelist.addItem( txt )
		optionlayer.modelist.wlist[idx] = width
		optionlayer.modelist.hlist[idx] = height
		if w==width and h==height then
			curmode = i
		end
	end
	
	if curmode > 0 then
		optionlayer.modelist.selectItem(curmode)
	end

end

local function apply_picture_style( styleparam )
	if styleparam.hue then
		optionlayer.sliderHue.setValue( styleparam.hue )
	end
	if styleparam.saturation then
		optionlayer.sliderSaturation.setValue( styleparam.saturation )
	end
	if styleparam.hue or styleparam.saturation then
		UIevent_OnSliderValueChanged( optionlayer.getLayerOrder(), ID_SATURATION ) -- change hue and saturation
	end
	
	if styleparam.colorful then
		set_hue_saturation(nil,nil, styleparam.colorful ) -- change colorful
	end
end

local function updateGoodsListBox( itemlist )
	if not inventorylayer then return end

	inventorylayer.lbGoods.removeAllItems()

	for n=1,itemlist.size() do
		local it=itemlist[n]
		local idx = inventorylayer.lbGoods.addItem( it.getDesc(), it.getImage(), it.getID() )
		if idx then
			inventorylayer.lbGoods.setItemAmount( idx, it.getAmount() )
		end
	end

end

local function setupInventoryUI()
	if inventorylayer then return end
	inventorylayer = uilayer.new(3)

	inventorylayer.addStatic( 0, ' 物 品 列 表：', 4, 4, 80, 20 )
	inventorylayer.addButton( ID_USEITEM, '使  用', 90, 4, 50, 20 )
	inventorylayer.addButton( ID_DELITEM, '丢  弃', 145, 4, 50, 20 )
	inventorylayer.lbGoods = inventorylayer.addListBox( ID_INVENTORY, 4, 25, inventoryW-8, inventoryH - 30 )
	inventorylayer.lbGoods.setStyle( orDWORD( inventorylayer.lbGoods.getStyle(), LBS_ICON ) )

	-- for updateGoodsListBox()
	goodsPick(goodsID.yifu,true,true)
	goodsConsume(goodsID.yifu)

	resizeUI()
end


function cb_OnItemListChanged(itemlist)
	updateGoodsListBox( itemlist )
end


-------------------------------------------------
function UIevent_OnButtonDown( layer, ctrlid )
	if (ID_YES_exit==ctrlid) then
		Exit()
	elseif (ID_YES_bambooraft==ctrlid) then
		BambooraftOnOff()
	elseif (ID_YES_igo==ctrlid) then
		turnon_gogame()
	elseif (ID_YES_enter_secretroom==ctrlid) then
		enter_secretroom_scene()
	elseif (ID_YES_exit_secretroom==ctrlid) then
		exit_secretroom_scene()
	elseif (ID_YES_enter_dungeon==ctrlid) then
		enter_dungeon_scene()
	elseif (ID_YES_exit_dungeon==ctrlid) then
		exit_dungeon_scene()
	elseif (ID_YES_exit_stream==ctrlid) then
		exit_stream_scene()
	elseif (ID_YES_sleep==ctrlid) then
		house_sleep()
	elseif (ID_OPTION==ctrlid) then
		setupOptionUI()
		optionlayer.show( not optionlayer.isVisible() )
	elseif (ID_INVENTORY==ctrlid) then
		setupInventoryUI()
		inventorylayer.show ( not inventorylayer.isVisible() )
	elseif (ID_WEAPON==ctrlid) then
		if pplayer.getWeapon() then
			pplayer.takeoffWeapon()
		else
			goodsUse( goodsID.sword )
		end

	elseif (ID_BRIGHTNESS_DEFAULT==ctrlid) then
		optionlayer.sliderBrightness.setValue(50)
		UIevent_OnSliderValueChanged( optionlayer.getLayerOrder(), ID_BRIGHTNESS )
	elseif (ID_CONTRAST_DEFAULT==ctrlid) then
		optionlayer.sliderContrast.setValue(50)
		UIevent_OnSliderValueChanged( optionlayer.getLayerOrder(), ID_CONTRAST )
	elseif (ID_HUE_DEFAULT==ctrlid) then
		optionlayer.sliderHue.setValue(50)
		UIevent_OnSliderValueChanged( optionlayer.getLayerOrder(), ID_HUE )
	elseif (ID_SATURATION_DEFAULT==ctrlid) then
		optionlayer.sliderSaturation.setValue(50)
		UIevent_OnSliderValueChanged( optionlayer.getLayerOrder(), ID_SATURATION )

	elseif (ID_QUIT==ctrlid) then
		msgBox("要退出游戏吗？", "风雨江湖", orDWORD(MB_YESNO,MB_ICONWARNING), ID_YES_exit, ID_NO )
	elseif (ID_FULLSCREEN==ctrlid) then
		FullScreen( not IsFullScreen() )
	elseif (ID_USEITEM==ctrlid) then
		local sele = inventorylayer.lbGoods.getSelectedIndex()
		if sele<1 then return end
		local txt, amount, data, img = inventorylayer.lbGoods.getItem(sele)
		goodsUse(data)
	elseif (ID_DELITEM==ctrlid) then
		local sele = inventorylayer.lbGoods.getSelectedIndex()
		if sele<1 then return end
		local txt, amount, data, img = inventorylayer.lbGoods.getItem(sele)
		msgBox('要丢弃 '.. txt .. ' 吗？', '风雨江湖', orDWORD(MB_YESNO,MB_ICONWARNING), ID_YES_delitem, ID_NO )
	elseif (ID_YES_delitem==ctrlid) then
		local sele = inventorylayer.lbGoods.getSelectedIndex()
		if sele<1 then print('error: del item in setupui.lua'); return end
		local txt, amount, data, img = inventorylayer.lbGoods.getItem(sele)
		goodsDrop(data)
	end
end

function UIevent_OnCheckBoxChanged( layer, ctrlid )
	if ID_SOUND==ctrlid then
		local bsound = optionlayer.checksound.isChecked()
		g_config.bSoundOff = not bsound;
	elseif ID_MUSIC==ctrlid then
		local bmusic = optionlayer.checkmusic.isChecked()
		g_config.bMusicOff = not bmusic;
		if not bmusic then
			StopMusic()
		end
	end
end

function UIevent_OnSliderValueChanged( layer, ctrlid )
	if (ID_BRIGHTNESS==ctrlid or ID_CONTRAST==ctrlid) then
		local brightness = optionlayer.sliderBrightness.getValue() * 0.01 - 0.5;
		local contrast = optionlayer.sliderContrast.getValue() / 50
		set_brightness_contrast( brightness, contrast )
	elseif (ID_HUE==ctrlid or ID_SATURATION==ctrlid) then
		local hue = optionlayer.sliderHue.getValue()*0.02 -1 -- map 0 ~100 to -1 ~ 1
		local saturation = optionlayer.sliderSaturation.getValue()*0.02 -1  -- map 0 ~100 to -1 ~ 1
		set_hue_saturation( hue, saturation )
	end

end

function UIevent_OnEditBoxString( layer, ctrlid )
	if ID_CHAT == ctrlid then
		local txt = baselayer.editChat.getText()
		if '\\quit'==txt then
			Exit()
		end
		message_Push( txt, COLOR_LIGHTGREEN )
		baselayer.editChat.setText('')
	end
end

function UIevent_OnComboBoxSelection( layer, ctrlid )
	if ID_MODELIST == ctrlid then
		local sele = optionlayer.modelist.getSelectedIndex()
		if sele>0 and sele <= optionlayer.modelist.getSize() then
			local w,h = optionlayer.modelist.wlist[sele], optionlayer.modelist.hlist[sele]
			--print(w,h)
			FullScreen(true, w, h)
		end
	elseif ID_PICTURE_STYLE == ctrlid then
		local sele = optionlayer.picstyles.getSelectedIndex()
		if sele>0 and sele <= optionlayer.picstyles.getSize() then
			apply_picture_style( optionlayer.picstyles.styleparamlist[sele] )
		end
	end
end

-----------------------------------------

function UI_OnSize( type, cx, cy )
	wx,wy=cx,cy
	ui_OnWindowSizeChange(cx,cy)
	setupBaseUI()
	baselayer.show(true)
	resizeUI()
end

function UI_OnRButtonUp(x,y)
--	menuClearItems()
--	menuAddItem( ID_FULLSCREEN, "全屏 / 窗口" )
--	menuAddItem( ID_QUIT, "退 出 游 戏" )
--	menuPopup(x,y)

	ui_Hide( not ui_IsHidden() )
end

local nextcheckweapon = 1
function UI_OnFrameMove( AppTimeD )
	local nowtime = GetAppTime()
	if ( nowtime > nextcheckweapon ) then
		nextcheckweapon = nowtime + 1

		if ( pplayer.getWeapon() or goodsGetItem(goodsID.sword) ) then -- 如果手上或包里有武器，显示相关ui
			baselayer.butWeapon.setVisible(true)
		else
			baselayer.butWeapon.setVisible(false)
		end
	end
end

function OnBrightnessContrastChanged( bright, contrast )
	if not optionlayer then return end
	optionlayer.sliderBrightness.setValue( bright*100 + 50 )
	optionlayer.sliderContrast.setValue( contrast * 50 )
end


if not g_config.vr then return end


gDuckInput=false
gJumpInput=false

local _onControllerButtonPress = onControllerButtonPress
function onControllerButtonPress( deviceID, buttonid )
	if _onControllerButtonPress then
		if _onControllerButtonPress( deviceID, buttonid ) then return end
	end
	if deviceID == ControllerA.getDeviceID() then
		if buttonid == ControllerButtonID.ApplicationMenu then
			UIevent_OnButtonDown(0, ID_WEAPON ) -- 模拟武器按钮
			return true
		elseif buttonid == ControllerButtonID.Touchpad then
			local x,y = ControllerA.getAxis()
			if y < 0 then
				gDuckInput=true
			else
				gJumpInput=true
			end
			return true
		end
	end
end

local _onControllerButtonUnpress = onControllerButtonUnpress
function onControllerButtonUnpress( deviceID, buttonid )
	if _onControllerButtonUnpress then
		if _onControllerButtonUnpress( deviceID, buttonid ) then return end
	end
	if deviceID == ControllerA.getDeviceID() then
		if buttonid == ControllerButtonID.Touchpad then
			gDuckInput, gJumpInput = false, false
			return true
		end
	end
end