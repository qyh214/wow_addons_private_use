local AddOnName, WDH = ...
local L, B, C, DB = WDH.L, WDH.Base, WDH.Config, WDH.DataBase
local EP = WDH:NewModule("EnemyProgress", "AceHook-3.0", "AceEvent-3.0")
local LOP = LibStub("LibObjectiveProgress-1.0")

DB.defaults.profile.modules.EnemyProgress = {
	enable = false,
}

C.ModulesOrder.EnemyProgress = 21
C.ModulesOption.EnemyProgress = {
    name = L["Enemy Progress"],
	type = "group",
	childGroups = "tree",
    args = {
		general = {
			order = 1,
			name = L["General"],
			type = "group",
			inline = true,
			args = {
				enable = {
					order = 1,
					name = L["Enable"],
					desc = L["Enables / disables the module"],
					type = "toggle",
					width = "full",
					set = function(info,value)
						EP.db.enable = value
						if EP.db.enable then EP:Enable() else EP:Disable() end
					end,
					get = function(info) return EP.db.enable end
				},
			}
		},
    }
}

function EP.OnTooltipSetUnit(TT)
    if not EP.db.enable or not TT or not TT.NumLines or TT:NumLines() == 0 then return end

    local name, unit = TT:GetUnit()
    if not unit then return end

    local GUID = UnitGUID(unit)
    if not GUID or GUID == "" then return end

    local npcID = select(6, ("-"):split(GUID))
    if not npcID or npcID == "" then return end

    local weightsTable = LOP:GetNPCWeightByCurrentQuests(tonumber(npcID))
    if not weightsTable then return end

    for questID, npcWeight in next, weightsTable do
        local questTitle = C_TaskQuest.GetQuestInfoByQuestID(questID)
        for j = 1, TT:NumLines() do
            if _G["GameTooltipTextLeft" .. j] and _G["GameTooltipTextLeft" .. j]:GetText() == questTitle then
                _G["GameTooltipTextLeft" .. j]:SetText(_G["GameTooltipTextLeft" .. j]:GetText() .. " - " .. tostring(math.floor((npcWeight * 100) + 0.5) / 100) .. "%")
            end
        end
    end
end

function EP:OnInitialize()
    self.Version = B.Version
    self.db = DB.profile.modules.EnemyProgress
    GameTooltip:HookScript("OnTooltipSetUnit", EP.OnTooltipSetUnit)
end

function EP:RefreshOption()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("WindDungeonHelper")
end
