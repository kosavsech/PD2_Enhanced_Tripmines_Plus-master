if not Enhanced_Tripmines_Plus then dofile(ModPath .. 'lua/menumanager.lua') end
	----------------------------------------------------------------------------------
	-- 
	-- Immediately revert any mode changes made to our tripmines by other players
	-- 
	----------------------------------------------------------------------------------
if string.lower(RequiredScript) == "lib/network/handlers/unitnetworkhandler" then 
	local old_UnitNetworkHandler_sync_trip_mine_set_armed = UnitNetworkHandler.sync_trip_mine_set_armed
	function UnitNetworkHandler:sync_trip_mine_set_armed(unit, bool, length, sender)
		if unit == nil then
			return old_UnitNetworkHandler_sync_trip_mine_set_armed(self, unit, bool, length, sender)
		end
		local we_own_this_tripmine = unit:base()._owner
		local was_armed = unit:base():armed()
		old_UnitNetworkHandler_sync_trip_mine_set_armed(self, unit, bool, length, sender)
		local now_armed = unit:base():armed()
		if we_own_this_tripmine and was_armed ~= now_armed and Enhanced_Tripmines_Plus.settings.main_settings.changables == true then
			unit:base():set_armed(was_armed)
		end
	end
end

	----------------------------------------------------------------------------------
	-- 
	-- Block explosion mode changes to our tripmines by self
	-- 
	----------------------------------------------------------------------------------

if string.lower(RequiredScript) == "lib/units/interactions/interactionext" then
	local old_BaseInteractionExt_can_select = BaseInteractionExt.can_select
	function BaseInteractionExt:can_select(player)
		if Enhanced_Tripmines_Plus.settings.main_settings.changables_self == false then
			return old_BaseInteractionExt_can_select(self, player)
		end
		local text_id = self._tweak_data.text_id or alive(self._unit) and self._unit:base().interaction_text_id and self._unit:base():interaction_text_id()
		if text_id == "hud_int_equipment_normal_mode_trip_mine" then
			return false
		else
			return old_BaseInteractionExt_can_select(self, player)
		end
	end
end

	----------------------------------------------------------------------------------
	-- 
	--		Default our tripmines to sensor mode when they are placed 
	-- 
	----------------------------------------------------------------------------------
if string.lower(RequiredScript) == "lib/units/weapons/trip_mine/tripminebase" then
	local old_TripMineBase_set_active = TripMineBase.set_active
	function TripMineBase:set_active(active, owner)
		old_TripMineBase_set_active(self, active, owner)
		if Enhanced_Tripmines_Plus.settings.main_settings.sensor == true then
			if active then
				self:set_armed(false)
			end
		end
	end

	----------------------------------------------------------------------------------
	--
	--		Make our tripmines invincible when they are set to sensor mode
	--
	----------------------------------------------------------------------------------
	local old_TripMineBase__explode = TripMineBase._explode
	function TripMineBase:_explode(col_ray)
		if Enhanced_Tripmines_Plus.settings.main_settings.invincibility == false or self:armed() then
			return old_TripMineBase__explode(self, col_ray)
		end
		-- nothing bcuz it is stealth mode and invincibility is on
	end

	local function local_beeping(trip_mine_unit)
		local function local_beep()
			trip_mine_unit:sound_source():post_event("trip_mine_sensor_alarm")
		end
		if Enhanced_Tripmines_Plus.settings.main_settings.beeps == 1 then
			local_beep()
		elseif Enhanced_Tripmines_Plus.settings.main_settings.beeps == 2 then
			--do nothing
		elseif Enhanced_Tripmines_Plus.settings.main_settings.beeps == 3 then
			if managers.groupai:state():whisper_mode() then
				local_beep()
			end
		elseif Enhanced_Tripmines_Plus.settings.main_settings.beeps == 4 then
			if not managers.groupai:state():whisper_mode() then
				local_beep()
			end
		end
	end

	local function synced_beeping(trip_mine_unit)
		local function synced_beep()
			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", trip_mine_unit, "base", TripMineBase.EVENT_IDS.sensor_beep)
		end
		if Enhanced_Tripmines_Plus.settings.main_settings.beeps_others == 1 then
			if managers.network:session() then
				synced_beep()
			end
		elseif Enhanced_Tripmines_Plus.settings.main_settings.beeps_others == 2 then
			--do nothing 
		elseif Enhanced_Tripmines_Plus.settings.main_settings.beeps_others == 3 then
			if managers.groupai:state():whisper_mode() then
				synced_beep()
			end
		elseif Enhanced_Tripmines_Plus.settings.main_settings.beeps_others == 4 then
			if not managers.groupai:state():whisper_mode() then
				synced_beep()
			end
		end
	end


	local function getPersonalColor(unitType)
		if Enhanced_Tripmines_Plus.settings.contour_color_mode[unitType] == 1 then
			return Enhanced_Tripmines_Plus:GetColor('default') -- if toggled to default
		elseif Enhanced_Tripmines_Plus.settings.ColorList[unitType] then
			return Enhanced_Tripmines_Plus:GetColor(unitType) -- if listed
		else
			return Enhanced_Tripmines_Plus:GetColor('default') -- if not listed
		end
	end

	--------------------------------------------------------------------------------------
	--
	--		Changes how our sensor-mode tripmines highlight specials and non-specials
	--
	--------------------------------------------------------------------------------------
	function TripMineBase:_sensor(t)
		local ray = self:_raycast()

		if ray and ray.unit and not tweak_data.character[ray.unit:base()._tweak_table].is_escort then
			local custom_unit_color = getPersonalColor(ray.unit:base()._tweak_table)
			Enhanced_Tripmines_Plus:custom_colour(ray.unit, custom_unit_color)
			self._sensor_units_detected = self._sensor_units_detected or {}

			if not self._sensor_units_detected[ray.unit:key()] then
				self._sensor_units_detected[ray.unit:key()] = true

				if managers.player:has_category_upgrade("trip_mine", "sensor_highlight") then
					local can_be_marked = managers.groupai:state():whisper_mode() and tweak_data.character[ray.unit:base()._tweak_table].silent_priority_shout or tweak_data.character[ray.unit:base()._tweak_table].priority_shout
					if can_be_marked then
						managers.game_play_central:auto_highlight_enemy(ray.unit, true)
					elseif not can_be_marked and Enhanced_Tripmines_Plus.settings.main_settings.marking == 1 then
						local time_multiplier = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1)
						if managers.groupai:state():whisper_mode() then
							time_multiplier = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 3)
						end
						ray.unit:contour():add("mark_enemy", true, time_multiplier)
					end
					local_beeping(self._unit)

					if managers.network:session() then
						synced_beeping(self._unit)
					end
				end
				self._sensor_last_unit_time = t + 5
			end
		end
	end
end