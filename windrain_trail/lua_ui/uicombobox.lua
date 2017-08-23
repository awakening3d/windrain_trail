
local function new( ctrl )
	if (type(ctrl) ~= "userdata") then error("combobox expected") end
--[[
	local getStyle = function()
		return ctrl:get_style()
	end

	local setStyle = function( style )
		return ctrl:set_style( style )
	end
--]]
	local getSize = function()
		return ctrl:get_size()
	end

	local getScrollbarWidth = function()
		return ctrl:get_scrollbar_width()
	end
	
	local setScrollbarWidth = function( width )
		return ctrl:set_scrollbar_width( width )
	end
	
	local setDropHeight = function( dropheight )
		return ctrl:set_drop_height( dropheight )
	end

	local addItem = function( text, img, data )
		return ctrl:add_item( text, img, data )
	end

--[[
	local insertItem = function( index, text, img, data )
		return ctrl:insert_item( index, text, img, data )
	end

	local removeItem = function( index )
		return ctrl:remove_item(index)
	end

	local removeItemByText = function( text )
		return ctrl:remove_item_by_text( text )
	end

	local removeItemByData = function( data )
		return ctrl:remove_item_by_data( data )
	end
--]]
	local removeAllItems = function()
		return ctrl:remove_all_items()
	end

	local getItem = function( index )
		return ctrl:get_item( index )
	end
	
	local getSelectedIndex = function( )
		return ctrl:get_selected_index( )
	end

	local selectItem = function( index )
		return ctrl:select_item( index )
	end
--[[
	local setItemAmount = function( index, amount )
		return ctrl:set_item_amount( index, amount )
	end
--]]

	local r=_new_uibutton_tb(ctrl)

--	r.getStyle = getStyle
--	r.setStyle = setStyle
	r.getSize = getSize
	r.getScrollbarWidth = getScrollbarWidth
	r.setScrollbarWidth = setScrollbarWidth

	r.setDropHeight = setDropHeight

	r.addItem = addItem
--	r.insertItem = insertItem
--	r.removeItem = removeItem
--	r.removeItemByText = removeItemByText
--	r.removeItemByData = removeItemByData
	r.removeAllItems = removeAllItems
	r.getItem = getItem
	r.getSelectedIndex = getSelectedIndex
	r.selectItem = selectItem
--	r.setItemAmount = setItemAmount

	return r
end

-- export ----
_new_uicombobox_tb = new
