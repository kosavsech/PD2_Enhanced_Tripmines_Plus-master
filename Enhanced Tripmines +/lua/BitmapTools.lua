_G.BitmapToolMaster_ET = _G.BitmapToolMaster_ET or {}
function BitmapToolMaster_ET:CreateBitmap(color, x, y)
	local bmp = self._panel:bitmap({
		h = 48,
		w = 48,
		valign = 'center',
		halign = 'center',
		visible = true,
		color = color,
		layer = tweak_data.gui.MENU_LAYER + 150,
		blend_mode = 'normal'
	})
	bmp:set_right(self._panel:right() - self._panel:w() * (0.35 + x))
	bmp:set_top(self._panel:h() * y)
	
	return bmp
end

function BitmapToolMaster_ET:CreateText(unit, x, y)
	local text = self._panel:text({
		name = "unit_text",
		text = unit .. " setting",
		valign = "center",
		align = "center",
		vertical = "center",
		layer = tweak_data.gui.MENU_LAYER + 150,
		color = tweak_data.screen_colors.text,
		blend_mode = "normal",
		font = tweak_data.hud.small_font,
		font_size = 34,
		visible = true
	})
	text:set_right(self._panel:right() - self._panel:w() * (0.35 + x))
	text:set_top(self._panel:h() * y)

	return text
end

function BitmapToolMaster_ET:CreatePanel()
	if self._panel or not managers.menu_component then
		return
	end
	self._panel = managers.menu_component._ws:panel():panel()
end

function BitmapToolMaster_ET:DestroyPanel()
	if not alive(self._panel) then
		return
	end
	self._panel:clear()
	self._unit_color_bmp = nil

	self._panel:parent():remove(self._panel)
	self._panel = nil
end

function BitmapToolMaster_ET:UpdateBitmapColor(type)
	if alive(self._panel) and alive(self._unit_color_bmp) then
		self._unit_color_bmp:set_color(Enhanced_Tripmines_Plus:GetColor(type))
	end
end

function BitmapToolMaster_ET:ShowPanel(unit)
	if alive(self._panel) then
		self._unit_color_bmp = self:CreateBitmap(Enhanced_Tripmines_Plus:GetColor(unit), 0.02, 0.12)
		self._unit_color_text = self:CreateText(unit, -0.4352, -0.465104)
	end
end