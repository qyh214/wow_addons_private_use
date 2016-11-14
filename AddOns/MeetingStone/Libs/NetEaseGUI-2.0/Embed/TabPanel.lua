
local GUI = LibStub('NetEaseGUI-2.0')
local View = GUI:NewEmbed('TabPanel', 2)
if not View then
    return
end

View._PanelList = View._PanelList or setmetatable({}, {__index = function(t, k)
    t[k] = {}
    return t[k]
end})

local _PanelList = View._PanelList

function View:EnableTabFrame(flag)
    self.noTab = not flag or nil
    if self.TabFrame then
        self.TabFrame:Hide()
    end
end

function View:GetPanelList()
    return _PanelList[self]
end

function View:UpdateTab()
    if not self.noTab then
        if self.selectTab then
            self:GetTabFrame():SetSelected(self.selectTab)
            self.selectTab = nil
        end
        self:GetTabFrame():Refresh()
    else
        local data = _PanelList[self][1]
        if data then
            data.panel:Show()

            if self.Inset2 then
                self.Inset:SetShown(not data.noInset)
                self.Inset2:SetShown(data.noInset)
            elseif self.Inset then
                self.Inset:Show()
            end
        end
    end
end

function View:RegisterPanel(name, panel, padding, topHeight, bottomHeight, noInset)
    if self.noTab then
        if #_PanelList[self] > 0 then
            error([[Can register only one panel into notab container.]], 2)
        end
    end
    if self:IsPanelRegistered(name) then
        error([[Cannot register panel (same name)]], 2)
    end
    if panel.InjectPanelArgs then
        padding, topHeight, bottomHeight, noInset = panel:InjectPanelArgs()
    end

    GUI:Embed(panel, 'Owner')

    local data = {
        name = name,
        panel = panel,
        topHeight = topHeight or self.GetTopHeight and self:GetTopHeight() or 0,
        bottomHeight = bottomHeight or self.GetBottomHeight and self:GetBottomHeight() or 0,
        noInset = noInset,
    }
    tinsert(_PanelList[self], data)

    padding = padding or 10
    panel:Hide()
    panel:SetOwner(self)
    panel:SetParent(noInset and self.Inset2 or self.Inset)
    panel:ClearAllPoints()
    panel:SetPoint('TOPLEFT', padding, -padding)
    panel:SetPoint('BOTTOMRIGHT', -padding, padding)
    panel:SetFrameLevel(self.Inset:GetFrameLevel()+1)

    if self.PortraitFrame then
        self.PortraitFrame:SetFrameLevel(max(panel:GetFrameLevel()+1, self.PortraitFrame:GetFrameLevel()))
    end

    return data
end

function View:UnregisterPanel(name)
    local i, v = self:IsPanelRegistered(name)
    if i then
        tremove(_PanelList[self], i)

        v.panel:Hide()
        v.panel:ClearAllPoints()
        v.panel:SetParent(nil)
    end
end

function View:IsPanelRegistered(name)
    for i, v in ipairs(_PanelList[self]) do
        if v.name == name then
            return i, v
        end
    end
end

function View:UnregisterAllPanels()
    for i, v in ipairs(_PanelList[self]) do
        v.panel:Hide()
        v.panel:ClearAllPoints()
        v.panel:SetParent(nil)
    end
    wipe(_PanelList[self])
end

function View:EnableTab(index)
    local tabframe = self:GetTabFrame()
    if tabframe then
        tabframe:EnableTab(index)
    end
end

function View:DisableTab(index)
    local tabframe = self:GetTabFrame()
    if tabframe then
        tabframe:DisableTab(index)
    end
end

function View:SetTabEnabled(index, flag)
    local tabframe = self:GetTabFrame()
    if tabframe then
        tabframe:SetTabEnabled(index, flag)
    end
end

function View:SelectTab(index)
    self.selectTab = index
    local tabframe = self:GetTabFrame()
    if tabframe then
        tabframe:SetSelected(index)
    end
end

function View:SetTabText(index, text)
    local tabframe = self:GetTabFrame()
    if not tabframe then
        return
    end
    if _PanelList[self] and _PanelList[self][index] then
        _PanelList[self][index].name = text
    end
    tabframe:Refresh()
end

function View:GetPanelIndex(panel)
    for i, v in ipairs(_PanelList[self]) do
        if v.panel == panel then
            return i
        end
    end
end

function View:SelectPanel(panel)
    local index = self:GetPanelIndex(panel)
    if index then
        self:SelectTab(index)
    end
end

function View:EnablePanel(panel)
    local index = self:GetPanelIndex(panel)
    if index then
        self:EnableTab(index)
    end
end

function View:DisablePanel(panel)
    local index = self:GetPanelIndex(panel)
    if index then
        self:DisableTab(index)
    end
end

function View:SetPanelEnabled(panel, flag)
    local index = self:GetPanelIndex(panel)
    if index then
        self:SetTabEnabled(index, flag)
    end
end

function View:SetPanelText(panel, text)
    local index = self:GetPanelIndex(panel)
    if index then
        self:SetTabText(index, text)
    end
end

function View:GetSelectedTab()
    local tabframe = self:GetTabFrame()
    if tabframe then
        return tabframe:GetSelected()
    end
end

function View:GetSelectedPanel()
    local index = self:GetSelectedTab()
    return _PanelList[self][index] and _PanelList[self][index].panel
end

function View:GetPanelByIndex(index)
    return _PanelList[self][index] and _PanelList[self][index].panel
end
