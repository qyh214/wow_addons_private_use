

----------------------------------------------------------------------
--  Local variables
----------------------------------------------------------------------

local bDebugMode = false;
TITAN_POINTS_ID = "Points";
TITAN_POINTS_VERSION = "7.0.3";
TITAN_NIL = false;
TITAN_POINTS_TAB = "TokenFrame";    -- Currency Tab

----------------------------------------------------------------------
--  TitanPanelPointsButton_OnLoad(self)
----------------------------------------------------------------------

function TitanPanelPointsButton_OnLoad(self)

    -- init realid_TimeCounter
    realid_TimeCounter = 0;

    self.registry = {
        id = TITAN_POINTS_ID,
        version = TITAN_POINTS_VERSION,
        menuText = TITAN_POINTS_MENU_TEXT,
        tooltipTitle = TITAN_POINTS_TOOLTIP,
        buttonTextFunction = "TitanPanelPointsButton_GetButtonText",
        tooltipTextFunction = "TitanPanelPointsButton_GetTooltipText",
        iconWidth = 16,
        icon = "Interface\\PVPFrame\\PVP-Currency-Alliance";
        category = "Information",
        controlVariables = {
            ShowIcon = true,
            DisplayOnRightSide = false
        },
        savedVariables = {
            ShowLabelText = false,
            watched = {
                ShowNethershard = true,
                ShowValor = true,
                ShowTimewarpedBadge = true
            },
            ShowLabel = false,
            ShowPointLabels = false,
            ShowShortLabels = false,
            ShowIcons = true,
            ShowIcon = false,
            ShowHKs = true,
          }
    };

    -- Currency Events
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE");
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");

end



----------------------------------------------------------------------
--  TitanPanelPointsButton_OnEvent(self, event, ...)
----------------------------------------------------------------------

function TitanPanelPointsButton_OnEvent(self, event, ...)

    -- Debugging. Pay no attention to the man behind the curtain.
    if(bDebugMode) then
        if(event == "PLAYER_ENTERING_WORLD") then
            DEFAULT_CHAT_FRAME:AddMessage("Titan"..TITAN_POINTS_ID.." v"..TITAN_POINTS_VERSION.." Loaded.");
        end
        DEFAULT_CHAT_FRAME:AddMessage("Points: Caught Event "..event);
    end

    -- Update button label
    TitanPanelButton_UpdateButton(TITAN_POINTS_ID);

end


----------------------------------------------------------------------
--  TitanPanelPointsButton_OnClick(self, button)
----------------------------------------------------------------------

function TitanPanelPointsButton_OnClick(self, button)

    if (button == "LeftButton") then
        ToggleCharacter(TITAN_POINTS_TAB);
    end

end

----------------------------------------------------------------------
--  TitanPanelRightClickMenu_PreparePointsMenu()
----------------------------------------------------------------------

function TitanPanelRightClickMenu_PreparePointsMenu()

    TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_POINTS_ID].menuText);
    TitanPanelRightClickMenu_AddToggleIcon(TITAN_POINTS_ID);
    TitanPanelRightClickMenu_AddToggleLabelText(TITAN_POINTS_ID);
    TitanPanelRightClickMenu_AddSpacer();
    TitanPanelRightClickMenu_AddToggleVar(TITAN_POINTS_MENU_ICONS, TITAN_POINTS_ID, "ShowIcons");
    TitanPanelRightClickMenu_AddToggleVar(TITAN_POINTS_MENU_LABELS, TITAN_POINTS_ID, "ShowPointLabels");
    TitanPanelRightClickMenu_AddToggleVar(TITAN_POINTS_MENU_SHORT_LABELS, TITAN_POINTS_ID, "ShowShortLabels");

    TitanPanelRightClickMenu_AddSpacer();
    
    TitanPanelRightClickMenu_AddToggleVar("Honor Kills", TITAN_POINTS_ID, "ShowHKs");

    TitanPanelRightClickMenu_AddSpacer();

    for CurrencyIndex=1, GetCurrencyListSize() do
        local name, isHeader, nothing, nothing, nothing, nothing, icon, nothing, nothing, nothing, nothing = GetCurrencyListInfo(CurrencyIndex);

        if(not isHeader) then
            local info = {};
            info.text = name;
            info.value = icon;
            info.checked = TitanPanelPoints_isVisible(icon);
            info.func = function()
                TitanPanelPoints_ToggleVisibility(icon);
            end
            info.keepShownOnClick = 1;
            UIDropDownMenu_AddButton(info, 1);
        else
            TitanPanelRightClickMenu_AddSpacer();
            TitanPanelRightClickMenu_AddTitle(name);
        end
    end

end

----------------------------------------------------------------------
--  TitanPanelPointsButton_OnUpdate()
----------------------------------------------------------------------

function TitanPanelPointsButton_OnUpdate(elapsed)
end

----------------------------------------------------------------------
--  TitanPanelPoints_GetIcon(CurrencyType)
----------------------------------------------------------------------

function TitanPanelPoints_GetIcon(CurrencyType, SuppliedIcon)

    local icon = nil;
    local faction = UnitFactionGroup( "player" );

    if not SuppliedIcon then
        SuppliedIcon = [[Interface\Icons\Temp]];
    end

    -- icon = " |T"..SuppliedIcon..":0|t ";
    icon = "  |T"..SuppliedIcon..":16:16:0:0:64:64:4:60:4:60|t ";

    return icon;

end

----------------------------------------------------------------------
--  TitanPanelPoints_GetLabel(CurrencyType)
----------------------------------------------------------------------

function TitanPanelPoints_GetLabel(CurrencyType)
    if (TitanGetVar(TITAN_POINTS_ID, "ShowPointLabels") ~= nil) then
        if(TitanGetVar(TITAN_POINTS_ID, "ShowShortLabels") ~= nil) then
            return gsub(CurrencyType, "[^%u]", "")..": ";
        else
            return CurrencyType..": ";
        end
    end
    return "";
end

function TitanPanelPoints_getCurrencyKey(icon)
    local key = gsub("Show"..icon, "[^%w]", "");
    -- DEFAULT_CHAT_FRAME:AddMessage("Points: "..icon.." key "..key);
    return key;
end

function TitanPanelPoints_ToggleVisibility(icon)
    local set = TitanGetVar(TITAN_POINTS_ID, 'watched');
    local key = TitanPanelPoints_getCurrencyKey(icon);
    local value = true
    if (TitanPanelPoints_isVisible(icon)) then
        value = nil
    end
    set[key] = value;
    TitanSetVar(TITAN_POINTS_ID, 'watched', set);
    TitanPanelButton_UpdateButton(TITAN_POINTS_ID);
end

function TitanPanelPoints_isVisible(icon)
    local set = TitanGetVar(TITAN_POINTS_ID, 'watched');
    local key = TitanPanelPoints_getCurrencyKey(icon);
    return set[key] ~= nil
end

----------------------------------------------------------------------
-- TitanPanelPointsButton_GetButtonText(id)
----------------------------------------------------------------------

function TitanPanelPointsButton_GetButtonText(id)
    local id = TitanUtils_GetButton(id);
    local buttonRichText = "";
    local label = "";

    if (TitanGetVar(TITAN_POINTS_ID,"ShowLabelText") ~= nil) then
        label = TITAN_POINTS_BUTTON_LABEL;
    end

    for CurrencyIndex=1, GetCurrencyListSize() do
        local name, isHeader, nothing, nothing, nothing, count, icon, nothing, nothing, nothing, nothing = GetCurrencyListInfo(CurrencyIndex)

        if (not isHeader) then
            if (TitanPanelPoints_isVisible(icon)) then
                if (TitanGetVar(TITAN_POINTS_ID,"ShowIcons") ~= nil) then
                    buttonRichText = buttonRichText..TitanPanelPoints_GetIcon(name, icon)
                end
                buttonRichText = buttonRichText..format(TitanPanelPoints_GetLabel(name)..TitanUtils_GetHighlightText(count).." ");
            end
        end
    end

    if (TitanGetVar(TITAN_POINTS_ID, "ShowHKs") ~= nil) then
        local HKs, null = GetPVPLifetimeStats()
        if(TitanGetVar(TITAN_POINTS_ID,"ShowIcons") ~= nil) then
            buttonRichText = buttonRichText..TitanPanelPoints_GetIcon(TITAN_POINTS_HKS);
        end
        buttonRichText = buttonRichText..format(TitanPanelPoints_GetLabel(TITAN_POINTS_HKS)..TitanUtils_GetHighlightText(HKs).." ");
    end

    return label..buttonRichText;

end



----------------------------------------------------------------------
-- TitanPanelPointsButton_GetTooltipText()
----------------------------------------------------------------------

function TitanPanelPointsButton_GetTooltipText()

    local id = TitanUtils_GetButton(id);
    local TITAN_POINTS_LIST_SIZE = GetCurrencyListSize();
    local tooltipRichText = "";

    if (TITAN_POINTS_LIST_SIZE > 0) then

        for CurrencyIndex=1, TITAN_POINTS_LIST_SIZE do
            local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(CurrencyIndex)

            if(not isHeader) then
                tooltipRichText = tooltipRichText..TitanUtils_GetHighlightText(name).."\t"..TitanUtils_GetHighlightText(count).."\n";
            else
                tooltipRichText = tooltipRichText.." \n"..TitanUtils_GetNormalText(name).."\n";
            end

        end
    
        -- Append Honor Kills
        if (TitanGetVar(TITAN_POINTS_ID, "ShowHKs") ~= nil) then
            local HKs, null = GetPVPLifetimeStats()
            tooltipRichText = tooltipRichText..TitanUtils_GetHighlightText(TITAN_POINTS_HKS).."\t"..TitanUtils_GetHighlightText(HKs).."\n";
            format(TitanPanelPoints_GetLabel(TITAN_POINTS_HKS), TitanUtils_GetHighlightText(HKs));
        end

    end

    return tooltipRichText;

end
