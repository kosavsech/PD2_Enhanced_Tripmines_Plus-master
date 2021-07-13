_G.SceneToolMaster_ET = _G.SceneToolMaster_ET or {}
function SceneToolMaster_ET:SetScene(unit_name)
	if managers.network:session() or unit_name == "default" then
		return
	end
	
	if not CopBase then
		require('lib/units/enemies/cop/CopBase')
	end
	if not CivilianBase then
		require('lib/units/civilians/CivilianBase')
	end
	if not ContourExt or not ContourExt.add then
		require('lib/units/ContourExt')
	end

	if not managers.occlusion then
		self.dummy_occlusion_manager = true
		managers.occlusion = {
			add_occlusion = function() end,
			remove_occlusion = function() end
		}
	end

	if not PackageManager:has(Idstring("unit"), Idstring(ETUnitNamesData[unit_name])) then
		return
	end

	local unit = World:spawn_unit(
		Idstring(ETUnitNamesData[unit_name]),
		Vector3(0, 200, -125),
		Rotation(140, 0, 0)
	)

	if alive(unit) then
		unit:interaction().refresh_material = function() end
		unit:play_redirect(Idstring('e_so_ntl_bored'), 0)
		unit:contour():add('highlight_character')
		Enhanced_Tripmines_Plus.preview_cop_unit = unit
	end
end

function SceneToolMaster_ET:ClearScene()
	if self.dummy_occlusion_manager then
		managers.occlusion = nil
		self.dummy_occlusion_manager = nil
	end

	if alive(Enhanced_Tripmines_Plus.preview_cop_unit) then
		World:delete_unit(Enhanced_Tripmines_Plus.preview_cop_unit)
		Enhanced_Tripmines_Plus.preview_cop_unit = nil
	end
end