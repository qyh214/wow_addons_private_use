local W, F, L = unpack(select(2, ...))
local EP = W:NewModule("EnemyProgress", "AceHook-3.0")

local _G = _G

local format = format
local select = select
local tonumber = tonumber

local GameTooltip = _G.GameTooltip
local GetInstanceInfo = GetInstanceInfo

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local TooltipDataProcessor_AddTooltipPostCall = TooltipDataProcessor.AddTooltipPostCall

local Enum_TooltipDataType_Unit = Enum.TooltipDataType.Unit

local icon1 = F.GetIconString(132147, 14)
local icon2 = F.GetIconString(5926319, 14)

local function isWindToolsLoaded()
	if C_AddOns_IsAddOnLoaded("ElvUI_WindTools") then
		local E = _G.ElvUI and _G.ElvUI[1]
		if E and E.private and E.private.WT and E.private.WT.tooltips and E.private.WT.tooltips.objectiveProgress then
			return true
		end
	end
end

function EP:AddEnemyProgress(tt, data)
	if not _G.MDT or not _G.MDT.GetEnemyForces or not self.db or not self.db.enable then
		return
	end

	local difficultyID = select(3, GetInstanceInfo())
	if not difficultyID or difficultyID ~= 8 then
		return
	end

	if
		isWindToolsLoaded()
		or not tt
		or not tt == _G.GameTooltip and not tt.NumLines
		or tt:NumLines() == 0
		or tt.__windEnemyProgress
	then
		return
	end

	local accuracy = self.db.accuracy
	local npcID = data and data.guid and select(6, strsplit("-", data.guid))
	if not npcID or npcID == "" then
		return
	end

	tt.__windEnemyProgress = true
	local count, max = _G.MDT:GetEnemyForces(tonumber(npcID))

	if count and max and count > 0 and max > 0 then
		local left = format("%s |cff00d1b2%s|r |cffffffff-|r |cffffdd57%s|r", icon1, count, max)
		local right = format("%s |cff209cee%s|r|cffffffff%%|r", icon2, F.Round(100 * count / max, accuracy))

		tt:AddDoubleLine(left, right)
		tt:Show()
	end
end

function EP:ProfileUpdate()
	self.db = W.db.enemyProgress

	if self.db and self.db.enable then
		TooltipDataProcessor_AddTooltipPostCall(Enum_TooltipDataType_Unit, function(...)
			self:AddEnemyProgress(...)
		end)

		GameTooltip:HookScript("OnTooltipCleared", function(tt)
			tt.__windEnemyProgress = nil
		end)
	end
end

EP.OnInitialize = EP.ProfileUpdate
