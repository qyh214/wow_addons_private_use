local E = select(2, ...):unpack()
local P, CM = E.Party, E.Comm

local pairs, ipairs, type, format, gsub = pairs, ipairs, type, format, gsub
local UnitIsConnected, CanInspect, CheckInteractDistance = UnitIsConnected, CanInspect, CheckInteractDistance
local GetPvpTalentInfoByID, GetTalentInfo, GetGlyphSocketInfo = GetPvpTalentInfoByID, GetTalentInfo, GetGlyphSocketInfo
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
local C_SpecializationInfo_GetInspectSelectedPvpTalent = C_SpecializationInfo and C_SpecializationInfo.GetInspectSelectedPvpTalent
local C_SpecializationInfo_GetPvpTalentSlotInfo = C_SpecializationInfo and C_SpecializationInfo.GetPvpTalentSlotInfo
local C_Traits_GetNodeInfo = C_Traits and C_Traits.GetNodeInfo
local C_Soulbinds_GetConduitSpellID = C_Soulbinds and C_Soulbinds.GetConduitSpellID


local GetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

local InspectQueueFrame = CreateFrame("Frame")
local InspectTooltip, tooltipData
if not E.postDF then
	InspectTooltip = CreateFrame("GameTooltip", "OmniCDInspectToolTip", nil, "GameTooltipTemplate")
	InspectTooltip:SetOwner(UIParent, "ANCHOR_NONE")
end

local LibDeflate = LibStub("LibDeflate")
local INSPECT_INTERVAL = 2
local INSPECT_TIMEOUT = 300
local queriedGUID

local inspectOrderList = {}
local queueEntries = {}
local staleEntries = {}

CM.SERIALIZATION_VERSION = E.preWOTLKC and 6 or 7
CM.ACECOMM = LibStub("AceComm-3.0"):Embed(CM)

function CM:Enable()
	if self.isEnabled then
		return
	end

	self.AddonPrefix = E.AddOn
	self:RegisterComm(self.AddonPrefix, "CHAT_MSG_ADDON")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")
	if E.preBCC then
		self:RegisterEvent("CHARACTER_POINTS_CHANGED")
	elseif E.preCata then

		self:RegisterEvent("PLAYER_TALENT_UPDATE")
	elseif E.preMoP then

		self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	else

		self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")

		self:RegisterEvent("COVENANT_CHOSEN")
		self:RegisterEvent("SOULBIND_ACTIVATED")
		self:RegisterEvent("SOULBIND_NODE_LEARNED")
		self:RegisterEvent("SOULBIND_NODE_UNLEARNED")
		self:RegisterEvent("SOULBIND_NODE_UPDATED")
		self:RegisterEvent("SOULBIND_CONDUIT_INSTALLED")
		self:RegisterEvent("SOULBIND_PATH_CHANGED")
		self:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED")


		self:RegisterEvent("TRAIT_CONFIG_UPDATED")
	end
	self:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)

	self:InitInspect()
	self:InitCooldownSync()
	self.isEnabled = true
end

function CM:Disable()
	if not self.isEnabled then
		return
	end
	self:UnregisterAllEvents()
	self:DisableInspect()
	self:DesyncUserFromGroup()
	self.isEnabled = false
end

local timeSinceUpdate = 0

local function InspectQueueFrame_OnUpdate(_, elapsed)
	timeSinceUpdate = timeSinceUpdate + elapsed


	if timeSinceUpdate > INSPECT_INTERVAL then
		CM:RequestInspect()
		timeSinceUpdate = 0
	end
end

function CM:InitInspect()
	if self.initInspect then
		return
	end
	InspectQueueFrame:Hide()
	InspectQueueFrame:SetScript("OnUpdate", InspectQueueFrame_OnUpdate)
	self.initInspect = true
end

function CM:EnableInspect()
	if self.enabledInspect or #inspectOrderList == 0 then
		return
	end
	InspectQueueFrame:Show()
	self:RegisterEvent("INSPECT_READY")
	self.enabledInspect = true
end

function CM:DisableInspect()
	if not self.enabledInspect then
		return
	end
	ClearInspectPlayer()
	InspectQueueFrame:Hide()
	self:UnregisterEvent("INSPECT_READY")

	wipe(inspectOrderList)
	wipe(queueEntries)
	wipe(staleEntries)
	queriedGUID = nil
	self.enabledInspect = false
end

local function PendingInspect(guid)
	return queueEntries[guid] or staleEntries[guid]
end

function CM:AddToInspectList(guid)





	if not PendingInspect(guid) then
		inspectOrderList[#inspectOrderList + 1] = guid
	end
end

function CM:AddToInspectListAndQueue(guid, addedTime)
	if guid == E.userGUID then
		self:InspectUser()
	elseif not PendingInspect(guid) then
		queueEntries[guid] = addedTime
		inspectOrderList[#inspectOrderList + 1] = guid
	end
end

function CM:EnqueueInspect(force, guid)
	local addedTime = GetTime()
	if force then
		for infoGUID in pairs(P.groupInfo) do
			self:AddToInspectListAndQueue(infoGUID, addedTime)
		end
	elseif guid then
		self:AddToInspectListAndQueue(guid, addedTime)
	else
		local n = #inspectOrderList
		if n == 0 then
			return
		end
		for i = 1, n do
			local listGUID = inspectOrderList[i]
			if not PendingInspect(guid) then
				queueEntries[listGUID] = addedTime
			end
		end
	end

	self:EnableInspect()
end

function CM:DequeueInspect(guid, moveToStale)
	if queriedGUID == guid then
		ClearInspectPlayer()
		queriedGUID = nil
	end

	if moveToStale then
		staleEntries[guid] = queueEntries[guid]
	else
		for i = #inspectOrderList, 1, -1 do
			local listGUID = inspectOrderList[i]
			if guid == listGUID then
				tremove(inspectOrderList, i)
			end
		end
	end
	queueEntries[guid] = nil
end

function CM:RequestInspect()
	if UnitIsDead("player") or InspectFrame and InspectFrame:IsShown() then
		return
	end

	if #inspectOrderList == 0 then
		self:DisableInspect()
		return
	end


	if queriedGUID then
		ClearInspectPlayer()
		staleEntries[queriedGUID] = queueEntries[queriedGUID]
		queueEntries[queriedGUID] = nil
		queriedGUID = nil
	end

	if next(queueEntries) == nil and next(staleEntries) then
		local copy = queueEntries
		queueEntries = staleEntries
		staleEntries = copy
	end

	local now = GetTime()
	local inCombat = InCombatLockdown()

	for i = 1, #inspectOrderList do
		local guid = inspectOrderList[i]
		local addedTime = queueEntries[guid]
		if addedTime then
			local info = P.groupInfo[guid]
			local unitIsSynced = self.syncedGroupMembers[guid]
			if guid == E.userGUID then
				self:InspectUser()
				self:DequeueInspect(guid)
			elseif info and not info.isNPC and not unitIsSynced then
				local unit = info.unit
				local elapsed = now - addedTime
				if not UnitIsConnected(unit) or elapsed > INSPECT_TIMEOUT or info.isAdminForMDI then
					self:DequeueInspect(guid)
				elseif E.preMoP and (inCombat or not CheckInteractDistance(unit,1))


					or not CanInspect(unit) then

					staleEntries[guid] = addedTime
					queueEntries[guid] = nil
				else
					queriedGUID = guid
					NotifyInspect(unit)
					return
				end
			else
				self:DequeueInspect(guid)
			end
		end
	end
end

function CM:INSPECT_READY(guid)
	if queriedGUID == guid then
		self:InspectUnit(guid)
	end
end

local INVSLOT_INDEX = {
	INVSLOT_HEAD,
	INVSLOT_NECK,
	INVSLOT_SHOULDER,

	INVSLOT_CHEST,
	INVSLOT_WAIST,
	INVSLOT_LEGS,
	INVSLOT_FEET,
	INVSLOT_WRIST,
	INVSLOT_HAND,
	INVSLOT_FINGER1,
	INVSLOT_FINGER2,
	INVSLOT_TRINKET1,
	INVSLOT_TRINKET2,
	INVSLOT_BACK,
	INVSLOT_MAINHAND,
	INVSLOT_OFFHAND,
}
local NUM_INVSLOTS = #INVSLOT_INDEX

E.essenceData = {
	[2]  = { 293019, 298080, 298081, 298081, 294668, 298082, 298083, 298083 },
	[3]  = { 293031, 300009, 300010, 300010, 294910, 300012, 300013, 300013 },
	[4]  = { 295186, 298628, 299334, 299334, 295078, 298627, 299333, 299333 },
	[5]  = { 295258, 299336, 299338, 299338, 295246, 299335, 299337, 299337 },
	[6]  = { 295337, 299345, 299347, 299347, 295293, 299343, 299346, 299346 },
	[7]  = { 294926, 300002, 300003, 300003, 294964, 300004, 300005, 300005 },
	[12] = { 295373, 299349, 299353, 299353, 295365, 299348, 299350, 299350 },
	[13] = { 295746, 300015, 300016, 300016, 295750, 300018, 300020, 300020 },
	[14] = { 295840, 299355, 299358, 299358, 295834, 299354, 299357, 299357 },
	[15] = { 302731, 302982, 302983, 302983, 302916, 302984, 302985, 302985 },
	[16] = { 296036, 310425, 310442, 310442, 293030, 310422, 310426, 310426 },
	[17] = { 296072, 299875, 299876, 299876, 296050, 299878, 299879, 299879 },
	[18] = { 296094, 299882, 299883, 299883, 296081, 299885, 299887, 299887 },
	[19] = { 296197, 299932, 299933, 299933, 296136, 299935, 299936, 299936 },
	[20] = { 293032, 299943, 299944, 299944, 296207, 299939, 299940, 299940 },
	[21] = { 296230, 299958, 299959, 299959, 303448, 303474, 303476, 303476 },
	[22] = { 296325, 299368, 299370, 299370, 296320, 299367, 299369, 299369 },
	[23] = { 297108, 298273, 298277, 298277, 297147, 298274, 298275, 298275 },
	[24] = { 297375, 298309, 298312, 298312, 297411, 298302, 298304, 298304 },
	[25] = { 298168, 299273, 299275, 299275, 298193, 299274, 299277, 299277 },
	[27] = { 298357, 299372, 299374, 299374, 298268, 299371, 299373, 299373 },
	[28] = { 298452, 299376, 299378, 299378, 298407, 299375, 299377, 299377 },
	[32] = { 303823, 304088, 304121, 304121, 304081, 304089, 304123, 304123 },
	[33] = { 295046, 299984, 299988, 299988, 295164, 299989, 299991, 299991 },
	[34] = { 310592, 310601, 310602, 310602, 310603, 310607, 310608, 310608 },
	[35] = { 310690, 311194, 311195, 311195, 310712, 311197, 311198, 311198 },
	[36] = { 311203, 311302, 311303, 311303, 311210, 311304, 311306, 311306 },
	[37] = { 312725, 313921, 313922, 313922, 312771, 313919, 313920, 313920 },
}

CM.essencePowerIDs = {}

for essenceID, essencePowers in pairs(E.essenceData) do

	local link = E.postSL and C_AzeriteEssence.GetEssenceHyperlink(essenceID, 1)
	if link and link ~= "" then
		link = link:match("%[(.-)%]"):gsub("%-","%%-")
		essencePowers.name = link
		essencePowers.ID = essenceID
		for i = 1, #essencePowers do
			local spellID = essencePowers[i]
			local rank1ID = essencePowers[i > 4 and 5 or 1]
			CM.essencePowerIDs[spellID] = rank1ID
		end
	end
end

function E:IsEssenceRankUpgraded(id)
	return id and id ~= CM.essencePowerIDs[id]
end

local function GetNumTooltipLines()
	if InspectTooltip then
		return InspectTooltip:NumLines()
	end
	return tooltipData and tooltipData.lines and #tooltipData.lines or 0
end

local function GetTooltipLineData(i)
	local lineData
	if tooltipData then
		lineData = tooltipData.lines[i]
		return lineData, lineData.leftText
	elseif InspectTooltip then
		lineData = _G["OmniCDInspectToolTipTextLeft" .. i]
		return lineData, lineData:GetText()
	end
end

local function GetTooltipLineTextColor(lineData)
	if not lineData then
		return 1, 1, 1
	elseif tooltipData then
		return lineData.leftColor.r, lineData.leftColor.g, lineData.leftColor.b
	elseif InspectTooltip then
		return lineData:GetTextColor()
	end
end

local ITEM_LEVEL = gsub(ITEM_LEVEL,"%%d","(%%d+)")

local function FindAzeriteEssencePower(info, specID, list)
	local heartOfAzerothLevel
	local majorID

	local numLines = math.min(16, GetNumTooltipLines())
	for j = 2, numLines do
		local lineData, text = GetTooltipLineData(j)
		if text and text ~= "" then
			if not heartOfAzerothLevel then
				heartOfAzerothLevel = strmatch(text, ITEM_LEVEL)
				if heartOfAzerothLevel then
					heartOfAzerothLevel = tonumber(heartOfAzerothLevel)
				end
			elseif j > 10 then
				for essenceID, essencePowers in pairs(E.essenceData) do
					if strfind(text, essencePowers.name .. "$") == 1 then
						local r, _, b = GetTooltipLineTextColor(lineData)
						local rank = 3
						if r < .01 then
							rank = 2
						elseif r > .90 then
							rank = 4
						elseif b < .01 then
							rank = 1
						end

						if not majorID and GetTooltipLineData(j - 1) == " " then
							majorID = essencePowers[rank]
							local rank1 = essencePowers[1]
							info.talentData[rank1] = "AE"
							info.talentData["essMajorRank1"] = rank1
							info.talentData["essMajorID"] = majorID
							if list then
								list[#list + 1] = majorID .. ":AE"
							end

							if E.essMajorConflict[majorID] then
								local pvpTalent = E.pvpTalentsByEssMajorConflict[specID]
								if pvpTalent then
									info.talentData[pvpTalent] = "AE"
									if list then
										list[#list + 1] = pvpTalent
									end
								end
							end
							if rank1 ~= 296325 then
								break
							end
						end

						local minorID = essencePowers[rank + 4]
						if E.essMinorStrive[minorID] then

							local mult = (90.1 - ((heartOfAzerothLevel - 117) * 0.15)) / 100
							if P.isInPvPInstance then
								mult = 0.2 + mult * 0.8
							end
							mult = math.max(0.75, math.min(0.9, mult))
							info.talentData["essStriveMult"] = mult
							if list then
								list[#list + 1] = mult .. ":ae"
							end
							return
						end
						break
					end
				end
			end
		end
	end
end

local function FindAzeritePower(info, list)
	local numLines = GetNumTooltipLines()
	for j = 10, numLines do
		local _, text = GetTooltipLineData(j)
		if text and text ~= "" and strfind(text, "^-") == 1 then
			for _, v in pairs(E.spell_cxmod_azerite) do
				if strfind(text, v.name .. "$") == 3 then
					info.talentData[v.azerite] = "A"
					if list then list[#list + 1] = v.azerite .. ":A" end
					return
				end
			end
		end
	end
end

local S_ITEM_SET_NAME = "^" .. ITEM_SET_NAME:gsub("([%(%)])", "%%%1"):gsub("%%%d?$?d", "(%%d+)"):gsub("%%%d?$?s", "(.+)") .. "$"

local function FindSetBonus(info, specBonus, list)
	local bonusID, numRequired = specBonus[1], specBonus[2]
	local numLines = GetNumTooltipLines()
	for j = 10, numLines do
		local _, text = GetTooltipLineData(j)
		if text and text ~= "" then
			local name, numEquipped, numFullSet = strmatch(text, S_ITEM_SET_NAME)
			if name and numEquipped and numFullSet then
				numEquipped = tonumber(numEquipped)
				if numEquipped and numEquipped >= numRequired then
					info.talentData[bonusID] = "S"
					if list then list[#list + 1] = bonusID .. ":S" end

					local bonusID2 = specBonus[3]
					if bonusID2 and numEquipped >= specBonus[4] then
						info.talentData[bonusID2] = "S"
						if list then list[#list + 1] = bonusID2 .. ":S" end
					end
				end
				return bonusID
			end
		end
	end
end

local function FindCraftedRuneforgeLegendary(info, itemLink, list)
	local _,_,_,_,_,_,_,_,_,_,_,_,_, numBonusIDs, bonusIDs = strsplit(":", itemLink, 15)
	numBonusIDs = tonumber(numBonusIDs)
	if numBonusIDs and bonusIDs then
		local t = { strsplit(":", bonusIDs, numBonusIDs + 1) }
		for j = 1, numBonusIDs do
			local bonusID = t[j]
			bonusID = tonumber(bonusID)
			local runeforgeDescID = E.runeforge_bonus_to_descid[bonusID]
			if runeforgeDescID then
				if type(runeforgeDescID) == "table" then
					for _, descID in pairs(runeforgeDescID) do
						info.talentData[descID] = "R"
						if list then list[#list + 1] = descID .. ":R" end
					end
				else
					info.talentData[runeforgeDescID] = "R"
					if list then list[#list + 1] = runeforgeDescID .. ":R" end
				end
				return
			end
		end
	end
end

local runeforgeBaseItems = {
	[1]  = { 173245, 172317, 172325, 171415 },
	[2]  = { 178927, 178927, 178927, 178927 },
	[3]  = { 173247, 172319, 172327, 171417 },
	[5]  = { 173241, 172314, 172322, 171412 },
	[6]  = { 173248, 172320, 172328, 171418 },
	[7]  = { 173246, 172318, 172326, 171416 },
	[8]  = { 173243, 172315, 172323, 171413 },
	[9]  = { 173249, 172321, 172329, 171419 },
	[10] = { 173244, 172316, 172324, 171414 },
	[11] = { 178926, 178926, 178926, 178926 },
	[12] = { 178926, 178926, 178926, 178926 },
	[15] = { 173242, 173242, 173242, 173242 },
}

--[[
if we're separating player inspect:
	local itemID = GetInventoryItemID(unit, slotID)
	local itemLink = GetInventoryItemLink(unit, slotID)
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotID)
	local isRuenforgeBaseItem = C_LegendaryCrafting.IsValidRuneforgeBaseItem(itemLocation)
	local isRuneforgeLegendary = C_LegendaryCrafting.IsRuneforgeLegendary(itemLocation)
]]
local function GetEquippedItemData(info, unit, specID, list)
	local moveToStale
	local numRuneforge = 0
	local numTierSetBonus = 0
	local foundTierSpecBonus
	local e
	if list then list[#list + 1] = "^M"; e = { "^E" }; end

	for i = 1, NUM_INVSLOTS do
		local slotID = INVSLOT_INDEX[i]
		local itemLink = GetInventoryItemLink(unit, slotID)
		if itemLink then
			local itemID, _,_,_,_,_, subclassID = GetItemInfoInstant(itemLink)
			if itemID then
				if i < 10 then
					local tierSetBonus = E.item_set_bonus[itemID]
					local equipBonusID = E.item_equip_bonus[itemID]
					subclassID = subclassID == 0 and 1 or subclassID
					local unityRuneforgeLegendary = E.item_unity[itemID]
					local isCraftedRuneforgeLegendary = numRuneforge <= 2
						and runeforgeBaseItems[slotID]
						and itemID == runeforgeBaseItems[slotID][subclassID]
					if InspectTooltip then
						InspectTooltip:SetInventoryItem(unit, slotID)
					else

						tooltipData = C_TooltipInfo.GetInventoryItem(unit, slotID)
						--[[ removed in 11.0
						if tooltipData and TooltipUtil.SurfaceArgs then
							TooltipUtil.SurfaceArgs(tooltipData)
							for _, line in ipairs(tooltipData.lines) do
							TooltipUtil.SurfaceArgs(line)
							end
						end
						]]
					end
					if equipBonusID then
						info.talentData[equipBonusID] = true
						if list then list[#list + 1] = equipBonusID .. ":S" end
					end
					if tierSetBonus then
						local specBonus = E.preMoP and tierSetBonus or tierSetBonus[specID] or tierSetBonus[info.heroSpecID]
						if specBonus and numTierSetBonus < 2 and specBonus[1] ~= foundTierSpecBonus then
							foundTierSpecBonus = FindSetBonus(info, specBonus, list)
							if foundTierSpecBonus then
								numTierSetBonus = numTierSetBonus + 1
							end
						end

					elseif isCraftedRuneforgeLegendary then
						FindCraftedRuneforgeLegendary(info, itemLink, list)
						numRuneforge = numRuneforge + 1
					elseif unityRuneforgeLegendary then
						if type(unityRuneforgeLegendary) == "table" then
							for _, runeforgeDescID in pairs(unityRuneforgeLegendary) do
								info.talentData[runeforgeDescID] = "R"
								if list then list[#list + 1] = runeforgeDescID .. ":R" end
							end
						else
							info.talentData[unityRuneforgeLegendary] = "R"
							if list then list[#list + 1] = unityRuneforgeLegendary .. ":R" end
						end
						numRuneforge = numRuneforge + 1
					elseif itemID == 158075 then
						FindAzeriteEssencePower(info, specID, list)
					elseif C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink) then
						FindAzeritePower(info, list)
					end
					if InspectTooltip then
						InspectTooltip:ClearLines()
					end
				end
				itemID = E.item_merged[itemID] or itemID
				info.itemData[itemID] = true
				if e then e[#e + 1] = itemID end
			elseif not moveToStale then
				moveToStale = true
			end
		end
	end
	if e then
		list[#list + 1] = table.concat(e, ",")
		e = nil
	end

	return moveToStale
end

local tmpDump={[199483]=true,[207028]=true,[32]=true,[1022]=true,[202425]=true,[263165]=true,[207029]=true,[2050]=true,[387972]=true,[450631]=true,[22570]=true,[275699]=true,[386951]=true,[383115]=true,[10326]=true,[215982]=true,[384651]=true,[1044]=true,[359844]=true,[22842]=true,[5211]=true,[474421]=true,[51886]=true,[384909]=true,[200383]=true,[391559]=true,[228260]=true,[322507]=true,[88747]=true,[233759]=true,[207289]=true,[152175]=true,[383121]=true,[102558]=true,[201664]=true,[394121]=true,[1217413]=true,[378266]=true,[394123]=true,[469314]=true,[34]=true,[378779]=true,[387219]=true,[205630]=true,[271877]=true,[469317]=true,[102560]=true,[457042]=true,[262161]=true,[218164]=true,[47476]=true,[207167]=true,[373926]=true,[96231]=true,[389783]=true,[34433]=true,[57994]=true,[324312]=true,[196555]=true,[319454]=true,[442726]=true,[279302]=true,[343240]=true,[469325]=true,[387230]=true,[378279]=true,[385696]=true,[385952]=true,[343242]=true,[205636]=true,[393371]=true,[444777]=true,[444010]=true,[42650]=true,[111898]=true,[321507]=true,[80313]=true,[207684]=true,[88625]=true,[257044]=true,[343247]=true,[444780]=true,[389794]=true,[428924]=true,[288848]=true,[389539]=true,[55342]=true,[1160]=true,[461917]=true,[1215610]=true,[215652]=true,[211522]=true,[473522]=true,[264735]=true,[153595]=true,[388007]=true,[260243]=true,[193876]=true,[197073]=true,[205385]=true,[418359]=true,[333919]=true,[231793]=true,[377779]=true,[459875]=true,[394983]=true,[102693]=true,[441206]=true,[388212]=true,[263716]=true,[388827]=true,[311203]=true,[296197]=true,[197899]=true,[470347]=true,[236077]=true,[193531]=true,[389359]=true,[383228]=true,[443454]=true,[1241059]=true,[205411]=true,[3411]=true,[92297]=true,[391339]=true,[33206]=true,[378244]=true,[199023]=true,[115399]=true,[469344]=true,[198100]=true,[207407]=true,[46584]=true,[452415]=true,[381623]=true,[123986]=true,[1217092]=true,[212295]=true,[437122]=true,[432919]=true,[235313]=true,[185314]=true,[294926]=true,[46968]=true,[192222]=true,[390163]=true,[212552]=true,[457574]=true,[184662]=true,[49206]=true,[63560]=true,[436358]=true,[280001]=true,[198103]=true,[204403]=true,[235941]=true,[39]=true,[353584]=true,[248443]=true,[295186]=true,[353753]=true,[381630]=true,[428940]=true,[46585]=true,[384444]=true,[394930]=true,[197721]=true,[429211]=true,[114154]=true,[394931]=true,[427775]=true,[407876]=true,[66]=true,[256188]=true,[374277]=true,[325093]=true,[343527]=true,[458359]=true,[1236403]=true,[368847]=true,[269737]=true,[471366]=true,[328669]=true,[384820]=true,[205036]=true,[375777]=true,[469870]=true,[403631]=true,[45438]=true,[206803]=true,[206931]=true,[633]=true,[210256]=true,[124081]=true,[199259]=true,[389732]=true,[389849]=true,[375982]=true,[452409]=true,[382513]=true,[48792]=true,[212431]=true,[197214]=true,[316402]=true,[196447]=true,[370388]=true,[472719]=true,[256165]=true,[472433]=true,[375443]=true,[389724]=true,[383854]=true,[179057]=true,[235450]=true,[196704]=true,[424654]=true,[374227]=true,[232893]=true,[378962]=true,[203235]=true,[459991]=true,[400472]=true,[388039]=true,[108199]=true,[388551]=true,[412723]=true,[391109]=true,[470540]=true,[209749]=true,[451211]=true,[377811]=true,[199452]=true,[378425]=true,[108839]=true,[432804]=true,[354825]=true,[391271]=true,[278326]=true,[205727]=true,[354540]=true,[469886]=true,[155148]=true,[207399]=true,[296230]=true,[374383]=true,[383697]=true,[450448]=true,[1236370]=true,[1215613]=true,[388813]=true,[202335]=true,[108968]=true,[382953]=true,[387791]=true,[146956]=true,[212182]=true,[451546]=true,[119582]=true,[1218692]=true,[106839]=true,[116705]=true,[444099]=true,[268358]=true,[236662]=true,[21]=true,[42]=true,[353313]=true,[31]=true,[382424]=true,[441257]=true,[23]=true,[19]=true,[429483]=true,[391888]=true,[358385]=true,[200183]=true,[1215991]=true,[233412]=true,[1213597]=true,[397768]=true,[1218603]=true,[472707]=true,[40]=true,[375577]=true,[190319]=true,[383707]=true,[64843]=true,[205025]=true,[382552]=true,[1235091]=true,[370665]=true,[200652]=true,[428937]=true,[64044]=true,[288826]=true,[97462]=true,[429420]=true,[469642]=true,[392911]=true,[5484]=true,[440743]=true,[373481]=true,[375783]=true,[451041]=true,[390994]=true,[443046]=true,[381922]=true,[355580]=true,[470549]=true,[470668]=true,[414659]=true,[368838]=true,[197995]=true,[265046]=true,[414660]=true,[406732]=true,[390620]=true,[387807]=true,[2782]=true,[205029]=true,[137639]=true,[451234]=true,[411164]=true,[122783]=true,[65]=true,[115750]=true,[196718]=true,[375406]=true,[252216]=true,[409293]=true,[414664]=true,[414969]=true,[382440]=true,[278350]=true,[86659]=true,[31687]=true,[325153]=true,[385881]=true,[392160]=true,[228049]=true,[376204]=true,[392928]=true,[353294]=true,[123040]=true,[238100]=true,[410320]=true,[392162]=true,[459546]=true,[115176]=true,[360194]=true,[459507]=true,[449707]=true,[108271]=true,[200174]=true,[445027]=true,[391397]=true,[147362]=true,[431442]=true,[387044]=true,[453677]=true,[394309]=true,[431484]=true,[393414]=true,[199454]=true,[450989]=true,[382268]=true,[416719]=true,[375528]=true,[360966]=true,[204268]=true,[31224]=true,[390378]=true,[51514]=true,[391174]=true,[377847]=true,[198898]=true,[31884]=true,[206315]=true,[32375]=true,[192249]=true,[61]=true,[2908]=true,[194679]=true,[443442]=true,[37]=true,[1215275]=true,[356367]=true,[206572]=true,[469409]=true,[107570]=true,[116841]=true,[157980]=true,[13750]=true,[417493]=true,[110959]=true,[20]=true,[321076]=true,[404195]=true,[352278]=true,[157981]=true,[414170]=true,[1236368]=true,[382550]=true,[310592]=true,[321078]=true,[740]=true,[328767]=true,[115203]=true,[321079]=true,[116011]=true,[443328]=true,[248518]=true,[379391]=true,[86184]=true,[452536]=true,[204018]=true,[196985]=true,[231895]=true,[271466]=true,[441415]=true,[386763]=true,[404436]=true,[390135]=true,[12975]=true,[34477]=true,[23920]=true,[213610]=true,[305483]=true,[35]=true,[255937]=true,[365585]=true,[218612]=true,[429523]=true,[433871]=true,[450892]=true,[344359]=true,[34861]=true,[426438]=true,[116844]=true,[204021]=true,[205364]=true,[377509]=true,[228920]=true,[217832]=true,[51485]=true,[453828]=true,[115310]=true,[370960]=true,[440661]=true,[459450]=true,[47585]=true,[409835]=true,[440674]=true,[107574]=true,[462440]=true,[204023]=true,[404977]=true,[48]=true,[451524]=true,[378081]=true,[322115]=true,[132158]=true,[381647]=true,[376079]=true,[202168]=true,[78675]=true,[365933]=true,[370965]=true,[213871]=true,[397103]=true,[431067]=true,[384072]=true,[322118]=true,[152108]=true,[396286]=true,[441429]=true,[407028]=true,[202107]=true,[231691]=true,[334033]=true,[388615]=true,[198144]=true,[205625]=true,[400636]=true,[360995]=true,[368412]=true,[372760]=true,[381867]=true,[5217]=true,[49]=true,[60]=true,[423647]=true,[44]=true,[401150]=true,[212084]=true,[36]=true,[108280]=true,[375576]=true,[333889]=true,[462791]=true,[258887]=true,[377623]=true,[206970]=true,[30283]=true,[205180]=true,[383762]=true,[108920]=true,[405757]=true,[22]=true,[18]=true,[404015]=true,[329033]=true,[325197]=true,[365350]=true,[388112]=true,[386113]=true,[390670]=true,[44614]=true,[116849]=true,[383254]=true,[408083]=true,[50]=true,[326734]=true,[389942]=true,[200209]=true,[320341]=true,[115315]=true,[157997]=true,[345829]=true,[357170]=true,[202370]=true,[329038]=true,[455428]=true,[376237]=true,[1249658]=true,[212459]=true,[197000]=true,[19574]=true,[384447]=true,[406788]=true,[114165]=true,[186387]=true,[230332]=true,[462031]=true,[196439]=true,[353082]=true,[383005]=true,[329042]=true,[203651]=true,[213915]=true,[424742]=true,[436162]=true,[440992]=true,[51]=true,[414720]=true,[429539]=true,[423662]=true,[377637]=true,[198793]=true,[434136]=true,[280197]=true,[202246]=true,[416506]=true,[373035]=true,[6544]=true,[275339]=true,[453678]=true,[298357]=true,[59]=true,[417537]=true,[383011]=true,[43]=true,[390684]=true,[392986]=true,[381989]=true,[382245]=true,[108285]=true,[316262]=true,[385059]=true,[383269]=true,[113656]=true,[414073]=true,[383012]=true,[453675]=true,[15286]=true,[124974]=true,[375087]=true,[391330]=true,[64901]=true,[235587]=true,[236776]=true,[410126]=true,[192088]=true,[378937]=true,[56805]=true,[321291]=true,[455395]=true,[449582]=true,[356962]=true,[468743]=true,[392993]=true,[280719]=true,[274837]=true,[51490]=true,[400140]=true,[374968]=true,[205800]=true,[441274]=true,[77606]=true,[87100]=true,[58875]=true,[115173]=true,[11426]=true,[203965]=true,[444081]=true,[221562]=true,[53]=true,[213634]=true,[386348]=true,[441846]=true,[58]=true,[155835]=true,[87099]=true,[198034]=true,[29166]=true,[108416]=true,[102342]=true,[382503]=true,[267171]=true,[1215995]=true,[196884]=true,[391572]=true,[385840]=true,[296072]=true,[264332]=true,[5277]=true,[210476]=true,[389763]=true,[109248]=true,[265895]=true,[392983]=true,[384052]=true,[403745]=true,[354897]=true,[1719]=true,[276079]=true,[234299]=true,[264874]=true,[54]=true,[431112]=true,[204596]=true,[266921]=true,[342249]=true,[200851]=true,[270581]=true,[108270]=true,[148039]=true,[114556]=true,[208652]=true,[428557]=true,[202770]=true,[122278]=true,[6940]=true,[41]=true,[33]=true,[451576]=true,[871]=true,[203316]=true,[231548]=true,[385422]=true,[371016]=true,[47528]=true,[1233429]=true,[429072]=true,[33891]=true,[408543]=true,[353115]=true,[48743]=true,[277925]=true,[389688]=true,[55]=true,[102793]=true,[384318]=true,[444931]=true,[196937]=true,[297108]=true,[1215132]=true,[391548]=true,[55233]=true,[216853]=true,[390142]=true,[374346]=true,[415945]=true,[103827]=true,[354654]=true,[101643]=true,[264119]=true,[455449]=true,[455450]=true,[10060]=true,[205673]=true,[374348]=true,[389627]=true,[1776]=true,[64]=true,[378441]=true,[24]=true,[203415]=true,[372048]=true,[8143]=true,[320387]=true,[412713]=true,[216331]=true,[202137]=true,[56]=true,[199324]=true,[106951]=true,[389880]=true,[31661]=true,[386686]=true,[269751]=true,[202138]=true,[353128]=true,[296094]=true,[419110]=true,[468571]=true,[184364]=true,[192077]=true,[31821]=true,[386937]=true,[295840]=true,[351338]=true,[297375]=true,[113724]=true,[200733]=true,[319217]=true,[371032]=true,[473909]=true,[15487]=true,[382030]=true,[62971]=true,[12051]=true,[264130]=true,[293030]=true,[19801]=true,[221622]=true,[57]=true,[293031]=true,[32379]=true,[209584]=true,[382800]=true,[293032]=true,[5246]=true,[132578]=true,[426591]=true,[31230]=true,[378198]=true,[205723]=true,[51271]=true,[167105]=true,[260643]=true,[389708]=true,[370452]=true,[114051]=true,[295337]=true,[388686]=true,[328530]=true,[360952]=true,[1219201]=true,[213691]=true,[227847]=true,[114050]=true,[102351]=true,[6353]=true,[19577]=true,[102543]=true,[410939]=true,[-157980]=true,[79206]=true,[114052]=true,[221699]=true,[389713]=true,[459533]=true,[1122]=true,[382297]=true,[61336]=true,[213644]=true,[372835]=true,[328774]=true,[5394]=true,[267211]=true,[378974]=true,[327193]=true,[439843]=true,[458513]=true,[394320]=true,[310690]=true,[197268]=true,[73325]=true,[394321]=true,[204066]=true,[389718]=true,[370537]=true,[288613]=true,[386394]=true,[258925]=true,[321077]=true,[356719]=true,[30884]=true,[47788]=true,[1238680]=true,[152278]=true,[108503]=true,[414273]=true,[327574]=true,[121471]=true,[205179]=true,[203173]=true,[104316]=true,[64382]=true,[384352]=true,[207777]=true,[321530]=true,[202918]=true,[102401]=true,[475]=true,[320416]=true,[115078]=true,[205604]=true,[118038]=true,[295046]=true,[202162]=true,[121536]=true,[152280]=true,[320418]=true,[298168]=true,[360827]=true,[386997]=true,[115008]=true,[388193]=true,[356736]=true,[386659]=true,[454433]=true,[258860]=true,[302731]=true,[153561]=true,[320421]=true,[269513]=true,[98008]=true,[382569]=true,[211489]=true,[212640]=true,[194223]=true,[12472]=true,[12323]=true,[387174]=true,[383338]=true,[367226]=true,[62618]=true,[53480]=true,[263648]=true,[209258]=true,[421453]=true,[31935]=true,[204074]=true,[378773]=true,[370553]=true,[51690]=true,[384100]=true,[123904]=true,[212638]=true,[199855]=true,[187707]=true,[116680]=true,[204331]=true,[384110]=true,[63231]=true,[194844]=true,[265187]=true,[207017]=true,[391528]=true,[31850]=true,[6789]=true,[236273]=true,[359816]=true,[429636]=true,[191634]=true,[207018]=true,[387976]=true,[198067]=true,[198013]=true,[106898]=true,[469279]=true,[342245]=true,[375901]=true,[387184]=true,[120517]=true,[295746]=true,[192058]=true,[108238]=true,[102359]=true,[359053]=true,[120644]=true,[86183]=true,[132469]=true,[444986]=true,[62]=true,[386071]=true,[295373]=true,[99]=true,[321460]=true,[51052]=true,[20066]=true,[384631]=true,[204336]=true,[219809]=true,[363916]=true,[390770]=true,[383013]=true,[198838]=true,[473378]=true,[202163]=true,[395152]=true,[434249]=true,[432459]=true,[5938]=true,[295258]=true,[383019]=true,[84714]=true,[385627]=true,[47568]=true,[293019]=true,[49028]=true,[54825]=true,[372616]=true,[86185]=true,[190784]=true,[157153]=true,[192063]=true,[274281]=true,[406888]=true,[444995]=true,[374251]=true,[207025]=true,[187698]=true,[391124]=true,[288733]=true,[359073]=true,[298452]=true,[274156]=true,[355936]=true,[363534]=true,[443028]=true,[343721]=true,[80240]=true,[212653]=true,[185313]=true,[57934]=true,[51533]=true,[2094]=true,[377226]=true,[386689]=true,[342817]=true,[202424]=true,[205021]=true,[280195]=true,[200199]=true,[388218]=true,[203340]=true,[79008]=true,[205596]=true,[199448]=true,[354489]=true,[408557]=true,[314867]=true,[260404]=true,}


local talentIDFix = {
	[103211] = 377779,
	[103216] = 343240,
	[103224] = 377623
}


local talentChargeFix = {
	[5394] = true
}

local MAX_NUM_TALENTS = MAX_NUM_TALENTS or ((E.isWOTLKC or E.isCata) and 31 or 25)

local GetSelectedTalentData = (E.postDF and function(info, unit, isInspect)
	local list, c
	if not isInspect then
		list, c = { CM.SERIALIZATION_VERSION, info.spec, "^T" }, 4
	end

	for i = 1, 3 do
		local talentID
		if isInspect then
			talentID = C_SpecializationInfo_GetInspectSelectedPvpTalent(unit, i)
		else
			local slotInfo = C_SpecializationInfo_GetPvpTalentSlotInfo(i)
			talentID = slotInfo and slotInfo.selectedTalentID
		end
		if talentID then
			local _,_,_,_,_, spellID = GetPvpTalentInfoByID(talentID)
			info.talentData[spellID] = "PVP"
			if list then
				list[c] = -spellID
				c = c + 1
			end
		end
	end

	local configID = isInspect and Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID or C_ClassTalents.GetActiveConfigID()
	if configID then
		local configInfo = C_Traits.GetConfigInfo(configID)
		if configInfo then
			info.heroSpecID = nil
			for _, treeID in ipairs(configInfo.treeIDs) do
				local treeNodes = C_Traits.GetTreeNodes(treeID)
				for _, treeNodeID in ipairs(treeNodes) do
					local treeNode = C_Traits_GetNodeInfo(configID, treeNodeID)
					local activeEntry = treeNode.activeEntry
					if activeEntry then
						local activeRank = treeNode.activeRank
						if activeRank > 0 then
							local activeEntryID = activeEntry.entryID
							local entryInfo = C_Traits.GetEntryInfo(configID, activeEntryID)
							local definitionID = entryInfo.definitionID
							if definitionID then
								local definitionInfo = C_Traits.GetDefinitionInfo(definitionID)
								local spellID = definitionInfo.spellID
								spellID = talentIDFix[activeEntryID] or spellID
								if spellID then
									if not treeNode.subTreeID or treeNode.subTreeActive then
										if talentChargeFix[spellID] then

											if talentChargeFix[spellID] == true then
												if info.talentData[spellID] then
													activeRank = 2
												end

											elseif talentChargeFix[spellID][info.spec] then
												activeRank = 2
											end
										end
										info.talentData[spellID] = activeRank
										if list and tmpDump[spellID] then
											if activeRank > 1 then
												list[c] = format("%s:%s", spellID, activeRank)
											else
												list[c] = spellID
											end
											c = c + 1
										end
										if treeNode.subTreeActive and not info.heroSpecID then
											info.heroSpecID = treeNode.subTreeID
											if list then
												list[c] = treeNode.subTreeID .. ":h"
												c = c + 1
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return list
end) or (E.isSL and function(info, unit, isInspect)
	local list
	if not isInspect then
		list = { CM.SERIALIZATION_VERSION, info.spec, "^T" }
	end

	for i = 1, 3 do
		local talentID
		if isInspect then
			talentID = C_SpecializationInfo_GetInspectSelectedPvpTalent(unit, i)
		else
			local slotInfo = C_SpecializationInfo_GetPvpTalentSlotInfo(i)
			talentID = slotInfo and slotInfo.selectedTalentID
		end
		if talentID then
			local _,_,_,_,_, spellID = GetPvpTalentInfoByID(talentID)
			info.talentData[spellID] = "PVP"
			if list then list[#list + 1] = -spellID end
		end
	end

	local specGroupIndex = 1
	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local _,_,_, selected, _, spellID = GetTalentInfo(tier, column, specGroupIndex , isInspect, unit)
			if selected then
				info.talentData[spellID] = true
				if list then list[#list + 1] = spellID end
				break
			end
		end
	end

	return list
end) or (E.isWOTLKC and function(info, unit, isInspect)
	local list
	if not isInspect then
		list = { CM.SERIALIZATION_VERSION, info.spec, "^T" }
	end

	local talentGroup = GetActiveTalentGroup and GetActiveTalentGroup(isInspect, nil)

	if list then
		for i = 1, 6 do
			local _,_, glyphSpellID = GetGlyphSocketInfo(i, talentGroup)
			if glyphSpellID then
				info.talentData[glyphSpellID] = true
				list[#list + 1] = glyphSpellID
			end
		end
	end

	for tabIndex = 1, 3 do
		for talentIndex = 1, MAX_NUM_TALENTS do
			local name, _,_,_, currentRank = GetTalentInfo(tabIndex, talentIndex, isInspect, unit, talentGroup)
			if not name then
				break
			end
			if currentRank > 0 then
				local talentRankIDs = E.talentNameToRankIDs[name]
				if talentRankIDs then
					if type(talentRankIDs[1]) == "table" then
						for _, t in pairs(talentRankIDs) do
							local talentID = t[currentRank]
							if talentID then
								info.talentData[talentID] = true
								if list then list[#list + 1] = talentID end
							end
						end
					else
						local talentID = talentRankIDs[currentRank]
						if talentID then
							info.talentData[talentID] = true
							if list then list[#list + 1] = talentID end
						end
					end
				end
			end
		end
	end

	return list
end) or (E.isCata and function(info, unit, isInspect)
	local list
	if not isInspect then
		list = { CM.SERIALIZATION_VERSION, 0, "^T" }
	end

	local talentGroup = GetActiveTalentGroup and GetActiveTalentGroup(isInspect, nil)


	local primaryTree = GetPrimaryTalentTree(isInspect, nil, talentGroup)
	if primaryTree then
		info.spec = primaryTree
		info.talentData[primaryTree] = true
		if list then
			list[2] = primaryTree
			list[#list + 1] = primaryTree
		end
	end

	if list then
		for i = 1, 9 do
			local _,_,_, glyphSpellID = GetGlyphSocketInfo(i, talentGroup)
			if glyphSpellID then
				info.talentData[glyphSpellID] = true
				list[#list + 1] = glyphSpellID
			end
		end
	end

	for tabIndex = 1, 3 do
		for talentIndex = 1, MAX_NUM_TALENTS do
			local name, _,_,_, currentRank = GetTalentInfo(tabIndex, talentIndex, isInspect, unit, talentGroup)
			if not name then
				break
			end
			if currentRank > 0 then
				local talentRankIDs = E.talentNameToRankIDs[name]
				if talentRankIDs then
					if type(talentRankIDs[1]) == "table" then
						for _, t in pairs(talentRankIDs) do
							local talentID = t[currentRank]
							if talentID then
								info.talentData[talentID] = true
								if list then list[#list + 1] = talentID end
							end
						end
					else
						local talentID = talentRankIDs[currentRank]
						if talentID then
							info.talentData[talentID] = true
							if list then list[#list + 1] = talentID end
						end
					end
				end
			end
		end
	end

	return list
end) or (E.isMoP and function(info, unit, isInspect)
	local list
	if not isInspect then
		list = { CM.SERIALIZATION_VERSION, info.spec, "^T" }
	end

	local talentGroup = GetActiveTalentGroup and GetActiveTalentGroup(isInspect, nil)

	for i = 1, 6 do
		local _,_,_, glyphSpellID = GetGlyphSocketInfo(i, talentGroup, isInspect, unit)
		if glyphSpellID then
			info.talentData[glyphSpellID] = true
			if list then list[#list + 1] = glyphSpellID end
		end
	end

	for tier = 1, MAX_NUM_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local talentInfoQuery = {}
			talentInfoQuery.tier = tier
			talentInfoQuery.column = column
			talentInfoQuery.groupIndex = talentGroup
			talentInfoQuery.isInspect = isInspect
			talentInfoQuery.target = unit
			local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
			if talentInfo and talentInfo.selected then
				local spellID = talentInfo.spellID
				info.talentData[spellID] = true
				if list then list[#list + 1] = spellID end
			end
		end
	end

	return list
end) or function(info, unit, isInspect)
	local list
	if not isInspect then
		list = { CM.SERIALIZATION_VERSION, info.spec, "^T" }
	end

	for tabIndex = 1, 3 do
		for talentIndex = 1, MAX_NUM_TALENTS do
			local name, _,_,_, currentRank = GetTalentInfo(tabIndex, talentIndex, isInspect, unit)
			if not name then
				break
			end
			if currentRank > 0 then
				local talentRankIDs = E.talentNameToRankIDs[name]
				if talentRankIDs then
					if type(talentRankIDs[1]) == "table" then
						for _, t in pairs(talentRankIDs) do
							local talentID = t[currentRank]
							if talentID then
								info.talentData[talentID] = true
								if list then list[#list + 1] = talentID end
							end
						end
					else
						local talentID = talentRankIDs[currentRank]
						if talentID then
							info.talentData[talentID] = true
							if list then list[#list + 1] = talentID end
						end
					end
				end
			end
		end
	end

	return list
end

function CM:InspectUnit(guid)
	local info = P.groupInfo[guid]


	if not info or self.syncedGroupMembers[guid] then
		self:DequeueInspect(guid)
		return
	end

	local unit = info.unit
	local specID = E.preCata and info.raceID or GetInspectSpecialization(unit)


	if not specID or specID == 0 then
		return
	end

	info.spec = specID
	if info.name == "" or info.name == UNKNOWN then
		info.name = GetUnitName(unit, true)
		info.nameWithoutRealm = UnitName(unit)
	end
	if info.level == 200 then
		local lvl = UnitLevel(unit)
		if lvl > 0 then
			info.level = lvl
		end
	end

	if UnitSpellHaste then
		info.spellHasteMult = 1/(1 + UnitSpellHaste(unit)/100)
	end

	wipe(info.talentData)
	wipe(info.itemData)

	GetSelectedTalentData(info, unit, true)
	local failed = GetEquippedItemData(info, unit, specID)

	self:DequeueInspect(guid, failed)
	info:SetupBar()
end

local enhancedSoulbindRowRenownLevel = {
	[1]  = { [1] = 63, [3] = 66, [5] = 68, [6] = 72, [8] = 73, [10] = 78 },
	[2]  = { [1] = 61, [3] = 64, [5] = 67, [6] = 70, [8] = 75, [10] = 79 },
	[3]  = { [1] = 62, [3] = 65, [5] = 69, [6] = 71, [8] = 74, [10] = 77 },
	[4]  = { [1] = 63, [3] = 66, [5] = 68, [6] = 72, [8] = 73, [10] = 78 },
	[5]  = { [1] = 61, [3] = 64, [5] = 67, [6] = 70, [8] = 75, [10] = 79 },
	[6]  = { [1] = 62, [3] = 65, [5] = 69, [6] = 71, [8] = 74, [10] = 77 },
	[7]  = { [1] = 63, [3] = 66, [5] = 68, [6] = 72, [8] = 73, [10] = 78 },
	[8]  = { [1] = 63, [3] = 66, [5] = 68, [6] = 72, [8] = 73, [10] = 78 },
	[9]  = { [1] = 61, [3] = 64, [5] = 67, [6] = 70, [8] = 75, [10] = 79 },
	[10] = { [1] = 62, [3] = 65, [5] = 69, [6] = 71, [8] = 74, [10] = 77 },
	[13] = { [1] = 61, [3] = 64, [5] = 67, [6] = 70, [8] = 75, [10] = 79 },
	[18] = { [1] = 62, [3] = 65, [5] = 69, [6] = 71, [8] = 74, [10] = 77 },
}

local function IsSoulbindRowEnhanced(soulbindID, row, renownLevel)
	local minLevel = enhancedSoulbindRowRenownLevel[soulbindID] and enhancedSoulbindRowRenownLevel[soulbindID][row]
	if minLevel then
		return renownLevel >= minLevel
	end
end

local function GetCovenantSoulbindData(info, list)
	wipe(info.shadowlandsData)

	local covenantID = C_Covenants.GetActiveCovenantID()
	if covenantID == 0 then
		return
	end

	local covenantSpellID = E.covenant_to_spellid[covenantID]
	info.shadowlandsData.covenantID = covenantID
	info.talentData[covenantSpellID] = "C"
	list[#list + 1] = "^C," .. covenantID

	local soulbindID = C_Soulbinds.GetActiveSoulbindID()
	if soulbindID == 0 then
		return
	end

	info.shadowlandsData.soulbindID = soulbindID
	list[#list + 1] = soulbindID

	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID)
	local nodes = soulbindData.tree and soulbindData.tree.nodes
	if not nodes then
		return
	end

	local renownLevel = C_CovenantSanctumUI.GetRenownLevel()
	for i = 1, #nodes do
		local node = nodes[i]
		if node.state == Enum.SoulbindNodeState.Selected then
			local conduitID, conduitRank, row, spellID = node.conduitID, node.conduitRank, node.row, node.spellID
			if conduitID ~= 0 then
				spellID = C_Soulbinds_GetConduitSpellID(conduitID, conduitRank)
				if IsSoulbindRowEnhanced(soulbindID, row, renownLevel) then
					conduitRank = conduitRank + 2
				end
				local rankValue = E.soulbind_conduits_rank[spellID] and (E.soulbind_conduits_rank[spellID][conduitRank]
				or E.soulbind_conduits_rank[spellID][1])
				if rankValue then
					info.talentData[spellID] = rankValue
					list[#list + 1] = format("%s:%s", spellID, rankValue)
				end
			elseif E.soulbind_abilities[spellID] then
				info.talentData[spellID] = 0
				list[#list + 1] = spellID
			end
		end
	end
end

function CM:InspectUser()
	local info = P.userInfo
	local specID

	if E.preCata then
		specID = info.raceID
	else
		local specIndex = GetSpecialization()

		if specIndex == 5 then
			return true
		end
		if specIndex then
			specID = GetSpecializationInfo(specIndex)
		end
	end

	if not specID or specID == 0 then
		return false
	end
	info.spec = specID

	wipe(info.talentData)
	wipe(info.itemData)

	local dataList = GetSelectedTalentData(info, "player")
	GetEquippedItemData(info, "player", specID, dataList)


	if E.isClassic or E.isBCC then
		local speed = UnitRangedDamage("player")
		if speed and speed > 0 then
			info.rangedWeaponSpeed = speed
			dataList[#dataList + 1] = -speed
		end
	else
		if E.postSL then
			GetCovenantSoulbindData(info, dataList)
		end
		info.spellHasteMult = 1/(1 + UnitSpellHaste("player")/100)
	end

	local serializedData = table.concat(dataList, ","):gsub(",%^", "^")
	local compressedData = LibDeflate:CompressDeflate(serializedData)
	local encodedData = LibDeflate:EncodeForWoWAddonChannel(compressedData)
	self.serializedSyncData = encodedData


	if P.groupInfo[info.guid] then
		CM:RefreshCooldownSyncIDs(info)
		info:SetupBar()
		CM:AssignSpellIDsToCooldownSyncIDs(info)
	end

	return true
end
