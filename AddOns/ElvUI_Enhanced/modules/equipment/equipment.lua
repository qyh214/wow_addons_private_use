local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local EQ = E:NewModule('Equipment', 'AceHook-3.0', 'AceEvent-3.0');

-- Based on ElvUI Improved Spec Switch Datatext
-- Author: Lockslap
-- Updated for Legion/BtS by NickBock/Feraldin

local changingEquipmentSet = nil
local join = string.join

function EQ:GetCurrentEquipmentSet()
	if C_EquipmentSet.GetNumEquipmentSets() == 0 then return false end
	local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs();
	for key,value in pairs(equipmentSetIDs) do
		local name, _, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(value)
		if isEquipped then
			return name
		end
	end
	return false
end

function EQ:CheckForGearChange()
	if InCombatLockdown() or C_EquipmentSet.GetNumEquipmentSets() == 0 or not self.db then return end

	local activeSet = EQ:GetCurrentEquipmentSet()
	local currentSpec = GetSpecialization()
	
	if self.db.battleground.enable then
		local inInstance, instanceType = IsInInstance()
		if (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
			local set = self.db.equipmentset
			if set ~= "none" and set ~= activeSet then
				changingEquipmentSet = set
				local sID = C_EquipmentSet.GetEquipmentSetID(set)
				C_EquipmentSet.UseEquipmentSet(sID)	
			end
			return
		end
	end

	if not GetSpecializationInfo(1) then return end
	if self.db.specialization.enable then
		local set = currentSpec == 1 and self.db.spec1 or currentSpec == 2 and self.db.spec2 or currentSpec == 3 and self.db.spec3 or currentSpec == 4 and self.db.spec4
		if set ~= "none" and set ~= activeSet then
			changingEquipmentSet = set
			local sID = C_EquipmentSet.GetEquipmentSetID(set)
			C_EquipmentSet.UseEquipmentSet(sID)			
		end
	end
end

function EQ:UpdateTalentConfiguration()
	if not E.Options.args.equipment then return end
	local numSpecs = GetNumSpecializations(false, self.isPet);
	local sex = self.isPet and UnitSex("pet") or UnitSex("player");

	for i = 1, numSpecs do
		local _, name, description, icon = GetSpecializationInfo(i, false, self.isPet, nil, sex);
		E.Options.args.equipment.args.specialization.args["spec"..i].name = name
	end
end

function EQ:EquipmentSwapFinished()
	if changingEquipmentSet then
		E:Print(join('', L["You have equipped equipment set: "], changingEquipmentSet))
		changingEquipmentSet = nil
	end
end

function EQ:Initialize()
	E.equipment = self
	
	self.db = E.private.equipment;
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckForGearChange")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckForGearChange")
	
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "UpdateTalentConfiguration")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateTalentConfiguration")
	
	self:RegisterEvent("EQUIPMENT_SWAP_FINISHED", "EquipmentSwapFinished")
	
	self:UpdateTalentConfiguration()
end

E:RegisterModule(EQ:GetName())
