_G.Enhanced_Tripmines_Plus = _G.Enhanced_Tripmines_Plus or {}
Enhanced_Tripmines_Plus._path = ModPath
Enhanced_Tripmines_Plus.data_path = SavePath .. "enhanced_tripmines.txt"
Enhanced_Tripmines_Plus.preview_cop_unit = nil
Enhanced_Tripmines_Plus.default_settings = {
	palettes = { --for ColorPicker
	"ADFF2F",
	"7FFF00",
	"7CFC00",
	"00FF00",
	"32CD32",
	"00FA9A",
	"3CB371",
	"228B22",
	"008000",
	"9ACD32",
	"556B2F",
	"00FFFF",
	"AFEEEE",
	"40E0D0",
	"7FFFD4",
	"C71585",
	"CD5C5C",
	"F08080",
	"FA8072",
	"E9967A",
	"FFA07A",
	"DC143C",
	"FF0000",
	"B22222",
	"8B0000"
	},
	main_settings = {
		invincibility = false,
		changables = true,
		changables_self = false,
		sensor = true,
		marking = 2,
		beeps = 3,
		beeps_others = 3,
		language = 1
	},
	ColorList = {
		default = {
			r = 51,
			g = 102,
			b = 153
		},
		civilian = {
			r = 255,
			g = 255,
			b = 255
		},
		civilian_female = {
			r = 224,
			g = 163,
			b = 194
		}, 
		spooc = { 
			r = 0,
			g = 0,
			b = 255
		}, 
		taser = { 
			r = 255,
			g = 255,
			b = 0
		}, 
		shield = {
			r = 192,
			g = 192,
			b = 192
		},
		tank = {
			r = 255,
			g = 0,
			b = 0
		},
		sniper = {
			r = 255,
			g = 200,
			b = 65
		},
		medic = {
			r = 255,
			g = 0,
			b = 255
		}, 
		gangster = {
			r = 115,
			g = 0,
			b = 100
		},
		security = {
			r = 115,
			g = 40,
			b = 70
		},
		fbi = {
			r = 115,
			g = 40,
			b = 70
		},
		heavy_swat = {
			r = 115,
			g = 40,
			b = 70
		},
		fbi_heavy_swat = {
			r = 115,
			g = 40,
			b = 70
		},
		heavy_swat_sniper = {
			r = 115,
			g = 40,
			b = 70
		},
		tank_hw = {
			r = 115,
			g = 40,
			b = 70
		},
		tank_medic = {
			r = 115,
			g = 40,
			b = 70
		},
		tank_mini = {
			r = 115,
			g = 40,
			b = 70
		},
		phalanx_minion = {
			r = 115,
			g = 40,
			b = 70
		},
		phalanx_vip = {
			r = 115,
			g = 40,
			b = 70
		},
		city_swat = {
			r = 115,
			g = 40,
			b = 70
		}
	},
	ColorPickerColorList = {
		default = "336699",
		civilian = "ffffff",
		civilian_female = "e0a3c2",
		spooc = "0000ff",
		taser = "ffff00",
		shield = "c0c0c0",
		tank = "ff0000",
		sniper = "ffc841",
		medic = "ff00ff",
		gangster = "730064",
		security = "732846",
		fbi = "732846",
		heavy_swat = "732846",
		fbi_heavy_swat = "732846",
		heavy_swat_sniper = "732846",
		tank_hw = "732846",
		tank_medic = "732846",
		tank_mini = "732846",
		phalanx_minion = "732846",
		phalanx_vip = "732846",
		city_swat = "732846"
	},
	contour_color_mode = {
		civilian = 2,
		civilian_female = 2,
		spooc = 2,
		taser = 2,
		shield = 2,
		tank = 2,
		sniper = 2,
		medic = 2,
		gangster = 2,
		security = 2,
		fbi = 2,
		heavy_swat = 2,
		fbi_heavy_swat = 2,
		heavy_swat_sniper = 2,
		tank_hw = 2,
		tank_medic = 2,
		tank_mini = 2,
		phalanx_minion = 2,
		phalanx_vip = 2,
		city_swat = 2
	}
}
Enhanced_Tripmines_Plus.settings = table.deep_map_copy(Enhanced_Tripmines_Plus.default_settings)

function Enhanced_Tripmines_Plus:set_colorpicker_menu(menu)
	Enhanced_Tripmines_Plus._colorpicker = menu
end

function Enhanced_Tripmines_Plus.clbk_show_colorpicker_with_callbacks(color, changed_callback, done_callback)
	Enhanced_Tripmines_Plus._colorpicker:Show({color = color,changed_callback = changed_callback,done_callback = done_callback,palettes = Enhanced_Tripmines_Plus:GetPaletteColors(),blur_bg_x = 750})
end

function Enhanced_Tripmines_Plus:GetPaletteColors()
	local result = {}
	for i,hex in ipairs(self.settings.palettes) do 
		result[i] = Color(hex)
	end
	return result
end

function Enhanced_Tripmines_Plus:SetPaletteCodes(tbl)
	if type(tbl) == "table" then 
		for i,color in ipairs(tbl) do 
			self.settings.palettes[i] = color:to_hex()
		end
	else
		self:log("Error: SetPaletteCodes(" .. tostring(tbl) .. ") Bad palettes table from ColorPicker callback")
	end
end

function Enhanced_Tripmines_Plus:custom_colour(rayunit, color)
	if not rayunit then
		return
	end

	local materials = rayunit:get_objects_by_type(Idstring("material"))
	for _, material in ipairs(materials) do
		if alive(material) and material:variable_exists(Idstring('contour_color')) then
			material:set_variable(Idstring('contour_color'), color)
		end
	end
end
function Enhanced_Tripmines_Plus:Check_Scene(unit, color_picker_preview)
	if Enhanced_Tripmines_Plus.preview_cop_unit == nil or Enhanced_Tripmines_Plus.preview_cop_unit:base()._tweak_table ~= unit then -- if no unit or unit need to be re-created
		-- create unit
		SceneToolMaster_ET:ClearScene()
		SceneToolMaster_ET:SetScene(unit)

		-- create bitmap
		BitmapToolMaster_ET:DestroyPanel()
		if not color_picker_preview then
			BitmapToolMaster_ET:CreatePanel()
			BitmapToolMaster_ET:ShowPanel(unit)
		end
	end
end
function Enhanced_Tripmines_Plus:preview_color(unit, color_to_show)
	Enhanced_Tripmines_Plus:Check_Scene(unit)
	DelayedCalls:Add('Delayed_Contour_2_Enhanced_Tripmines_+', 0.06, function()
		if not color_to_show then
			BitmapToolMaster_ET:UpdateBitmapColor(unit)
		end
		Enhanced_Tripmines_Plus:custom_colour(Enhanced_Tripmines_Plus.preview_cop_unit, color_to_show == nil and Enhanced_Tripmines_Plus:GetColor(unit) or color_to_show)
	end)
end

function Enhanced_Tripmines_Plus:ColorUnpack(unit)
	return Enhanced_Tripmines_Plus.settings.ColorList[unit].r, Enhanced_Tripmines_Plus.settings.ColorList[unit].g, Enhanced_Tripmines_Plus.settings.ColorList[unit].b
end

function Enhanced_Tripmines_Plus:GetColor(unit)
	if not unit then
		return
	end
	return Color(255, Enhanced_Tripmines_Plus:ColorUnpack(unit)) / 255
end

function Enhanced_Tripmines_Plus:save()
	local file = io.open(self.data_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function Enhanced_Tripmines_Plus:load()
	local file = io.open(self.data_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read('*all'))) do
			self.settings[k] = v
		end
	else
		self:save()
	end
end

function Enhanced_Tripmines_Plus:toggle_color_mode(unit)
	local menu = MenuHelper:GetMenu("Enhanced_Tripmines_Plus_colors")
	if not _G.ColorPicker then
		if not menu:item(unit .. "_r_colorslider") or not menu:item(unit .. "_g_colorslider") or not menu:item(unit .. "_b_colorslider") then
			return
		end
		if Enhanced_Tripmines_Plus.settings.contour_color_mode[unit] == 1 then
			menu:item(unit .. "_r_colorslider"):set_enabled(false)
			menu:item(unit .. "_g_colorslider"):set_enabled(false)
			menu:item(unit .. "_b_colorslider"):set_enabled(false)
			return true -- disabled
		else
			menu:item(unit .. "_r_colorslider"):set_enabled(true)
			menu:item(unit .. "_g_colorslider"):set_enabled(true)
			menu:item(unit .. "_b_colorslider"):set_enabled(true)
			return false -- not disabled
		end
	elseif Enhanced_Tripmines_Plus._colorpicker then
		if not menu:item(unit .. "_colorchanger") then
			return
		end
		if Enhanced_Tripmines_Plus.settings.contour_color_mode[unit] == 1 then
			menu:item(unit .. "_colorchanger"):set_enabled(false)
			return true -- disabled
		else
			menu:item(unit .. "_colorchanger"):set_enabled(true)
			return false -- not disabled
		end
	end
end

Enhanced_Tripmines_Plus:load()
if not ETUnitNamesData then dofile(ModPath .. 'lua/ETUnitNamesData.lua') end
if not SceneToolMaster_ET then dofile(ModPath .. 'lua/SceneTools.lua') end
if not BitmapToolMaster_ET then dofile(ModPath .. 'lua/BitmapTools.lua') end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Enhanced_Tripmines_Plus", function(loc)
	Enhanced_Tripmines_Plus:load()
	local filename
	if Enhanced_Tripmines_Plus.settings.main_settings.language == 1 then
		filename="english"
	elseif Enhanced_Tripmines_Plus.settings.main_settings.language == 2 then
		filename="russian"
	elseif Enhanced_Tripmines_Plus.settings.main_settings.language == 3 then
		filename="spanish"
	end
	loc:load_localization_file(Enhanced_Tripmines_Plus._path .. "loc/" .. filename .. ".json")
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_Enhanced_Tripmines_Plus", function(menu_manager)
	MenuCallbackHandler.Enhanced_Tripmines_Plus_language_callback = function(self, item)
		Enhanced_Tripmines_Plus.settings.main_settings.language = item:value()
	end

	MenuCallbackHandler.Enhanced_Tripmines_Plus_marking_callback  = function(self,item)
		Enhanced_Tripmines_Plus.settings.main_settings.marking = item:value()
	end

	MenuCallbackHandler.Enhanced_Tripmines_Plus_beeps_callback  = function(self,item)
		Enhanced_Tripmines_Plus.settings.main_settings.beeps = item:value()
	end
	
	MenuCallbackHandler.Enhanced_Tripmines_Plus_beeps_other_callback  = function(self,item)
		Enhanced_Tripmines_Plus.settings.main_settings.beeps_others = item:value()
	end
	
	MenuCallbackHandler.Enhanced_Tripmines_Plus_invincibility_callback = function(self,item)
		Enhanced_Tripmines_Plus.settings.main_settings.invincibility = Utils:ToggleItemToBoolean(item)
	end
	
	MenuCallbackHandler.Enhanced_Tripmines_Plus_changables_callback = function(self,item)
		Enhanced_Tripmines_Plus.settings.main_settings.changables = Utils:ToggleItemToBoolean(item)
	end

	MenuCallbackHandler.Enhanced_Tripmines_Plus_changables_self_callback = function(self,item)
		Enhanced_Tripmines_Plus.settings.main_settings.changables_self = Utils:ToggleItemToBoolean(item)
	end
	
	MenuCallbackHandler.Enhanced_Tripmines_Plus_sensor_callback = function(self,item)
		Enhanced_Tripmines_Plus.settings.main_settings.sensor = Utils:ToggleItemToBoolean(item)
	end

	MenuCallbackHandler.r_colorslider_callback = function(self, item)
		local unit = string.gsub(item:name(), "_r_colorslider", "")
		Enhanced_Tripmines_Plus.settings.ColorList[unit].r = item:value()

		Enhanced_Tripmines_Plus:preview_color(unit)
	end
	MenuCallbackHandler.g_colorslider_callback = function(self, item)
		local unit = string.gsub(item:name(), "_g_colorslider", "")
		Enhanced_Tripmines_Plus.settings.ColorList[unit].g = item:value()

		Enhanced_Tripmines_Plus:preview_color(unit)
	end
	MenuCallbackHandler.b_colorslider_callback = function(self, item)
		local unit = string.gsub(item:name(), "_b_colorslider", "")
		Enhanced_Tripmines_Plus.settings.ColorList[unit].b = item:value()

		Enhanced_Tripmines_Plus:preview_color(unit)
	end

	MenuCallbackHandler.Enhanced_Tripmines_Plus_unitcolor_callback = function(self, item)
		local unit = string.gsub(item:name(), "_colorchanger", "")
		local function clbk_colorpicker (color, palettes, success)
			--save color to settings
			if success then 
				Enhanced_Tripmines_Plus.settings.ColorPickerColorList[unit] = color:to_hex()
				Enhanced_Tripmines_Plus:save()
			end
			--save palette swatches to settings
			if palettes then 
				Enhanced_Tripmines_Plus:SetPaletteCodes(palettes)
			end
		end
		Enhanced_Tripmines_Plus.clbk_show_colorpicker_with_callbacks(Color(Enhanced_Tripmines_Plus.settings.ColorPickerColorList[unit]), clbk_colorpicker, clbk_colorpicker)
	end
	
	MenuCallbackHandler.color_mode_callback = function(self, item)
		local unit = string.gsub(item:name(), "_color_mode", "")
		Enhanced_Tripmines_Plus.settings.contour_color_mode[unit] = item:value()

		Enhanced_Tripmines_Plus:Check_Scene(unit)

		DelayedCalls:Add('Delayed_Contour_1_Enhanced_Tripmines_+', 0.06, function()
			if item:value() == 1 then -- if default
				Enhanced_Tripmines_Plus:custom_colour(Enhanced_Tripmines_Plus.preview_cop_unit, Enhanced_Tripmines_Plus:GetColor("default"))
				BitmapToolMaster_ET:UpdateBitmapColor("default")
			else
				Enhanced_Tripmines_Plus:custom_colour(Enhanced_Tripmines_Plus.preview_cop_unit, Enhanced_Tripmines_Plus:GetColor(unit))
				BitmapToolMaster_ET:UpdateBitmapColor(unit)
			end
		end)

		Enhanced_Tripmines_Plus:toggle_color_mode(unit)
	end

	MenuCallbackHandler.Enhanced_Tripmines_PlusChangedFocus = function(node, focus)
		if focus then
			local package = "packages/ukrainian_job"-- for casual female 1
			PackageManager:load(package)
			local package = "packages/job_family"-- for casual male 1
			PackageManager:load(package)
			Enhanced_Tripmines_Plus:save()
		else
			SceneToolMaster_ET:ClearScene()
			BitmapToolMaster_ET:DestroyPanel()
			Enhanced_Tripmines_Plus:save()
		end
	end

	MenuCallbackHandler.Enhanced_Tripmines_Plus_back = function(self, item)
		Enhanced_Tripmines_Plus:save()
	end
	
	Enhanced_Tripmines_Plus:load()
	Enhanced_Tripmines_Plus._colorpicker = Enhanced_Tripmines_Plus._colorpicker or (ColorPicker and ColorPicker:new("Enhanced_Tripmines_Plus_colorpicker_menu_id",colorpicker_data,callback(Enhanced_Tripmines_Plus,Enhanced_Tripmines_Plus,"set_colorpicker_menu")))

	Hooks:Add("MenuManagerSetupCustomMenus", "Base_SetupCustomMenus_Json_Enhanced_Tripmines_Plus_main_menu", function( menu_manager, nodes)
		MenuHelper:NewMenu( "Enhanced_Tripmines_Plus_main_menu" )
		MenuHelper:NewMenu( "Enhanced_Tripmines_Plus_colors" )
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "Base_BuildCustomMenus_Json_Enhanced_Tripmines_Plus_main_menu", function(menu_manager, nodes)
		local parent_menu = "blt_options"
		local menu_id = "Enhanced_Tripmines_Plus_main_menu"
		local menu_name = "Enhanced_Tripmines_Plus_main_menu_title"
		local menu_desc = "Enhanced_Tripmines_Plus_main_menu_desc"

		local data = {
			focus_changed_callback = "Enhanced_Tripmines_PlusChangedFocus",
			back_callback = "Enhanced_Tripmines_Plus_back",
			area_bg = nil,
		}
		nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )

		MenuHelper:AddMenuItem( nodes[parent_menu], menu_id, menu_name, menu_desc, nil )

		local parent_menu = "Enhanced_Tripmines_Plus_main_menu"
		local menu_id = "Enhanced_Tripmines_Plus_colors"
		local menu_name = "Enhanced_Tripmines_Plus_colors_title"
		local menu_desc = "Enhanced_Tripmines_Plus_colors_desc"

		local data = {
			focus_changed_callback = "Enhanced_Tripmines_PlusChangedFocus",
			back_callback = "Enhanced_Tripmines_Plus_back",
			area_bg = nil,
		}
		nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )

		MenuHelper:AddMenuItem( nodes[parent_menu], menu_id, menu_name, menu_desc, nil )
	end)
end)


Hooks:Add("MenuManagerPopulateCustomMenus", "Base_PopulateCustomMenus_Json_Enhanced_Tripmines_Plus_main_menu", function(menu_manager, nodes)
	MenuHelper:AddMultipleChoice({
		id = "Enhanced_Tripmines_Plus_loc",
		title = "Enhanced_Tripmines_Plus_loc_title",
		desc = "Enhanced_Tripmines_Plus_loc_desc",
		callback = "Enhanced_Tripmines_Plus_language_callback",
		items = {
			"Enhanced_Tripmines_Plus_loc_eng",
			"Enhanced_Tripmines_Plus_loc_rus",
			"Enhanced_Tripmines_Plus_loc_spa"
		},
		value = Enhanced_Tripmines_Plus.settings.main_settings.language,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 10,
		localized = true
	})

	MenuHelper:AddDivider({
		id = "Enhanced_Tripmines_Plus_divider_0",
		size = 15,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 9
	})

	MenuHelper:AddMultipleChoice({
		id = "Enhanced_Tripmines_Plus_marking",
		title = "Enhanced_Tripmines_Plus_marking_title",
		desc = "Enhanced_Tripmines_Plus_marking_desc",
		callback = "Enhanced_Tripmines_Plus_marking_callback",
		items = {"Enhanced_Tripmines_Plus_marking_1",
		"Enhanced_Tripmines_Plus_marking_2"},
		value = Enhanced_Tripmines_Plus.settings.main_settings.marking,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 8,
		localized = true
	})
	MenuHelper:AddMultipleChoice({
		id = "Enhanced_Tripmines_Plus_beeps",
		title = "Enhanced_Tripmines_Plus_beeps_title",
		desc = "Enhanced_Tripmines_Plus_beeps_desc",
		callback = "Enhanced_Tripmines_Plus_beeps_callback",
		items = {
			"Enhanced_Tripmines_Plus_beeps_1",
			"Enhanced_Tripmines_Plus_beeps_2",
			"Enhanced_Tripmines_Plus_beeps_3",
			"Enhanced_Tripmines_Plus_beeps_4"
		},
		value = Enhanced_Tripmines_Plus.settings.main_settings.beeps,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 7,
		localized = true
	})
	MenuHelper:AddMultipleChoice({
		id = "Enhanced_Tripmines_Plus_other_beeps",
		title = "Enhanced_Tripmines_Plus_other_beeps_title",
		desc = "Enhanced_Tripmines_Plus_other_beeps_desc",
		callback = "Enhanced_Tripmines_Plus_beeps_other_callback",
		items = {"Enhanced_Tripmines_Plus_beeps_1",
		"Enhanced_Tripmines_Plus_beeps_2",
		"Enhanced_Tripmines_Plus_beeps_3",
		"Enhanced_Tripmines_Plus_beeps_4"},
		value = Enhanced_Tripmines_Plus.settings.main_settings.beeps_others,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 6,
		localized = true
	})

	MenuHelper:AddDivider({
		id = "Enhanced_Tripmines_Plus_divider_1",
		size = 12,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 5
	})

	MenuHelper:AddToggle({
		id = "Enhanced_Tripmines_Plus_invincibility",
		title = "Enhanced_Tripmines_Plus_invincibility_title",
		desc = "Enhanced_Tripmines_Plus_invincibility_desc",
		callback = "Enhanced_Tripmines_Plus_invincibility_callback",
		value = Enhanced_Tripmines_Plus.settings.main_settings.invincibility,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 4,
		localized = true
	})

	MenuHelper:AddToggle({
		id = "Enhanced_Tripmines_Plus_changables",
		title = "Enhanced_Tripmines_Plus_changables_title",
		desc = "Enhanced_Tripmines_Plus_changables_desc",
		callback = "Enhanced_Tripmines_Plus_changables_callback",
		value = Enhanced_Tripmines_Plus.settings.main_settings.changables,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 3,
		localized = true
	})

	MenuHelper:AddToggle({
		id = "Enhanced_Tripmines_Plus_changables_self",
		title = "Enhanced_Tripmines_Plus_changables_self_title",
		desc = "Enhanced_Tripmines_Plus_changables_self_desc",
		callback = "Enhanced_Tripmines_Plus_changables_self_callback",
		value = Enhanced_Tripmines_Plus.settings.main_settings.changables_self,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 2,
		localized = true
	})
	
	MenuHelper:AddToggle({
		id = "Enhanced_Tripmines_Plus_sensor",
		title = "Enhanced_Tripmines_Plus_sensor_title",
		desc = "Enhanced_Tripmines_Plus_sensor_desc",
		callback = "Enhanced_Tripmines_Plus_sensor_callback",
		value = Enhanced_Tripmines_Plus.settings.main_settings.sensor,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = 1,
		localized = true
	})

	MenuHelper:AddDivider({
		id = "Enhanced_Tripmines_Plus_divider_3",
		size = 15,
		menu_id = "Enhanced_Tripmines_Plus_main_menu",
		priority = -1
	})

	-- Color Menu
	if not _G.ColorPicker then
		MenuHelper:AddSlider({
			id = "default_r_colorslider",
			title = "r_colorslider_title",
			desc = "colorslider_desc",
			callback = "r_colorslider_callback",
			priority = 504,
			value = Enhanced_Tripmines_Plus.settings.ColorList.default.r,
			menu_id = "Enhanced_Tripmines_Plus_colors",
			show_value = true,
			min = 0,
			max = 255,
			step = 1,
			localized = true,
		})
		MenuHelper:AddSlider({
			id = "default_g_colorslider",
			title = "g_colorslider_title",
			desc = "colorslider_desc",
			callback = "g_colorslider_callback",
			priority = 503,
			value = Enhanced_Tripmines_Plus.settings.ColorList.default.g,
			menu_id = "Enhanced_Tripmines_Plus_colors",
			show_value = true,
			min = 0,
			max = 255,
			step = 1,
			localized = true,
		})
		MenuHelper:AddSlider({
			id = "default_b_colorslider",
			title = "b_colorslider_title",
			desc = "colorslider_desc",
			callback = "b_colorslider_callback",
			priority = 502,
			value = Enhanced_Tripmines_Plus.settings.ColorList.default.b,
			menu_id = "Enhanced_Tripmines_Plus_colors",
			show_value = true,
			min = 0,
			max = 255,
			step = 1,
			localized = true,
		})
		MenuHelper:AddDivider({
			id = "Enhanced_Tripmines_Plus_divider",
			size = 28,
			menu_id = "Enhanced_Tripmines_Plus_colors",
			priority = 501
		})
		local last_priority = last_priority or 500
		for unit, i in pairs(Enhanced_Tripmines_Plus.settings.contour_color_mode) do
			MenuHelper:AddMultipleChoice({
				id = tostring(unit) .. "_color_mode",
				title = tostring(unit) .. "_color_mode_title",
				desc = tostring(unit) .. "_color_mode_desc",
				callback = "color_mode_callback",
				items = {
					"default",
					"custom"
				},
				priority = last_priority,
				value = Enhanced_Tripmines_Plus.settings.contour_color_mode[unit],
				menu_id = "Enhanced_Tripmines_Plus_colors"
			})
			last_priority = last_priority - 1

			for color_part, i in pairs(Enhanced_Tripmines_Plus.settings.ColorList[unit]) do
				if color_part == "g" then 
					last_priority = last_priority + 2
				elseif color_part == "b" then
					last_priority = last_priority - 1
				end
				MenuHelper:AddSlider({
					id = tostring(unit) .. "_" .. tostring(color_part) .."_colorslider",
					title = tostring(color_part) .."_colorslider_title",
					desc = tostring(color_part) .."_colorslider_desc", 
					callback = color_part .. "_colorslider_callback",
					priority = last_priority,
					value = Enhanced_Tripmines_Plus.settings.ColorList[unit][color_part],
					menu_id = "Enhanced_Tripmines_Plus_colors",
					show_value = true,
					min = 0,
					max = 255,
					step = 1,
					disabled = Enhanced_Tripmines_Plus:toggle_color_mode(unit),
					localized = true,
				})
				last_priority = last_priority - 1
			end
			last_priority = last_priority - 1

			MenuHelper:AddDivider({
				id = "Enhanced_Tripmines_Plus_divider",
				size = 28,
				menu_id = "Enhanced_Tripmines_Plus_colors",
				priority = last_priority
			})
			last_priority = last_priority - 1
		end
	elseif Enhanced_Tripmines_Plus._colorpicker then
		MenuHelper:AddButton({
			id = "default_colorchanger",
			title = "ColorPicker_default_button_title",
			desc = "colorslider_desc",
			callback = "Enhanced_Tripmines_Plus_unitcolor_callback",
			menu_id = "Enhanced_Tripmines_Plus_colors",
			priority = 504
		})
		MenuHelper:AddDivider({
			id = "Enhanced_Tripmines_Plus_divider",
			size = 28,
			menu_id = "Enhanced_Tripmines_Plus_colors",
			priority = 503
		})
		local last_priority = last_priority or 500
		for unit, i in pairs(Enhanced_Tripmines_Plus.settings.contour_color_mode) do
			MenuHelper:AddMultipleChoice({
				id = tostring(unit) .. "_color_mode",
				title = tostring(unit) .. "_color_mode_title",
				desc = tostring(unit) .. "_color_mode_desc",
				callback = "color_mode_callback",
				items = {
					"default",
					"custom"
				},
				priority = last_priority,
				value = Enhanced_Tripmines_Plus.settings.contour_color_mode[unit],
				menu_id = "Enhanced_Tripmines_Plus_colors"
			})
			last_priority = last_priority - 1
			MenuHelper:AddButton({
				id = tostring(unit) .. "_colorchanger",
				title = "ColorPicker_button_title",
				desc = "r_colorslider_desc",
				callback = "Enhanced_Tripmines_Plus_unitcolor_callback",
				menu_id = "Enhanced_Tripmines_Plus_colors",
				disabled = Enhanced_Tripmines_Plus:toggle_color_mode(unit),
				priority = last_priority
			})
			last_priority = last_priority - 1

			MenuHelper:AddDivider({
				id = "Enhanced_Tripmines_Plus_divider",
				size = 28,
				menu_id = "Enhanced_Tripmines_Plus_colors",
				priority = last_priority
			})
			last_priority = last_priority - 1
		end
	end
end)