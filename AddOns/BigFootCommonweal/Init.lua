---@class BFC
local BFC = select(2, ...)
_G.BFC = BFC

---------------------------------------------------------------------
-- vars
---------------------------------------------------------------------
BFC.name = ...
BFC.displayedName = "大脚公益助手"

---------------------------------------------------------------------
-- shared
---------------------------------------------------------------------
function BFC.Copy(t)
    local newTbl = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            newTbl[k] = BFC.Copy(v)
        else
            newTbl[k] = v
        end
    end
    return newTbl
end

---------------------------------------------------------------------
-- font
---------------------------------------------------------------------
local font = CreateFont("BFC_FONT_WHITE")
font:SetFont("Fonts/ARKai_T.ttf", 14, "")
font:SetShadowColor(0, 0, 0, 1)
font:SetShadowOffset(1, -1)

---------------------------------------------------------------------
-- minimap icon
---------------------------------------------------------------------
local icon = LibStub("LibDBIcon-1.0")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("BFC_LDB", {
    type = "launcher",
	icon = "Interface\\AddOns\\BigFootCommonweal\\bfc_icon.tga",
	OnClick = function(clickedframe, button)
        BFC.ToggleMainFrame()
	end,
    OnTooltipShow = function(self)
        self:AddLine(BFC.displayedName)
    end,
})

---------------------------------------------------------------------
-- process data
---------------------------------------------------------------------
BFC.LRI = LibStub("LibRealmInfoCN")
BFC.loadedCraftsman = {
    updateTime = 0,
    data = {},
}

local function LoadData()
    wipe(BFC.loadedCraftsman.data)
    local serverUpdateTime = 0
    for server, t in pairs(BFCCraftsman.data) do
        if BFC.LRI.IsConnectedRealm(server) then
        -- if server == "燃烧之刃" then
            serverUpdateTime = max(serverUpdateTime, t.updateTime)
            for _, c in pairs(t.list) do
                tinsert(BFC.loadedCraftsman.data, c)
            end
        end
    end
    BFC.loadedCraftsman.count_total = BFC.loadedCraftsman.count_total or #BFC.craftsman.data
    BFC.loadedCraftsman.count_server = #BFC.loadedCraftsman.data
    BFC.loadedCraftsman.updateTime = max(BFCCraftsman.localUpdateTime, serverUpdateTime)

    BFC.craftsman = nil
    collectgarbage()
end

local function IsValid(t)
    return t.serverName and t.serverName ~= ""
        and t.gameCharacterName and t.gameCharacterName ~= ""
        and t.title and t.categoryName
end

function BFC.ProcessLocalCraftsmanData()
    if not BFC.craftsman then return end
    if BFC.craftsman.updateTime > BFCCraftsman.localUpdateTime then
        BFCCraftsman.localUpdateTime = BFC.craftsman.updateTime -- overall updateTime
        wipe(BFCCraftsman.data)

        for _, t in pairs(BFC.craftsman.data) do
            if IsValid(t) then
                if not BFCCraftsman.data[t.serverName] then
                    BFCCraftsman.data[t.serverName] = {
                        updateTime = BFC.craftsman.updateTime, -- server updateTime
                        list = {}, -- server data
                    }
                end
                tinsert(BFCCraftsman.data[t.serverName].list, t)
            end
        end

        print("|cffffff00[" .. BFC.displayedName .. "]|r 工匠数据已更新 |cffababab" .. date("%Y/%m/%d %H:%M", BFCCraftsman.localUpdateTime) .. "|r")
    end
    LoadData()
end

function BFC.ProcessImportedCraftsmanData(data, updateTime)
    local processed = {}

    -- local total, valid = 0, 0
    for _, t in pairs(data) do
        -- total = total + 1
        if IsValid(t) then
            -- valid = valid + 1
            if not processed[t.serverName] then
                processed[t.serverName] = true
                -- overwrite old
                BFCCraftsman.data[t.serverName] = {
                    updateTime = updateTime, -- server updateTime
                    list = {}, -- server data
                }
            end
            tinsert(BFCCraftsman.data[t.serverName].list, t)
        end
    end
    -- print("Total:"..total..", Valid:"..valid)
    LoadData()
end

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](...)
end)

function eventFrame.ADDON_LOADED(name)
    if name == BFC.name then
        if type(BFCConfig) ~= "table" then BFCConfig = {} end

        if type(BFCConfig.minimap) ~= "table" then
            BFCConfig.minimap = {
                hide = false,
            }
        end
        icon:Register(BFC.name, ldb, BFCConfig.minimap)

        if type(BFCCraftsman) ~= "table" then
            BFCCraftsman = {
                localUpdateTime = 0,
                data = {
                    -- (serverName) = {
                    --     updateTime = 0,
                    --     list = {},
                    -- },
                },
                favorites = {},
            }
        end

        BFC_MainFrame:SetTitle(BFC.displayedName .. " |cffababab" .. C_AddOns.GetAddOnMetadata(BFC.name, "Version"))

    elseif name == "Blizzard_ProfessionsCustomerOrders" then
        eventFrame:UnregisterEvent("ADDON_LOADED")
        -- order browsing
        local button1 = CreateFrame("Button", "BFC_SearchCraftsmanButton", ProfessionsCustomerOrdersFrame.BrowseOrders, "UIPanelButtonTemplate")
        button1:SetPoint("TOPLEFT", ProfessionsCustomerOrdersFrame.BrowseOrders, 70, -38)
        button1:SetSize(100, 22)
        button1:SetText("工匠列表")
        button1:SetScript("OnClick", function()
            BFC.ShowMainFrame()
        end)

        -- order form
        local button2 = CreateFrame("Button", "BFC_SearchCraftsmanButton", ProfessionsCustomerOrdersFrame.Form, "UIPanelButtonTemplate")
        button2:SetPoint("BOTTOMRIGHT", ProfessionsCustomerOrdersFrame.Form, "TOPRIGHT", 0, 5)
        button2:SetSize(100, 22)
        button2:SetText("查询工匠")
        button2:SetScript("OnClick", function()
            BFC.ShowMainFrame()
            BFC.ShowCraftsmanFrame(ProfessionsCustomerOrdersFrame.Form.RecipeName:GetText())
        end)
    end
end

function eventFrame:PLAYER_LOGIN()
    -- BFC.server = GetNormalizedRealmName()
    BFC.ProcessLocalCraftsmanData()
end

---------------------------------------------------------------------
-- slash
---------------------------------------------------------------------
SLASH_BFCRAFTSMAN1 = "/bfc"
SlashCmdList["BFCRAFTSMAN"] = function(text)
    local command, rest = text:match("^(%S*)%s*(.-)$")
    command = strlower(command or "")
    rest = strlower(rest or "")

    if command == "reset" then
        BFCConfig = nil
        BFCCraftsman = nil
        ReloadUI()
    else
        BFC.ShowMainFrame()
    end
end