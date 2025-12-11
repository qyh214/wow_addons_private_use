local L = BtWQuests.L;
BTWQUESTS_VIEW_ALL = L["BTWQUESTS_VIEW_ALL"];

local min = math.min;
local max = math.max;
local floor = math.floor;
local ceil = math.ceil;

local CHAIN_GRID_HORIZONTAL_SIZE = 95;
local CHAIN_GRID_VERTICAL_SIZE = 80;
local CHAIN_GRID_HORIZONTAL_PADDING = 99;
local CHAIN_GRID_VERTICAL_PADDING = 52 + (CHAIN_GRID_VERTICAL_SIZE * 2);

--@REMOVE AFTER 9.0
local GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local IsQuestComplete = C_QuestLog.IsComplete
local IsQuestFailed = C_QuestLog.IsFailed
if select(4, GetBuildInfo()) < 90000 then
    GetLogIndexForQuestID = GetQuestLogIndexByID
    function IsQuestComplete(questLogIndex)
        local complete = select(6, GetQuestLogTitle(questLogIndex))
        return complete and complete > 0
    end
    function IsQuestFailed(questLogIndex)
        local complete = select(6, GetQuestLogTitle(questLogIndex))
        return complete and complete < 0
    end
end

-- [[ Chain ]]
function BtWQuestsChainItemPool_HideAndClearAnchors(framePool, frame)
	frame:Hide();
	frame:ClearAllPoints();

    frame.linePool:ReleaseAll()

    frame.IsNextAnim:Stop()
    frame.previousButtons = nil
    frame.status = nil
end

BtWQuestsExpansionItemMixin = {}


BtWQuestsChainItemMixin = {}
function BtWQuestsChainItemMixin:OnLoad()
    self.linePool = CreateFramePool("FRAME", self:GetParent(), "BtWQuestsLineTemplate");

    self.Name:SetText("Quest Name")
    self.Tick:SetShown(false)

    self.tooltip = BtWQuestsTooltip
end
function BtWQuestsChainItemMixin:SetHideSpoilers(value)
    self.hideSpoilers = value
end
function BtWQuestsChainItemMixin:GetHideSpoilers()
    return self.hideSpoilers
end
function BtWQuestsChainItemMixin:Set(item, character)
    self.item = item
    self.character = character;

    self:StopAnimating()

    local status = item:GetStatus(character)

    self.Name:SetText(item:GetName(character))
    self.Name:SetShown(not self.hideSpoilers or status ~= nil)
    self.SpoilerName:SetShown(not self.Name:IsShown())

    local tagID = item:GetTagID()
    local difficulty = item:GetDifficulty()
    if tagID and QUEST_TAG_TCOORDS[tagID] then
        self.TagTexture:SetTexCoord(unpack(QUEST_TAG_TCOORDS[tagID]))
        self.TagTexture:Show()

        if difficulty then
            self.TagTexture:SetPoint("BOTTOMRIGHT", -10, 6)
        else
            self.TagTexture:SetPoint("BOTTOMRIGHT", -10, 16)
        end
    else
        self.TagTexture:Hide()
    end

    self.HeroicTexture:SetShown(difficulty == "heroic" or difficulty == "normal" or difficulty == "lfr")
    self.MythicTexture:SetShown(difficulty == "mythic")

    local atlas = item.GetAtlas and item:GetAtlas()
    if atlas ~= nil then
        self.Icon:SetAtlas(atlas)
    end

    if status == "complete" then
        self.ForgottenAnimQuick:Play() -- Just setting the alpha doesnt always work, using a animation with a very short duration seems to solve this
    else
        self.Name:SetAlpha(1)
    end

    if status == "active" then
        self.ActiveTexture:Show()
        self.ActiveAnim:Play()
    else
        self.ActiveTexture:Hide()
    end

    self.Tick:SetShown(status == "complete")

    self:SetShown(item:Visible(character))
    self.status = status
end
function BtWQuestsChainItemMixin:Update(item)
    self.item = item

    local character = self.character;
    local status = item:GetStatus(character)

    self:StopAnimating()

    self.Name:SetText(item:GetName(character))
    if not self.hideSpoilers or status ~= nil then
        self.Name:SetShown(true)
        self.SpoilerName:SetShown(false)
    end

    if self.status ~= status then
        if status == "complete" then
            self.ForgottenAnim:Play()
        end

        if status == "active" then
            self.ActiveTexture:Show()
            self.ActiveAnim:Play()
        else
            self.ActiveTexture:Hide()
        end
    end

    self.Tick:SetShown(status == "complete")

    self:SetShown(item:Visible(character))
    self.status = status
end
function BtWQuestsChainItemMixin:SetChainView(value)
    self.chainView = value
end
function BtWQuestsChainItemMixin:GetChainView()
    return self.chainView
end
function BtWQuestsChainItemMixin:SetTooltip(value)
    self.tooltip = value
end
function BtWQuestsChainItemMixin:GetTooltip()
    return self.tooltip
end
function BtWQuestsChainItemMixin:OnClick()
    if self.item then
        return self.item:OnClick(self.character, self, self:GetChainView(), self:GetTooltip())
    end
end
function BtWQuestsChainItemMixin:OnEnter()
    if not self.hideSpoilers or self.status ~= nil then
        if self.item then
            return self.item:OnEnter(self.character, self, self:GetChainView(), self:GetTooltip())
        end
    end
end
function BtWQuestsChainItemMixin:OnLeave()
    if self.item then
        return self.item:OnLeave(self.character, self, self:GetChainView(), self:GetTooltip())
    end
end

BtWQuestsCategoryHeaderMixin = {}
function BtWQuestsCategoryHeaderMixin:Set(item, character)
    self.item = item

    self.Name:SetText(item:GetName())

    self.id = item:GetID();
end

BtWQuestsCategoryItemMixin = {}
function BtWQuestsCategoryItemMixin:Set(item, character)
    self.item = item
    self.character = character;

    self.Name:SetText(item:GetName(character))
    if item:GetType() == "chain" and character:IsChainIgnored(item:GetID()) then
        self.Name:SetAlpha(0.5)
    elseif item:GetType() == "category" and character:IsCategoryIgnored(item:GetID()) then
        self.Name:SetAlpha(0.5)
    else
        self.Name:SetAlpha(1)
    end

    local texture, left, right, top, bottom = item:GetButtonImage()
    self.Background:SetTexture(texture)
    if left ~= nil then
        self.Background:SetTexCoord(left, right, top, bottom)
    else
        self.Background:SetTexCoord(0.01953125, 0.66015625, 0.0390625, 0.7109375)
    end
    self.Acive:SetShown(item:IsActive(character))
    self.Tick:SetShown(item:IsCompleted(character))
    self.Major:SetShown(item:IsMajor())

    self.id = item:GetID();
end
function BtWQuestsCategoryItemMixin:OnClick()
    return self.item:OnClick(self.character, self, BtWQuestsFrame, BtWQuestsFrame.Tooltip)
end
function BtWQuestsCategoryItemMixin:OnEnter()
    return self.item:OnEnter(self.character, self, BtWQuestsFrame, BtWQuestsFrame.Tooltip)
end
function BtWQuestsCategoryItemMixin:OnLeave()
    return self.item:OnLeave(self.character, self, BtWQuestsFrame, BtWQuestsFrame.Tooltip)
end
function BtWQuestsCategoryItemMixin:OnMouseUp(button)
    if button == "RightButton" then
        BtWQuestsFrame:ZoomOut()
    end
end

BtWQuestsCategoryListItemMixin = Mixin({}, BtWQuestsCategoryItemMixin)
function BtWQuestsCategoryListItemMixin:Set(item, character)
    self.item = item
    self.character = character;

    local subtext = item:GetSubtext(character)

    self.Name:SetText(item:GetName(character))
    self.Subtext:SetText(subtext)

    self.Name:ClearAllPoints()
    if subtext == nil then
        self.Name:SetPoint("LEFT", 60, 0)
    else
        self.Name:SetPoint("TOPLEFT", 60, -13)
    end
    if item:GetType() == "chain" and character:IsChainIgnored(item:GetID()) then
        self.Name:SetAlpha(0.5)
    elseif item:GetType() == "category" and character:IsCategoryIgnored(item:GetID()) then
        self.Name:SetAlpha(0.5)
    else
        self.Name:SetAlpha(1)
    end

    local texture, left, right, top, bottom = item:GetListImage()
    if texture ~= nil then
        self.Background:SetTexture(texture)
        self.Background:SetTexCoord(left, right, top, bottom)
    else
        self.Background:SetTexture("Interface\\Addons\\BtWQuests\\UI-CategoryButton")
        self.Background:SetTexCoord(0.0, 0.7353515625, 0.3515625, 0.46875)
    end
    self.Acive:SetShown(item:IsActive(character))
    self.Tick:SetShown(item:IsCompleted(character))
    self.Major:SetShown(item:IsMajor())
    self.Major:SetAlpha(1)

    self.id = item:GetID();
end
function BtWQuestsCategoryListItemMixin:OnEnter()
    BtWQuestsCategoryItemMixin.OnEnter(self)
    self.Ignore.texture:SetAlpha(0.75)
end
function BtWQuestsCategoryListItemMixin:OnLeave()
    BtWQuestsCategoryItemMixin.OnLeave(self)
    self.Ignore.texture:SetAlpha(0.0)
end

BtWQuestsCategoryGridItemMixin = Mixin({}, BtWQuestsCategoryItemMixin)
function BtWQuestsCategoryGridItemMixin:OnEnter()
    BtWQuestsCategoryItemMixin.OnEnter(self)
    self.Major:SetAlpha(0)
    self.Ignore.texture:SetAlpha(0.75)
end
function BtWQuestsCategoryGridItemMixin:OnLeave()
    BtWQuestsCategoryItemMixin.OnLeave(self)
    self.Major:SetAlpha(1)
    self.Ignore.texture:SetAlpha(0.0)
end

BtWQuestsChainViewItemMixin = {}
function BtWQuestsChainViewItemMixin:OnLoad()
    BtWQuestsChainItemMixin.OnLoad(self)
    self:RegisterForDrag("LeftButton")
end
function BtWQuestsChainViewItemMixin:GetChainView()
    return self:GetParent():GetParent()
end
function BtWQuestsChainViewItemMixin:GetTooltip()
    return self:GetChainView():GetTooltip()
end
function BtWQuestsChainViewItemMixin:OnDragStart()
    self:GetChainView():OnDragStart()
end
function BtWQuestsChainViewItemMixin:OnDragStop()
    self:GetChainView():OnDragStop()
end
function BtWQuestsChainViewItemMixin:OnMouseUp(button)
    if button == "RightButton" then
        BtWQuestsFrame:ZoomOut()
    end
end

BtWQuestsChainViewMixin = {}
function BtWQuestsChainViewMixin:OnLoad()
    self.noScrollBar = true
    ScrollFrame_OnLoad(self)
    self.itemPool = CreateFramePool("BUTTON", self.Child, "BtWQuestsChainViewItemTemplate", BtWQuestsChainItemPool_HideAndClearAnchors);
    self:RegisterForDrag("LeftButton")
end
function BtWQuestsChainViewMixin:OnDragStart()
    self.scrollX, self.scrollY = self:GetHorizontalScroll(), self:GetVerticalScroll()
    self.mouseX, self.mouseY = GetCursorPosition()

    local scale = self:GetScrollChild():GetEffectiveScale()
    self.mouseX, self.mouseY = self.mouseX / scale, self.mouseY / scale

    self:SetScript("OnUpdate", BtWQuestsChainViewMixin.OnDrag)
end
function BtWQuestsChainViewMixin:OnDragStop()
    self:SetScript("OnUpdate", nil)
end
function BtWQuestsChainViewMixin:OnDrag()
    local mouseX, mouseY = GetCursorPosition()
    local scale = self:GetEffectiveScale()
    mouseX, mouseY = mouseX / scale, mouseY / scale

    local maxXScroll, maxYScroll = self:GetHorizontalScrollRange(), self:GetVerticalScrollRange()

    mouseX = min(max(mouseX - self.mouseX + self.scrollX, 0), maxXScroll)
    mouseY = min(max(mouseY - self.mouseY + self.scrollY, 0), maxYScroll)

    self:SetHorizontalScroll(mouseX)
    self:SetVerticalScroll(mouseY)
end
function BtWQuestsChainViewMixin:GetZoom()
    return 1
    -- return self:GetScrollChild():GetScale()
end
function BtWQuestsChainViewMixin:SetZoom(value)
    -- return self:GetScrollChild():SetScale(value)
end
function BtWQuestsChainViewMixin:SetCharacter(name, realm)
    if type(name) == "string" then
        if realm ~= nil then
            name = name .. "-" .. realm
        end

        self.Character = BtWQuestsCharacters:GetCharacter(name)
    else
        self.Character = name
    end
end
function BtWQuestsChainViewMixin:GetCharacter()
    return self.Character
end
function BtWQuestsChainViewMixin:GetTooltip()
    return BtWQuestsTooltip
end
function BtWQuestsChainViewMixin:SetHideSpoilers(value)
    self.hideSpoilers = value
end
function BtWQuestsChainViewMixin:GetHideSpoilers()
    return self.hideSpoilers
end
function BtWQuestsChainViewMixin:SelectFromLink(...)
    -- return self:GetParent():GetParent():SelectFromLink(...)
end
function BtWQuestsChainViewMixin:SetChain(chainID, scrollTo, zoom)
    self.chainID = chainID

    self.itemPool:ReleaseAll()
    self.ItemButtons = {}

    self.rect = {};

    self.scrollTo = scrollTo
    self.scrollToButton = nil
    self.scrollToButtonAside = nil

    self.lowestButton = nil
    self.lowestY = nil

    if zoom ~= nil then
        self:SetZoom(zoom)
    end

    self:AddButtons(chainID, 0, 0)

    do
        local Child = self:GetScrollChild();
        local rect = self.rect;
        rect.left, rect.right = floor(rect.left or 0), ceil(rect.right or 0)
        rect.top, rect.bottom = floor(rect.top or 0), ceil(rect.bottom or 0)
        rect.top = max(rect.top, 0)

        local width = rect.right - rect.left;
        local height = (rect.bottom - rect.top);

        if width % 2 == 1 then
            if rect.left % 2 == 1 then
                rect.left = rect.left - 1;
            elseif rect.right % 2 == 1 then
                rect.right = rect.right + 1;
            end
            width = rect.right - rect.left;
        end

        while width < 6 do
            rect.left = rect.left - 1;
            rect.right = rect.right + 1;
            width = rect.right - rect.left;
        end

        if rect.left < 0 or rect.top > 0 then
            local hShift = -(rect.left) * CHAIN_GRID_HORIZONTAL_SIZE;
            local vShift = rect.top * CHAIN_GRID_VERTICAL_SIZE;
            for itemButton in self.itemPool:EnumerateActive() do
                local x, y = select(4, itemButton:GetPoint(1)); -- CENTER - Can no longer look up point by name
                itemButton:SetPoint(
                    "CENTER", itemButton:GetParent(), "TOPLEFT",
                    x + hShift,
                    y + vShift
                );
            end
        end

        Child:SetWidth(width * CHAIN_GRID_HORIZONTAL_SIZE + (CHAIN_GRID_HORIZONTAL_PADDING * 2));
        Child:SetHeight(height * CHAIN_GRID_VERTICAL_SIZE + (CHAIN_GRID_VERTICAL_PADDING * 2));
    end

    self:UpdateScrollChildRect()
    if type(scrollTo) == "table" and scrollTo.type == "coords" then
        local scale = self:GetZoom()
        -- self:SetHorizontalScroll(scrollTo.x / scale)
        self:SetVerticalScroll(scrollTo.y / scale)
    elseif scrollTo ~= false then
        if self.scrollToButton == nil then
            self.scrollToButton = self.scrollToButtonAside
        end

        -- if self.scrollToButton == nil then
        --     local buttons = self.ItemButtons[chainID]
        --     local index = 1
        --     while buttons[index] and not buttons[index]:IsShown() do
        --         index = index + 1
        --     end

        --     self.scrollToButton = buttons[index]
        -- end

        if self.scrollToButton then
            local scale = self:GetZoom()
            local x, y = select(4, self.scrollToButton:GetPoint(1)); -- CENTER - Can no longer look up point by name

            -- self:SetHorizontalScroll(x - (self:GetWidth() / scale) / 2)
            self:SetVerticalScroll(-y - (self:GetHeight() / scale) / 2)
        else
            self:SetVerticalScroll(0)
        end
    end
end
function BtWQuestsChainViewMixin:AddButtons(chainID, xOffset, yOffset, asideOverride, connectionsOverride, connectionsChainOverride)
    local character = self:GetCharacter()
    assert(character ~= nil, "Must set a character before setting a chain")

    local buttons = self.ItemButtons[chainID]
    if not buttons then
        buttons = {};
        self.ItemButtons[chainID] = buttons;
    end
    local rect = self.rect;

    local chain = BtWQuestsDatabase:GetChainByID(chainID)

    -- Normally previous and embed are the same, but after embedding a chain, previous is the last spot of
    -- the embedded chain and embed is the first spot.
    local previousX, previousY, embedX, embedY = nil, 0, nil, 0

    local index = 1
    local item = chain:GetItem(index, character)
    while item do
        if item:IsValidForCharacter(character) then
            local x = item:GetX()
            local y = item:GetY()

            if x == nil then
                if y == nil then
                    if previousX == nil then
                        x = 0
                        y = 0
                    else
                        x = embedX + 2
                        y = embedY

                        if x > 6 then
                            x = x - 8
                            y = y + 1
                        end
                    end
                else
                    x = previousX
                    y = y
                end
            elseif y == nil then
                x = x
                if previousX ~= nil and x <= previousX then
                    y = previousY + 1
                else
                    y = embedY
                end
            else
                x = x
                y = y
            end

            embedX, embedY = x, y
            previousX, previousY = x, y

            x = x + xOffset
            y = y + yOffset

            if item:GetType() == "chain" and item:IsEmbed() then
                local connections = item:GetConnections();
                local connectionsOverride;
                if connections then
                    connectionsOverride = {};
                    for i,itemConnections in pairs(connections) do
                        local override = {};
                        for k,connection in ipairs(itemConnections) do
                            override[k] = index + connection
                        end
                        connectionsOverride[i] = override;
                    end
                end
                previousX, previousY = self:AddButtons(item:GetID(), x or 0, y or 0, item:IsAside(character), connectionsOverride, chain)
            else
                rect.left = rect.left and min(rect.left, x) or x;
                rect.right = rect.right and max(rect.right, x) or x;
                rect.top = rect.top and min(rect.top, y) or y;
                rect.bottom = rect.bottom and max(rect.bottom, y) or y;

                local itemButton = buttons[index] or self.itemPool:Acquire();
                buttons[index] = itemButton

                itemButton:SetHideSpoilers(self:GetHideSpoilers())
                itemButton:Set(item, character)

                -- Check if the item should be next
                itemButton.IsNextAnim:Stop()
                if itemButton.status == nil then-- and itemButton.previousButtons ~= nil then
                    local available = true
                    for i,previous in ipairs(itemButton.previousButtons or {}) do
                        if previous.status ~= "complete" then
                            available = false
                            break
                        end
                    end

                    if available then
                        itemButton.ActiveTexture:Show()
                        itemButton.IsNextAnim:Play()

                        itemButton.Name:SetShown(true)
                        itemButton.SpoilerName:SetShown(false)
                    end

                    itemButton.previousButtons = nil
                end

                itemButton:SetPoint(
                    "CENTER", itemButton:GetParent(), "TOPLEFT",
                    x * CHAIN_GRID_HORIZONTAL_SIZE + CHAIN_GRID_HORIZONTAL_PADDING,
                    -(y * CHAIN_GRID_VERTICAL_SIZE + CHAIN_GRID_VERTICAL_PADDING)
                );

                local connectionIndex = 1
                local connectionItem = item:GetConnection(connectionIndex, character, connectionsOverride and connectionsOverride[index], connectionsChainOverride)
                while connectionItem do
                    if connectionItem:IsValidForCharacter(character) then
                        local connectionChainID = connectionItem:GetRoot():GetID();
                        local connectionIndex = connectionItem:GetIndex();

                        if not self.ItemButtons[connectionChainID] then
                            self.ItemButtons[connectionChainID] = {};
                        end

                        local connectionButton = self.ItemButtons[connectionChainID][connectionIndex] or self.itemPool:Acquire();
                        self.ItemButtons[connectionChainID][connectionIndex] = connectionButton

                        -- Storing this so the connected items can check if they should be next
                        if connectionButton.previousButtons == nil then
                            connectionButton.previousButtons = {}
                        end
                        table.insert(connectionButton.previousButtons, itemButton)

                        local lineContainer = itemButton.linePool:Acquire();

                        lineContainer.Background:SetStartPoint("CENTER", itemButton);
                        lineContainer.Background:SetEndPoint("CENTER", connectionButton);

                        lineContainer.Active:SetStartPoint("CENTER", itemButton);
                        lineContainer.Active:SetEndPoint("CENTER", connectionButton);

                        lineContainer.Complete:SetStartPoint("CENTER", itemButton);
                        lineContainer.Complete:SetEndPoint("CENTER", connectionButton);

                        -- lineContainer:SetAlpha(1)

                        lineContainer.PulseAlpha:Stop()

                        lineContainer.Active:Hide()
                        lineContainer.Complete:Hide()

                        if itemButton.status == "complete" then
                            lineContainer.Complete:Show()
                        elseif itemButton.status == "active" then
                            -- lineContainer.Active:Show()
                        end

                        lineContainer.connection = connectionButton
                        lineContainer:SetShown(itemButton:IsShown() and connectionItem:Visible(character));
                    end

                    connectionIndex = connectionIndex + 1
                    connectionItem = item:GetConnection(connectionIndex, character, connectionsOverride and connectionsOverride[index], connectionsChainOverride)
                end

                if item:Visible(character) then
                    if self.lowestY == nil or y > self.lowestY then
                        self.lowestY = y
                        self.lowestButton = itemButton
                    end

                    if self.scrollTo == nil and itemButton.status ~= "complete" then
                        if asideOverride or item:IsAside(character) then
                            if self.scrollToButtonAside == nil then
                                self.scrollToButtonAside = itemButton
                            end
                        elseif self.scrollToButton == nil then
                            self.scrollToButton = itemButton
                        end
                    elseif type(self.scrollTo) == "number" and index == self.scrollTo then
                        self.scrollToButton = itemButton
                    elseif type(self.scrollTo) == "table" and item:EqualsItem(self.scrollTo) then
                        self.scrollToButton = itemButton
                    end
                end
            end
        end

        index = index + 1
        item = chain:GetItem(index, character)
    end

    return (previousX or 0) + xOffset, (previousY or 0) + yOffset
end
function BtWQuestsChainViewMixin:Update()
    self:UpdateChain(self.chainID)
end
function BtWQuestsChainViewMixin:UpdateChain(chainID, connectionsOverride, connectionsChainOverride)
    local character = self:GetCharacter()

    local buttons = self.ItemButtons[chainID]
    assert(buttons ~= nil, "Cannot update a chain that was never added")

    local chain = BtWQuestsDatabase:GetChainByID(chainID)

    local index = 1
    local item = chain:GetItem(index, character)
    while item do
        if item:IsValidForCharacter(character) then
            if item:GetType() == "chain" and item:IsEmbed() then
                local connections = item:GetConnections();
                local connectionsOverride;
                if connections then
                    connectionsOverride = {};
                    for i,itemConnections in pairs(connections) do
                        local override = {};
                        for k,connection in ipairs(itemConnections) do
                            override[k] = index + connection
                        end
                        connectionsOverride[i] = override;
                    end
                end
                self:UpdateChain(item:GetID(), connectionsOverride, chain)
            else
                local itemButton = buttons[index]
                assert(itemButton, "Chain item was never added in the first place")

                local status = itemButton.status

                itemButton:Update(item)

                -- Check if the item should be next
                itemButton.IsNextAnim:Stop()
                if itemButton.status == nil then-- and itemButton.previousButtons ~= nil then
                    local available = true
                    for i,previous in ipairs(itemButton.previousButtons or {}) do
                        if previous.status ~= "complete" then
                            available = false
                            break
                        end
                    end

                    if available then
                        itemButton.ActiveTexture:Show()
                        itemButton.IsNextAnim:Play()

                        itemButton.Name:SetShown(true)
                        itemButton.SpoilerName:SetShown(false)
                    end

                    itemButton.previousButtons = nil
                end

                local connectionIndex = 1
                local connectionItem = item:GetConnection(connectionIndex, character, connectionsOverride and connectionsOverride[index], connectionsChainOverride)
                while connectionItem do
                    if connectionItem:IsValidForCharacter(character) then
                        local connectionChainID = connectionItem:GetRoot():GetID();
                        local connectionIndex = connectionItem:GetIndex();

                        local connectionButton = self.ItemButtons[connectionChainID][connectionIndex];

                        -- Storing this so the connected items can check if they should be next
                        if connectionButton.previousButtons == nil then
                            connectionButton.previousButtons = {}
                        end
                        table.insert(connectionButton.previousButtons, itemButton)
                    end

                    connectionIndex = connectionIndex + 1
                    connectionItem = item:GetConnection(connectionIndex, character, connectionsOverride and connectionsOverride[index], connectionsChainOverride)
                end

                for lineContainer in itemButton.linePool:EnumerateActive() do
                    if itemButton.status == "complete" and status ~= "complete" then
                        lineContainer.DefaultToCompleteAnim:Play()
                    end
                    lineContainer:SetShown(itemButton:IsShown() and lineContainer.connection:IsShown())
                end
            end
        end

        index = index + 1
        item = chain:GetItem(index, character)
    end
end

-- [[ Expansions View ]]
BtWQuestsExpansionButtonMixin = {}
function BtWQuestsExpansionButtonMixin:OnClick()
    return self.item:OnClick(self.character, self, BtWQuestsFrame, BtWQuestsFrame.Tooltip)
end
function BtWQuestsExpansionButtonMixin:Set(item, character)
    assert(character ~= nil);
    self.item = item

    self:SetText(item:GetName(character))
    self.Subtext:SetText(item:GetSubtext(character, true))
    self.Active:SetShown(item:IsActive(character))
    self.character = character;
end

BtWQuestsExpansionMixin = {}
function BtWQuestsExpansionMixin:OnLoad()
    self.buttonPool = CreateFramePool("BUTTON", self, "BtWQuestsExpansionButtonTemplate")
end
function BtWQuestsExpansionMixin:Set(item, character)
    self.item = item

    self.Name:SetText(item:GetName())

    local texture, left, right, top, bottom = item:GetImage()
    if texture ~= nil then
        self.Background:SetTexture(texture)
        self.Background:SetTexCoord(left, right, top, bottom)
    else
        self.Background:SetTexture("Interface\\Addons\\BtWQuests\\UI-Expansion")
        self.Background:SetTexCoord(0.43359375, 0.66015625, 0.0, 0.8125)
    end

    self.buttonPool:ReleaseAll()

    self.AutoLoad:SetShown(item:SupportAutoLoad())
    self.AutoLoad:SetChecked(item:IsAutoLoad())

    if item:IsLoaded() then
        local items = item:GetMajorItems(character)
        local previous = self.ViewAll
        for i=#items,1,-1 do
            local button = self.buttonPool:Acquire()
            button:Set(items[i], character)
            button:SetPoint("BOTTOM", previous, "TOP", 0, 5)
            button:Show()
            previous = button
        end

        self.Load:Hide()
        self.ViewAll:Show()
    else
        self.Load:Show()
        self.ViewAll:Hide()
    end
end

-- [[ Navbar ]]
BtWQuestsNavBarMixin = {}
function BtWQuestsNavBarMixin:OnShow()
    if not self.Initialized then
        local homeData = {
            name = HOME,
            OnClick = BtWQuestsNavBarButtonMixin.OnClick
        }
        self.dropDown = CreateFrame("Frame", nil, self, "BtWQuestsNavBarDropDownTemplate")
        NavBar_Initialize(self, "BtWQuestsNavBarButtonTemplate", homeData, self.home, self.overflow)
        self.overflow:SetScript("OnClick", function (self, button)
            local dropDown = self:GetParent().dropDown
            if ( dropDown.buttonOwner ~= self ) then
                CloseDropDownMenus();
            end
            dropDown.buttonOwner = self;
            dropDown:Toggle(self, 20, 3)
        end)
        self.Initialized = true
    end
end
function BtWQuestsNavBarMixin:EnableExpansions(value)
    self.enableExpansions = value
end
function BtWQuestsNavBarMixin:Reset()
    NavBar_Reset(self)
end
function BtWQuestsNavBarMixin:SetExpansion(id)
    local character = self:GetCharacter()

    NavBar_Reset(self)
    self:AddButtons("expansion", id, character)
end
function BtWQuestsNavBarMixin:SetCategory(id)
    local character = self:GetCharacter()

    NavBar_Reset(self)
    self:AddButtons("category", id, character)
end
function BtWQuestsNavBarMixin:SetChain(id)
    local character = self:GetCharacter()

    NavBar_Reset(self)
    self:AddButtons("chain", id, character)
end
function BtWQuestsNavBarMixin:AddButtons(type, id, character)
    local id, name, expansion, parent, _ = tonumber(id)
    local item
    if type == "expansion" then
        if not self.enableExpansions then
            return
        end

        item = BtWQuestsDatabase:GetExpansionByID(id)

        name = item:GetName()
    elseif type == "category" then
        item = BtWQuestsDatabase:GetCategoryByID(id)
        name, expansion, parent = item:GetName(), item:GetExpansion(), item:GetParent()
    elseif type == "chain" then
        item = BtWQuestsDatabase:GetChainByID(id)
        name, expansion, parent = item:GetName(), item:GetExpansion(), item:GetCategory()
    end

    if parent then
        self:AddButtons("category", parent, character)

        parent = {
            type = "category",
            id = parent,
        }
    elseif expansion then
        self:AddButtons("expansion", expansion, character)

        parent = {
            type = "expansion",
            id = expansion,
        }
    end

    self:AddButton(type, id, name, parent, character)
end
function BtWQuestsNavBarMixin:AddButton(type, id, name, parent)
    local buttonData = {
        type = type,
        id = tonumber(id),
        name = name,
        parent = parent,
        OnClick = BtWQuestsNavBarButtonMixin.OnClick,
        listFunc = BtWQuestsNavBarButtonMixin.GetList,
    }
    NavBar_AddButton(self, buttonData);
end
function BtWQuestsNavBarMixin:GoToItem(item)
    local BtWQuestsFrame = self:GetParent()

    if item.type == nil then
        if self.enableExpansions then
            BtWQuestsFrame:SelectExpansion()
        else
            BtWQuestsFrame:SelectExpansion(BtWQuestsFrame.expansionID or BtWQuestsDatabase:GetBestExpansionForCharacter(self:GetCharacter()))
        end
    elseif item.type == "expansion" then
        BtWQuestsFrame:SelectExpansion(item.id)
    elseif item.type == "category" then
        BtWQuestsFrame:SelectCategory(item.id)
    elseif item.type == "chain" then
        BtWQuestsFrame:SelectChain(item.id)
    end
end
function BtWQuestsNavBarMixin:GetCharacter()
    return self:GetParent():GetCharacter()
end

BtWQuestsNavBarButtonMixin = {}
function BtWQuestsNavBarButtonMixin:GetList()
    local character = self:GetParent():GetCharacter()

    local item = self.data.parent

    local sisters = {}
    if item == nil then
        for i=0,LE_EXPANSION_LEVEL_CURRENT do
            if BtWQuestsDatabase:HasExpansion(i) then
                table.insert(sisters, {
                    id = {
                        type = "expansion",
                        id = i
                    },
                    text = BtWQuestsDatabase:GetExpansionByID(i):GetName(),
                    func = function(button, item)
                        self:GetParent():GoToItem(item)
                    end,
                })
            end
        end
    elseif item.type == "expansion" then
        local items = BtWQuestsDatabase:GetExpansionByID(item.id):GetItemList(character, true, false, false)
        for _,item in ipairs(items) do
            table.insert(sisters, {
                id = {
                    type = item:GetType(),
                    id = item:GetID()
                },
                text = item:GetName(character),
                func = function(button, item)
                    self:GetParent():GoToItem(item)
                end,
            })
        end
    elseif item.type == "category" then
        local items = BtWQuestsDatabase:GetCategoryByID(item.id):GetItemList(character, true, false, false)
        for _,item in ipairs(items) do
            table.insert(sisters, {
                id = {
                    type = item:GetType(),
                    id = item:GetID()
                },
                text = item:GetName(character),
                func = function(button, item)
                    self:GetParent():GoToItem(item)
                end,
            })
        end
    elseif item.type == "chain" then
    end
    return sisters
end
function BtWQuestsNavBarButtonMixin:OnClick()
    self:GetParent():GoToItem(self.data)
end

BtWQuestsNavBarDropDownMenuMixin = {}
function BtWQuestsNavBarDropDownMenuMixin:OnLoad()
	self.displayMode = "MENU"
end
function BtWQuestsNavBarDropDownMenuMixin:Initialize()
	local navButton = self.buttonOwner;
	if not navButton or not navButton.listFunc then
		return;
	end

	local info = self:CreateInfo();
	info.func = NavBar_DropDown_Click;
	info.owner = navButton;
	info.notCheckable = true;
	local list = navButton:listFunc();
	if ( list ) then
        for i, entry in ipairs(list) do
			info.text = entry.text;
			info.arg1 = entry.id;
			info.func = entry.func;
			self:AddButton(info);
		end
	end
end

-- [[ DropDown Menu ]]
-- This is a simplified replacement for the built in drop down menus to prevent taint
-- Most of this is a copy and paste from the built in system
BtWQuestsDropDownMenuMixin = {}
function BtWQuestsDropDownMenuMixin:SetDropDownWidth(width, padding)
	-- self.Middle:SetWidth(width)
    -- self:SetWidth(self.Left:GetWidth() + self.Right:GetWidth() + self.Middle:GetWidth())

	self.Middle:SetWidth(width);
	local defaultPadding = 25;
	if ( padding ) then
		self:SetWidth(width + padding);
	else
		self:SetWidth(width + defaultPadding + defaultPadding);
	end
	if ( padding ) then
		self.Text:SetWidth(width);
	else
		self.Text:SetWidth(width - defaultPadding);
	end
	-- frame.noResize = 1;
end
function BtWQuestsDropDownMenuMixin:SetText(text)
	self.Text:SetText(text)
end
function BtWQuestsDropDownMenuMixin:GetText()
	return self.Text:GetText()
end
function BtWQuestsDropDownMenuMixin:JustifyText(justification)
	local text = self.Text
	text:ClearAllPoints()
	if justification == "LEFT" then
		text:SetPoint("LEFT", self.Left, "LEFT", 27, 2)
		text:SetJustifyH("LEFT")
	elseif justification == "RIGHT" then
		text:SetPoint("RIGHT", self.Right, "RIGHT", -43, 2)
		text:SetJustifyH("RIGHT")
	elseif justification == "CENTER" then
		text:SetPoint("CENTER", self.Middle, "CENTER", -5, 2)
		text:SetJustifyH("CENTER")
	end
end
function BtWQuestsDropDownMenuMixin:GetListFrame()
    local list = self.list

    if list == nil then
		list = CreateFrame("Button", nil, nil, "BtWQuestsDropDownListTemplate")
		list:SetFrameStrata("FULLSCREEN_DIALOG")
		list:SetToplevel(true)
		list:Hide()
		list:SetWidth(180)
        list:SetHeight(10)
        self.list = list
        self.buttonPool = CreateFramePool("BUTTON", list, "BtWQuestsDropDownButtonTemplate")

        local menu = self
        hooksecurefunc("ToggleDropDownMenu", function ()
            menu:Close()
        end)
        hooksecurefunc("CloseDropDownMenus", function ()
            if not list:IsMouseOver() then
                menu:Close()
            end
        end)
    end

    return list
end
function BtWQuestsDropDownMenuMixin:CreateInfo()
    local prefix = self.prefix or "BtWQuestsDropDown"
    local info = _G[prefix .. 'Info']
    if info == nil then
        _G[prefix .. 'Info'] = {}
        return _G[prefix .. 'Info']
    end

    table.wipe(info)
    return info
end
function BtWQuestsDropDownMenuMixin:GetButtonWidth(button)
    local minWidth = button.minWidth or 0;
    if button.customFrame and button.customFrame:IsShown() then
        return math.max(minWidth, button.customFrame:GetPreferredEntryWidth());
    end

    if not button:IsShown() then
        return 0;
    end

    local width;
    local icon = button.Icon;
    local normalText = button.NormalText

    if ( button.iconOnly and icon ) then
        width = icon:GetWidth();
    elseif ( normalText and normalText:GetText() ) then
        width = normalText:GetWidth() + 40;

        if ( button.icon ) then
            -- Add padding for the icon
            width = width + 10;
        end
    else
        return minWidth;
    end

    -- Add padding if has and expand arrow or color swatch
    if ( button.hasArrow or button.hasColorSwatch ) then
        width = width + 10;
    end
    if ( button.notCheckable ) then
        width = width - 30;
    end
    if ( button.padding ) then
        width = width + button.padding;
    end

    return math.max(minWidth, width);
end
function BtWQuestsDropDownMenuMixin:AddButton(info)
    local listFrame = self:GetListFrame()
    local button = self.buttonPool:Acquire()
    local index = self.buttonPool:GetNumActive()

	local normalText = button.NormalText
	local icon = button.Icon
	-- This button is used to capture the mouse OnEnter/OnLeave events if the dropdown button is disabled, since a disabled button doesn't receive any events
	-- This is used specifically for drop down menu time outs
    -- local invisibleButton = button.InvisibleButton

    button:SetWidth(listFrame:GetWidth() - 30)

	-- Default settings
	button:SetDisabledFontObject(GameFontDisableSmallLeft);
	-- invisibleButton:Hide();
	button:Enable();

	-- If not clickable then disable the button and set it white
	if ( info.notClickable ) then
		info.disabled = true;
		button:SetDisabledFontObject(GameFontHighlightSmallLeft);
	end

	-- Set the text color and disable it if its a title
	if ( info.isTitle ) then
		info.disabled = true;
		button:SetDisabledFontObject(GameFontNormalSmallLeft);
	end

	-- Disable the button if disabled and turn off the color code
	if ( info.disabled ) then
		button:Disable();
		-- invisibleButton:Show();
		info.colorCode = nil;
	end

	-- If there is a color for a disabled line, set it
	if( info.disablecolor ) then
		info.colorCode = info.disablecolor;
	end

	-- Configure button
	if ( info.text ) then
		-- look for inline color code this is only if the button is enabled
		if ( info.colorCode ) then
			button:SetText(info.colorCode..info.text.."|r");
		else
			button:SetText(info.text);
		end

		-- Set icon
		if ( info.icon or info.mouseOverIcon ) then
			icon:SetSize(16,16);
			icon:SetTexture(info.icon);
			icon:ClearAllPoints();
			icon:SetPoint("RIGHT");

			if ( info.tCoordLeft ) then
				icon:SetTexCoord(info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom);
			else
				icon:SetTexCoord(0, 1, 0, 1);
			end
			icon:Show();
		else
			icon:Hide();
		end

		-- Check to see if there is a replacement font
		if ( info.fontObject ) then
			button:SetNormalFontObject(info.fontObject);
			button:SetHighlightFontObject(info.fontObject);
		else
			button:SetNormalFontObject(GameFontHighlightSmallLeft);
			button:SetHighlightFontObject(GameFontHighlightSmallLeft);
		end
	else
		button:SetText("");
		icon:Hide();
	end

	button.iconOnly = nil;
	button.icon = nil;
	button.iconInfo = nil;

	if (info.iconInfo) then
		icon.tFitDropDownSizeX = info.iconInfo.tFitDropDownSizeX;
	else
		icon.tFitDropDownSizeX = nil;
	end
	if (info.iconOnly and info.icon) then
		button.iconOnly = true;
		button.icon = info.icon;
		button.iconInfo = info.iconInfo;

		UIDropDownMenu_SetIconImage(icon, info.icon, info.iconInfo);
		icon:ClearAllPoints();
		icon:SetPoint("LEFT");
	end

	-- Pass through attributes
	button.func = info.func;
	button.owner = info.owner;
	button.hasOpacity = info.hasOpacity;
	button.opacity = info.opacity;
	button.opacityFunc = info.opacityFunc;
	button.cancelFunc = info.cancelFunc;
	button.swatchFunc = info.swatchFunc;
	button.keepShownOnClick = info.keepShownOnClick;
	button.tooltipTitle = info.tooltipTitle;
	button.tooltipText = info.tooltipText;
	button.tooltipInstruction = info.tooltipInstruction;
	button.tooltipWarning = info.tooltipWarning;
	button.arg1 = info.arg1;
	button.arg2 = info.arg2;
	button.hasArrow = info.hasArrow;
	button.hasColorSwatch = info.hasColorSwatch;
	button.notCheckable = info.notCheckable;
	button.menuList = info.menuList;
	button.tooltipWhileDisabled = info.tooltipWhileDisabled;
	button.noTooltipWhileEnabled = info.noTooltipWhileEnabled;
	button.tooltipOnButton = info.tooltipOnButton;
	button.noClickSound = info.noClickSound;
	button.padding = info.padding;
	button.icon = info.icon;
    button.mouseOverIcon = info.mouseOverIcon;
    button.deleteFunc = info.deleteFunc
    button.hasDelete = info.hasDelete

	if ( info.value ) then
		button.value = info.value;
	elseif ( info.text ) then
		button.value = info.text;
	else
		button.value = nil;
	end

	-- If not checkable move everything over to the left to fill in the gap where the check would be
	local xPos = 5;
	local yPos = -((index - 1) * UIDROPDOWNMENU_BUTTON_HEIGHT) - UIDROPDOWNMENU_BORDER_HEIGHT;
	local displayInfo = normalText;
	if (info.iconOnly) then
		displayInfo = icon;
	end

	displayInfo:ClearAllPoints();
	if ( info.notCheckable ) then
		if ( info.justifyH and info.justifyH == "CENTER" ) then
			displayInfo:SetPoint("CENTER", button, "CENTER", -7, 0);
		else
			displayInfo:SetPoint("LEFT", button, "LEFT", 0, 0);
		end
		xPos = xPos + 10;

	else
		xPos = xPos + 12;
		displayInfo:SetPoint("LEFT", button, "LEFT", 20, 0);
	end

	if ( info.leftPadding ) then
		xPos = xPos + info.leftPadding;
	end
	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", xPos, yPos)

	if not info.notCheckable then
		local check = button.Check
		local uncheck = button.UnCheck
		if ( info.disabled ) then
			check:SetDesaturated(true);
			check:SetAlpha(0.5);
			uncheck:SetDesaturated(true);
			uncheck:SetAlpha(0.5);
		else
			check:SetDesaturated(false);
			check:SetAlpha(1);
			uncheck:SetDesaturated(false);
			uncheck:SetAlpha(1);
		end

		if info.customCheckIconAtlas or info.customCheckIconTexture then
			check:SetTexCoord(0, 1, 0, 1);
			uncheck:SetTexCoord(0, 1, 0, 1);

			if info.customCheckIconAtlas then
				check:SetAtlas(info.customCheckIconAtlas);
				uncheck:SetAtlas(info.customUncheckIconAtlas or info.customCheckIconAtlas);
			else
				check:SetTexture(info.customCheckIconTexture);
				uncheck:SetTexture(info.customUncheckIconTexture or info.customCheckIconTexture);
			end
		elseif info.isNotRadio then
			check:SetTexCoord(0.0, 0.5, 0.0, 0.5);
			check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
			uncheck:SetTexCoord(0.5, 1.0, 0.0, 0.5);
			uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
		else
			check:SetTexCoord(0.0, 0.5, 0.5, 1.0);
			check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
			uncheck:SetTexCoord(0.5, 1.0, 0.5, 1.0);
			uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
		end

		-- Checked can be a function now
		local checked = info.checked;
		if ( type(checked) == "function" ) then
			checked = checked(button);
		end

		-- Show the check if checked
		if ( checked ) then
			button:LockHighlight();
			check:Show();
			uncheck:Hide();
		else
			button:UnlockHighlight();
			check:Hide();
			uncheck:Show();
		end
	else
		button.Check:Hide();
		button.UnCheck:Hide();
	end
	button.checked = info.checked;

	-- If has a colorswatch, show it and vertex color it
	local colorSwatch = button.ColorSwatch
	if ( info.hasColorSwatch ) then
		button.ColorSwatch.NormalTexture:SetVertexColor(info.r, info.g, info.b);
		button.r = info.r;
		button.g = info.g;
		button.b = info.b;
		colorSwatch:Show();
	else
		colorSwatch:Hide();
    end

	local deleteButton = button.DeleteButton
    if info.hasDelete then
        deleteButton:Show()
    else
        deleteButton:Hide()
    end

	UIDropDownMenu_CheckAddCustomFrame(listFrame, button, info);

	button:SetShown(button.customFrame == nil);

	button.minWidth = info.minWidth;

	local width = max(self:GetButtonWidth(button), info.minWidth or 0);
	--Set maximum button width
	if ( width > listFrame.maxWidth ) then
		listFrame.maxWidth = width;
    end

    -- Set the height of the listframe
	listFrame:SetHeight((index * UIDROPDOWNMENU_BUTTON_HEIGHT) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2));

    button:Show()
end
function BtWQuestsDropDownMenuMixin:Toggle(anchorName, xOffset, yOffset)
    local list = self:GetListFrame()
    if list:IsShown() and self.anchorName == anchorName then
        self:Close()
    else
        self.anchorName = anchorName
        self:Open(anchorName, xOffset, yOffset)
    end
end
function BtWQuestsDropDownMenuMixin:Open(anchorName, xOffset, yOffset)
    CloseDropDownMenus()

    local list = self:GetListFrame()
    -- Set the dropdownframe scale
    local uiScale;
    local uiParentScale = UIParent:GetScale();
    if GetCVar("useUIScale") == "1" then
        uiScale = tonumber(GetCVar("uiscale"))
        if uiParentScale < uiScale then
            uiScale = uiParentScale
        end
    else
        uiScale = uiParentScale
    end
    list:SetScale(uiScale)

    list:ClearAllPoints()
    local point, relativeTo, relativePoint

    if ( not anchorName ) then
        -- See if the anchor was set manually using setanchor
        if ( self.xOffset ) then
            xOffset = self.xOffset;
        end
        if ( self.yOffset ) then
            yOffset = self.yOffset;
        end
        if ( self.point ) then
            point = self.point;
        end
        if ( self.relativeTo ) then
            relativeTo = self.relativeTo;
        else
            relativeTo = self.Left
        end
        if ( self.relativePoint ) then
            relativePoint = self.relativePoint;
        end
    elseif ( anchorName == "cursor" ) then
        relativeTo = nil;
        local cursorX, cursorY = GetCursorPosition();
        cursorX = cursorX/uiScale;
        cursorY =  cursorY/uiScale;

        if ( not xOffset ) then
            xOffset = 0;
        end
        if ( not yOffset ) then
            yOffset = 0;
        end
        xOffset = cursorX + xOffset;
        yOffset = cursorY + yOffset;
    else
        -- See if the anchor was set manually using setanchor
        if ( self.xOffset ) then
            xOffset = self.xOffset;
        end
        if ( self.yOffset ) then
            yOffset = self.yOffset;
        end
        if ( self.point ) then
            point = self.point;
        end
        if ( self.relativeTo ) then
            relativeTo = self.relativeTo;
        else
            relativeTo = anchorName;
        end
        if ( self.relativePoint ) then
            relativePoint = self.relativePoint;
        end
    end

    if not point then
        point = "TOPLEFT"
    end
    if not relativePoint then
        relativePoint = "BOTTOMLEFT"
    end
    if not xOffset or not yOffset then
        xOffset = 8
        yOffset = 22
    end

    list:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);

    if self.displayMode == "MENU" then
        list.Backdrop:Hide()
        list.MenuBackdrop:Show()
    else
        list.Backdrop:Show()
        list.MenuBackdrop:Hide()
    end

    list.maxWidth = 0

    self.buttonPool:ReleaseAll()
    self:Initialize()

    list:SetWidth(list.maxWidth + 25)

    for button in self.buttonPool:EnumerateActive() do
        button:SetWidth(list.maxWidth);
    end

    list:Show()

    local offLeft = list:GetLeft()/uiScale;
    local offRight = (GetScreenWidth() - list:GetRight())/uiScale;
    local offTop = (GetScreenHeight() - list:GetTop())/uiScale;
    local offBottom = list:GetBottom()/uiScale;

    local xAddOffset, yAddOffset = 0, 0;
    if ( offLeft < 0 ) then
        xAddOffset = -offLeft;
    elseif ( offRight < 0 ) then
        xAddOffset = offRight;
    end

    if ( offTop < 0 ) then
        yAddOffset = offTop;
    elseif ( offBottom < 0 ) then
        yAddOffset = -offBottom;
    end

    list:ClearAllPoints();
    if ( anchorName == "cursor" ) then
        list:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset);
    else
        list:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset);
    end
end
function BtWQuestsDropDownMenuMixin:Close()
    self:GetListFrame():Hide()
end

-- [[ Character Dropdown ]]
BtWQuestsCharacterDropDownMixin = {}
function BtWQuestsCharacterDropDownMixin:OnLoad()
    self:SetDropDownWidth(156, 23 * 2);
    self.xOffset = 8
    self.yOffset = 15
    -- self:JustifyText("LEFT");
    -- if not self.Initialized then
    --     UIDropDownMenu_SetWidth(self, 156, 23 * 2);
	-- 	UIDropDownMenu_SetInitializeFunction(self, self.Initialize);
    --     -- UIDropDownMenu_Initialize(self, self.Initialize);
    --     self.xOffset = 8
    --     self.yOffset = 15

    --     self.Initialized = true
    -- end
end
function BtWQuestsCharacterDropDownMixin:Initialize()
    local function Select (button)
        self:GetParent():SelectCharacter(button.value)
    end

    local name = UnitName("player")
    local realm = GetRealmName()
    local player = name .. "-" .. realm

    local currentName, currentRealm = self:GetParent():GetCharacter():GetFullName()
    local current = currentName .. "-" .. currentRealm

    if C_QuestSession.HasJoined() then
        local info = self:CreateInfo();
        info.text = BtWQuests.L["Party Sync"]
        info.value = "-partysync"
        info.func = Select
        info.checked = "-partysync" == current
        self:AddButton(info)
    end
    if select(4, GetBuildInfo()) >= 110000 then
        local info = self:CreateInfo();
        info.text = BtWQuests.L["Warband"]
        info.value = "-warband"
        info.func = Select
        info.checked = "-warband" == current
        self:AddButton(info)
    end

    local info = self:CreateInfo();
    info.text = RAID_CLASS_COLORS[select(2,UnitClass("player"))]:WrapTextInColorCode(player .. " (" .. UnitLevel("player") .. ")")
    -- info.text = player
    info.value = player
    info.func = Select
    info.checked = player == current
    info.deleteFunc = function (button, ...)
       BtWQuestsCharacters:RemoveCharacter(button.value)
    end
    self:AddButton(info)

    info.hasDelete = true

    for _,character,data in BtWQuestsCharacters:ipairs() do
        if character ~= player then
            info.text = RAID_CLASS_COLORS[data:GetClassString()]:WrapTextInColorCode(character .. " (" .. data:GetLevel() .. ")")
            -- info.text = character
            info.value = character
            info.func = Select
            info.checked = character == current
            self:AddButton(info)
        end
    end
end

-- [[ Expansion Dropdown ]]
BtWQuestsExpansionDropDownMixin = {}
function BtWQuestsExpansionDropDownMixin:OnLoad()
    self:SetDropDownWidth(156);
    self:JustifyText("LEFT");
    -- if not self.Initialized then
    --     UIDropDownMenu_SetWidth(self, 156);
    --     UIDropDownMenu_JustifyText(self, "LEFT");
	-- 	UIDropDownMenu_SetInitializeFunction(self, self.Initialize);
    --     -- UIDropDownMenu_Initialize(self, self.Initialize);

    --     self.Initialized = true
    -- end
end
function BtWQuestsExpansionDropDownMixin:Initialize(level)
    local function Select (button)
        self:GetParent():SelectExpansion(button.value)
    end

    local info = self:CreateInfo()
    local current = self:GetParent():GetExpansion()
    for i=0,LE_EXPANSION_LEVEL_CURRENT do
        if BtWQuestsDatabase:HasExpansion(i) then
            info.text = BtWQuestsDatabase:GetExpansionByID(i)
            info.value = i;
            info.func = Select
            info.checked = i == current;

            self:AddButton(info)
        elseif i == current then
            info.text = _G['BTWQUESTS_EXPANSION_NAME' .. i]
            info.value = i;
            info.func = Select
            info.checked = i == current;

            self:AddButton(info)
        end
    end
end

-- [[ Tooltip ]]
BtWQuestsTooltipMixin = {}
function BtWQuestsTooltipMixin:OnLoad()
    GameTooltip_OnLoad(self)
    if not TooltipDataProcessor or not TooltipDataProcessor.AddTooltipPostCall then
        self:SetScript("OnTooltipSetQuest", self.OnSetQuest)
    end
end
function BtWQuestsTooltipMixin:OnSetQuest()
    local quest = BtWQuestsDatabase:GetQuestByID(self.questID)
    if quest == nil then
        return
    end

    if not self.character:IsPartySync() or not C_QuestLog.IsQuestReplayable(self.questID) then
        self:AddRewards(quest, self.character)
    end
end
function BtWQuestsTooltipMixin:AddRewards(item, character)
    local rewards = item:GetRewards()
    if not rewards or #rewards == 0 then
        return
    end

    local addedRewards
    for _,reward in ipairs(rewards) do
        reward = reward:GetVariation(character) or reward;

        if reward:IsValidForCharacter(character) and reward:Visible(character) then
            if not addedRewards then
                self:AddLine(" ")
                self:AddLine(L["BTWQUESTS_TOOLTIP_REWARDS"])
                addedRewards = true
            end

            self:AddLine(" - " .. reward:GetName(character, "reward"), 1, 1, 1)
        end
	end
end
function BtWQuestsTooltipMixin:SetChain(chainID, character)
    local chainID = tonumber(chainID)
    local chain = BtWQuestsDatabase:GetChainByID(chainID);

    self:ClearLines()
    self:AddDoubleLine(chain:GetName(character))

    if chain:IsActive(character) then
        self:AddLine(GREEN_FONT_COLOR_CODE..L["BTWQUESTS_QUEST_CHAIN_ACTIVE"]..FONT_COLOR_CODE_CLOSE)
    end

    local prerequisites, hasLowPrio = chain:GetPrerequisites()
    if prerequisites then
        local addedPrerequisite
        for _,prerequisite in ipairs(prerequisites) do
            prerequisite = prerequisite:GetVariation(character) or prerequisite;

            if prerequisite:IsValidForCharacter(character) and prerequisite:Visible(character, IsModifiedClick("SHIFT")) then
                if not addedPrerequisite then
                    self:AddLine(" ")
                    self:AddLine(L["BTWQUESTS_TOOLTIP_PREREQUISITES"])
                    addedPrerequisite = true
                end

                if prerequisite:IsCompleted(character) then
                    self:AddLine(" - " .. prerequisite:GetName(character, "prerequisite"), 0.5, 0.5, 0.5)
                else
                    self:AddLine(" - " .. prerequisite:GetName(character, "prerequisite"), 1, 1, 1)
                end
            end
        end
    end

    self:AddRewards(chain, character)

    if IsModifiedClick("SHIFT") then
        local restrictions = chain:GetRestrictions()
        if restrictions then
            local addedRestrictions
            for _,restriction in ipairs(restrictions) do
                restriction = restriction:GetVariation(character) or restriction;

                if not addedRestrictions then
                    self:AddLine(" ")
                    self:AddLine(L["BTWQUESTS_TOOLTIP_RESTRICTIONS"])
                    addedRestrictions = true
                end

                if restriction:IsCompleted(character) then
                    self:AddLine(" - " .. restriction:GetName(character, "restriction"), 0.5, 0.5, 0.5)
                else
                    self:AddLine(" - " .. restriction:GetName(character, "restriction"), 1, 1, 1)
                end
            end
        end
    end

    self:Show();
end
local IsUnitOnQuest = C_QuestLog.IsUnitOnQuest
if not IsUnitOnQuest then
    function IsUnitOnQuest(unit, questID)
        return IsUnitOnQuestByQuestID(questID, unit)
    end
end
-- Custom function for displaying an active quest showing completed requirements
function BtWQuestsTooltipMixin:SetActiveQuest(id, character)
    local id = tonumber(id)

    self.character = character
    self.questID = id

    local quest = BtWQuestsDatabase:GetQuestByID(id)
    local questLogIndex = GetLogIndexForQuestID(id)
	local isComplete = IsQuestComplete(id);
	local isFailed = IsQuestFailed(id);
    local _, objectiveText = GetQuestLogQuestText(questLogIndex);

    self:ClearLines()
    self:SetText(quest:GetName())

    if character:IsQuestActive(id) then
        if character:IsPlayer() and C_QuestLog.IsQuestReplayable and C_QuestLog.IsQuestReplayable(id) then
            GameTooltip_AddInstructionLine(self, QuestUtils_GetReplayQuestDecoration(id)..QUEST_SESSION_QUEST_TOOLTIP_IS_REPLAY, false);
        elseif character:IsPlayer() and C_QuestLog.IsQuestDisabledForSession and C_QuestLog.IsQuestDisabledForSession(id) then
            GameTooltip_AddColoredLine(self, QuestUtils_GetDisabledQuestDecoration(id)..QUEST_SESSION_ON_HOLD_TOOLTIP_TITLE, DISABLED_FONT_COLOR, false);
        else
            self:AddLine(GREEN_FONT_COLOR_CODE..QUEST_TOOLTIP_ACTIVE..FONT_COLOR_CODE_CLOSE)
        end
    end

	if isFailed then
		QuestUtils_AddQuestTagLineToTooltip(self, FAILED, "FAILED", nil, RED_FONT_COLOR);
	end

	if isComplete then
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
        self:AddLine(" ")
		self:AddLine(completionText, 1, 1, 1, true);
    else
        if objectiveText then
            self:AddLine(" ")
            self:AddLine(objectiveText, 1, 1, 1, true)
        end

        local numRequirements = character:GetNumQuestLeaderBoards(id);
        local addedTitle
        for index = 1,numRequirements do
            local name, _, completed = character:GetQuestLogLeaderBoard(index, id);
            if name then
                if not addedTitle then
                    self:AddLine(" ")
                    self:AddLine(QUEST_TOOLTIP_REQUIREMENTS)
                    addedTitle = true
                end

                if completed then
                    self:AddLine(" - " .. name, 0.5, 0.5, 0.5)
                else
                    self:AddLine(" - " .. name, 1, 1, 1)
                end
            end
        end
    end

	local partyMembersOnQuest = 0;
    for i=1, GetNumSubgroupMembers() do
        if IsUnitOnQuest("party"..i, i) then
			-- Found at least one party member who is also on the quest, set it up!
			self:AddLine(" ");
			self:AddLine(PARTY_QUEST_STATUS_ON);

			local omitTitle = true;
			local ignoreActivePlayer = true;
			self:SetQuestPartyProgress(id, omitTitle, ignoreActivePlayer);

			break;
		end
	end

    self:OnSetQuest()
    self:Show()
end
-- Custom function for displaying quests not in the log, used for bcc and before SetHyperlink
function BtWQuestsTooltipMixin:SetQuest(id, character)
    local id = tonumber(id)

    self.character = character
    self.questID = id

    local quest = BtWQuestsDatabase:GetQuestByID(id)

    self:ClearLines()
    self:SetText(quest:GetName())

    -- if objectiveText then
    --     self:AddLine(" ")
    --     self:AddLine(objectiveText, 1, 1, 1, true)
    -- end

    local objectives = C_QuestLog.GetQuestObjectives(id);
    if objectives then
        local addedTitle
        for _,objective in ipairs(objectives) do
            if objective then
                if not addedTitle then
                    self:AddLine(" ")
                    self:AddLine(QUEST_TOOLTIP_REQUIREMENTS)
                    addedTitle = true
                end

                self:AddLine(" - " .. objective.text, 1, 1, 1)
            end
        end
    end

    for i=1, GetNumSubgroupMembers() do
        if IsUnitOnQuest("party"..i, i) then
			-- Found at least one party member who is also on the quest, set it up!
			self:AddLine(" ");
			self:AddLine(PARTY_QUEST_STATUS_ON);

			local omitTitle = true;
			local ignoreActivePlayer = true;
			self:SetQuestPartyProgress(id, omitTitle, ignoreActivePlayer);

			break;
		end
	end

    self:OnSetQuest()
    self:Show()
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, function (self, data)
        if self.OnSetQuest then
            self:OnSetQuest();
        end
    end)
end

-- Doing this because TSM and Auctioneer tainted GameTooltip.SetHyperlink without checking if their variables exist
local dummpGameTooltip = CreateFrame("GameTooltip", "BtWQuestsDummyTooltip", UIParent, "GameTooltipTemplate")
dummpGameTooltip:Hide()
function BtWQuestsTooltipMixin:SetHyperlink(link, character)
    local _, _, color, linkstring, name = string.find(link, "^|cff(%x%x%x%x%x%x)|H([^|]+)|h%[(.*)%]|h|r$")
    linkstring = linkstring or link

    local _, _, type, text = string.find(linkstring, "([^:]+):([^|]+)")
    if type == "garrmission" then
        _, _, type, text = string.find(text, "^([^:]*):(.*)")
    end

    if type == "quest" then
        local _, _, id = string.find(text, "^(%d+)")
        id = tonumber(id);
        if character:IsQuestActive(id) then
            self:SetActiveQuest(id, character)
        else
            self.character = character
            self.questID = id

            self:SetQuest(id, character)
            if QuestEventListener then
                QuestEventListener:AddCallback(id, function()
                    if self.questID == id then
                        dummpGameTooltip.SetHyperlink(self, link)
                    end
                end)
            end
        end
    elseif type == "btwquests" then
        local _, _, subtype, id = string.find(text, "^([^:]*):(%d+)")

        if subtype == "chain" then
            self:SetChain(id, character)
        end
    else
        dummpGameTooltip.SetHyperlink(self, link)
    end
end

-- [[ Search ]]
local MIN_CHARACTER_SEARCH = 3
BTWQUESTS_NUM_SEARCH_PREVIEWS = 5;
BTWQUESTS_SHOW_ALL_SEARCH_RESULTS_INDEX = BTWQUESTS_NUM_SEARCH_PREVIEWS + 1;

BtWQuestsSearchBoxMixin = {}
function BtWQuestsSearchBoxMixin:GetViewFrame() -- Should be the BtWQuestsFrame
    return self:GetParent()
end
function BtWQuestsSearchBoxMixin:GetPreviewFrame()
    return self:GetViewFrame().SearchPreview
end
function BtWQuestsSearchBoxMixin:GetResultsFrame()
    return self:GetViewFrame().SearchResults
end
function BtWQuestsSearchBoxMixin:GetCharacter()
    return self:GetViewFrame():GetCharacter()
end
function BtWQuestsSearchBoxMixin:GetTooltip()
    return BtWQuestsTooltip
end
function BtWQuestsSearchBoxMixin:SetSearch(query)
    local start = debugprofilestop()
    self.query = query
    if not self.results then
        self.results = {};
    end
    wipe(self.results);
    BtWQuestsDatabase:Search(self.results, query, self:GetCharacter())
    -- print (string.format("BtWQuests search found %d in %fms", #self.results, debugprofilestop() - start))
end
function BtWQuestsSearchBoxMixin:ClearSearch()
    self.query = nil
    self.results = {}
end
function BtWQuestsSearchBoxMixin:HidePreview()
    local frame = self:GetPreviewFrame()
    if frame then
        frame:Hide()
    end
end
function BtWQuestsSearchBoxMixin:HideResults()
    local frame = self:GetResultsFrame()
    if frame then
        frame:Hide()
    end
end
function BtWQuestsSearchBoxMixin:UpdateResults()
    local resultsFrame = self:GetResultsFrame()
    local previewFrame = self:GetPreviewFrame()
    if resultsFrame and (resultsFrame:IsShown() or not previewFrame) then
        resultsFrame:UpdateResults(self.query, self.results)
    else
        previewFrame:UpdateResults(self.query, self.results)
    end
end
function BtWQuestsSearchBoxMixin:ShowFullSearch()
    local resultsFrame = self:GetResultsFrame()
    local previewFrame = self:GetPreviewFrame()
    if resultsFrame then
        if previewFrame then
            previewFrame:Hide()
        end

        resultsFrame:Show()
        self:UpdateResults()
        self:ClearFocus()
    end
end
function BtWQuestsSearchBoxMixin:OnLoad()
    SearchBoxTemplate_OnLoad(self)
end
function BtWQuestsSearchBoxMixin:OnShow()
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
end
function BtWQuestsSearchBoxMixin:OnHide()
end
function BtWQuestsSearchBoxMixin:OnTextChanged()
    SearchBoxTemplate_OnTextChanged(self)

    local text = self:GetText();

    self:SetSearch(text)
    self:UpdateResults()
end
function BtWQuestsSearchBoxMixin:OnEnterPressed()
    local previewFrame = self:GetPreviewFrame()
    if previewFrame then
        previewFrame:OpenSelection(self)
    end
end
function BtWQuestsSearchBoxMixin:OnKeyDown(key)
    local previewFrame = self:GetPreviewFrame()
    if previewFrame then
        if key == "UP" then
            previewFrame:MoveSelection(-1)
        elseif key == "DOWN" then
            previewFrame:MoveSelection(1)
        end
    end
end
function BtWQuestsSearchBoxMixin:OnFocusLost()
    SearchBoxTemplate_OnEditFocusLost(self);
    if not self:GetPreviewFrame():IsMouseOver() then
        self:HidePreview()
    end
end
function BtWQuestsSearchBoxMixin:OnFocusGained()
    SearchBoxTemplate_OnEditFocusGained(self)

    if self:GetNumResults() == 0 then
        self:HidePreview()
        self:HideResults()

        return
    end

    self:SetSearch(self:GetText())

    local resultsFrame = self:GetResultsFrame()
    local previewFrame = self:GetPreviewFrame()
    if previewFrame then
        if resultsFrame then
            resultsFrame:Hide()
        end
        -- self:SetPreviewSelection(1)
        previewFrame:UpdateResults(self.query, self.results)
    end
end
function BtWQuestsSearchBoxMixin:GetNumResults()
    return #self.results
end

BtWQuestsSearchPreviewMixin = {}
function BtWQuestsSearchPreviewMixin:OnLoad()
    self:SetSelection(1)
end
function BtWQuestsSearchPreviewMixin:UpdateResults(query, results)
    local numResults = #results
    if numResults == 0 then
        self:Hide()
    end

    for index = 1, BTWQUESTS_NUM_SEARCH_PREVIEWS do
        local button = self.Results[index]
        if index <= numResults then
            button.Name:SetText(results[index].name);
            button.link = results[index].item.link;
            button.tooltip = results[index].item.tooltip;
            button.scrollTo = results[index].item.scrollTo;
            button:SetID(index)
            button:Show()
        else
            button:Hide()
        end
    end

    self:Show()

    self.ShowAllResults:Hide();
    -- self.searchBox.searchProgress:Hide();
    if numResults > BTWQUESTS_NUM_SEARCH_PREVIEWS then
        self.ShowAllResults.text:SetText(string.format(ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS, numResults));
        self.ShowAllResults:Show();
    end

    self:FixBottomBorder()
end
function BtWQuestsSearchPreviewMixin:OpenSelection(SearchBox)
    if self.selectedIndex > BTWQUESTS_SHOW_ALL_SEARCH_RESULTS_INDEX or self.selectedIndex < 0 then
        return;
    elseif self.selectedIndex == BTWQUESTS_SHOW_ALL_SEARCH_RESULTS_INDEX then
        if self.ShowAllResults:IsShown() then
            self.ShowAllResults:Click();
        end
    else
        local result = self.Results[self.selectedIndex];
        if result:IsShown() then
            result:Click();
        end
    end

    self:Hide()
end
function BtWQuestsSearchPreviewMixin:FixBottomBorder()
    local lastShownButton = nil
    if self.ShowAllResults:IsShown() then
        lastShownButton = self.ShowAllResults
    else
        for index = 1, BTWQUESTS_NUM_SEARCH_PREVIEWS do
            local button = self.Results[index]
            if button:IsShown() then
                lastShownButton = button;
            end
        end
    end

    if lastShownButton ~= nil then
        self:SetHeight(self:GetTop() - lastShownButton:GetBottom())
        self.botRightCorner:SetPoint("BOTTOM", lastShownButton, "BOTTOM", 0, -8)
        self.botLeftCorner:SetPoint("BOTTOM", lastShownButton, "BOTTOM", 0, -8)
    else
        self:Hide()
    end
end
function BtWQuestsSearchPreviewMixin:SetSelection(selectedIndex)
    local numShown = 0;
    for index = 1, BTWQUESTS_NUM_SEARCH_PREVIEWS do
        self.Results[index].selectedTexture:Hide();

        if self.Results[index]:IsShown() then
            numShown = numShown + 1;
        end
    end

    if self.ShowAllResults:IsShown() then
        numShown = numShown + 1;
    end

    self.ShowAllResults.selectedTexture:Hide();

    if numShown == 0 then
        selectedIndex = 1;
    elseif selectedIndex > numShown then
        -- Wrap under to the beginning.
        selectedIndex = 1;
    elseif selectedIndex < 1 then
        -- Wrap over to the end;
        selectedIndex = numShown;
    end

    self.selectedIndex = selectedIndex;

    if selectedIndex == BTWQUESTS_SHOW_ALL_SEARCH_RESULTS_INDEX then
        self.ShowAllResults.selectedTexture:Show();
    else
        self.Results[selectedIndex].selectedTexture:Show();
    end
end
function BtWQuestsSearchPreviewMixin:GetSelection()
    return self.selectedIndex
end
function BtWQuestsSearchPreviewMixin:MoveSelection(value)
    return self:SetSelection(self.selectedIndex + value)
end

BtWQuestsSearchResultsMixin = {}
function BtWQuestsSearchResultsMixin:OnLoad()
    local this = self
    local scrollFrame = self.scrollFrame
    scrollFrame.update = function ()
        this:UpdateSearch()
    end
	scrollFrame.scrollBar.doNotHide = true
    HybridScrollFrame_CreateButtons(scrollFrame, "BtWQuestsSearchResultFullTemplate", 0, 0)
end
function BtWQuestsSearchResultsMixin:UpdateResults(query, results)
    self.query = query
    self.results = results

    self:UpdateSearch()
end
function BtWQuestsSearchResultsMixin:UpdateSearch()
    local scrollFrame = self.scrollFrame
    local query = self.query
    local results = self.results
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local button, index

    local numResults = #results

    self.TitleText:SetText(string.format(ENCOUNTER_JOURNAL_SEARCH_RESULTS, query, numResults));

    for i=1,#buttons do
        button = buttons[i];
        index = offset + i;
        if index <= numResults then
            button.Name:SetText(results[index].name)
            button.resultType:SetText(results[index].item.type)
            button.path:SetText(results[index].item.path or "test")
            button.link = results[index].item.link;
            button.tooltip = results[index].item.tooltip;
            button.scrollTo = results[index].item.scrollTo;

            button:SetID(index)
            button:Show();
        else
            button:Hide();
        end
    end

    local totalHeight = numResults * 49;
    HybridScrollFrame_Update(scrollFrame, totalHeight, 370);
end

BtWQuestsSearchResultMixin = {}
function BtWQuestsSearchResultMixin:GetResultsFrame() -- Gets the preview or full results frame
end
function BtWQuestsSearchResultMixin:GetViewFrame() -- Normally would get BtWQuestsFrame
end
function BtWQuestsSearchResultMixin:OnEnter()
    local viewFrame = self:GetViewFrame()
    if self.tooltip or self.link then
        BtWQuestsTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT")
        BtWQuestsTooltip:SetOwner(self, "ANCHOR_PRESERVE");
        BtWQuestsTooltip:SetHyperlink(self.tooltip or self.link, viewFrame:GetCharacter())
    end
end
function BtWQuestsSearchResultMixin:OnLeave()
    BtWQuestsTooltip:Hide();
end
function BtWQuestsSearchResultMixin:OnClick()
    local viewFrame = self:GetViewFrame()
    if viewFrame:SelectFromLink(self.link, self.scrollTo) then
        BtWQuestsTooltip:Hide();
    end
    self:GetResultsFrame():Hide()
    PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
end

BtWQuestsSearchResultPreviewMixin = {}
function BtWQuestsSearchResultPreviewMixin:GetResultsFrame() -- Gets the preview or full results frame
    return self:GetParent()
end
function BtWQuestsSearchResultPreviewMixin:GetViewFrame() -- Normally would get BtWQuestsFrame
    return self:GetParent():GetParent()
end
function BtWQuestsSearchResultPreviewMixin:OnEnter()
    BtWQuestsSearchResultMixin.OnEnter(self)
    self:GetParent():SetSelection(self:GetID())
end

BtWQuestsSearchResultFullMixin = {}
function BtWQuestsSearchResultFullMixin:GetResultsFrame() -- Gets the preview or full results frame
    return self:GetParent():GetParent():GetParent()
end
function BtWQuestsSearchResultFullMixin:GetViewFrame() -- Normally would get BtWQuestsFrame
    return self:GetParent():GetParent():GetParent():GetParent()
end