
local WIDGET, VERSION = 'ItemButton', 3

local GUI = LibStub('NetEaseGUI-2.0')
local Class = LibStub('LibClass-2.0')
local ItemButton = GUI:NewClass(WIDGET, 'CheckButton', VERSION, 'Owner')
if not ItemButton then
    return
end

function ItemButton:Constructor(parent, highlightWithoutChecked)
    self.highlightWithoutChecked = highlightWithoutChecked

    self:SetMotionScriptsWhileDisabled(true)
    self:SetFrameLevel(parent:GetFrameLevel() + 1)

    self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

    self:SetScript('OnClick', self.OnClick)
    self:SetScript('OnEnter', self.OnEnter)
    self:SetScript('OnLeave', self.OnLeave)
    self:SetScript('OnDoubleClick', self.OnDoubleClick)
end

function ItemButton:FireHandler(name, ...)
    local parent = self:GetOwner()
    if parent then
        parent:Fire(name, self, parent:GetItem(self:GetID()), ...)
    end
end

function ItemButton:OnClick(button)
    PlaySound('igMainMenuOptionCheckBoxOn')
    if not self:GetOwner() then
        return
    end

    self:SetChecked(not self:GetChecked())

    if button == 'LeftButton' then
        if not IsModifierKeyDown() then
            if self:GetID() == 0 then
                if type(self:GetOwner().ToggleMenu) == 'function' then
                    self:GetOwner():ToggleMenu(self)
                end
            elseif not self.noSelectable then
                self:GetOwner():SetSelected(self:GetID())
            end
        end
        self:FireHandler('OnItemClick')

        if self.highlightWithoutChecked then
            self:UnlockHighlight()
            if self:GetHighlightTexture() then
                self:GetHighlightTexture():Hide()
            end
        end
    elseif button == 'RightButton' then
        self:FireHandler('OnItemMenu')
    end
end

function ItemButton:OnDoubleClick(button)
    if button == 'LeftButton' then
        self:FireHandler('OnItemDoubleClick')
    end
end

function ItemButton:OnEnter()
    if self.highlightWithoutChecked and self:GetChecked() then
        self:UnlockHighlight()
    else
        if self:GetHighlightTexture() then
            self:GetHighlightTexture():Show()
        end
    end
    self.isEntered = true
    self:FireHandler('OnItemEnter')
end

function ItemButton:OnLeave()
    self.isEntered = nil
    self:FireHandler('OnItemLeave')
end

function ItemButton:SetStatus()
end

function ItemButton:GetAutoWidth()
    return self:GetWidth()
end

function ItemButton:FireFormat()
    self:FireHandler('OnItemFormatted')

    if self.isEntered then
        self:FireHandler('OnItemEnter')
    end
end

function ItemButton:SetSelectable(flag)
    self.noSelectable = not flag or nil
end

function ItemButton:Group(...)
    self:FireHandler('OnItemGrouped', ...)
end