local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local function CreateDropdown(category, variable, key, name, options, tooltip, onChange)
    local default = CraftScan.CONST.DEFAULT_SETTINGS[key];

    local setting = Settings.RegisterAddOnSetting(category, variable, key, CraftScan.DB.settings, type(default), name,
        default);

    if onChange then
        setting:SetValueChangedCallback(function(setting, value)
            onChange(value)
        end);
    end
    local initializer = Settings.CreateDropdown(category, setting, options, tooltip);
    initializer:AddSearchTags(L(LID.CRAFT_SCAN));
end

local function SetupMultiSelectDropdown(dropdown, setting, options, width, initTooltip)
    local function Inserter(rootDescription, isSelected, setSelected)
        -- Instead of the default dropdown buttons, we use checkboxes, and
        -- convert the checked ones into a list that gets saved into the
        -- specified variableKey in the settings DB.
        local function IsSelected(value)
            local values = CraftScan.DB.settings[setting.variableKey];
            if values == nil then return false; end
            for _, entry in ipairs(values) do
                if entry == value then return true; end
            end
            return false;
        end

        local function SetSelected(value)
            local values = CraftScan.Utils.saved(CraftScan.DB.settings, setting.variableKey, {})
            for i, entry in ipairs(values) do
                if entry == value then
                    table.remove(values, i)
                    return;
                end
            end
            table.insert(values, value);
        end

        local options = options();
        for _, option in ipairs(options) do
            rootDescription:CreateCheckbox(option.label, IsSelected, SetSelected, option.text);
        end

        -- TODO: Scrolling is bugged or I'm doing something wrong. If you select
        -- an entry before scrolling to the bottom of the list, you get an error
        -- from bliz scroll code. If you scroll to the bottom, then change
        -- selections, it works fine.
        --
        -- With four columns, it's unlikely anyone will need scrolling anyway,
        -- so not having scrolling is likely better..
        --
        --local extent = 20;
        --local maxEntries = 32;
        --local maxScrollExtent = extent * maxEntries;
        --rootDescription:SetScrollMode(maxScrollExtent);
    end

    Settings.InitDropdown(dropdown, setting, Inserter, initTooltip);
end

-- SettingsDropdownButtonTemplate inherited in XML.
CraftScanSettingsMultiSelectDropDownMixin = {}

function CraftScanSettingsMultiSelectDropDownMixin:SetupDropdownMenu(button, setting, options, initTooltip)
    -- Override the default SetupDropdownMenu behavior so we can use checkboxes instead of buttons.
    SetupMultiSelectDropdown(self.Control.Dropdown, setting, options, initTooltip);
    self.Control.Dropdown:SetSelectionText(function(selection)
        -- Override the button text to indicate the number of selected items
        -- instead of the comma separated list.
        local values = CraftScan.DB.settings[setting.variableKey];
        local count = values and #values or 0;
        return string.format(L(LID.MULTI_SELECT_BUTTON_TEXT), count);
    end);
    self.Control.Dropdown:GenerateMenu(); -- Apply our custom selection text immediately.
    self.Control.IncrementButton:Hide();
    self.Control.DecrementButton:Hide();
end

local function CreateMultiSelectDropdown(category, variable, key, name, options, tooltip)
    local function GetValue()
        -- No-op. It's done by the menu checkbox get/sets
        return "";
    end

    local function SetValue(value)
        -- No-op. It's done by the menu checkbox get/sets
    end

    local default = "";
    local setting = Settings.RegisterProxySetting(category, variable, Settings.VarType.String,
        name, default, GetValue, SetValue)
    local initializer = Settings.CreateControlInitializer("CraftScanSettingsMultiSelectDropDownTemplate", setting,
        options, tooltip);

    initializer.data.setting.variableKey = key;

    local layout = SettingsPanel:GetLayout(category);
    layout:AddInitializer(initializer);

    initializer:AddSearchTags(L(LID.CRAFT_SCAN));
end

local function CreateSlider(category, variable, key, name, options, tooltip, OnValueChanged)
    local default = CraftScan.CONST.DEFAULT_SETTINGS[key];
    local setting = Settings.RegisterAddOnSetting(category, variable, key, CraftScan.DB.settings, type(default),
        name, default);
    if OnValueChanged then
        setting:SetValueChangedCallback(OnValueChanged);
    end

    local initializer = Settings.CreateSlider(category, setting, options, tooltip);
    initializer:AddSearchTags(L(LID.CRAFT_SCAN));
end

local craftScanCategory = nil;
CraftScan.Utils.onLoad(function()
    local category, layout = Settings.RegisterVerticalLayoutCategory(L("CraftScan"));
    craftScanCategory = category;

    do
        -- The addon list is likely to be large, so we list this option first so
        -- it expandss downward instead of overlapping on top of the button.
        local function GetOptions()
            local container = Settings.CreateControlTextContainer();

            local numAddOns = C_AddOns.GetNumAddOns()
            for i = 1, numAddOns do
                local name, _, _, enabled = C_AddOns.GetAddOnInfo(i)
                if name ~= 'CraftScan' then
                    container:Add(name, name);
                end
            end
            return container:GetData();
        end

        CreateMultiSelectDropdown(category, "CRAFT_SCAN_ADDON_WHITELIST", 'disabled_addon_whitelist',
            L(LID.ADDON_WHITELIST_LABEL), GetOptions,
            L(LID.ADDON_WHITELIST_TOOLTIP)
        );
    end

    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer();
            for _, entry in ipairs(CraftScan.CONST.SOUNDS) do
                container:Add(entry.path, entry.name);
            end
            return container:GetData();
        end

        CreateDropdown(category, "CRAFT_SCAN_PING_SOUND", "ping_sound", L(LID.PING_SOUND_LABEL), GetOptions,
            L(LID.PING_SOUND_TOOLTIP),
            function(path)
                PlaySoundFile(path, "Master");
            end
        );
    end
    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer();
            container:Add(CraftScan.CONST.LEFT, L("Left"));
            container:Add(CraftScan.CONST.RIGHT, L("Right"));
            return container:GetData();
        end

        CreateDropdown(category, "CRAFT_SCAN_BANNER_DIRECTION", "banner_direction", L(LID.BANNER_SIDE_LABEL), GetOptions,
            L(LID.BANNER_SIDE_TOOLTIP));
    end
    do
        local options = Settings.CreateSliderOptions(1, 10, 1);
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return value .. ' ' .. (value == 1 and L("Minute") or L("Minutes")) end);
        CreateSlider(category, "CRAFTSCAN_CUSTOMER_TIMEOUT", "customer_timeout", L(LID.CUSTOMER_TIMEOUT_LABEL), options,
            L(LID.CUSTOMER_TIMEOUT_TOOLTIP));
    end
    do
        local options = Settings.CreateSliderOptions(1, 60, 1);
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return value .. ' ' .. (value == 1 and L("Second") or L("Seconds")) end);
        CreateSlider(category, "CRAFTSCAN_BANNER_TIMEOU", "banner_timeout", L(LID.BANNER_TIMEOUT_LABEL), options,
            L(LID.BANNER_TIMEOUT_TOOLTIP));
    end
    if CraftScan.CONST.AUTO_REPLIES_SUPPORTED then
        local options = Settings.CreateSliderOptions(250, 2000, 100);
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return value .. ' ' .. (value == 1 and L("Millisecond") or L("Milliseconds")) end);
        CreateSlider(category, "CRAFTSCAN_AUTO_REPLY_DELAY", "auto_reply_delay", "Auto reply delay", options,
            "When auto replies are enabled, wait this long before replying to make youself seem a little less bot-like.");
    end
    do
        local options = Settings.CreateSliderOptions(25, 200, 5);
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return value .. ' %' end);
        CreateSlider(category, "CRAFTSCAN_ALERT_ICON_SCALE", "alert_icon_scale", L("Alert icon scale"), options, nil,
            function()
                CraftScan.UpdateAlertIconScale();
            end);
    end
    do
        local options = Settings.CreateSliderOptions(0, 650, 5);
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return value .. ' ' .. L("Pixels") end);
        CreateSlider(category, "CRAFTSCAN_BUTTON_HEIGHT", "show_button_height", L("Show button height"), options, nil,
            function()
                CraftScan.UpdateShowButtonHeight();
            end);
        --L(LID.CUSTOMER_TIMEOUT_TOOLTIP));
    end
    do
        local GetValue = function()
            return CraftScan.DB.settings.discoverable;
        end
        local SetValue = function(value)
            CraftScan.DB.settings.discoverable = value;
        end

        local setting = Settings.RegisterProxySetting(category, "CRAFTSCAN_DISCOVERABLE",
            Settings.VarType.Boolean, L("Discoverable to customers"), Settings.Default.True, GetValue, SetValue);
        local initializer = Settings.CreateCheckbox(category, setting, L(LID.DISCOVERABLE_SETTING));
        initializer:AddSearchTags(L(LID.CRAFT_SCAN));
    end
    do
        local GetValue = function()
            return CraftScan.DB.settings.permissive_matching;
        end
        local SetValue = function(value)
            CraftScan.DB.settings.permissive_matching = value;
            CraftScan.UpdateHasMatchStyle()
        end

        local setting = Settings.RegisterProxySetting(category, "CRAFTSCAN_PERMISSIVE_MATCHING",
            Settings.VarType.Boolean, L("Permissive keyword matching"), Settings.Default.True, GetValue, SetValue);
        local initializer = Settings.CreateCheckbox(category, setting, L(LID.PERMISSIVE_MATCH_SETTING));
        initializer:AddSearchTags(L(LID.CRAFT_SCAN));
    end
    do
        local GetValue = function()
            return CraftScan.DB.settings.show_chat_orders_tab;
        end
        local SetValue = function(value)
            CraftScan.DB.settings.show_chat_orders_tab = value;
            CraftScan.UpdateShowChatOrdersTab()
        end

        local setting = Settings.RegisterProxySetting(category, "CRAFTSCAN_SHOW_CHAT_ORDERS_BUTTON",
            Settings.VarType.Boolean, L("Show chat orders tab"), Settings.Default.True, GetValue, SetValue);
        local initializer = Settings.CreateCheckbox(category, setting, L(LID.SHOW_CHAT_ORDER_TAB));
        initializer:AddSearchTags(L(LID.CRAFT_SCAN));
    end
    do
        local GetValue = function()
            return CraftScan.DB.settings.collapse_chat_context;
        end
        local SetValue = function(value)
            CraftScan.DB.settings.collapse_chat_context = value;
        end

        local setting = Settings.RegisterProxySetting(category, "CRAFTSCAN_COLLAPSE_CHAT_CONTEXT",
            Settings.VarType.Boolean, L("Collapse chat context menu"), Settings.Default.False, GetValue, SetValue);
        local initializer = Settings.CreateCheckbox(category, setting, L(LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP));
        initializer:AddSearchTags(L(LID.CRAFT_SCAN));
    end

    Settings.RegisterAddOnCategory(category);
end)

CraftScan.Settings = {}

function CraftScan.Settings:Open()
    Settings.OpenToCategory(craftScanCategory:GetID());
end
