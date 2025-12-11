local ADDON_NAME, DTH = ...;

local L = DTH.L;

local addonTitle = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title");
addonTitle = addonTitle:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");

local function MenuGenerator(owner, rootDescription)
    rootDescription:CreateTitle(addonTitle);

    rootDescription:CreateCheckbox(
        L.AUTO_ACCEPT,
        function()
            return DecorTreasureHuntDB.autoAccept;
        end,
        function()
            DecorTreasureHuntDB.autoAccept = not DecorTreasureHuntDB.autoAccept;
            local message = DecorTreasureHuntDB.autoAccept and L.AUTO_ACCEPT_ENABLED or L.AUTO_ACCEPT_DISABLED;
            print("|cffe6c619" .. addonTitle .. ":|r " .. message);
        end
    );

    rootDescription:CreateCheckbox(
        L.AUTO_TURNIN,
        function()
            return DecorTreasureHuntDB.autoTurnIn;
        end,
        function()
            DecorTreasureHuntDB.autoTurnIn = not DecorTreasureHuntDB.autoTurnIn;
            local message = DecorTreasureHuntDB.autoTurnIn and L.AUTO_TURNIN_ENABLED or L.AUTO_TURNIN_DISABLED;
            print("|cffe6c619" .. addonTitle .. ":|r " .. message);
        end
    );
end

AddonCompartmentFrame:RegisterAddon({
    text = addonTitle,
    icon = "dashboard-panel-homestone-teleport-button",
    func = function(frame, button)
        MenuUtil.CreateContextMenu(frame, MenuGenerator);
    end,
    funcOnEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:SetText(addonTitle, 1, 1, 1);
        GameTooltip:AddLine(L.TOOLTIP_TEXT, nil, nil, nil, true);
        GameTooltip:Show();
    end,
    funcOnLeave = function()
        GameTooltip:Hide();
    end
});
