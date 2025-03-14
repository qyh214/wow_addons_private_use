local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScan_FindCrafterButtonMixin = {}

function CraftScan_FindCrafterButtonMixin:OnLoad()
    self:SetText(L("Find Crafter"))
    self:FitToText();
end

local testmode = nil -- {};

local foundCrafterPage = nil;
function DisplayCrafterTable()
    if not foundCrafterPage then
        foundCrafterPage = CreateFrame("Frame", "CraftScan_FoundCrafterTable", ProfessionsCustomerOrdersFrame,
            "CraftScan_FoundCrafterPageTemplate")
        CraftScan.Frames.makeMovable(foundCrafterPage);
        foundCrafterPage:ClearAllPoints();
        foundCrafterPage:SetPoint("TOPLEFT", ProfessionsCustomerOrdersFrame, "TOPRIGHT", 0, 0);
        foundCrafterPage:SetPoint("BOTTOMLEFT", ProfessionsCustomerOrdersFrame, "RIGHT", 0, 0);

        --[[
        -- Kinda nice to be able to run off and check mats on the AH, so leaving this out for now.
        ProfessionsCustomerOrdersFrame:HookScript("OnHide", function()
            foundCrafterPage:Hide()
        end)
        ProfessionsCustomerOrdersFrame:HookScript("OnShow", function()
            foundCrafterPage:Show()
        end)
 ]]

        foundCrafterPage:SetTitle(L("Potential Crafters"));

        -- So ESC closes it
        table.insert(UISpecialFrames, "CraftScan_FoundCrafterTable")

        foundCrafterPage.CrafterList.Header.CrafterName:SetText(L("Crafter [Currently Playing]"));
        foundCrafterPage.CrafterList.Header.Commission:SetText(L("Commission"));
    end
    foundCrafterPage:Show();
    foundCrafterPage.CrafterList:Init();
end

local foundCrafters = nil;
function CraftScan.SearchResultsReceived(itemID, player, crafter, greeting, busy, commission)
    if foundCrafters then
        local entry = {
            itemID = itemID,
            player = player,
            crafter = crafter,
            greeting = greeting,
            commission = commission,
            busy = busy,
        };
        table.insert(foundCrafters, entry);

        if testmode then
            for i = 1, 50 do
                local entry = {
                    itemID = itemID,
                    player = player .. i,
                    crafter = crafter .. i,
                    greeting = greeting,
                    busy = math.random() < 0.5,
                };
                table.insert(foundCrafters, entry);
            end
        end
        DisplayCrafterTable();
    end
end

local selectedItemID = nil;
function CraftScan_FindCrafterButtonMixin:OnClick()
    foundCrafters = {};
    CraftScanComm:FindCrafters(selectedItemID);
    DisplayCrafterTable();
end

local button = nil;
local function UpdateButtonVisibility(recipient)
    if recipient == Enum.CraftingOrderType.Personal then
        button:Show();
    else
        button:Hide();
    end
end

local function OnCraftingOrderPageOpened()
    if not button then
        button = CreateFrame("Button", "CraftScan_FindCrafterButton", ProfessionsCustomerOrdersFrame.Form,
            "CraftScan_FindCrafterButtonTemplate");
        button:SetPoint("RIGHT", ProfessionsCustomerOrdersFrame.Form.OrderRecipientDropdown, "LEFT", -5, 0);

        local recipient = tonumber(GetCVar("professionsOrderRecipientDropdown"));
        UpdateButtonVisibility(recipient);
    end
end

local function OnCraftingOrderTypeChanged(event, cvar, value)
    if cvar == "professionsOrderRecipientDropdown" then
        local recipient = tonumber(value);
        UpdateButtonVisibility(recipient);
    end
end

local function OnRecipeSelected(event, recipeID, success)
    if UnitAffectingCombat("player") == true then
        return
    end

    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if not recipeInfo then
        return;
    end
    local itemIDs = CraftScan.Utils.GetOutputItems(recipeInfo)
    if itemIDs and #itemIDs then
        selectedItemID = itemIDs[1];
    end

    if foundCrafterPage then
        foundCrafterPage:Hide();
    end
end

CraftScanScannerMenu:RegisterEventCallback("CRAFTINGORDERS_SHOW_CUSTOMER", OnCraftingOrderPageOpened);
CraftScanScannerMenu:RegisterEventCallback("CVAR_UPDATE", OnCraftingOrderTypeChanged);
CraftScanScannerMenu:RegisterEventCallback("SPELL_DATA_LOAD_RESULT", OnRecipeSelected);

CraftScan_FoundCrafterListMixin = {}

local function ItsMe(crafter)
    if testmode then
        return #crafter % 2 == 0;
    end

    return CraftScan.Utils.ItsMe(crafter, true);
end

function CraftScan_FoundCrafterListMixin:Init()
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, nil, nil);

    if #foundCrafters == 0 then
        self.ResultsText:SetText(L("No Crafters Found"))
        self.ResultsText:Show();
        self.ScrollBox:Hide();
        return;
    end
    self.ResultsText:Hide();

    local topPadding = 3;
    local leftPadding = 4;
    local rightPadding = 2;
    local spacing = 1;
    local view = CreateScrollBoxListLinearView(topPadding, 0, leftPadding, rightPadding, spacing);

    local function FrameInitializer(frame, foundCrafter)
        frame.CrafterName:SetText(crafterName)
        frame.info = foundCrafter;
        frame:RegisterForClicks("AnyUp");

        local crafter = CraftScan.NameAndRealmToName(foundCrafter.crafter, true);
        local player = CraftScan.NameAndRealmToName(foundCrafter.player, true);
        frame.Commission:SetText(foundCrafter.commission or L(LID.DEFAULT_COMMISSION));
        if crafter ~= player then
            frame.CrafterName:SetText(string.format(L(LID.FOUND_CRAFTER_NAME_ENTRY), crafter, player));
        else
            frame.CrafterName:SetText(crafter);
        end

        if frame.info.busy then
            frame.BusyIcon:Show();
        else
            frame.BusyIcon:Hide();
        end

        frame.CrafterName:ClearAllPoints();
        if ItsMe(crafter) then
            frame.ItsMeIcon:Show();
            frame.CrafterName:SetPoint("LEFT", frame, "LEFT", 20, 0)
        else
            frame.ItsMeIcon:Hide();
            frame.CrafterName:SetPoint("LEFT", frame, "LEFT", 0, 0)
        end
    end

    view:SetElementFactory(function(factory)
        factory("CraftScan_FoundCrafterListElementTemplate", FrameInitializer);
    end);

    self.ScrollBox:Show();

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, nil,
        nil);

    table.sort(foundCrafters, function(lhs, rhs)
        local lhsIsMe = (ItsMe(lhs.crafter) and 1 or 0);
        local rhsIsMe = (ItsMe(rhs.crafter) and 1 or 0);
        if lhsIsMe == rhsIsMe then
            return (lhs.busy and 1 or 0) < (rhs.busy and 1 or 0);
        end

        return lhsIsMe > rhsIsMe;
    end)


    local dataProvider = CreateDataProvider(foundCrafters)
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function CraftScan_FoundCrafterListMixin:OnHide()
    foundCrafters = nil;
end

CraftScan_FoundCrafterListElementMixin = {}

function CraftScan_FoundCrafterListElementMixin:OnClick(button)
    if not self.info then return; end

    if button == 'LeftButton' and not self.info.sent then
        CraftScanComm:RequestCraft(self.info.player, self.info.itemID);
        self.info.sent = true;
    else
        ChatFrame_SendTell(CraftScan.NameAndRealmToName(self.info.player), DEFAULT_CHAT_FRAME)
    end
end

local tooltip = nil;
function CraftScan_FoundCrafterListElementMixin:ShowTooltip()
    local name = "CraftScan_FoundCrafterTooltip"
    if not tooltip then
        tooltip = CreateFrame("GameTooltip", name, UIParent, "GameTooltipTemplate");
        tooltip.TextLeft2:SetFontObject(ChatFrame1:GetFontObject());
        tooltip.TextRight1:SetFontObject(tooltip.TextRight2:GetFontObject());
    end

    tooltip:ClearLines();

    tooltip:SetOwner(self, "ANCHOR_TOPLEFT");

    if self.info.sent then
        tooltip:AddDoubleLine(L("Crafter Greeting"), L("Chat Help"));
    else
        tooltip:AddDoubleLine(L("Crafter Greeting"), L(LID.GREET_FOUND_CRAFTER));
        tooltip:AddDoubleLine(nil, string.format(L("Chat Override"), "")); -- No keybinds for customers
    end

    GameTooltip_AddBlankLineToTooltip(tooltip);

    local greeting = CraftScan.Utils.SplitResponse(self.info.greeting);
    local wc = ChatTypeInfo["WHISPER"]
    for _, line in ipairs(greeting) do
        tooltip:AddLine(line, wc.r, wc.g, wc.b, true, 0);
    end

    GameTooltip_AddBlankLineToTooltip(tooltip);

    CraftScan.Utils.SizeTooltipLikeChat(name, tooltip);

    tooltip:Show();
end

function CraftScan_FoundCrafterListElementMixin:OnEnter()
    if not self.info then return; end
    self.HoverBackground:Show();
    self:ShowTooltip();
end

function CraftScan_FoundCrafterListElementMixin:OnLeave()
    if not self.info then return; end
    self.HoverBackground:Hide();
    tooltip:Hide();
end

CraftScan_ItsMeIconMixin = {}

function CraftScan_ItsMeIconMixin:OnEnter()
    self:GetParent().HoverBackground:Show();
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText("|cFFFFFFFFThe CraftScan creator. Give him some business!|r");
    GameTooltip:Show()
end

function CraftScan_ItsMeIconMixin:OnLeave()
    self:GetParent().HoverBackground:Hide();
    GameTooltip:Hide()
end

CraftScan_BusyIconMixin = {}

function CraftScan_BusyIconMixin:OnEnter()
    self:GetParent().HoverBackground:Show();
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L(LID.BUSY_ICON));
    GameTooltip:Show()
end

function CraftScan_BusyIconMixin:OnLeave()
    self:GetParent().HoverBackground:Hide();
    GameTooltip:Hide()
end
