local ns = select(2, ...)
local W, F, L = unpack(ns)
local LibStub = _G.LibStub
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local ADBO = LibStub("AceDBOptions-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBI = LibStub("LibDBIcon-1.0")

local CreateFrame = CreateFrame
local Settings = Settings

local C_Timer_After = C_Timer.After

local titleImageConfig = F.GetTitleSize(0.8)

local options = {
    type = "group",
    name = "",
    childGroups = "tab",
    args = {
        beforeLogo = {
            order = 1,
            type = "description",
            fontSize = "small",
            name = " ",
            width = "full"
        },
        logo = {
            order = 2,
            type = "description",
            name = "",
            image = function()
                return W.Media.Textures.title
            end,
            imageWidth = titleImageConfig.width(),
            imageHeight = titleImageConfig.height(),
            imageCoords = F.GetTitleTexCoord
        },
        afterLogo = {
            order = 3,
            type = "description",
            fontSize = "small",
            name = "|cffff0000" ..
                L["I've just returned to World of Warcraft, and the next data update will be for TWW Season 1!"] .. "|r",
            width = "full"
        }
    }
}

ns[5] = options.args

function W:BuildOptions()
    local name = "WindDungeonHelper"
    options.args.profiles = ADBO:GetOptionsTable(W.Database)
    options.args.profiles.order = 1000

    ACR:RegisterOptionsTable(name, options)
    self.OptionFrame, self.OptionName = ACD:AddToBlizOptions(name, W.AddonName)
    self.DataBroker =
        LDB:NewDataObject(
        L["Wind Dungeon Helper"],
        {
            type = "data source",
            text = "WDH",
            icon = "Interface\\Icons\\Achievement_challengemode_gold",
            OnClick = function()
                W:ShowOptions()
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine("|cff00a8ff" .. L["Wind Dungeon Helper"] .. "|r")
                tooltip:AddLine(L["Click to toggle config window."])
            end
        }
    )

    LDBI:Register(L["Wind Dungeon Helper"], self.DataBroker, self.db.minimapIcon)
end

function W:ShowOptions()
    Settings.OpenToCategory(self.OptionName)
end

_G.WindDungeonHelper_OnAddonCompartmentClick = function()
    W:ShowOptions()
end

function W:RefreshOptions()
    ACR:NotifyChange("WindDungeonHelper")
end

function W:RefreshOptionsAfter(second)
    C_Timer_After(second, self.RefreshOptions)
end
