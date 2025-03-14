local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScan.ChatOrderSortOrder = EnumUtil.MakeEnum("CustomerName", "CrafterName", "ProfessionName", "ItemName", "Time"); -- , "Sent");

CraftScanTableConstants = {};
CraftScanTableConstants.StandardPadding = 10;
CraftScanTableConstants.NoPadding = 0;
CraftScanTableConstants.Name = {
    Width = 100,
    Padding = CraftScanTableConstants.NoPadding,
    FillCoefficient = 1.0,
    LeftCellPadding = CraftScanTableConstants.StandardPadding,
    RightCellPadding = CraftScanTableConstants.NoPadding
};
CraftScanTableConstants.ItemName = {
    Width = 330,
    Padding = CraftScanTableConstants.StandardPadding,
    LeftCellPadding = CraftScanTableConstants.NoPadding,
    RightCellPadding = CraftScanTableConstants.NoPadding
};
CraftScanTableConstants.CustomerName = {
    Width = 160,
    Padding = CraftScanTableConstants.StandardPadding,
    LeftCellPadding = CraftScanTableConstants.NoPadding,
    RightCellPadding = CraftScanTableConstants.NoPadding
};
CraftScanTableConstants.CrafterName = {
    Width = 120,
    Padding = CraftScanTableConstants.StandardPadding,
    LeftCellPadding = CraftScanTableConstants.NoPadding,
    RightCellPadding = CraftScanTableConstants.NoPadding
};
CraftScanTableConstants.ProfessionName = {
    Width = 120,
    Padding = CraftScanTableConstants.StandardPadding,
    LeftCellPadding = CraftScanTableConstants.NoPadding,
    RightCellPadding = CraftScanTableConstants.NoPadding
};
CraftScanTableConstants.Interaction = {
    Width = 60,
    Padding = CraftScanTableConstants.StandardPadding,
    LeftCellPadding = CraftScanTableConstants.NoPadding,
    RightCellPadding = CraftScanTableConstants.NoPadding
};
CraftScanTableConstants.Time = {
    Width = 40,
    Padding = CraftScanTableConstants.StandardPadding,
    LeftCellPadding = CraftScanTableConstants.NoPadding,
    RightCellPadding = CraftScanTableConstants.NoPadding
};

CraftScanCrafterListTableConstants = {};
CraftScanCrafterListTableConstants.StandardPadding = 10;
CraftScanCrafterListTableConstants.NoPadding = 0;
CraftScanCrafterListTableConstants.CrafterName = {
    Width = 120,
    Padding = CraftScanCrafterListTableConstants.StandardPadding,
    LeftCellPadding = CraftScanCrafterListTableConstants.NoPadding,
    RightCellPadding = CraftScanCrafterListTableConstants.NoPadding
}

CraftScanCrafterTableHeaderStringMixin = CreateFromMixins(TableBuilderElementMixin);

function CraftScanCrafterTableHeaderStringMixin:OnClick()
    if not self.sortOrder then
        return;
    end

    self.owner:SetSortOrder(self.sortOrder);
    self:UpdateArrow();
end

function CraftScanCrafterTableHeaderStringMixin:Init(owner, headerText, sortOrder)
    self:SetText(headerText);

    self.owner = owner;
    self.sortOrder = sortOrder;
    self:UpdateArrow();
end

function CraftScanCrafterTableHeaderStringMixin:UpdateArrow()
    local sortOrder, ascending = self.owner:GetSortOrder();
    if sortOrder == self.sortOrder then
        self.Arrow:Show();
        if ascending then
            self.Arrow:SetTexCoord(0, 1, 0, 1);
        else
            self.Arrow:SetTexCoord(0, 1, 1, 0);
        end
    else
        self.Arrow:Hide();
    end
end

CraftScanTableBuilderMixin = {};

function CraftScanTableBuilderMixin:AddColumnInternal(owner, sortOrder, cellTemplate, ...)
    local column = self:AddColumn();

    if sortOrder then
        local headerName = self:GetHeaderNameFromSortOrder(sortOrder);
        column:ConstructHeader("BUTTON", self.header_template or "CraftScanCrafterTableHeaderStringTemplate", owner, headerName,
            sortOrder);
    end

    column:ConstructCells("FRAME", cellTemplate, owner, ...);

    return column;
end

function CraftScanTableBuilderMixin:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...)
    local column = self:AddColumn();
    local sortOrder = nil;
    column:ConstructHeader("BUTTON", self.header_template or "CraftScanCrafterTableHeaderStringTemplate", owner, headerText, sortOrder);
    column:ConstructCells("FRAME", cellTemplate, owner, ...);
    return column;
end

function CraftScanTableBuilderMixin:AddFixedWidthColumn(owner, padding, width, leftCellPadding, rightCellPadding,
                                                        sortOrder, cellTemplate, ...)
    local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
    column:SetFixedConstraints(width, padding);
    column:SetCellPadding(leftCellPadding, rightCellPadding);
    return column;
end

function CraftScanTableBuilderMixin:AddFillColumn(owner, padding, fillCoefficient, leftCellPadding,
                                                  rightCellPadding, sortOrder, cellTemplate, ...)
    local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
    column:SetFillConstraints(fillCoefficient, padding);
    column:SetCellPadding(leftCellPadding, rightCellPadding);
    return column;
end

function CraftScanTableBuilderMixin:AddUnsortableFixedWidthColumn(owner, padding, width, leftCellPadding,
                                                                  rightCellPadding, headerText, cellTemplate, ...)
    local column = self:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...);
    column:SetFixedConstraints(width, padding);
    column:SetCellPadding(leftCellPadding, rightCellPadding);
    return column;
end

function CraftScanTableBuilderMixin:AddUnsortableFillColumn(owner, padding, fillCoefficient, leftCellPadding,
                                                            rightCellPadding, headerText, cellTemplate, ...)
    local column = self:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...);
    column:SetFillConstraints(fillCoefficient, padding);
    column:SetCellPadding(leftCellPadding, rightCellPadding);
    return column;
end

CraftScanOrderTableBuilderMixin = CreateFromMixins(CraftScanTableBuilderMixin);

function CraftScanOrderTableBuilderMixin:GetHeaderNameFromSortOrder(sortOrder)
    if sortOrder == CraftScan.ChatOrderSortOrder.ItemName then
        return PROFESSIONS_COLUMN_HEADER_ITEM;
    elseif sortOrder == CraftScan.ChatOrderSortOrder.CrafterName then
        return L("Crafter Name");
    elseif sortOrder == CraftScan.ChatOrderSortOrder.ProfessionName then
        return L("Profession");
        -- elseif sortOrder == CraftScanSortOrder.Time then
        -- return CreateAtlasMarkup("auctionhouse-icon-clock", 16, 16, 2, -2);
        -- elseif sortOrder == CraftScanSortOrder.ItemName then
        -- return AUCTION_HOUSE_BROWSE_HEADER_NAME;
    elseif sortOrder == CraftScan.ChatOrderSortOrder.CustomerName then
        return L("Customer Name");
    elseif sortOrder == CraftScan.ChatOrderSortOrder.Time then
        return CreateAtlasMarkup("auctionhouse-icon-clock", 16, 16, 2, -2);
    end
end

CraftScanTableCellTextMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanTableCellTextMixin:SetText(text)
    self.Text:SetText(text);
end

CraftScanCrafterTableCellNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanCrafterTableCellNameMixin:Populate(rowData, dataIndex)
    local order = rowData;
    local text = order:GetName();
    CraftScanTableCellTextMixin.SetText(self, text);
end

CraftScanCrafterTableCellItemNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanCrafterTableCellItemNameMixin:Populate(rowData, dataIndex)
    local response = CraftScan.OrderToResponse(rowData.order);

    if not response.itemID then
        self.Icon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(response.professionID))
        self.Text:SetText(CraftScan.Utils.ColorizeProfessionName(response.parentProfID, response.professionName))
        return
    end

    local item = Item:CreateFromItemID(response.itemID);
    item:ContinueOnItemLoad(function()
        if item:GetItemID() ~= response.itemID then
            -- Callback from a previous async request
            return;
        end
        local icon = item:GetItemIcon();
        self.Icon:SetTexture(icon);

        local qualityColor = item:GetItemQualityColor().color;
        local itemName = qualityColor:WrapTextInColorCode(item:GetItemName());
        self.Text:SetText(itemName);
    end);
end

CraftScanCrafterTableCellTimeMixin = CreateFromMixins(TableBuilderCellMixin);

local function UpdateAge(self, response)
    local age = math.floor(time() - response.time)
    local text;
    if (age < 60) then
        text = string.format("%us", math.floor(age / 5) * 5)
    elseif (age < 3600) then
        text = string.format("%um", math.floor(age / 60))
    else
        text = string.format("%uh", math.floor(age / 3600))
    end

    CraftScanTableCellTextMixin.SetText(self, text);
end

function CraftScanCrafterTableCellTimeMixin:Populate(rowData, dataIndex)
    local order = rowData.order;
    local response = CraftScan.OrderToResponse(order);
    local liveResponse = CraftScan.OrderToLiveResponse(order, true)
    liveResponse.updateAge = function()
        UpdateAge(self, response)
    end
    UpdateAge(self, response)
end

CraftScanCrafterTableCellCustomerNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanCrafterTableCellCustomerNameMixin:Populate(rowData, dataIndex)
    local order = rowData.order
    local customerInfo = CraftScan.OrderToCustomerInfo(order)
    CraftScanTableCellTextMixin.SetText(self, CraftScan.ColorizePlayerName(order.customerName, customerInfo.guid))
end

CraftScanCrafterTableCellCrafterNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanCrafterTableCellCrafterNameMixin:Populate(rowData, dataIndex)
    local response = CraftScan.OrderToResponse(rowData.order);
    CraftScanTableCellTextMixin.SetText(self,
        CraftScan.ColorizeCrafterName(response.crafterName));
end

CraftScanCrafterTableCellProfessionNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanCrafterTableCellProfessionNameMixin:Populate(rowData, dataIndex)
    local response = CraftScan.OrderToResponse(rowData.order);
    CraftScanTableCellTextMixin.SetText(self,
        CraftScan.Utils.ColorizeProfessionName(response.parentProfID, response.professionName))

    -- We can dig into the crafting order APIs, but they require you to be
    -- standing next to the table 'IsNearProfessionSpellFocus' to work.
    -- We can also only request orders for the current player. Given that you
    -- have to be standing where the menu is available on the character where it
    -- is available, this doesn't seem worth the effort, but leaving this stub
    -- here for now.

    -- The best we could do is put a button on our page to move you over to the
    -- the crafting page so you can hit the craft button.

    -- Going to follow the route of my weakaura, and simply scan chat for
    -- 'Personal order placed', and send a ping for it.

    --if profession and C_CraftingOrders.ShouldShowCraftingOrderTab() and C_TradeSkillUI.IsNearProfessionSpellFocus(profession) then
    local testCraftingOrderApis = false
    if testCraftingOrderApis and response.crafterName == CraftScan.GetPlayerName() then
        local function SendOrderRequest(request)
            -- Sort orders added to request in the send in case search orders changed from a cached request
            request.primarySort = {
                sortType = Enum.CraftingOrderSortType.ItemName,
                reversed = false,
            }
            ;
            request.secondarySort = {
                sortType = Enum.CraftingOrderSortType.TimeRemaining,
                reversed = false,
            };

            if self.requestCallback then
                self.requestCallback:Cancel();
            end
            self.requestCallback = C_FunctionContainers.CreateCallback(function(...)
                local craftingOrders = C_CraftingOrders.GetCrafterOrders()
                CraftScan.Utils.printTable("craftingOrders", craftingOrders)
            end);
            request.callback = self.requestCallback;
            C_CraftingOrders.RequestCrafterOrders(request);
        end


        local request =
        {
            orderType = Enum.CraftingOrderType.Personal,
            --selectedSkillLineAbility = response.professionID,
            searchFavorites = false,
            initialNonPublicSearch = false,
            offset = 0,
            forCrafter = true,
            profession = C_TradeSkillUI.GetProfessionInfoBySkillLineID(response.professionID).profession
        };
        SendOrderRequest(request);
    end
end

CraftScanCrafterTableCellInteractionMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanCrafterTableCellInteractionMixin:Populate(rowData, dataIndex)
    self.order = rowData.order;
    local response = CraftScan.OrderToResponse(rowData.order);
    if response.greeting_sent then
        self.PlayerIcon:SetAtlas("common-icon-checkmark")
    else
        self.PlayerIcon:SetAtlas("common-icon-redx")
    end

    if response.customer_answered then
        self.CustomerIcon:SetAtlas("common-icon-checkmark")
    else
        self.CustomerIcon:SetAtlas("common-icon-redx")
    end

    -- Link ourselves to the response. This allows all chat bubble icons with a
    -- single customer to act in unison.
    CraftScan.OrderToLiveResponse(self.order, true).interactionFrame = self
end

CraftScanChatPopOutButtonMixin = {}

local function PopulateChatHistory(order, chatFrame)
    local customerInfo = CraftScan.OrderToCustomerInfo(order)

    local accessID = ChatHistory_GetAccessID("WHISPER", order.customerName);
    for _, item in ipairs(customerInfo.chat_history) do
        -- With Prat, this leads to a double timestamp because they hook
        -- AddMessage to add the timestamp, and our message already includes a
        -- timestamp. Tried what they do by calling historyBuffer:PushBack, but
        -- that leads to scrollframe getting upset. I'm fine with the double
        -- timestamp for now.
        if item.args then
            chatFrame:AddMessage(item.message, unpack(item.args))
        else
            chatFrame:AddMessage(item.message)
        end
    end
    chatFrame:ResetAllFadeTimes()
end

function CraftScanChatPopOutButtonMixin:OnClick(button)
    local order = self:GetParent().order;

    local liveCustomerInfo = CraftScan.OrderToLiveCustomerInfo(order, true)
    local liveResponses = CraftScan.OrderToLiveResponses(order, true)

    if button == "RightButton" or liveCustomerInfo.chatFrame then
        -- Right click only closes. Left click toggles
        if liveCustomerInfo and liveCustomerInfo.chatFrame then
            FCF_Close(liveCustomerInfo.chatFrame)
        end
    else
        if liveCustomerInfo and liveCustomerInfo.chatFrame then
            liveCustomerInfo.chatFrame:Clear();
            PopulateChatHistory(order, liveCustomerInfo.chatFrame)
            FCF_SelectDockFrame(liveCustomerInfo.chatFrame)
            return
        end

        local chatFrame = FCF_OpenTemporaryWindow("WHISPER", order.customerName, nil, true)
        PopulateChatHistory(order, chatFrame)
        liveCustomerInfo.chatFrame = chatFrame
        for _, response in pairs(liveResponses) do
            response.interactionFrame.Chat.SelectedHighlight:Show()
        end

        -- Handle close events triggered outside our control as well.
        hooksecurefunc("FCF_Close", function(frame)
            if frame == liveCustomerInfo.chatFrame then
                liveCustomerInfo.chatFrame = nil
                for _, response in pairs(liveResponses) do
                    response.interactionFrame.Chat.SelectedHighlight:Hide()
                end
            end
        end)
    end
end

CraftScanRecipeListPanelMixin = {};

function CraftScanRecipeListPanelMixin:StoreCollapses(scrollbox)
    self.collapses = {};
    local dataProvider = scrollbox:GetDataProvider();
    local childrenNodes = dataProvider:GetChildrenNodes();
    for idx, child in ipairs(childrenNodes) do
        if child.data and child:IsCollapsed() then
            self.collapses[child.data.categoryInfo.categoryID] = true;
        end
    end
end

function CraftScanRecipeListPanelMixin:GetCollapses()
    return self.collapses;
end
