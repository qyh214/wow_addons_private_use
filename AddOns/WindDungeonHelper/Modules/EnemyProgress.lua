local W, F, L = unpack(select(2, ...))
local EP = W:NewModule("EnemyProgress", "AceHook-3.0")
local LOP = LibStub("LibObjectiveProgress-1.0")

local _G = _G

local floor = floor
local format = format
local next = next
local select = select
local tonumber = tonumber
local tostring = tostring

local GameTooltip = _G.GameTooltip
local IsAddOnLoaded = IsAddOnLoaded
local UnitGUID = UnitGUID

local C_QuestLog_GetInfo = C_QuestLog.GetInfo
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local TooltipDataProcessor_AddTooltipPostCall = TooltipDataProcessor.AddTooltipPostCall

local Enum_TooltipDataType_Unit = Enum.TooltipDataType.Unit

local function isWindToolsLoaded()
	if IsAddOnLoaded("ElvUI_WindTools") then
		local E = _G.ElvUI and _G.ElvUI[1]
		if E and E.private and E.private.WT and E.private.WT.tooltips and E.private.WT.tooltips.objectiveProgress then
			return true
		end
	end
end

function EP:AddObjectiveProgress(tt, data)
	if not self.db or not self.db.enable then
		return
	end

	if isWindToolsLoaded() or not tt or not tt == _G.GameTooltip and not tt.NumLines or tt:NumLines() == 0 then
		return
	end

	local npcID = select(6, strsplit("-", data.guid))

	if not npcID or npcID == "" then
		return
	end

	local weightsTable = LOP:GetNPCWeightByCurrentQuests(tonumber(npcID))
	if not weightsTable then
		return
	end

	for questID, npcWeight in next, weightsTable do
		local info = C_QuestLog_GetInfo(C_QuestLog_GetLogIndexForQuestID(questID))
		for i = 1, tt:NumLines() do
			local text = _G["GameTooltipTextLeft" .. i]
			if text and text:GetText() == info.title then
				text:SetText(text:GetText() .. format(" + %s%%", F.Round(npcWeight, self.db.accuracy)))
			end
		end
	end
end

function EP:ProfileUpdate()
	self.db = W.db.enemyProgress

	if self.db and self.db.enable then
		TooltipDataProcessor_AddTooltipPostCall(
			Enum_TooltipDataType_Unit,
			function(...)
				self:AddObjectiveProgress(...)
			end
		)
	end
end

EP.OnInitialize = EP.ProfileUpdate
