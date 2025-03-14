local CraftScan = select(2, ...)

CraftScanCrafterOrderListElementMixin = CreateFromMixins(TableBuilderRowMixin);

CraftScan.LIVE = {}
CraftScan.LIVE.customers = {}

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local function GetSortedProfessions()
    local result = {}
    for parentProfID, color in pairs(CraftScan.CONST.PROFESSION_COLORS) do
        local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(parentProfID);
        table.insert(result, {
            key = profInfo.professionName,
            name = CraftScan.Utils.ColorizeText(profInfo.professionName, color),
            ppID = parentProfID,
        });
    end

    table.sort(result, function(lhs, rhs) return lhs.key < rhs.key; end)

    for _, profession in ipairs(result) do
        profession.key = nil;
    end

    return result;
end

function CraftScanCrafterOrderListElementMixin:Init(elementData)
    self.order = elementData.order
    -- self.browseType = elementData.browseType;
    self.pageFrame = elementData.pageFrame;
    self.contextMenu = elementData.contextMenu;
end

local function removeOrder(orders, order)
    local customerInfo = CraftScan.OrderToCustomerInfo(order)
    local response = customerInfo.responses[order.responseID]
    local orderID = CraftScan.OrderToOrderID(order)

    if CraftScan.State.activeOrder == orders[orderID] then
        CraftScan.State.activeOrder = nil;
    end

    -- Wipe out any less granular reponses related to this one
    local response = customerInfo.responses[order.responseID];
    if not response then
        -- A less_granular child that was already wiped out. Nothing left to do.
        return
    end

    if response.less_granular then
        for _, child in ipairs(response.less_granular) do
            customerInfo.responses[child] = nil
        end
    end
    customerInfo.responses[order.responseID] = nil

    -- I somehow managed to get a random empty entry in the responses table.
    -- Clear that out in case there's a bug somewhere creating them. No idea how
    -- it happened. Hopefully just something during development.
    for key, value in pairs(customerInfo.responses) do
        if not next(value) then
            customerInfo.responses[key] = nil;
        end
    end

    if not next(customerInfo.responses) then
        -- No more orders with this customer, so close out the frames related to them.
        local liveCustomerInfo = CraftScan.LIVE.customers[order.customerName]
        if liveCustomerInfo then
            if liveCustomerInfo.chatFrame then
                FCF_Close(liveCustomerInfo.chatFrame)
                liveCustomerInfo.chatFrame = nil
            end
            CraftScan.LIVE.customers[order.customerName] = nil
        end
        CraftScan.DB.customers[order.customerName] = nil
    end

    -- Remove ourselves from the global list of displayed orders
    orders[orderID] = nil
end

function CraftScan.GreetCustomer(button, order)
    CraftScanScannerMenu:ClearAlert(order)

    local response = CraftScan.OrderToResponse(order)
    if button == "LeftButton" then
        if not response.greeting_sent then
            CraftScan.Utils.SendResponses(response.message, order.customerName)
            response.greeting_sent = true
            -- TODO: More efficient way to update the display?
            CraftScanCraftingOrderPage:ShowGeneric()
        else
            -- After sending the initial greeting, subsequent clicks open a chat with the customer.
            ChatFrame_SendTell(order.customerName, DEFAULT_CHAT_FRAME)
        end
    elseif button == "MiddleButton" then
        -- Middle button to begin chat without the generated greeting
        response.greeting_sent = true
        ChatFrame_SendTell(order.customerName, DEFAULT_CHAT_FRAME)
    elseif button == "RightButton" then
        CraftScan.DismissOrder(order);
    end
end

function CraftScan.DismissOrder(order)
    removeOrder(CraftScan.DB.listed_orders, order)
    CraftScanCraftingOrderPage:ShowGeneric()
end

function CraftScanCrafterOrderListElementMixin:OnClick(button)
    CraftScan.GreetCustomer(button, self.order)
end

local chatTooltip = CraftScan.Utils.ChatHistoryTooltip:new();
function CraftScanCrafterOrderListElementMixin:OnLineEnter()
    self.HighlightTexture:Show();

    -- If the request has a specific item, toss up the item tooltip just like
    -- the real crafting order page.
    local response = CraftScan.OrderToResponse(self.order)
    if response.recipeID then
        local reagents = {};
        local qualityIDs = C_TradeSkillUI.GetQualitiesForRecipe(response.recipeID);
        local qualityIdx = qualityIDs and #qualityIDs or 0;
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetRecipeResultItem(response.recipeID, reagents, nil, nil, qualityIDs and qualityIDs[qualityIdx]);
    end

    -- In addition, pop up a tooltip that looks like the chat window. We copy
    -- the chat window width (up to a limit that fits over the crafting window),
    -- and the primary chat window's font settings. This seems to make the text
    -- wrapping match and overall it looks pretty close to the real chat window
    -- to give an easy refresher on prior interactions without popping out the
    -- dedicated chat frame.
    chatTooltip:Show("CraftScanChatHistoryTooltip", self, self.order,
        string.format(L("Chat History"), CraftScan.NameAndRealmToName(self.order.customerName)));
end

function CraftScanCrafterOrderListElementMixin:OnLineLeave()
    self.HighlightTexture:Hide();

    GameTooltip:Hide();
    chatTooltip:Hide();
    ResetCursor();
end

local function CreateAcceptLinkedAccountDialog()
    if not CraftScanComm:HavePendingPeerRequest() then
        return;
    end

    local OnAccept = function(nickname)
        CraftScanComm:AcceptPeerRequest(nickname);
    end
    local OnReject = function()
        CraftScanComm:RejectPeerRequest();
    end
    CraftScan.Dialog.Show({
        key = "accept_linked_account",
        title = L("Accept Linked Account"),
        submit = L("Accept Linked Account"),
        OnAccept = OnAccept,
        OnReject = OnReject,
        elements = {
            {
                type = CraftScan.Dialog.Element.Text,
                text = string.format(L(LID.ACCOUNT_LINK_ACCEPT_DST_INFO),
                    CraftScanComm:GetPendingPeerRequestCharacter(),
                    CraftScanComm:GetPendingPeerRequestPermissions()),
            },
            {
                type = CraftScan.Dialog.Element.EditBox,
            },
        },
    })
end

CraftScanCraftingOrderPageMixin = {} --CreateFromMixins(ProfessionsRecipeListPanelMixin);

function CraftScanCraftingOrderPageMixin:InitOrderListTable()
    local orderList = self.BrowseFrame.OrderList;
    orderList:SetHeight(CraftScan.DB.settings.order_list_height or 200);

    local pad = 5;
    local spacing = 1;
    local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
    view:SetElementInitializer("CraftScanCrafterOrderListElementTemplate", function(button, elementData)
        button:Init(elementData);
    end);
    ScrollUtil.InitScrollBoxListWithScrollBar(orderList.ScrollBox, orderList.ScrollBar, view);
end

function CraftScanCraftingOrderPageMixin:UpdateFilterResetVisibility()
    self.BrowseFrame.LeftPanel.CrafterList.FilterButton.ResetButton:SetShown(
        not CraftScan.IsUsingDefaultFilters(ignoreSkillLine));
end

function CraftScanCraftingOrderPageMixin:GetDesiredPageWidth()
    return 1105;
end

local function UpdateAnalyticsEnabled()
    local enabled = CraftScan.DB.analytics.enabled;
    if enabled then
        CraftScanCraftingOrderPage:EnableAnalytics()
    else
        CraftScanCraftingOrderPage:DisableAnalytics()
    end
end

function CraftScanCraftingOrderPageMixin:OnLoad()
    CraftScan.Utils.onLoad(function()
        self:ResetSortOrder() -- self.InitButtons()
        self:InitOrderListTable()
        self:SetupOrderListTable()
        UpdateAnalyticsEnabled();
    end);
end

function CraftScanCraftingOrderPageMixin:OnShow()
    CraftScanScannerMenu:ClearPulses()
    self:ShowGeneric()

    local icon = CraftScan.Utils.GetCurrentProfessionIcon();
    self:SetPortraitToAsset(icon or 4620670);

    -- Since we are a UIPanel, Bliz tries to close all other windows, including
    -- the dialog we might try to open, so wait a sec then open any incoming
    -- requests.
    C_Timer.After(1, CreateAcceptLinkedAccountDialog);
end

function CraftScanCraftingOrderPageMixin:OnHide()
end

local function getOrderName(response)
    if response.itemID then
        local item = Item:CreateFromItemID(response.itemID);
        return item:GetItemName()
    else
        return response.professionName;
    end
end

local function ApplySortOrder(sortOrder, lhsOrder, rhsOrder)
    -- CraftScan.ChatOrderSortOrder = EnumUtil.MakeEnum("CustomerName", "CrafterName", "ProfessionName", "ItemName", "Interaction"); -- , "Sent");
    local lhs = CraftScan.OrderToResponse(lhsOrder);
    local rhs = CraftScan.OrderToResponse(rhsOrder);
    if sortOrder == CraftScan.ChatOrderSortOrder.ItemName then
        local lhsName = getOrderName(lhs)
        local rhsName = getOrderName(rhs)
        return SortUtil.CompareUtf8i(lhsName, rhsName)
    elseif sortOrder == CraftScan.ChatOrderSortOrder.CustomerName then
        return SortUtil.CompareUtf8i(lhsOrder.customerName, rhsOrder.customerName)
    elseif sortOrder == CraftScan.ChatOrderSortOrder.CrafterName then
        return SortUtil.CompareUtf8i(lhs.crafterName, rhs.crafterName)
    elseif sortOrder == CraftScan.ChatOrderSortOrder.ProfessionName then
        return SortUtil.CompareUtf8i(lhs.professionName, rhs.professionName)
    elseif sortOrder == CraftScan.ChatOrderSortOrder.Time then
        local now = time()
        local lhsAge = math.floor(now - lhs.time)
        local rhsAge = math.floor(now - rhs.time)
        return SortUtil.CompareNumeric(lhsAge, rhsAge)
    end
    return 0;
end

local function PurgeOldOrders()
    local orders = CraftScan.DB.listed_orders

    local now = time()
    local old = {}
    local timeout = CraftScan.Utils.GetSetting('customer_timeout') * 60;
    for orderID, order in pairs(orders) do
        local response = CraftScan.OrderToResponse(order)
        if not response or now - response.time > timeout then
            table.insert(old, order)
        end
    end

    for _, order in ipairs(old) do
        removeOrder(orders, order)
    end

    return #old ~= 0
end

local function UpdateCells()
    for customer, customerInfo in pairs(CraftScan.LIVE.customers) do
        for _, response in pairs(customerInfo.responses) do
            if response.updateAge then
                response.updateAge()
            end
        end
    end

    if PurgeOldOrders() then
        CraftScanCraftingOrderPage:ShowGeneric()
    else
        C_Timer.After(5, UpdateCells)
    end
end

local function SortItemsByComparator(items, keys, comparator)
    table.sort(items, function(lhs, rhs)
        local cmp = comparator(keys.primarySort.order, lhs, rhs);

        if cmp ~= 0 then
            if keys.primarySort.ascending then
                return cmp < 0
            else
                return cmp > 0
            end
        end

        if keys.secondarySort then
            cmp = comparator(keys.secondarySort.order, lhs, rhs);
            if keys.secondarySort.ascending then
                return cmp < 0
            else
                return cmp > 0
            end
        end

        return false;
    end);
end

function CraftScanCraftingOrderPageMixin:DisableAnalytics()
    self.BrowseFrame.AnalyticsTable:Hide();
    self.BrowseFrame.ResizeButton:Hide();

    self.BrowseFrame.OrderList:SetHeight(self.BrowseFrame.LeftPanel:GetHeight());
end

function CraftScanCraftingOrderPageMixin:EnableAnalytics()
    self.BrowseFrame.AnalyticsTable:Init();
    self.BrowseFrame.AnalyticsTable:Show();
    self.BrowseFrame.ResizeButton:Show();

    self.BrowseFrame.OrderList:SetHeight(CraftScan.DB.settings.order_list_height or 250)
end

function CraftScanCraftingOrderPageMixin:UpdateAnalytics()
    if not self:IsShown() then return end
    self.BrowseFrame.AnalyticsTable:Refresh();
end

function CraftScanCraftingOrderPageMixin:ShowGeneric()
    local scrollBox = self.BrowseFrame.OrderList.ScrollBox;
    scrollBox:Show();

    local dataProvider = CreateDataProvider();
    scrollBox:SetDataProvider(dataProvider);

    local orders = {}
    for _, order in pairs(CraftScan.DB.listed_orders) do
        table.insert(orders, order)
    end

    SortItemsByComparator(orders, self, ApplySortOrder);

    if #orders == 0 then
        self.BrowseFrame.OrderList.ResultsText:SetText(PROFESSIONS_CUSTOMER_NO_ORDERS);
        self.BrowseFrame.OrderList.ResultsText:Show();
    else
        self.BrowseFrame.OrderList.ResultsText:Hide();
    end

    for i, order in ipairs(orders) do
        dataProvider:Insert({
            order = order,
            pageFrame = self,
            contextMenu = self.BrowseFrame.OrderList.ContextMenu
        });
    end
    scrollBox:SetDataProvider(dataProvider);

    ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, self.BrowseFrame.OrderList.ScrollBar, nil, nil);

    C_Timer.After(5, UpdateCells)
end

function CraftScanCraftingOrderPageMixin:SortOrderIsValid(sortOrder)
    return sortOrder == CraftScan.ChatOrderSortOrder.ItemName or sortOrder == CraftScan.ChatOrderSortOrder.CustomerName
end

function CraftScanCraftingOrderPageMixin:ResetSortOrder()
    self.primarySort = {
        order = CraftScan.ChatOrderSortOrder.Time,
        ascending = false
    };

    self.secondarySort = nil;

    if self.tableBuilder then
        for frame in self.tableBuilder:EnumerateHeaders() do
            frame:UpdateArrow();
        end
    end
end

function CraftScanCraftingOrderPageMixin:GetSortOrder()
    return self.primarySort.order, self.primarySort.ascending;
end

function CraftScanCraftingOrderPageMixin:SetSortOrder(sortOrder)
    if self.primarySort.order == sortOrder then
        self.primarySort.ascending = not self.primarySort.ascending;
    else
        self.secondarySort = CopyTable(self.primarySort);
        self.primarySort = {
            order = sortOrder,
            ascending = true
        };
    end

    if self.tableBuilder then
        for frame in self.tableBuilder:EnumerateHeaders() do
            frame:UpdateArrow();
        end
    end

    self:ShowGeneric()
    -- if self.lastRequest then
    -- self.lastRequest.offset = 0; -- Get a fresh page of sorted results
    -- self:SendOrderRequest(self.lastRequest);
    -- end
end

function CraftScanCraftingOrderPageMixin:SetupOrderListTable()
    if not self.tableBuilder then
        self.tableBuilder = CreateTableBuilder(nil, CraftScanOrderTableBuilderMixin);
        local function ElementDataTranslator(elementData)
            return elementData;
        end
        ScrollUtil.RegisterTableBuilder(self.BrowseFrame.OrderList.ScrollBox, self.tableBuilder, ElementDataTranslator);

        local function ElementDataProvider(elementData)
            return elementData;
        end
        self.tableBuilder:SetDataProvider(ElementDataProvider);
    end

    self.tableBuilder:Reset();
    self.tableBuilder:SetColumnHeaderOverlap(2);
    self.tableBuilder:SetHeaderContainer(self.BrowseFrame.OrderList.HeaderContainer);
    self.tableBuilder:SetTableMargins(-3, 5);
    self.tableBuilder:SetTableWidth(777);

    local PTC = CraftScanTableConstants;

    self.tableBuilder:AddFillColumn(self, PTC.NoPadding, 1.0, 8, PTC.ItemName.RightCellPadding,
        CraftScan.ChatOrderSortOrder.ItemName, "CraftScanCrafterTableCellItemNameTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.CustomerName.Width, PTC.CustomerName.LeftCellPadding,
        PTC.CustomerName.RightCellPadding, CraftScan.ChatOrderSortOrder.CustomerName,
        "CraftScanCrafterTableCellCustomerNameTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.CrafterName.Width, PTC.CrafterName.LeftCellPadding,
        PTC.CrafterName.RightCellPadding, CraftScan.ChatOrderSortOrder.CrafterName,
        "CraftScanCrafterTableCellCrafterNameTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.ProfessionName.Width,
        PTC.ProfessionName.LeftCellPadding, PTC.ProfessionName.RightCellPadding,
        CraftScan.ChatOrderSortOrder.ProfessionName,
        "CraftScanCrafterTableCellProfessionNameTemplate");

    self.tableBuilder:AddUnsortableFixedWidthColumn(self, PTC.NoPadding, PTC.Interaction.Width,
        PTC.Interaction.LeftCellPadding, PTC.Interaction.RightCellPadding, L("Replies"),
        "CraftScanCrafterTableCellInteractionTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Time.Width, PTC.Time.LeftCellPadding,
        PTC.Time.RightCellPadding, CraftScan.ChatOrderSortOrder.Time, "CraftScanCrafterTableCellTimeTemplate");

    -- AddUnsortableFixedWidthColumn

    -- self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Tip.Width, PTC.Tip.LeftCellPadding,
    -- PTC.Tip.RightCellPadding, CraftScanSortOrder.Tip, "CraftScanCrafterTableCellActualCommissionTemplate");
    -- self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Reagents.Width, PTC.Reagents.LeftCellPadding,
    -- PTC.Reagents.RightCellPadding, CraftScanSortOrder.Reagents, "CraftScanCrafterTableCellReagentsTemplate");
    -- self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Expiration.Width, PTC.Expiration.LeftCellPadding,
    -- PTC.Expiration.RightCellPadding, CraftScanSortOrder.Expiration,
    -- "CraftScanCrafterTableCellExpirationTemplate");

    self.tableBuilder:Arrange();
end

local function ParentProfessionConfig(crafterInfo)
    return CraftScan.DB.characters[crafterInfo.name].parent_professions[crafterInfo.parentProfessionID];
end

-- States: 0 - all unchecked
--         1 - all checked
--         2 - indeterminate

local function ForEachProfession(op)
    local allTrue = true;
    local allFalse = true;
    for _, crafterConfig in pairs(CraftScan.DB.characters) do
        for _, ppConfig in pairs(crafterConfig.parent_professions) do
            if not ppConfig.character_disabled then
                local result = op(ppConfig);
                if result then
                    allFalse = false;
                else
                    allTrue = false;
                end
            end
        end
    end
    return allTrue and 1 or allFalse and 0 or 2;
end

local function ForEachCrafterFrame(op)
    for _, frame in pairs(CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.CrafterList.ScrollBox:GetFrames()) do
        op(frame)
    end
end

-- We re-use the same template for the header that we use for the rows. The
-- callbacks check if they are the header and act on the whole list if so.
local crafterListAll = nil
local function IsAll(self)
    return self:GetParent() == crafterListAll
end

local function UpdateAllCheckBox(checkbox)
    local stateBefore = checkbox.state;
    checkbox.state =
        ForEachProfession(function(ppConfig)
            return ppConfig[checkbox.ppconfig_key];
        end);
    checkbox:UpdateAllCheckBoxDisplay();
    if stateBefore == 2 and checkbox.state ~= 2 then
        -- If we're applying the remote state, it has already taken the snapshot
        -- for us, so we skip that step here.
        if not CraftScanComm.applying_remote_state then
            checkbox:RememberAllUserState();
        end
    end
end

local function InitAllCheckBox(checkbox)
    if not checkbox.checked_texture then
        checkbox.indeterminate_texture = checkbox:CreateTexture();
        checkbox.indeterminate_texture:SetSize(12, 12);
        checkbox.indeterminate_texture:SetAllPoints(checkbox);
        checkbox.indeterminate_texture:SetAtlas(checkbox.indeterminate_atlas);
        checkbox.indeterminate_texture:Hide();

        checkbox.checked_texture = checkbox:GetCheckedTexture();
    end

    UpdateAllCheckBox(checkbox);
end

CraftScan_CrafterToggleMixin = {}

function CraftScan_CrafterToggleMixin:UpdateAllCheckBoxDisplay()
    self.indeterminate_texture:Hide();
    if self.state == 0 then
        self:SetChecked(false);
    elseif self.state == 1 then
        self:SetCheckedTexture(self.checked_texture);
        self:SetChecked(true);
    else
        self.indeterminate_texture:Show();
        self:SetCheckedTexture(self.indeterminate_texture);
        self:SetChecked(true);
    end
end

function CraftScan_CrafterToggleMixin:RememberAllUserState()
    -- Remember the most recent user specified state so we can restore it when
    -- clicking through to the indeterminate state.
    ForEachProfession(function(ppConfig)
        ppConfig[self.ppconfig_key .. "_last"] = ppConfig[self.ppconfig_key];
    end)
end

function CraftScan_CrafterToggleMixin:OnClick(button)
    if IsAll(self) then
        if self.state == 2 then
            -- Moving from indeterminate to all disabled. Remember the user
            -- configured states of each box so we can click back to
            -- indeterminate to restore it.
            self:RememberAllUserState();
            self.state = 0;
        elseif self.state == 1 then
            local rememberedState = ForEachProfession(function(ppConfig) return ppConfig[self.ppconfig_key .. "_last"]; end);
            if rememberedState == 2 then
                self.state = 2;
            else
                self.state = 0;
            end
        else
            self.state = 1;
        end

        if self.state ~= 2 then
            -- Manually moving everything to all on or all off.
            local checked = self.state == 1;
            ForEachProfession(function(ppConfig)
                ppConfig[self.ppconfig_key] = checked;
            end)

            ForEachCrafterFrame(function(frame)
                frame[self:GetName()]:SetChecked(checked);
            end)

            -- Push only the ppConfig of all characters across
            CraftScanComm:ShareAllPpCharacterModifications();
        else
            -- When moving to the indeterminate state manually, reapply the last
            -- user state.
            ForEachProfession(function(ppConfig)
                ppConfig[self.ppconfig_key] = ppConfig[self.ppconfig_key .. "_last"];
            end)

            -- And update the display to match the saved config.
            ForEachCrafterFrame(function(frame)
                frame[self:GetName()]:InitState();
            end)

            -- Push only the ppConfig of all characters across
            CraftScanComm:ShareAllPpCharacterModifications();
        end

        self:UpdateAllCheckBoxDisplay();
    else
        local crafterInfo = self:GetParent().crafterInfo;
        ParentProfessionConfig(crafterInfo)[self.ppconfig_key] = self:GetChecked();
        UpdateAllCheckBox(crafterListAll[self:GetName()])

        local ppChangeOnly = true;
        CraftScanComm:ShareCharacterModification(crafterInfo.name, crafterInfo.parentProfessionID, ppChangeOnly);
    end
    if GameTooltip:IsShown() then
        self:SetTooltip();
    end
end

function CraftScan_CrafterToggleMixin:InitState()
    self:SetChecked(ParentProfessionConfig(self:GetParent().crafterInfo)[self.ppconfig_key])
end

function CraftScan_CrafterToggleMixin:SetTooltip()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    if self:GetChecked() then
        GameTooltip:SetText(self.enabled_tooltip);
    else
        GameTooltip:SetText(self.disabled_tooltip);
    end
end

function CraftScan_CrafterToggleMixin:OnEnter()
    self:GetParent().HoverBackground:Show();
    self:SetTooltip();
end

function CraftScan_CrafterToggleMixin:OnLeave()
    self:GetParent().HoverBackground:Hide();
    GameTooltip:Hide();
end

local function AddClearAnalytics(rootDescription, itemID)
    local intervals = {
        { L("1 minute"),    60 },
        { L("15 minutes "), 15 * 60 },
        { L("1 hour"),      60 * 60 },
        { L("1 day"),       24 * 60 * 60 },
        { L("1 week "),     7 * 24 * 60 * 60 },
        { L("30 days"),     30 * 24 * 60 * 60 },
        { L("180 days"),    180 * 24 * 60 * 60 },
        { L("1 year"),      365 * 24 * 60 * 60 },
    };

    local recentData = rootDescription:CreateButton(L("Clear recent data"));
    recentData:CreateTitle(L("Newer than"))
    recentData:QueueDivider();
    local function ClearItem(clearInfo)
        if CraftScan.Analytics:ClearAnalyticsForItem(itemID, clearInfo) then
            CraftScanCraftingOrderPage:UpdateAnalytics()
        end
    end
    for _, interval in ipairs(intervals) do
        recentData:CreateButton(interval[1], ClearItem, { seconds = interval[2], recent = true });
    end

    local oldData = rootDescription:CreateButton(L("Clear old data"));
    oldData:CreateTitle(L("Older than"))
    oldData:QueueDivider();
    for i = #intervals, 1, -1 do
        local interval = intervals[i];
        oldData:CreateButton(interval[1], ClearItem, { seconds = interval[2], recent = false });
    end
end

CraftScanAnalyticsTableListElementMixin = CreateFromMixins(TableBuilderRowMixin);

function CraftScanAnalyticsTableListElementMixin:OnClick(button)
    if button == "LeftButton" then
        CraftScan.Utils.ShowTooltipPlot(self, self.item.itemID, self.item.times, true);
    end

    if button == "RightButton" then
        MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
            rootDescription:CreateTitle(owner.item.name);

            local professionAssignment = rootDescription:CreateButton("Assign Profession");
            local professions = GetSortedProfessions();
            for _, profession in ipairs(professions) do
                professionAssignment:CreateRadio(profession.name,
                    function(ppID) return CraftScan.DB.analytics.seen_items[owner.item.itemID].ppID == ppID; end,
                    function(ppID)
                        CraftScan.DB.analytics.seen_items[owner.item.itemID].ppID = ppID;
                        CraftScanCraftingOrderPage:UpdateAnalytics()
                    end,
                    profession.ppID);
            end

            AddClearAnalytics(rootDescription, owner.item.itemID);
        end);
    end
end

function CraftScanAnalyticsTableListElementMixin:OnLineEnter()
    self.HighlightTexture:Show();
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetItemByID(self.item.itemID);
    GameTooltip:Show();
    CraftScan.Utils.ShowTooltipPlot(self, self.item.itemID, self.item.times);
end

function CraftScanAnalyticsTableListElementMixin:OnLineLeave()
    self.HighlightTexture:Hide();
    GameTooltip:Hide();
    CraftScan.Utils.HideTooltipPlot();
end

function CraftScanAnalyticsTableListElementMixin:OnHide()
    CraftScan.Utils.ForceHideTooltipPlot()
end

function CraftScanAnalyticsTableListElementMixin:Init(elementData)
    self.item = elementData.item;
    self.pageFrame = elementData.pageFrame;
    self.contextMenu = elementData.contextMenu;
end

CraftScanAnalyticsTableMixin = {}

local analyticsInitialized = false
function CraftScanAnalyticsTableMixin:Init()
    if not CraftScan.DB.analytics.enabled or analyticsInitialized then return; end

    self:ResetSortOrder();

    local pad = 5;
    local spacing = 1;
    local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
    view:SetElementInitializer("CraftScanAnalyticsTableListElementTemplate", function(button, elementData)
        button:Init(elementData);
    end);
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    if not self.tableBuilder then
        self.tableBuilder = CreateTableBuilder(nil, CraftScanAnalyticsTableBuilderMixin);
        local function ElementDataTranslator(elementData)
            return elementData;
        end
        ScrollUtil.RegisterTableBuilder(self.ScrollBox, self.tableBuilder, ElementDataTranslator);

        local function ElementDataProvider(elementData)
            return elementData;
        end
        self.tableBuilder:SetDataProvider(ElementDataProvider);
    end

    self.tableBuilder:Reset();
    self.tableBuilder:SetColumnHeaderOverlap(2);
    self.tableBuilder:SetHeaderContainer(self.HeaderContainer);
    self.tableBuilder:SetTableMargins(-3, 5);
    self.tableBuilder:SetTableWidth(777);

    local ATC = CraftScanAnalyticsTableConstants;

    self.tableBuilder:AddFillColumn(self, ATC.NoPadding, 1.0, 8, ATC.ItemName.RightCellPadding,
        CraftScan.AnalyticsTableSortOrder.ItemName, "CraftScanAnalyticsCellItemNameTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, ATC.NoPadding, ATC.ProfessionName.Width,
        ATC.ProfessionName.LeftCellPadding,
        ATC.ProfessionName.RightCellPadding, CraftScan.AnalyticsTableSortOrder.ProfessionName,
        "CraftScanAnalyticsTableCellProfessionNameTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, ATC.NoPadding, ATC.TotalSeen.Width, ATC.TotalSeen.LeftCellPadding,
        ATC.TotalSeen.RightCellPadding, CraftScan.AnalyticsTableSortOrder.TotalSeen,
        "CraftScanAnalyticsTableCellTotalSeenTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, ATC.NoPadding, ATC.TotalSeenFiltered.Width,
        ATC.TotalSeenFiltered.LeftCellPadding,
        ATC.TotalSeenFiltered.RightCellPadding, CraftScan.AnalyticsTableSortOrder.TotalSeenFiltered,
        "CraftScanAnalyticsTableCellTotalSeenFilteredTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, ATC.NoPadding, ATC.AveragePerDay.Width, ATC.AveragePerDay
        .LeftCellPadding,
        ATC.AveragePerDay.RightCellPadding, CraftScan.AnalyticsTableSortOrder.AveragePerDay,
        "CraftScanAnalyticsTableCellAveragePerDayTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, ATC.NoPadding, ATC.PeakPerHour.Width, ATC.PeakPerHour.LeftCellPadding,
        ATC.PeakPerHour.RightCellPadding, CraftScan.AnalyticsTableSortOrder.PeakPerHour,
        "CraftScanAnalyticsTableCellPeakPerHourTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, ATC.NoPadding, ATC.MedianPerCustomer.Width,
        ATC.MedianPerCustomer.LeftCellPadding,
        ATC.MedianPerCustomer.RightCellPadding, CraftScan.AnalyticsTableSortOrder.MedianPerCustomer,
        "CraftScanAnalyticsTableCellMedianPerCustomerTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, ATC.NoPadding, ATC.MedianPerCustomerFiltered.Width,
        ATC.MedianPerCustomerFiltered.LeftCellPadding,
        ATC.MedianPerCustomerFiltered.RightCellPadding, CraftScan.AnalyticsTableSortOrder.MedianPerCustomerFiltered,
        "CraftScanAnalyticsTableCellMedianPerCustomerFilteredTemplate");

    self.tableBuilder:Arrange();

    analyticsInitialized = true
end

function CraftScanAnalyticsTableMixin:SortOrderIsValid(sortOrder)
    return true;
end

function CraftScanAnalyticsTableMixin:ResetSortOrder()
    self.primarySort = {
        order = CraftScan.AnalyticsTableSortOrder.TotalSeen,
        ascending = false
    };

    self.secondarySort = nil;

    if self.tableBuilder then
        for frame in self.tableBuilder:EnumerateHeaders() do
            frame:UpdateArrow();
        end
    end
end

function CraftScanAnalyticsTableMixin:GetSortOrder()
    return self.primarySort.order, self.primarySort.ascending;
end

function CraftScanAnalyticsTableMixin:SetSortOrder(sortOrder)
    if self.primarySort.order == sortOrder then
        self.primarySort.ascending = not self.primarySort.ascending;
    else
        self.secondarySort = CopyTable(self.primarySort);
        self.primarySort = {
            order = sortOrder,
            ascending = true
        };
    end

    if self.tableBuilder then
        for frame in self.tableBuilder:EnumerateHeaders() do
            frame:UpdateArrow();
        end
    end

    self:Refresh()
end

function CraftScanAnalyticsTableMixin:OnShow()
    self:Refresh();
end

local function ApplyAnalyticsSortOrder(sortOrder, lhsItem, rhsItem)
    if sortOrder == CraftScan.AnalyticsTableSortOrder.ItemName then
        return SortUtil.CompareUtf8i(lhsItem.name, rhsItem.name);
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.ProfessionName then
        return SortUtil.CompareUtf8i(lhsItem.profession, rhsItem.profession);
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.TotalSeen then
        return SortUtil.CompareNumeric(lhsItem.totalSeen, rhsItem.totalSeen);
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.TotalSeenFiltered then
        return SortUtil.CompareNumeric(lhsItem.totalSeenFiltered, rhsItem.totalSeenFiltered);
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.AveragePerDay then
        return SortUtil.CompareNumeric(lhsItem.averagePerDay, rhsItem.averagePerDay);
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.PeakPerHour then
        return SortUtil.CompareNumeric(lhsItem.peakPerHour, rhsItem.peakPerHour);
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.MedianPerCustomer then
        return SortUtil.CompareNumeric(lhsItem.medianPerCustomer, rhsItem.medianPerCustomer);
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.MedianPerCustomerFiltered then
        return SortUtil.CompareNumeric(lhsItem.medianPerCustomerFiltered, rhsItem.medianPerCustomerFiltered);
    end
    return 0;
end

local function GetTimeStamp(timeEntry)
    return CraftScan.Analytics.GetTimeStamp(timeEntry);
end

local function CalculateAveragePerDay(times)
    local totalTimes = #times;
    local timeSpan = GetTimeStamp(times[totalTimes]) - GetTimeStamp(times[1]);
    local numberOfDays = math.max(1, timeSpan / 86400);
    return totalTimes / numberOfDays;
end

local function CalculateMedianPerCustomer(times)
    local indices = {}
    local n = #times;
    for i = 1, n do
        indices[i] = i
    end

    table.sort(indices, function(lhs, rhs)
        local lhsValue = type(times[lhs]) == "table" and times[lhs].c or 1;
        local rhsValue = type(times[rhs]) == "table" and times[rhs].c or 1;
        return lhsValue < rhsValue;
    end)

    -- Ignoring full correctness for simplicity, median is half way ignoring odd/even count.
    local medianPerCustomer = times[indices[math.ceil(n / 2)]]

    -- Count the number of entries that included a repeat count, then get the
    -- median of those. We're sorted low-high with raw timestamps first. Walk
    -- until we hit the first entry with a count. We likely have far more single
    -- requests than repeats, so walk in reverse.
    local begin = 1;
    for i = #indices, 1, -1 do
        if type(times[indices[i]]) ~= "table" then
            begin = i + 1;
            break;
        end
    end

    local filteredTotal = n - begin;
    local medianPerCustomerFiltered = times[indices[math.ceil(filteredTotal / 2) + begin]]

    return type(medianPerCustomer) == "table" and medianPerCustomer.c or 1,
        type(medianPerCustomerFiltered) == "table" and medianPerCustomerFiltered.c or 1;
end

local function CalculatePeakPerHour(times)
    local peakHour = nil;
    local peakCount = 0;
    local j = 1;
    for i = 1, #times do
        local windowStart = GetTimeStamp(times[i]);
        local windowEnd = windowStart + 3600;

        -- Move to the end of the 1 hour window after i.
        while j <= #times and GetTimeStamp(times[j]) <= windowEnd do
            j = j + 1;
        end

        local count = j - i;
        if count > peakCount then
            peakCount = count;
            peakHour = windowStart;
        end
    end
    return peakCount, peakHour;
end

function CountDuplicates(array)
    local count = 0
    for _, value in ipairs(array) do
        if type(value) == "table" and value.c and value.c > 1 then
            count = count + 1
        end
    end
    return count
end

function TableSize(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function CraftScanAnalyticsTableMixin:Refresh()
    if not CraftScan.DB.analytics.enabled then return; end

    self.ScrollBox:Show();

    local seenItems = CraftScan.DB.analytics.seen_items;
    if not seenItems or not next(seenItems) then
        self.ResultsText:SetText(L("No analytics data"));
        self.ResultsText:Show();
        return;
    else
        self.ResultsText:Hide();
    end

    local items = {}
    for itemID, itemInfo in pairs(seenItems) do
        item = Item:CreateFromItemID(itemID);
        item:ContinueOnItemLoad(function()
            local peakPerHour, peakHour = CalculatePeakPerHour(itemInfo.times);
            local medianPerCustomer, medianPerCustomerFiltered = CalculateMedianPerCustomer(itemInfo.times);
            table.insert(items, {
                itemID = itemID,
                times = itemInfo.times,
                name = item:GetItemName(),
                profession = itemInfo.ppID and CraftScan.Utils.ColorizedProfessionNameByID(itemInfo.ppID) or "Unknown",
                totalSeen = #itemInfo.times,
                totalSeenFiltered = CountDuplicates(itemInfo.times),
                averagePerDay = CalculateAveragePerDay(itemInfo.times),
                peakPerHour = peakPerHour,
                peakHour = peakHour,
                medianPerCustomer = medianPerCustomer,
                medianPerCustomerFiltered = medianPerCustomerFiltered,
            })
        end)
    end

    local dataProvider = CreateDataProvider();
    self.ScrollBox:SetDataProvider(dataProvider);
    local function OnAllItemsLoaded()
        if #items ~= TableSize(seenItems) then
            -- Wait for all item links to be asynchronously loaded.
            C_Timer.After(0, OnAllItemsLoaded)
            --return;
        end

        SortItemsByComparator(items, self, ApplyAnalyticsSortOrder);

        for _, item in ipairs(items) do
            dataProvider:Insert({
                item = item,
                pageFrame = self,
            });
        end
        self.ScrollBox:SetDataProvider(dataProvider);
    end

    OnAllItemsLoaded();
end

local function EscapeCSV(str)
    if str:find('[,"]') then
        -- Double up any existing quotes
        str = str:gsub('"', '""')
        -- Enclose the entire string in double quotes
        str = '"' .. str .. '"'
    end
    return str
end

CraftScan_ResetAnalyticsButtonMixin = {}

function CraftScan_ResetAnalyticsButtonMixin:OnLoad()
    self:SetText(L("Analytics Options"))
    self:FitToText();

    CraftScan.Utils.onLoad(function()
        self:SetupMenu(function(owner, rootDescription)
            do
                local function IsSelected()
                    return CraftScan.DB.analytics.enabled;
                end

                local function SetSelected()
                    CraftScan.DB.analytics.enabled = not CraftScan.DB.analytics.enabled;
                    UpdateAnalyticsEnabled();
                end

                rootDescription:CreateCheckbox(L("Gather Analytics"), IsSelected, SetSelected);
            end
            rootDescription:CreateTitle(L("Reset Data"));
            AddClearAnalytics(rootDescription);
            rootDescription:QueueDivider();
            rootDescription:QueueTitle(L("Export"));
            rootDescription:CreateButton(L("Export CSV"), function()
                local seenItems = CraftScan.DB.analytics.seen_items;
                if not seenItems or not next(seenItems) then return; end

                local csv = "itemID,name,time,count,wowhead" .. "\n";
                for itemID, entry in pairs(seenItems) do
                    local item = Item:CreateFromItemID(itemID);
                    local name = EscapeCSV(item:GetItemName());
                    for _, time in ipairs(entry.times) do
                        local t = type(time) == "table" and time.t or time;
                        local c = type(time) == "table" and time.c or 1;
                        csv = csv ..
                            string.format("%d,%s,%d,%d,https://www.wowhead.com/item=%d/", itemID, name, t, c, itemID) ..
                            "\n";
                    end
                end
                CraftScan.Utils.DumpCopyableText(csv);
            end)
        end);
    end)
end

CraftScan_ResizeOrderListButtonMixin = {}

function CraftScan_ResizeOrderListButtonMixin:OnLoad()
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
end

function CraftScan_ResizeOrderListButtonMixin:OnMouseDown()
    self.isDragging = true

    self.startY = select(2, GetCursorPosition())
    self.startHeight = self:GetParent().OrderList:GetHeight()
    self:GetParent().OrderList:SetScript("OnUpdate", function()
        if self.isDragging then
            local currentY = select(2, GetCursorPosition())
            local offsetY = self.startY - currentY;
            local newHeight = math.min(450, math.max(self.startHeight + offsetY, 100))
            self:GetParent().OrderList:SetHeight(newHeight)
            CraftScan.DB.settings.order_list_height = newHeight;
        end
    end)
end

function CraftScan_ResizeOrderListButtonMixin:OnMouseUp()
    self.isDragging = false
    self:GetParent().OrderList:SetScript("OnUpdate", nil);
    ResetCursor()
end

function CraftScan:GetSortedCrafters()
    local crafterRows = {}
    for name, info in pairs(CraftScan.DB.characters) do
        for parentProfessionID, ppInfo in pairs(info.parent_professions) do
            if not ppInfo.character_disabled then
                table.insert(crafterRows, {
                    name = name,
                    parentProfessionID = parentProfessionID,
                })
            end
        end
    end

    -- Sort characters so all primary crafters appear first, then alphabetically within the two groups.
    table.sort(crafterRows, function(lhs, rhs)
        local lhsPpConfig = CraftScan.DB.characters[lhs.name].parent_professions[lhs.parentProfessionID];
        local rhsPpConfig = CraftScan.DB.characters[rhs.name].parent_professions[rhs.parentProfessionID];

        local secondarySort = function()
            if lhs.name ~= rhs.name then
                return lhs.name < rhs.name
            end

            local lhsProfInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(lhs.parentProfessionID);
            local rhsProfInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(rhs.parentProfessionID);

            return lhsProfInfo.professionName < rhsProfInfo.professionName
        end

        if lhsPpConfig.primary_crafter then
            if rhsPpConfig.primary_crafter then
                return secondarySort()
            end
            return true;
        end

        if rhsPpConfig.primary_crafter then
            return false;
        end

        return secondarySort()
    end)
    return crafterRows;
end

CraftScan_CrafterListMixin = {}

function CraftScan_CrafterListMixin:SetupCrafterList()
    crafterListAll = self.CrafterListAllButton;

    InitAllCheckBox(crafterListAll.EnabledCheckBox)
    InitAllCheckBox(crafterListAll.SoundAlertCheckBox)
    InitAllCheckBox(crafterListAll.VisualAlertCheckBox)

    -- TODO Make this big and find a better texture
    crafterListAll.CrafterName:SetText(L("All crafters"))
    crafterListAll:Show();

    local topPadding = 3;
    local leftPadding = 4;
    local rightPadding = 2;
    local spacing = 1;
    local view = CreateScrollBoxListLinearView(topPadding, 0, leftPadding, rightPadding, spacing);

    local function FrameInitializer(frame, crafterInfo)
        local crafterName = CraftScan.ColorizeCrafterName(crafterInfo.name)
        frame.CrafterName:SetText(crafterName)
        frame.crafterInfo = crafterInfo
        frame.EnabledCheckBox:InitState()
        frame.SoundAlertCheckBox:InitState()
        frame.VisualAlertCheckBox:InitState()
        frame.ProfessionIcon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(crafterInfo.parentProfessionID))
        frame:RegisterForClicks("AnyUp");

        local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(crafterInfo.parentProfessionID);
        frame.ProfessionName:SetText(CraftScan.Utils.ColorizeProfessionName(profInfo.professionID,
            profInfo.professionName))

        if CraftScan.DB.characters[crafterInfo.name].parent_professions[crafterInfo.parentProfessionID].primary_crafter then
            frame.PrimaryCrafterIcon:Show();
        else
            frame.PrimaryCrafterIcon:Hide();
        end
        frame.LinkedAccountIcon:Init(frame.crafterInfo);
    end

    view:SetElementFactory(function(factory)
        factory("CraftScanCrafterListElementTemplate", FrameInitializer);
    end);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    -- Highly unlikely to ever need a scroll bar, so hide it unless needed.
    -- Tested one time with 20 dummy characters in the config and the scroll
    -- bar did appear and was usable.
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, nil,
        nil);


    local crafterRows = CraftScan.GetSortedCrafters();
    local dataProvider = CreateDataProvider(crafterRows)
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function CraftScan_CrafterListMixin:OnShow()
    self:SetupCrafterList();
end

CraftScanCrafterListElementMixin = {}

function CraftScanCrafterListElementMixin:OnEnter()
    self.HoverBackground:Show();
end

function CraftScanCrafterListElementMixin:OnLeave()
    self.HoverBackground:Hide();
end

function CraftScan.OnCrafterListModified()
    if CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.CrafterList:IsShown() then
        -- Refresh the list to display the change.
        CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.CrafterList:SetupCrafterList();
    end

    -- Reload the scanner data to apply the change.
    CraftScan.Scanner.LoadConfig()
end

-- Provide common properties for our various confirmations.
local function SetupPopupDialog(key, config)
    local popup = {
        button2 = "Cancel",
        OnCancel = nil,
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3, -- Avoid UI taint issues by using a higher index
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            parent.button1:Click() -- Simulate a click on the Confirm button
        end,
        EditBoxOnEscapePressed = function(self)
            local parent = self:GetParent()
            parent.button2:Click() -- Simulate a click on the Cancel button
        end,
    };
    for key, value in pairs(config) do
        popup[key] = value;
    end
    StaticPopupDialogs[key] = popup;
end

function CraftScan.RemoveChildProfessions(charConfig, ppID)
    local pConfigs = charConfig.professions;
    for profID, config in pairs(pConfigs) do
        if config.parentProfID == ppID then
            pConfigs[profID] = nil;
        end
    end
end

-- The confirmation dialog to 'disable' a profession for a specific character.
SetupPopupDialog("CRAFT_SCAN_CONFIRM_CONFIG_DELETE", {
    text = L(LID.DELETE_CONFIG_TOOLTIP_TEXT) .. '\n\n' .. L(LID.DELETE_CONFIG_CONFIRM),
    button1 = "Delete",
    OnAccept = function(self, crafterInfo)
        local userInput = self.editBox:GetText()
        if string.lower(userInput) == "delete" then
            local charConfig = CraftScan.DB.characters[crafterInfo.name];

            -- Flag the profession as disabled. We don't fully delete it
            -- because we want to remember that the user disabled it so
            -- we don't keep re-enabling it when they open the
            -- profession window.
            local parentProfID = crafterInfo.parentProfessionID;

            -- Wipe the ppConfig to a clean slate.
            local rev = charConfig.parent_professions[parentProfID].rev;
            charConfig.parent_professions[parentProfID] = CraftScan.Utils.DeepCopy(CraftScan.CONST.DEFAULT_PPCONFIG);
            local ppConfig = charConfig.parent_professions[parentProfID];
            ppConfig.rev = rev; -- The revision needs to persist through disable/enable cycles so we know which side wins.
            ppConfig.character_disabled = true;

            -- Delete all details about the expansion level professions.
            CraftScan.RemoveChildProfessions(charConfig, parentProfID);

            -- Send the modification to any linked accounts.
            local ppChangeOnly = true;
            CraftScanComm:ShareCharacterModification(crafterInfo.name, parentProfID, ppChangeOnly);

            CraftScan.OnCrafterListModified();
        else
            print("CraftScan confirmation failed.")
        end
    end
})

-- The confirmation dialog to 'cleanup' a profession for a specific character.
SetupPopupDialog("CRAFT_SCAN_CONFIRM_CONFIG_CLEANUP", {
    text = L(LID.CLEANUP_CONFIG_TOOLTIP_TEXT) .. '\n\n' .. L(LID.CLEANUP_CONFIG_CONFIRM),
    button1 = "Cleanup",
    OnAccept = function(self, crafterInfo)
        local userInput = self.editBox:GetText()
        if string.lower(userInput) == "cleanup" then
            local charConfig = CraftScan.DB.characters[crafterInfo.name];

            -- Fully delete the parent profession and all references to it
            local parentProfID = crafterInfo.parentProfessionID;
            charConfig.parent_professions[parentProfID] = nil;

            local pConfigs = charConfig.professions;
            for profID, config in pairs(pConfigs) do
                if config.parentProfID == parentProfID then
                    pConfigs[profID] = nil;
                end
            end

            CraftScan.OnCrafterListModified();
        else
            print("CraftScan confirmation failed.")
        end
    end
})

CraftScan_PrimaryCrafterIconMixin = {}

function CraftScan_PrimaryCrafterIconMixin:OnShow()
    local linkedAccount = self:GetParent().LinkedAccountIcon;
    linkedAccount:ClearAllPoints()
    linkedAccount:SetPoint("LEFT", self, "RIGHT", 2, 0)
end

function CraftScan_PrimaryCrafterIconMixin:OnHide()
    local linkedAccount = self:GetParent().LinkedAccountIcon;
    if linkedAccount then
        linkedAccount:ClearAllPoints()
        linkedAccount:SetPoint("LEFT", self:GetParent().CrafterName, "RIGHT", 2, 0)
    end
end

CraftScan_LinkedAccountIconMixin = {}

function CraftScan_LinkedAccountIconMixin:Init(crafterInfo)
    -- GetParent() doesn't return during OnLoad, so we have a manual init call
    -- to receive the crafterInfo directly.
    local charConfig = CraftScan.DB.characters[crafterInfo.name];
    if charConfig.sourceID and charConfig.sourceID ~= CraftScan.DB.settings.my_uuid then
        self:Show();
    else
        self:Hide();
    end
end

function CraftScan_LinkedAccountIconMixin:OnEnter()
    local crafter = self:GetParent().crafterInfo.name;
    local sourceID = CraftScan.DB.characters[crafter].sourceID;
    local nickname = CraftScan.DB.realm.linked_accounts[sourceID].nickname;

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(string.format(L(LID.REMOTE_CRAFTER_SUMMARY), nickname));
    GameTooltip:Show()
end

function CraftScan_LinkedAccountIconMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScan_ProxyEnabledMixin = {}

function CraftScan_ProxyEnabledMixin:OnShow()
    local value = CraftScan.DB.settings[self.key] or false;
    self:SetChecked(value);
    self.Text:SetText(L(self.key));
end

function CraftScan_ProxyEnabledMixin:OnClick()
    CraftScan.DB.settings[self.key] = not CraftScan.DB.settings[self.key];

    -- If disabled out in the world, we need a kick to hide the button.
    CraftScanScannerMenu:UpdateFrameVisibility();
end

function CraftScan_ProxyEnabledMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L(LID[self.tooltip]), 1, 1, 1, 1, true)
    GameTooltip:Show()
end

function CraftScan_ProxyEnabledMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScan_LinkAccountButtonMixin = {}

function CraftScan_LinkAccountButtonMixin:Reset()
    self:SetText(L("Link Account"));
    self:FitToText();
end

function CraftScan_LinkAccountButtonMixin:OnShow()
    self:Reset();
end

function CraftScan_LinkAccountButtonMixin:OnLoad()
    self:Reset();
end

function CraftScan_LinkAccountButtonMixin:OnClick()
    local Validator = function(fullcontrol, analytics, character, nickname)
        return fullcontrol == true or analytics == true;
    end

    local OnAccept = function(fullcontrol, analytics, character, nickname)
        if not CraftScan.State.realmID and string.find(character, "-") == nil then
            -- On non-connected realms, hardcode the realm to our own to
            -- avoid auto-complete on whisper sending to our own characters
            -- on other realms.
            character = CraftScan.GetUnitName(character, true, true);
        end
        local permissions = {};
        if fullcontrol then
            table.insert(permissions, CraftScanComm.Permissions.Full);
        elseif analytics then
            table.insert(permissions, CraftScanComm.Permissions.Analytics);
        end
        CraftScanComm:SendHandshake(character, nickname, permissions);
    end
    local elements = {
        {
            type = CraftScan.Dialog.Element.Text,
            text = L(LID.ACCOUNT_LINK_DESC),
        },
        {
            type = CraftScan.Dialog.Element.Text,
            text = L(LID.ACCOUNT_LINK_PERMISSIONS_DESC),
        },
        {
            type = CraftScan.Dialog.Element.CheckButton,
            default = true,
            text = L(CraftScanComm.PermissionStrings[CraftScanComm.Permissions.Full].name),
            description = L(CraftScanComm.PermissionStrings[CraftScanComm.Permissions.Full].desc),
        },
        {
            type = CraftScan.Dialog.Element.CheckButton,
            text = L(CraftScanComm.PermissionStrings[CraftScanComm.Permissions.Analytics].name),
            description = L(CraftScanComm.PermissionStrings[CraftScanComm.Permissions.Analytics].desc),
        },
        {
            type = CraftScan.Dialog.Element.Text,
            text = L(LID.ACCOUNT_LINK_PROMPT_CHARACTER),
            padding = 10,
        },
        {
            type = CraftScan.Dialog.Element.EditBox,
        },
        {
            type = CraftScan.Dialog.Element.Text,
            text = L(LID.ACCOUNT_LINK_PROMPT_NICKNAME),
            padding = 10,
        },
        {
            type = CraftScan.Dialog.Element.EditBox,
        },
    }
    CraftScan.Dialog.Show({
        key = "link_account",
        title = L("Link Account"),
        submit = L("Link Account"),
        Validator = Validator,
        OnAccept = OnAccept,
        elements = elements,
    })
end

function CraftScan.OnPendingPeerAdded()
    CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkAccountControls.LinkAccountButton:Reset();

    if CraftScanCraftingOrderPage:IsShown() then
        CreateAcceptLinkedAccountDialog();
    end
end

function CraftScan.OnPendingPeerAccepted()
    CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:Init();
end

CraftScan_LinkedAccountListMixin = {}

function CraftScan_LinkedAccountListMixin:OnShow()
    self:Init();
end

function FormatTimeAgo(pastTime)
    local currentTime = time()
    local diff = currentTime - pastTime

    if diff < 60 then
        return diff .. "s"
    elseif diff < 3600 then
        local minutes = math.floor(diff / 60)
        return minutes .. "m"
    else
        local hours = math.floor(diff / 3600)
        return hours .. "h"
    end
end

function CraftScan_LinkedAccountListMixin:Init()
    -- If there are linked accounts, show additional controls for them.
    -- Otherwise, we only show the button to create a link.
    local showList = CraftScan.DB.realm.linked_accounts and next(CraftScan.DB.realm.linked_accounts);

    local linkAccountControls = self:GetParent().LinkAccountControls;
    if showList then
        linkAccountControls:SetHeight(70)
        linkAccountControls.ProxyReceiveEnabled:Show();
        linkAccountControls.ProxySendEnabled:Show();
    else
        linkAccountControls:SetHeight(35)
        linkAccountControls.ProxyReceiveEnabled:Hide();
        linkAccountControls.ProxySendEnabled:Hide();
    end

    local crafterList = self:GetParent().CrafterList;
    crafterList:ClearAllPoints();
    crafterList:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 0, 0);
    crafterList:SetPoint("BOTTOMLEFT", linkAccountControls, "TOPLEFT", 0, showList and 105 or 0);

    if not showList then
        self:Hide();
        return;
    end

    self.Title:SetText(L("Linked Accounts"));

    local topPadding = 3;
    local leftPadding = 4;
    local rightPadding = 2;
    local spacing = 1;
    local view = CreateScrollBoxListLinearView(topPadding, 0, leftPadding, rightPadding, spacing);

    local function FrameInitializer(frame, linkedAccount)
        frame.linkedAccount = linkedAccount;
        frame.AccountName:SetText(linkedAccount.info.nickname);
        frame.UpdateDisplay = function(frame)
            local linkedAccount = frame.linkedAccount;
            local connectedTo, lastSeen = CraftScanComm:LinkState(linkedAccount.sourceID);
            frame.LinkState:SetText(connectedTo and
                string.format(L(LID.LINK_ACTIVE), CraftScan.NameAndRealmToName(connectedTo, true),
                    FormatTimeAgo(lastSeen)) or
                FRIENDS_LIST_OFFLINE);

            frame.StatusIcon:SetTexture(connectedTo and FRIENDS_TEXTURE_ONLINE or FRIENDS_TEXTURE_OFFLINE);
        end
        frame.UpdateDisplay(frame);
    end

    view:SetElementFactory(function(factory)
        factory("CraftScan_LinkedAccountListElementTemplate", FrameInitializer);
    end);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    -- Highly unlikely to ever need a scroll bar, so hide it unless needed.
    -- Tested one time with 20 dummy characters in the config and the scroll
    -- bar did appear and was usable.
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, nil,
        nil);

    local linkedAccounts = {}
    for sourceID, info in pairs(CraftScan.DB.realm.linked_accounts) do
        table.insert(linkedAccounts, {
            sourceID = sourceID,
            info = info
        });
    end

    -- Sort characters so all primary crafters appear first, then alphabetically within the two groups.
    table.sort(linkedAccounts, function(lhs, rhs)
        return lhs.info.nickname < rhs.info.nickname;
    end)

    local dataProvider = CreateDataProvider(linkedAccounts)
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

    local function UpdateDisplay()
        if CraftScanCraftingOrderPage:IsShown() then
            for _, frame in pairs(CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList.ScrollBox:GetFrames()) do
                frame.UpdateDisplay(frame);
            end

            C_Timer.After(5, self.UpdateDisplay)
        end
    end

    if self.UpdateDisplay then
        self.UpdateDisplay:Cancel();
    end
    self.UpdateDisplay = C_FunctionContainers.CreateCallback(UpdateDisplay);
    UpdateDisplay();

    self:Show();
end

CraftScan_LinkedAccountListElementMixin = {}

function CraftScan_LinkedAccountListElementMixin:OnClick()
    local linkedAccountID = self.linkedAccount.sourceID;
    local linkedAccount = self.linkedAccount.info;
    MenuUtil.CreateContextMenu(owner, function(owner, rootDescription)
        local hasFull = CraftScan.Utils.Contains(linkedAccount.permissions, CraftScanComm.Permissions.Full);
        local hasAnalytics = CraftScan.Utils.Contains(linkedAccount.permissions, CraftScanComm.Permissions.Analytics);

        local crafterList = {}
        for char, charConfig in pairs(CraftScan.DB.characters) do
            if charConfig.sourceID == linkedAccountID then
                table.insert(crafterList, CraftScan.NameAndRealmToName(char));
            end
        end


        do
            rootDescription:CreateTitle(linkedAccount.nickname);
            rootDescription:QueueDivider();

            if hasFull then
                rootDescription:QueueTitle(
                    L(CraftScanComm.PermissionStrings[CraftScanComm.Permissions.Full].name));
            else
                for _, perm in ipairs(linkedAccount.permissions) do
                    rootDescription:QueueTitle(L(CraftScanComm.PermissionStrings[perm].name));
                end
            end
        end
        do
            rootDescription:QueueDivider();
            rootDescription:QueueTitle(L("Backup characters"));
            local OnClick = function(char)
                for i, backup_char in ipairs(linkedAccount.backup_chars) do
                    if char == backup_char then
                        table.remove(linkedAccount.backup_chars, i)
                        break;
                    end
                end
            end

            for _, char in ipairs(linkedAccount.backup_chars) do
                local popoutButton = rootDescription:CreateButton(char);
                popoutButton:CreateButton(L("Remove"), OnClick, char);
            end

            do
                local OnClick = function()
                    local function AddChar(char)
                        if not CraftScan.State.realmID and string.find(char, "-") == nil then
                            -- Normalize adding the current realm onto
                            -- non-connected realms that don't provide it.
                            char = CraftScan.GetUnitName(char, true);
                        end

                        table.insert(CraftScan.DB.realm.linked_accounts[linkedAccountID].backup_chars, char);
                    end
                    CraftScan.Dialog.Show({
                        key = "add_backup_char",
                        title = L("Add character"),
                        submit = L("Add character"),
                        OnAccept = AddChar,
                        elements = {
                            {
                                type = CraftScan.Dialog.Element.Text,
                                text = string.format(L(LID.ACCOUNT_LINK_ADD_CHAR)),
                            },
                            {
                                type = CraftScan.Dialog.Element.EditBox,
                            },
                        },
                    });
                end

                local button = rootDescription:CreateButton(L("Add"), OnClick, nil)
            end
        end
        if hasFull or hasAnalytics then
            rootDescription:QueueDivider();
            do
                local function OnClick()
                    CraftScanComm:ShareAnalytics(linkedAccountID);
                end

                rootDescription:CreateButton(L("Sync Analytics"), OnClick, nil)
            end
            do
                local function OnClick()
                    CraftScanComm:ShareAnalytics(linkedAccountID, true);
                end

                rootDescription:CreateButton(L("Sync Recent Analytics"), OnClick, nil)
            end
        end
        rootDescription:QueueDivider();
        do
            local function DoRename(nickname)
                linkedAccount.nickname = nickname;
                CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:Init();
            end

            local OnClick = function()
                CraftScan.Dialog.Show({
                    key = "rename_linked_account",
                    title = L("Rename account"),
                    submit = L("Rename account"),
                    OnAccept = DoRename,
                    elements = {
                        {
                            type = CraftScan.Dialog.Element.Text,
                            text = L("New name"),
                        },
                        {
                            type = CraftScan.Dialog.Element.EditBox,
                        },
                    },
                });
            end

            rootDescription:CreateButton(L("Rename account"), OnClick, nil)
        end

        do
            local function DoDelete()
                for char, charConfig in pairs(CraftScan.DB.characters) do
                    if charConfig.sourceID == linkedAccountID then
                        CraftScan.DB.characters[char] = nil;
                    end
                end
                CraftScan.DB.realm.linked_accounts[linkedAccountID] = nil;

                CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:Init();
                CraftScan.OnCrafterListModified();
            end

            local OnClick = function()
                CraftScan.Dialog.Show({
                    key = "delete_linked_account",
                    title = L("Delete Linked Account"),
                    submit = L("Delete Linked Account"),
                    OnAccept = DoDelete,
                    elements = {
                        {
                            type = CraftScan.Dialog.Element.Text,
                            text = string.format(L(LID.ACCOUNT_LINK_DELETE_INFO), linkedAccount.nickname,
                                table.concat(crafterList, "\n")),
                        },
                    },
                });
            end

            rootDescription:CreateButton(L("Unlink account"), OnClick, nil)
        end
    end);
end

function CraftScan_LinkedAccountListElementMixin:OnEnter()
    self.HoverBackground:Show();
end

function CraftScan_LinkedAccountListElementMixin:OnLeave()
    self.HoverBackground:Hide();
end

function CraftScan.OnLinkedAccountStateChange()
    if CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:IsShown() then
        CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:Init();
    end
end

local function ProcessPrimaryCrafterUpdate(crafterInfo, ppConfig)
    -- We can only have one primary crafter for a given profession, so walk the
    -- list and turn off the others.
    if not ppConfig.primary_crafter then
        return
    end

    for char, charConfig in pairs(CraftScan.DB.characters) do
        if char ~= crafterInfo.name then
            for parentProfID, parentProfConfig in pairs(charConfig.parent_professions) do
                if parentProfID == crafterInfo.parentProfessionID and parentProfConfig.primary_crafter then
                    parentProfConfig.primary_crafter = false;

                    local ppChangeOnly = true;
                    CraftScanComm:ShareCharacterModification(char, parentProfID, ppChangeOnly);

                    return; -- There can only be one.
                end
            end
        end
    end
end

local function SetTooltipWithTitle(tooltip, elementDescription)
    local data = elementDescription:GetData();
    GameTooltip_SetTitle(tooltip, data.tooltipTitle or MenuUtil.GetElementText(elementDescription));
    GameTooltip_AddNormalLine(tooltip, data.tooltipText);
end;


-- We only register for RightButton on the individual character rows, not the
-- 'All Crafters' row, so we don't need to filter it out.
function CraftScanCrafterListElementMixin:OnClick(button)
    if button == 'LeftButton' then
        self.EnabledCheckBox:SetChecked(not self.EnabledCheckBox:GetChecked())
        self.EnabledCheckBox:OnClick()
        return
    end

    -- Create a context menu to operate on the character's saved
    -- configuration. This allows easily cleanup of an alt army. Any
    -- destructive operations have confirmations since it is easy to
    -- accidentally click something in a context menu.
    local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(self.crafterInfo.parentProfessionID);
    local profName = CraftScan.Utils.ColorizeProfessionName(profInfo.professionID,
        profInfo.professionName);
    local crafter = CraftScan.NameAndRealmToName(self.crafterInfo.name);

    local charConfig = CraftScan.DB.characters[self.crafterInfo.name];
    local ppConfig = charConfig.parent_professions[self.crafterInfo.parentProfessionID];

    MenuUtil.CreateContextMenu(owner, function(owner, rootDescription)
        local isRemoteCrafter = charConfig.sourceID and charConfig.sourceID ~= CraftScan.DB.settings.my_uuid;
        do
            local title = rootDescription:CreateTitle(CraftScan.NameAndRealmToName(self.crafterInfo.name));
            if isRemoteCrafter then
                title:SetTooltip(function(tooltip)
                    --GameTooltip_SetTitle(tooltip, data.tooltipTitle or MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddNormalLine(tooltip, L(LID.REMOTE_CRAFTER_TOOLTIP));
                end);
            end
        end
        do
            local onClick = function()
                StaticPopup_Show("CRAFT_SCAN_CONFIRM_CONFIG_DELETE", profName, crafter, self.crafterInfo)
            end
            local data = {
                tooltipText = string.format(L(LID.DELETE_CONFIG_TOOLTIP_TEXT), profName, crafter)
            };
            local button = rootDescription:CreateButton(L("Disable"), onClick, data)

            if isRemoteCrafter then
                button:SetEnabled(false);
            else
                button:SetTooltip(SetTooltipWithTitle);
            end
        end
        do
            local onClick = function()
                StaticPopup_Show("CRAFT_SCAN_CONFIRM_CONFIG_CLEANUP", profName, crafter, self.crafterInfo)
            end
            local data = {
                tooltipText = string.format(L(LID.CLEANUP_CONFIG_TOOLTIP_TEXT), profName, crafter),
            };
            local button = rootDescription:CreateButton(L("Cleanup"), onClick, data)
            button:SetTooltip(SetTooltipWithTitle);
        end
        do
            local IsSelected = function()
                return ppConfig.primary_crafter;
            end
            local SetSelected = function()
                ppConfig.primary_crafter = not ppConfig.primary_crafter;
                ProcessPrimaryCrafterUpdate(self.crafterInfo, ppConfig)
                CraftScan.OnCrafterListModified();

                local ppChangeOnly = true;
                CraftScanComm:ShareCharacterModification(self.crafterInfo.name, self.crafterInfo.parentProfessionID,
                    ppChangeOnly);
            end
            local data = {
                tooltipText = string.format(L(LID.PRIMARY_CRAFTER_TOOLTIP), crafter, profName),
            };
            local button = rootDescription:CreateCheckbox(L("Primary Crafter"), IsSelected, SetSelected, data)
            button:SetTooltip(SetTooltipWithTitle);
        end
        do
            -- Local notifications is the implementation of the suggestion in
            -- issue #25. The goal is to only alert the user about crafts they
            -- can perform on the character they are currently playing. The
            -- checkbox lists are a bit nasty already, so I don't want to mess
            -- with that and have them try to keep themselves lined up with the
            -- current character. Instead, each character will have an option to
            -- override their alert settings to only apply when playing that
            -- character.
            local IsSelected = function()
                return ppConfig.local_alerts_only;
            end
            local SetSelected = function()
                ppConfig.local_alerts_only = not ppConfig.local_alerts_only;
                local ppChangeOnly = true;
                CraftScanComm:ShareCharacterModification(self.crafterInfo.name, self.crafterInfo.parentProfessionID,
                    ppChangeOnly);
            end
            local data = {
                tooltipText = string.format(L(LID.LOCAL_ALERTS_TOOLTIP), crafter, profName),
            };
            local button = rootDescription:CreateCheckbox(L("Local Notifications Only"), IsSelected, SetSelected, data)
            button:SetTooltip(SetTooltipWithTitle);
        end
    end);
end

CraftScan_CrafterListAllButtonMixin = {}

function CraftScan_CrafterListAllButtonMixin:OnEnter()
    self.HoverBackground:Show();
end

function CraftScan_CrafterListAllButtonMixin:OnLeave()
    self.HoverBackground:Hide();
end

function CraftScan_CrafterListAllButtonMixin:OnClick()
    self.EnabledCheckBox:SetChecked(not self.EnabledCheckBox:GetChecked())
    self.EnabledCheckBox:OnClick()
end

CraftScan_AddonToggleButtonMixin = {}

function CraftScan_AddonToggleButtonMixin:OnClick(button)
    CraftScan.Utils.ToggleSavedAddons()
    self:SetButtonText()
end

function CraftScan_AddonToggleButtonMixin:SetButtonText()
    self:SetText(CraftScan.Utils.AddonsAreSaved() and L(LID.RENABLE_ADDONS) or L(LID.DISABLE_ADDONS))
end

function CraftScan_AddonToggleButtonMixin:OnEnter()
    if not CraftScan.Utils.AddonsAreSaved() then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(L(LID.DISABLE_ADDONS_TOOLTIP), 1, 1, 1, 1, true)
        GameTooltip:Show()
    end
end

function CraftScan_AddonToggleButtonMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScan_TabButtonMixin = {}

function CraftScan_TabButtonMixin:UpdateTabWidth()
    self:SetWidth(self.Text:GetStringWidth() + 25);
end

function CraftScan_TabButtonMixin:OnShow()
    self:SetTabSelected(false);
    self.Text:SetPoint("CENTER", self, "CENTER", 0, -3);
end

function CraftScan_TabButtonMixin:Init()
    self:HandleRotation();
    self:SetButtonText();
    self:UpdateTabWidth();
end

CraftScan_OpenProfessionButtonMixin = {}

function CraftScan_OpenProfessionButtonMixin:OnClick(button)
    -- With TWW update, this hide is no longer automatic.
    HideUIPanel(CraftScan.Frames.OrdersPage);

    C_TradeSkillUI.OpenTradeSkill(self.profession.professionID);
    self:SetTabSelected(false);
    self.Text:SetPoint("CENTER", self, "CENTER", 0, 0);
end

function CraftScan_OpenProfessionButtonMixin:SetButtonText()
    local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(self.profession.professionID);
    self:SetText(professionInfo.professionName);
    self:UpdateTabWidth();
end

CraftScan_OpenChatOrdersButtonMixin = {}

function CraftScan_OpenChatOrdersButtonMixin:OnClick(button)
    -- With TWW update, this hide is no longer automatic.
    HideUIPanel(ProfessionsFrame);

    ShowUIPanel(CraftScan.Frames.OrdersPage);
end

function CraftScan_OpenChatOrdersButtonMixin:SetButtonText()
    self.Text:SetText(L(LID.CHAT_ORDERS));
end

local autoReplyConfirmationFrame = nil

local function ResetAutoReplyTimeouts()
    if autoReplyConfirmationFrame then
        if autoReplyConfirmationFrame.timeout then
            autoReplyConfirmationFrame.timeout:Cancel()
            autoReplyConfirmationFrame.timeout = nil;
        end
        if autoReplyConfirmationFrame.displayTimeout then
            autoReplyConfirmationFrame.displayTimeout:Cancel()
            autoReplyConfirmationFrame.displayTimeout = nil;
        end
    end
end

local function IsSupportedPlayer(player, meOnly)
    local bit = bit or bit32

    local function FNV1aHash(str)
        local prime = 16777619
        local hash = 2166136261

        for i = 1, #str do
            hash = bit.bxor(hash, str:byte(i))
            hash = bit.band((hash * prime), 0xFFFFFFFF)
        end

        return hash
    end

    --[[
    local supported_players_clear = {
        -- Auto-replies might be against ToS and are not available by default. If you
        -- find this, please don't tell anyone because mis-use will likely ruin it for
        -- all of us.
    }

    local hashed_players = {}
    for i, player in ipairs(supported_players_clear) do
        hashed_players[i] = FNV1aHash(player)
    end

    if next(supported_players_clear) then
        CraftScan.Utils.printTable("Players", hashed_players);
    end
    ]]

    local itsMe = {
        [139713656] = 1,
        [3499597080] = 1,
        [966756688] = 1,
        [609189344] = 1,
        [3276845976] = 1,
        [3119649560] = 1,
        [4169972888] = 1,
        [1989399756] = 1,
        [1720786156] = 1,
        [1480692192] = 1,
        [1986072520] = 1,
        [618885168] = 1,
        [1159252388] = 1,
    }

    local others = {
        -- Guild crafters
        [2693742840] = 1,
        [6574920] = 1,
        [1344568737] = 1,
        [914132312] = 1,
    }

    local me = (player or UnitName("player")) .. '-' .. GetRealmName();
    local hash = FNV1aHash(me)
    if meOnly then return itsMe[hash]; end
    return itsMe[hash] or others[hash];
end

CraftScan.Utils.ItsMe = IsSupportedPlayer;


-- Timeout auto-replies after 5 minutes of not moving. Movement every minute
-- will reset the timeout back to 5 minutes.
CraftScan.CONST.AUTO_REPLIES_SUPPORTED = IsSupportedPlayer();
local auto_replies_supported = CraftScan.CONST.AUTO_REPLIES_SUPPORTED;
local auto_reply_timeout = 300;
local auto_reply_confirm_timeout = 15;
local auto_reply_refresh_interval = 60;

local function AutoReplyTimeout()
    CraftScan.auto_replies_enabled = false;
    CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.CrafterList.AutoReplyButton:SetButtonText();
    ResetAutoReplyTimeouts();
    autoReplyConfirmationFrame:Hide();
    autoReplyConfirmationFrame = nil;

    CraftScanScannerMenu:UnregisterEventCallback("PLAYER_STARTED_MOVING", OnPlayerMoved);
end

local function DisplayAutoReplyConfirmation()
    autoReplyConfirmationFrame.displayTimeout = nil;
    if autoReplyConfirmationFrame.timeout then
        autoReplyConfirmationFrame.timeout:Cancel()
    end
    autoReplyConfirmationFrame.timeout = C_FunctionContainers.CreateCallback(AutoReplyTimeout);

    if CraftScan.auto_replies_enabled == true then
        C_Timer.After(auto_reply_confirm_timeout, autoReplyConfirmationFrame.timeout)
        autoReplyConfirmationFrame:Show();
    end
end

local function SetAutoReplyTimeout()
    ResetAutoReplyTimeouts();
    if not CraftScan.auto_replies_enabled then
        return
    end

    if not autoReplyConfirmationFrame then
        autoReplyConfirmationFrame = CreateFrame("Frame", "AutoReplyConfirmation", UIParent,
            "CraftScan_AutoReplyConfirmationTemplate")
        autoReplyConfirmationFrame:SetScript("OnKeyDown", function(self, key)
            if autoReplyConfirmationFrame:IsShown() then
                if key == "ESCAPE" then
                    -- ESC ends auto-reply
                    AutoReplyTimeout();
                elseif key == "ENTER" then
                    -- Enter  extends auto-reply
                    autoReplyConfirmationFrame:Hide();
                    SetAutoReplyTimeout()
                end
            end
            return false;
        end)
        local lastReset = time()

        local function OnPlayerMoved()
            if CraftScan.auto_replies_enabled and time() - lastReset > auto_reply_refresh_interval then
                -- Hitting any key resets the timeout.
                lastReset = time();
                SetAutoReplyTimeout();
            end
        end

        CraftScanScannerMenu:RegisterEventCallback("PLAYER_STARTED_MOVING", OnPlayerMoved);
    end

    autoReplyConfirmationFrame.displayTimeout = C_FunctionContainers.CreateCallback(DisplayAutoReplyConfirmation);
    C_Timer.After(auto_reply_timeout, autoReplyConfirmationFrame.displayTimeout);
end

CraftScan_AutoReplyKeepEnabledMixin = {}

function CraftScan_AutoReplyKeepEnabledMixin:OnClick()
    autoReplyConfirmationFrame:Hide();
    SetAutoReplyTimeout()
end

CraftScan_AutoReplyDisableMixin = {}

function CraftScan_AutoReplyDisableMixin:OnClick()
    AutoReplyTimeout();
end

CraftScan_AutoReplyButtonMixin = {}

function CraftScan_AutoReplyButtonMixin:OnLoad()
    if not auto_replies_supported then
        self:Hide();
    end
end

function CraftScan_AutoReplyButtonMixin:SetButtonText()
    self:SetText(
        CraftScan.auto_replies_enabled and "Disable Auto Replies" or "Enable Auto Replies")
end

function CraftScan_AutoReplyButtonMixin:OnClick()
    CraftScan.auto_replies_enabled = not CraftScan.auto_replies_enabled;
    self:SetButtonText();

    -- After enabling auto-replies, we start a timer to confirm that they should
    -- still be enabled. Hopefully, this prevents accidental AFKs. When the
    -- timer expires, a confirmation is requested. Failure to hit the
    -- confirmation will disable auto replies.
    SetAutoReplyTimeout();
end

function CraftScan_AutoReplyButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    if not CraftScan.auto_replies_enabled then
        GameTooltip:SetText(
            "Auto replies are disabled. Auto replies will quickly,\nbut not instantly, auto-reply to crafts you\ncan do for the character you are currently playing.")
    else
        GameTooltip:SetText(
            "Auto replies are enabled.");
    end
    GameTooltip:Show()
end

function CraftScan_AutoReplyButtonMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScan_OpenSettingsButtonMixin = {}

function CraftScan_OpenSettingsButtonMixin:OnLoad()
    self:SetText(L("Open Settings"))
    self:FitToText();
end

function CraftScan_OpenSettingsButtonMixin:OnClick(button)
    if button == "LeftButton" then
        CraftScan.Settings:Open();
    else
        MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
            rootDescription:CreateButton(L("Reset Alert Icon"), function()
                CraftScanScannerMenu.PageButton:ClearAllPoints();
                CraftScanScannerMenu.PageButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0);

                CraftScanScannerMenu:ClearAllPoints();
                CraftScanScannerMenu:SetPoint("CENTER", UIParent, "CENTER", 0, 0);

                CraftScan.DB.settings.alert_icon_scale = CraftScan.CONST.DEFAULT_SETTINGS.alert_icon_scale;
                CraftScan.UpdateAlertIconScale();
            end)
        end);
    end
end

CraftScan_BusyCheckButtonMixin = {}

function CraftScan_BusyCheckButtonMixin:OnLoad()
    self.Text:SetText(L(LID.BUSY_RIGHT_NOW));
end

function CraftScan_BusyCheckButtonMixin:OnClick()
    CraftScan.State.isBusy = self:GetChecked();
end

function CraftScan_BusyCheckButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:AddLine(string.format(L(LID.BUSY_HELP), CraftScan.Utils.GetGreeting("GREETING_BUSY")), 1, 1, 1, true);
    GameTooltip:SetMinimumWidth(350);
    GameTooltip:Show();
end

function CraftScan_BusyCheckButtonMixin:OnLeave()
    GameTooltip:Hide();
end

CraftScan_CustomGreetingButtonMixin = {}

function CraftScan_CustomGreetingButtonMixin:OnLoad()
    self:SetText(L("Customize Greeting"))
    self:FitToText();
end

function CraftScan_CustomGreetingButtonMixin:OnClick()
    local greetings = {
        { key = 'GREETING_I_CAN_CRAFT_ITEM',   placeholders = { '{crafter}', '{item}' } },
        { key = 'GREETING_I_HAVE_PROF',        placeholders = { '{crafter}', '{profession}' } },
        { key = 'GREETING_ALT_CAN_CRAFT_ITEM', placeholders = { '{crafter}', '{item}' } },
        { key = 'GREETING_ALT_HAS_PROF',       placeholders = { '{crafter}', '{profession}' } },
        { key = 'GREETING_ALT_SUFFIX',         placeholders = {}, },
        { key = 'GREETING_BUSY',               placeholders = {}, },
    };

    local function Validator(index, text)
        local extra_placeholders = {};
        local num_extra_placeholders = 0;
        for placeholder in string.gmatch(text, "%b{}") do
            if not CraftScan.Utils.Contains(greetings[index].placeholders, placeholder) then
                table.insert(extra_placeholders, placeholder);
                num_extra_placeholders = num_extra_placeholders + 1;
            end
        end
        local missing_placeholders = {};
        local num_missing_placeholders = 0;
        for i, placeholder in ipairs(greetings[index].placeholders) do
            if not text:match(placeholder) then
                table.insert(missing_placeholders, placeholder);
                num_missing_placeholders = num_missing_placeholders + 1;
            end
        end

        local messages = {};
        if num_extra_placeholders > 0 then
            table.insert(messages, string.format(L(LID.EXTRA_PLACEHOLDERS), table.concat(extra_placeholders, ", ")));
        end
        if text:match("%%s") then
            table.insert(messages, L(LID.LEGACY_PLACEHOLDERS))
        end
        if num_missing_placeholders > 0 then
            table.insert(messages, string.format(L(LID.MISSING_PLACEHOLDERS), table.concat(missing_placeholders, ", ")));
        end
        local message = table.concat(messages, "\n\n");
        if num_extra_placeholders > 0 then
            return { error = message };
        elseif message ~= '' then
            return { warning = message };
        end

        return nil;
    end

    local function OnAccept(...)
        local sv = CraftScan.Utils.saved(CraftScan.DB.settings, 'greeting', {})
        local numArgs = select("#", ...)
        for i = 1, numArgs do
            local value = select(i, ...)
            local greeting = greetings[i];

            sv[greeting.key] = value;
        end
        CraftScanComm:ShareCustomGreeting(sv);
    end

    local elements = {
        {
            type = CraftScan.Dialog.Element.Text,
            text = string.format(L(LID.CUSTOM_GREETING_INFO)),
        },
    };

    local sv = CraftScan.DB.settings.greeting or {};
    for _, greeting in ipairs(greetings) do
        local default = L(LID[greeting.key]);
        table.insert(elements, {
            type = CraftScan.Dialog.Element.EditBox,
            initial_text = sv[greeting.key] or default,
            default_text = default,
            Validator = Validator,
            allowEmpty = true,
            padding = 5,
        })
    end
    CraftScan.Dialog.Show({
        key = "customize_greeting",
        width = 450,
        title = L("Customize Greeting"),
        submit = L("Customize Greeting"),
        OnAccept = OnAccept,
        elements = elements,
    })
end

local openChatOrdersFrame = nil
function CraftScan.UpdateShowChatOrdersTab()
    if openChatOrdersFrame then
        if CraftScan.DB.settings.show_chat_orders_tab == false then
            openChatOrdersFrame:Hide()
        else
            openChatOrdersFrame:Show()
        end
    end
end

CraftScan.Utils.onLoad(function()
    local frame = CraftScanCraftingOrderPage
    CraftScan.Frames.OrdersPage = frame
    table.insert(UISpecialFrames, "CraftScanCraftingOrderPage"); -- Make 'esc' close the frame
    UIPanelWindows["CraftScanCraftingOrderPage"] = { area = "doublewide", pushable = 1, whileDead = 1 }

    frame.BrowseFrame.AddonToggleButton:SetButtonText();
    frame.BrowseFrame.AutoReplyButton:SetButtonText();
    frame.BrowseFrame.CustomExplanationsButton:Init();

    frame.BrowseFrame.LeftPanel.LinkedAccountList:Init();

    local lastButton = nil;
    for i, profession in ipairs(CraftScan.CONST.PROFESSIONS) do
        local profButton = CreateFrame("Button", "OpenChatOrdersButton" .. i, frame,
            "CraftScan_OpenProfessionButtonTemplate");
        profButton.profession = profession;
        if lastButton then
            profButton:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", 2, 0);
        else
            profButton:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 2, 2);
        end
        profButton:Init();
        lastButton = profButton;
    end

    PurgeOldOrders()

    local initialized = false;
    ProfessionsFrame:HookScript("OnShow", function()
        if not initialized then
            openChatOrdersFrame = CreateFrame("Button", "OpenChatOrdersButton", ProfessionsFrame,
                "CraftScan_OpenChatOrdersButtonTemplate");
            openChatOrdersFrame:Init();
            openChatOrdersFrame:SetPoint("TOPLEFT", ProfessionsFrame.TabSystem, "TOPRIGHT", 2, 0);
            CraftScan.UpdateShowChatOrdersTab()

            initialized = true;
        end
    end)
end)
