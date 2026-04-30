local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local Favorites = KeystoneLoot.Favorites;
local Character = KeystoneLoot.Character;
local L = KeystoneLoot.L;

local HIGHLIGHTS = {
    { key = "settings.highlighting.crit",        label = ITEM_MOD_CRIT_RATING_SHORT },
    { key = "settings.highlighting.haste",       label = ITEM_MOD_HASTE_RATING_SHORT },
    { key = "settings.highlighting.mastery",     label = ITEM_MOD_MASTERY_RATING_SHORT },
    { key = "settings.highlighting.versatility", label = ITEM_MOD_VERSATILITY },
    { key = "settings.highlighting.noStats",     label = L["No stats"] },
};

local function GetColoredCharacterName()
    local info = Character:ParseKey(Character:GetSelectedKey());
    if (not info) then
        return "";
    end

    local classFile = Character:GetClassFile(info.classId);
    local classColor = C_ClassColor.GetClassColor(classFile);
    return classColor:WrapTextInColorCode(info.name);
end

local function GetColoredCharacterLabel(data)
    local classColor = C_ClassColor.GetClassColor(data.classFile);
    return classColor:WrapTextInColorCode(data.name);
end

local function HandleImportResult(success, result, skippedSpecs, overwrite)
    if (skippedSpecs) then
        print(RED_FONT_COLOR:WrapTextInColorCode(L["Some specs were skipped - import string belongs to a different class."]));
    end

    if (success) then
        local suffix = overwrite and L[" (overwritten)"] or "";
        print(YELLOW_FONT_COLOR:WrapTextInColorCode(string.format(L["%d |4favorite:favorites; imported%s."], result, suffix)));
        DB:Set("filters.slotId", -1);
    else
        print(YELLOW_FONT_COLOR:WrapTextInColorCode(string.format(L["Import failed - %s"], tostring(result))));
    end
end

StaticPopupDialogs.KEYSTONELOOT_DELETE_CHARACTER = {
    text = L["Delete all data for %s?"],
    button1 = DELETE,
    button2 = CANCEL,
    OnAccept = function(self, data)
        local wasSelected = data.key == Character:GetSelectedKey();

        if (Character:Delete(data.key) and wasSelected) then
            local key = Character:GetKey();
            DB:Set("ui.selectedCharacterKey", key);

            local info = Character:ParseKey(key);
            if (info) then
                DB:Set("filters.classId", info.classId);
                DB:Set("filters.specId", 0);
            end
        end
    end,
    timeout = 0,
    exclusive = true,
    whileDead = true,
    hideOnEscape = true
};


StaticPopupDialogs.KEYSTONELOOT_EXPORT = {
    text = L["Export favorites of %s"],
    button1 = CLOSE,
    hasEditBox = 1,
    editBoxWidth = 450,
    OnShow = function(self)
        self:GetEditBox():SetText(Favorites:Export());
        self:GetEditBox():HighlightText();
        self:GetEditBox():SetFocus();
    end,
    OnHide = function(self, data)
        ChatFrameUtil.FocusActiveWindow();
        self:GetEditBox():SetText("");
    end,
    timeout = 0,
    exclusive = true,
    whileDead = true,
    hideOnEscape = true
};

StaticPopupDialogs.KEYSTONELOOT_IMPORT = {
    text = L["Import favorites for %s\nPaste import string here:"],
    button1 = L["Merge"],
    button2 = L["Overwrite"],
    button3 = CANCEL,
    hasEditBox = 1,
    editBoxWidth = 450,
    OnAccept = function(self)
        local text = self:GetEditBox():GetText();
        local success, result, skippedSpecs = Favorites:Import(text, false);
        HandleImportResult(success, result, skippedSpecs, false);
    end,
    OnCancel = function(self)
        local text = self:GetEditBox():GetText();
        local success, result, skippedSpecs = Favorites:Import(text, true);
        HandleImportResult(success, result, skippedSpecs, true);
    end,
    OnHide = function(self, data)
        ChatFrameUtil.FocusActiveWindow();
        self:GetEditBox():SetText("");
    end,
    timeout = 0,
    exclusive = true,
    whileDead = true,
    hideOnEscape = true
};

KeystoneLootSettingsDropdownMixin = {};

function KeystoneLootSettingsDropdownMixin:Init()
    self:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetTag("MENU_KEYSTONELOOT_SETTINGS_DROPDOWN");

        -- General
        rootDescription:CreateTitle(GENERAL);

        local LDBIcon = LibStub and LibStub('LibDBIcon-1.0', true);
        if (LDBIcon) then
            rootDescription:CreateCheckbox(
                L["Minimap button"],
                function() return not DB:Get("settings.minimap.hide"); end,
                function()
                    DB:Set("settings.minimap.hide", not DB:Get("settings.minimap.hide"));

                    if (not DB:Get("settings.minimap.hide")) then
                        LDBIcon:Show(AddonName);
                    else
                        LDBIcon:Hide(AddonName);
                    end
                end
            );
        else
            rootDescription:CreateCheckbox(
                L["Minimap button"],
                function() return DB:Get("settings.minimap.enabled"); end,
                function() DB:Set("settings.minimap.enabled", not DB:Get("settings.minimap.enabled")); end
            );
        end

        rootDescription:CreateCheckbox(
            L["Item level in keystone tooltip"],
            function() return DB:Get("settings.keystoneTooltip"); end,
            function() DB:Set("settings.keystoneTooltip", not DB:Get("settings.keystoneTooltip")); end
        );
        rootDescription:CreateCheckbox(
            L["Favorite in item tooltip"],
            function() return DB:Get("settings.favoriteTooltip"); end,
            function() DB:Set("settings.favoriteTooltip", not DB:Get("settings.favoriteTooltip")); end
        );
        rootDescription:CreateCheckbox(
            L["Wide mode"],
            function() return DB:Get("settings.wideMode"); end,
            function() DB:Set("settings.wideMode", not DB:Get("settings.wideMode")); end
        );


        local manageButton = rootDescription:CreateButton(L["Manage characters"]);
        local extent = 20;
        local maxCharacters = 18;
        local maxScrollExtent = extent * maxCharacters;
        manageButton:SetScrollMode(maxScrollExtent);

        for _, data in ipairs(Character:GetAllCharacters(true)) do
            local isLoggedInChar = data.key == Character:GetKey();
            local charLabel = string.format(LFG_LIST_TOOLTIP_CLASS_ROLE, GetColoredCharacterLabel(data), data.realm);
            local charSubmenu = manageButton:CreateButton(charLabel);

            charSubmenu:CreateCheckbox(
                L["Hidden"],
                function() return Character:IsHidden(data.key); end,
                function()
                    local nowHidden = not Character:IsHidden(data.key);
                    Character:SetHidden(data.key, nowHidden);

                    if (nowHidden and data.key == Character:GetSelectedKey()) then
                        DB:Set("ui.selectedCharacterKey", Character:GetKey());
                    end
                end
            );

            local deleteButton = charSubmenu:CreateButton(L["Delete..."], function()
                StaticPopup_Show("KEYSTONELOOT_DELETE_CHARACTER", GetColoredCharacterLabel(data), nil, data);
            end);

            if (isLoggedInChar) then
                deleteButton:SetEnabled(false);
                deleteButton:SetTooltip(function(tooltip, elementDescription)
                    tooltip:SetText(L["Cannot delete the currently logged in character."]);
                end);
            end
        end

        -- Notifications
        rootDescription:CreateTitle(COMMUNITIES_NOTIFICATION_SETTINGS);
        rootDescription:CreateCheckbox(
            L["Loot reminder (dungeons)"],
            function() return DB:Get("settings.lootReminder.dungeons"); end,
            function() DB:Set("settings.lootReminder.dungeons", not DB:Get("settings.lootReminder.dungeons")); end
        );

        -- Highlights
        rootDescription:CreateTitle(L["Highlighting"]);
        for _, entry in ipairs(HIGHLIGHTS) do
            local key = entry.key;
            rootDescription:CreateCheckbox(
                entry.label,
                function() return DB:Get(key); end,
                function() DB:Set(key, not DB:Get(key)); end
            );
        end

        -- Favorites
        rootDescription:CreateTitle(FAVORITES);
        rootDescription:CreateButton(L["Export..."], function()
            StaticPopup_Show("KEYSTONELOOT_EXPORT", GetColoredCharacterName());
        end);
        rootDescription:CreateButton(L["Import..."], function()
            StaticPopup_Show("KEYSTONELOOT_IMPORT", GetColoredCharacterName());
        end);
    end);
end
