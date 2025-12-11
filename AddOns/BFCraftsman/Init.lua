---@class BFC
local BFC = select(2, ...)
BFC.name = "BFCraftsman"
BFC.channelName = "BFChannel"
BFC.channelID = 0
BFC.minVersion = 7

_G.BFCraftsman = BFC

local L = BFC.L

---@type AbstractFramework
local AF = _G.AbstractFramework

AF.RegisterAddon(BFC.name, L["BFCraftsman"])


---------------------------------------------------------------------
-- functions
---------------------------------------------------------------------
function BFC.IsStale(lastUpdate)
    return time() - lastUpdate > 310 -- 5 minutes
end

local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_DeactivateChat = ChatEdit_DeactivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend

function BFC.SendWhisper(name)
    local editBox = ChatEdit_ChooseBoxForSend()
    ChatEdit_DeactivateChat(editBox)
    ChatEdit_ActivateChat(editBox)
    editBox:SetText("/w " .. name .. " ")
end

---------------------------------------------------------------------
-- events
---------------------------------------------------------------------
AF.AddEventHandler(BFC)
BFC:RegisterEvent("ADDON_LOADED", function(_, _, addon)
    if addon == BFC.name then
        BFC.version = AF.GetAddOnMetadata("Version")
        BFC.versionNum = tonumber(BFC.version:match("%d+"))

        if type(BFC_DB) ~= "table" then
            BFC_DB = {
                scale = 1,
                publish = {
                    mode = "disabled",
                    tagline = "",
                    craftingFee = nil,
                    characters = {
                        -- {
                        --     name = (string),
                        --     class = (string),
                        --     prof1 = {
                        --         enabled = (boolean),
                        --         id = (number),
                        --         lastScanned = (number),
                        --         recipes = {},
                        --         allRecipesLearned = false,
                        --     },
                        --     prof2 = {...},
                        -- },
                    },
                },
                list = {
                    -- [id] = {
                    --     name = (string),
                    --     class = (string),
                    --     tagline = (string),
                    --     craftingFee = (number),
                    --     recipes = {
                    --         [recipeID] = {
                    --             {name, class},
                    --         },
                    --     },
                    --     professions = {
                    --         [skillLineID] = {
                    --             {name, class},
                    --         },
                    --     },
                    --     lastUpdate = (number),
                    -- }
                },
                favorite = {},
                blacklist = {},
                showStale = false,
                showBlacklisted = false,
                -- whisperTemplate = L["WHISPER_TEMPLATE"],
                minimap = {},
            }
        end
        BFCMainFrame:SetScale(BFC_DB.scale)

        if type(BFC_DB.whisperTemplate) ~= "string" then
            BFC_DB.whisperTemplate = L["WHISPER_TEMPLATE"]
        end

        ---------------------------------------------------------------------
        -- revise
        if type(BFC_DB.publish.enabled) == "boolean" then
            BFC_DB.publish.mode = BFC_DB.publish.enabled and "always" or "disabled"
            BFC_DB.publish.enabled = nil
        end

        if type(BFC_DB.publish.currentServerOnly) ~= "boolean" then
            BFC_DB.publish.currentServerOnly = true
        end
        ---------------------------------------------------------------------

        ---------------------------------------------------------------------
        -- validate list
        for id, t in pairs(BFC_DB.list) do
            if type(id) ~= "string" or #id ~= 32 or type(t.professions) ~= "table" or type(t.recipes) ~= "table" then
                BFC_DB.list[id] = nil
            else
                -- t.inInstance = nil -- reset in instance status
                t._lastServicesUpdate = nil
            end
        end
        -- validate publish
        for _, t in pairs(BFC_DB.publish.characters) do
            if type(t.prof1.enabled) ~= "boolean" then t.prof1.enabled = true end
            if type(t.prof2.enabled) ~= "boolean" then t.prof2.enabled = true end
        end
        ---------------------------------------------------------------------

        -- minimap button
        AF.NewMinimapButton(BFC.name, "Interface\\AddOns\\BFCraftsman\\BFC", BFC_DB.minimap, BFC.ToggleMainFrame, L["BFCraftsman"])

    elseif addon == "Blizzard_ProfessionsCustomerOrders" then
        -- title container button
        local button1 = AF.CreateButton(ProfessionsCustomerOrdersFrame.TitleContainer, nil, "accent_hover", 20, 20)
        AF.SetPoint(button1, "RIGHT", ProfessionsCustomerOrdersFrameCloseButton, "LEFT", -1, 0)
        AF.SetTooltip(button1, "TOP", 0, 5, L["BFCraftsman"])
        button1:SetTexture("Interface\\AddOns\\BFCraftsman\\BFC")
        button1:SetOnClick(BFC.ToggleMainFrame)

        if not BFC_DB.orderFrameHelpViewed then
            AF.ShowHelpTip({
                widget = button1,
                position = "TOP",
                text = L["Click this button to open BFCraftsman"],
                glow = true,
                callback = function()
                    BFC_DB.orderFrameHelpViewed = true
                end,
            })
        end

        -- order form button
        local button2 = AF.CreateButton(ProfessionsCustomerOrdersFrame.Form, L["Find Craftsmen"], "accent", 120, 20)
        AF.SetPoint(button2, "BOTTOMRIGHT", ProfessionsCustomerOrdersFrame.Form, "TOPRIGHT", -2, 7)
        button2:SetOnClick(BFC.ShowListFrame)
        button2:SetOnHide(BFC.HideListFrame)

        if not BFC_DB.formFrameHelpViewed then
            AF.ShowHelpTip({
                widget = button2,
                position = "RIGHT",
                text = L["Click this button to show craftsmen list"],
                glow = true,
                callback = function()
                    BFC_DB.formFrameHelpViewed = true
                end,
            })
        end

        -- hooksecurefunc(Professions, "CreateNewOrderInfo", function(...)
        --     print(...)
        -- end)

        -- hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, "Init", function(_, order)
        --     -- texplore(order)
        --     local recipeID = order.spellID
        --     -- texplore(C_TradeSkillUI.GetRecipeInfo(recipeID))
        --     texplore(C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID))
        -- end)

        -- prepare order info
        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, "InitSchematic", BFC.HandleOrderData)

    elseif addon == "Blizzard_Professions" then
        -- title container button
        local button = AF.CreateButton(ProfessionsFrame.TitleContainer, nil, "accent_hover", 20, 20)
        AF.SetTooltip(button, "TOP", 0, 5, L["BFCraftsman"])
        button:SetTexture("Interface\\AddOns\\BFCraftsman\\BFC")
        button:SetOnClick(BFC.ToggleMainFrame)

        if C_AddOns.IsAddOnLoaded("TradeSkillMaster") then
            AF.SetPoint(button, "RIGHT", ProfessionsFrame.MaximizeMinimize, "LEFT", -65, 0)
        else
            AF.SetPoint(button, "RIGHT", ProfessionsFrame.MaximizeMinimize, "LEFT", -1, 0)
        end

        if not BFC_DB.professionsFrameHelpViewed then
            AF.ShowHelpTip({
                widget = button,
                position = "TOP",
                text = L["Click this button to open BFCraftsman"],
                glow = true,
                callback = function()
                    BFC_DB.professionsFrameHelpViewed = true
                end,
            })
        end
    end
end)

local BNGetInfo = BNGetInfo
BFC:RegisterEvent("PLAYER_LOGIN", function()
    -- prepare
    local bTag = select(2, BNGetInfo())
    if bTag then
        BFC.battleTag = AF.Libs.MD5.sumhexa(bTag)
    end

    BFC.UpdateLearnedProfessions()
    BFC.UpdateLearnedRecipes()
    BFC.UpdateSendingData()
    BFC.ScheduleNextSync(true)

    -- check BigFootCommonweal
    if C_AddOns.IsAddOnLoaded("BigFootCommonweal") then
        local text = L["BFCraftsman is not compatible with %s.\nDisable it?"]:format(AF.WrapTextInColor(LOCALE_zhCN and "大脚公益助手" or "BigFootCommonweal", "accent"))
        AF.ShowGlobalDialog(text, function()
            C_AddOns.DisableAddOn("BigFootCommonweal")
            ReloadUI()
        end)
    end
end)

---------------------------------------------------------------------
-- channel
---------------------------------------------------------------------
AF.UnregisterChannel("BFCraftsman") -- leave old channel
AF.RegisterTemporaryChannel(BFC.channelName)
AF.BlockChatConfigFrameInteractionForChannel(BFC.channelName)
AF.RegisterCallback("AF_JOIN_TEMP_CHANNEL", function(_, channelName, channelID)
    if channelName == BFC.channelName then
        BFC.channelID = channelID
        BFC.BroadcastVersion()
        BFC.UpdateInstanceStatus()
    end
end)

---------------------------------------------------------------------
-- slash
---------------------------------------------------------------------
SLASH_BFCRAFTSMAN1 = "/bfc"
SlashCmdList["BFCRAFTSMAN"] = function(msg)
    if msg == "reset" then
        BFC_DB = nil
        ReloadUI()
    elseif msg == "clear list" then
        wipe(BFC_DB.list)
        BFC.UpdateList()
    elseif msg == "clear favorite" then
        wipe(BFC_DB.favorite)
        BFC.UpdateList()
    elseif msg == "clear blacklist" then
        wipe(BFC_DB.blacklist)
        BFC.UpdateList()

    --[==[@debug@
    elseif msg == "test" then
        local validSkillLine = {164, 165, 171, 197, 202, 333, 773, 755}
        for i = 1, 30 do
            local class = AF.GetClassFile(random(1, 13))

            BFC_DB.list["Player" .. i] = {
               name = "Player" .. i,
               class = class,
               tagline = "This is a tagline " .. i,
               craftingFee = random(1000, 10000),
               lastUpdate = time() - random(1, 10000),
               recipes = {},
               professions = {},
            }

            for j = 1, random(1, 2) do
                BFC_DB.list["Player" .. i]["professions"][validSkillLine[random(1, 8)]] = {{"Player" .. i, class}}
            end
        end
        BFC.UpdateList()
    --@end-debug@]==]

    else
        BFC.ToggleMainFrame()
    end
end

---------------------------------------------------------------------
-- addon button
---------------------------------------------------------------------
function BFC_OnAddonCompartmentClick()
    BFC.ToggleMainFrame()
end