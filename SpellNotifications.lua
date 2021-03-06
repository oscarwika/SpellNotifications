local _
local reflected = {}
local duration
local warnOP
local warnCS
local name,addon=...;

function SpellNotifications_OnLoad(self)
	local _,class = UnitClass("player")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED"); -- enter combat
	self:RegisterEvent("PLAYER_REGEN_ENABLED"); -- leave combat
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE");
end

function SpellNotifications_OnEvent(event)
	local bit_band = bit.band
	local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
	--        1        2       3           4            5           6              7              8        9          10          11

	-- SPELL_INTERRUPT
	if (checkEventAndSourceFlags(event, "SPELL_INTERRUPT", sourceFlags, bit_band)) then
		local extraSchool = select(17, CombatLogGetCurrentEventInfo())
		local spellSchool = addon.SpellSchools()[extraSchool]
		
		if spellSchool == nil then
			spellSchool = "unknown spell school"
		end

		addon.showText("Interrupted " .. string.lower(spellSchool) .. ".", "green", "small")
	end

	-- SPELL_DISPEL
	if (checkEventAndSourceFlags(event, "SPELL_DISPEL", sourceFlags, bit_band)) then
		local spellName = select(16, CombatLogGetCurrentEventInfo());
		if bit.band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0 then
			addon.showText("Dispelled "..spellName..".","white","small") -- friendly target
		else
			addon.showText("Dispelled "..spellName..".","yellow","small") -- enemy target
		end
	end

	-- SPELL_STOLEN
	if (checkEventAndSourceFlags(event, "SPELL_STOLEN", sourceFlags, bit_band)) then
		local spellName = select(16, CombatLogGetCurrentEventInfo());
		addon.showText("Stole "..spellName..".","yellow","small") -- enemy target
	end

	-- UNIT_DIED or something
	if ((event == "UNIT_DIED") or (event == "UNIT_DESTROYED") or (event == "UNIT_DESTROYED") and bit_band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 ) then
		if bit_band(destFlags, COMBATLOG_OBJECT_TYPE_PET) > 0 then
			addon.showText("Pet dead.","red","large")
			addon.playSound("buzz")
		end
	end
end

function checkEventAndSourceFlags(event, spellEvent, sourceFlags, bit_band)
	if(event == spellEvent) and bit_band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
		return true;
	else
		return false;
	end
end
