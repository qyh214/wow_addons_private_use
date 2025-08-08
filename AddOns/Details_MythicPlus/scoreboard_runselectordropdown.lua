
---@type details
---@diagnostic disable-next-line: undefined-field
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon
local _ = nil
local L = detailsFramework.Language.GetLanguageTable(addonName)
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

function addon.CreateRunSelectorDropdown(readyFrame)
    local buildRunInfoListFromCompressed = function()
        ---@type dropdownoption[]
        local runInfoList = {}

        local headers = addon.Compress.GetHeaders()

        --get the current run showing
        local selectedRunIndex = addon.GetSelectedRunIndex()
        local playerName = UnitName("player")

        for i = 1, #headers do
            local thisHeader = headers[i]
            local isPlayerCharacterInThisRun = true

            local playersInThisRun = thisHeader.groupMembers
            if (playersInThisRun) then
                isPlayerCharacterInThisRun = playersInThisRun[playerName] and true or false
            end

            local labelContent = table.concat(addon.Compress.GetDropdownRunDescription(thisHeader), "@")

            ---@type dropdownoption
            local option = {
                label = labelContent,
                value = i,
                onclick = function()
                    addon.SetSelectedRunIndex(i)
                end,
                icon = [[Interface\AddOns\Details_MythicPlus\Assets\Images\sandglass_icon.png]],
                iconsize = {18, 18},
                texcoord = {0, 1, 0, 1},
                iconcolor = {1, 1, 1, 0.7},
                color = isPlayerCharacterInThisRun and "white" or "gray",
            }

            if (i == selectedRunIndex) then
                option.statusbar = [[Interface\AddOns\Details\images\bar_serenity]]
                option.statusbarcolor = {0.4, 0.4, 0, 0.5}
                option.color = "yellow"
            end

            runInfoList[#runInfoList+1] = option
        end

        return runInfoList
    end

    local runInfoDropdown = detailsFramework:CreateDropDown(readyFrame, buildRunInfoListFromCompressed, addon.GetSelectedRunIndex(), addon.templates.dropdownRunSelector.width, addon.templates.dropdownRunSelector.height, "selectRunInfoDropdown", "DetailsMythicPlusRunSelectorDropdown", detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
    runInfoDropdown:SetPoint("right", readyFrame.ConfigButton, "left", -3, 0)
    readyFrame.RunInfoDropdown = runInfoDropdown
    runInfoDropdown:UseSimpleHeader(true)
    runInfoDropdown:SetMenuSize(nil, addon.templates.dropdownRunSelector.dropdownHeight)

    runInfoDropdown.OnCreateOptionFrame = function(dropdown, optionFrame, optionTable)
        if (not optionFrame.label2) then
            optionFrame.label2 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
            optionFrame.label3 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
            optionFrame.label4 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
            optionFrame.label5 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
            optionFrame.label6 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")

            optionFrame.label2:SetPoint("left", optionFrame, "left", 220, 0)
            optionFrame.label3:SetPoint("left", optionFrame, "left", 250, 0)
            optionFrame.label4:SetPoint("left", optionFrame, "left", 295, 0)
            optionFrame.label5:SetPoint("left", optionFrame, "left", 325, 0)
            optionFrame.label6:SetPoint("left", optionFrame, "left", 410, 0)

            local fontFace, fontSize, fontFlags = optionFrame.label:GetFont()
            optionFrame.label2:SetFont(fontFace, fontSize, fontFlags)
            optionFrame.label3:SetFont(fontFace, fontSize, fontFlags)
            optionFrame.label4:SetFont(fontFace, fontSize, fontFlags)
            optionFrame.label5:SetFont(fontFace, fontSize, fontFlags)
            optionFrame.label6:SetFont(fontFace, fontSize, fontFlags)
            optionFrame.label2:SetTextColor(optionFrame.label:GetTextColor())
            optionFrame.label3:SetTextColor(optionFrame.label:GetTextColor())
            optionFrame.label4:SetTextColor(optionFrame.label:GetTextColor())
            optionFrame.label5:SetTextColor(optionFrame.label:GetTextColor())
            optionFrame.label6:SetTextColor(optionFrame.label:GetTextColor())
        end
    end

    runInfoDropdown.OnUpdateOptionFrame = function(dropdown, optionFrame, optionTable)
        ---@type fontstring
        local label1 = optionFrame.label
        local text = label1:GetText()

        local dungeonName, keyLevel, runTime, keyUpgradeLevels, timeString, mapId, dungeonId, onTime, altName = text:match("(.-)@(%d+)@(%d+)@(%d+)@(.+)@(%d+)@(%d+)@(%d+)@(.+)")

        label1:SetText(dungeonName)
        optionFrame.label2:SetText(keyLevel)
        optionFrame.label3:SetText(detailsFramework:IntegerToTimer(runTime))

        if (tonumber(keyUpgradeLevels) > 0) then
            optionFrame.label4:SetText("+" .. keyUpgradeLevels)
        else
            optionFrame.label4:SetText("")
        end

        optionFrame.label5:SetText(timeString)

        optionFrame.label6:SetText(altName ~= "0" and altName or "") --when no altName is found, it returns "0"
    end

    hooksecurefunc(runInfoDropdown, "Selected", function(self, thisOption)
        local dungeonName, keyLevel, runTime, keyUpgradeLevels, timeString, mapId, dungeonId, onTime, altName = thisOption.label:match("(.-)@(%d+)@(%d+)@(%d+)@(.+)@(%d+)@(%d+)@(%d+)@(.+)")
        onTime = "1" and true or false

        dungeonId = tonumber(dungeonId)

        if (dungeonId == 370) then
            dungeonName = dungeonName:gsub("^.+%-", "")
        end

        --limit dungeon name to 22 letters
        local resizedDungeonName = dungeonName:sub(1, 22)

        self.label:SetText(resizedDungeonName .. " +" .. keyLevel .. " (" .. timeString .. ")")
    end)
    --DropDownMetaFunctions:Selected(thisOption)

    runInfoDropdown.widget:HookScript("OnMouseDown", function(self)

    end)
end
