
--localization
L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)
local _, _MS = ...
local _QR = _MS.QUICKRATING
local _DC = _MS.DATACORE
local _CD = _MS.CONSTDATA
local _UI = _MS.UI
local _OP = _UI.OPTION
local MS = _MS.addon


MSDB = {}
_MS.MSDB = MSDB


function Minesweeperr:loadSavedData()
    _MS.MSDB = MSDB
    _MS.DB = {}
    _CD.mainAchiID = self.db.profile.mainAchiID
    _CD.childAchi1ID = self.db.profile.childAchi1ID
    _CD.childAchi2ID = self.db.profile.childAchi2ID
    _CD.childAchi3ID = self.db.profile.childAchi3ID
    _CD.autoShowQC = self.db.profile.autoShow
end



local msLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MS", {
    type = "data source",
    text = "Minesweeperr",
    icon = "Interface\\Icons\\INV_Chest_Cloth_17",
    OnClick = function() _UI.mainFrame:Show() end,
    OnTooltipShow = function(tooltip)
		tooltip:AddLine("Minesweeperr")
		tooltip:Show()
	end
})
local icon = LibStub("LibDBIcon-1.0")


tinsert(UISpecialFrames, "MSMainFrame");

function Minesweeperr:CommandTheMS()
    _UI.mainFrame:Show()
end

function Minesweeperr:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("msACEDB", {
        profile = {
            minimap = {
                hide = false,
            },
            mainAchiID = 14145,
            childAchi1ID = 13781,
            childAchi2ID = 13449,
            childAchi3ID = 14043,
            autoShow = true,
        },
    })

    self:loadSavedData()

    icon:Register("MS", msLDB, self.db.profile.minimap)
    self:RegisterChatCommand("ms", "CommandTheMS")


    LibStub("AceConfig-3.0"):RegisterOptionsTable("Minesweeperr", MS.optionsTable)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Minesweeperr", "Minesweeperr")

    _UI:createMainFrame()
    _UI:createHistoryFrame()
    _DC:Initial()
    _UI:refreshInfoPanel("player")
    _UI.createQuickRatingFrame()
end