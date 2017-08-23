require 'uictrl'
require 'uistatic'
require 'uibutton'
require 'uislider'
require 'uilistbox'
require 'uieditbox'
require 'uicombobox'
require 'uicheckbox'

local function new( layernum )

	layernum = layernum or 0

	local handle = ui_GetLayer(layernum)
	if (not handle) then return end

	local layerud = _new_uilayer_ud(handle)

	local function getLayerOrder()	-- »°layer–Ú∫≈ 0 based
		return layernum
	end

	local function show( bShow )
		return layerud:set_visible( bShow )
	end

	local function isVisible()
		return layerud:get_visible()
	end

	local function getRect()
		return rect.new( layerud:get_rect() )
	end

	local function setRect( r )
		return layerud:set_rect( r.left, r.top, r.right, r.bottom )
	end

	local function addStatic( id, text, x, y, width, height )
		local sta = layerud:add_static( id, text, x, y, width, height )
		if not sta then return end
		return _new_uistatic_tb( _new_uistatic_ud(sta) )
	end

	local function addButton( id, text, x, y, width, height )
		local but = layerud:add_button( id, text, x, y, width, height )
		if not but then return end
		return _new_uibutton_tb( _new_uibutton_ud(but) )
	end

	local function addCheckBox( id, text, x, y, width, height, checked )
		local cb = layerud:add_checkbox( id, text, x, y, width, height, checked )
		if not cb then return end
		return _new_uicheckbox_tb( _new_uicheckbox_ud(cb) )
	end

	local function addRadioButton( id, text, x, y, width, height, group, checked )
		return layerud:add_radiobutton( id, text, x, y, width, height, group, checked )
	end
	
	local function addComboBox( id, x, y, width, height )
		local combox = layerud:add_combobox( id, x, y, width, height )
		if not combox then return end
		return _new_uicombobox_tb( _new_uicombobox_ud(combox) )
	end

	local function addSlider( id, x, y, width, height, min, max, value )
		local sli = layerud:add_slider( id, x, y, width, height, min, max, value )
		if not sli then return end
		return _new_uislider_tb( _new_uislider_ud(sli) )
	end

	local function addEditBox( id, text, x, y, width, height )
		local edi = layerud:add_editbox( id, text, x, y, width, height )
		if not edi then return end
		return _new_uieditbox_tb( _new_uieditbox_ud(edi) )
	end

	local function addIMEEditBox( id, text, x, y, width, height )
		local edi = layerud:add_ime_editbox( id, text, x, y, width, height )
		if not edi then return end
		return _new_uieditbox_tb( _new_uieditbox_ud(edi) )
	end

	local function addListBox( id, x, y, width, height, dwstyle )
		local listbox = layerud:add_listbox( id, x, y, width, height, dwstyle )
		if not listbox then return end
		return _new_uilistbox_tb( _new_uilistbox_ud(listbox) )
	end


	local r=_new_udhead_tb(layerud)


	r.getLayerOrder = getLayerOrder
	r.show = show
	r.isVisible = isVisible
	r.getRect = getRect
	r.setRect = setRect
	r.addStatic = addStatic
	r.addButton = addButton
	r.addCheckBox = addCheckBox
	r.addRadioButton = addRadioButton
	r.addComboBox = addComboBox
	r.addSlider = addSlider
	r.addEditBox = addEditBox
	r.addIMEEditBox = addIMEEditBox
	r.addListBox = addListBox
	return r;
end

local P = {
	new	= new,
}

if _REQUIREDNAME == nil then
	uilayer = P
else
	_G[_REQUIREDNAME] = P
end

return P