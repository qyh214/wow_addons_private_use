local env                  = select(2, ...)

local assert               = assert
local ipairs               = ipairs
local string_lower         = string.lower

local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetContainerItemID   = C_Container.GetContainerItemID
local GetContainerItemLink = C_Container.GetContainerItemLink
local GetItemInfo          = C_Item.GetItemInfo
local FindAuraByName       = AuraUtil.FindAuraByName
local ColorPickerFrame     = ColorPickerFrame
local StaticPopup_Show     = StaticPopup_Show
local StaticPopup_Hide     = StaticPopup_Hide

local Utils_Blizzard       = env.WPM:New("wpm_modules/utils/blizzard")


-- Shared
--------------------------------

local SHAPESHIFT_AURAS = {
    "Cat Form",
    "Bear Form",
    "Travel Form",
    "Moonkin Form",
    "Aquatic Form",
    "Treant Form",
    "Mount Form"
}


-- Bags
--------------------------------

function Utils_Blizzard.FindItemInInventory(itemName)
    if not itemName then return nil, nil end

    local targetName = string_lower(itemName)

    for bagIndex = 0, 4 do
        for slotIndex = 1, GetContainerNumSlots(bagIndex) do
            local itemID = GetContainerItemID(bagIndex, slotIndex)
            local itemLink = GetContainerItemLink(bagIndex, slotIndex)

            if itemLink then
                local bagItemName = GetItemInfo(itemLink)
                if bagItemName and string_lower(bagItemName) == targetName then
                    return itemID, itemLink
                end
            end
        end
    end

    return nil
end


-- Auras
--------------------------------

function Utils_Blizzard.IsPlayerInShapeshiftForm()
    for _, auraName in ipairs(SHAPESHIFT_AURAS) do
        if FindAuraByName(auraName, "Player") then
            return true
        end
    end
    return false
end


-- Color Picker
--------------------------------

function Utils_Blizzard.ShowColorPicker(initialColor, callback, opacityCallback, confirmCallback, cancelCallback)
    ColorPickerFrame:SetupColorPickerAndShow(initialColor)
    ColorPickerFrame.opacity     = initialColor.a
    ColorPickerFrame.func        = callback
    ColorPickerFrame.opacityFunc = opacityCallback
    ColorPickerFrame.swatchFunc  = confirmCallback
    ColorPickerFrame.cancelFunc  = cancelCallback
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

function Utils_Blizzard.HideColorPicker()
    ColorPickerFrame:Hide()
end


-- Popups
--------------------------------

function Utils_Blizzard.NewConfirmPopup(popupInfo)
    assert(popupInfo, "Invalid variable `popupInfo`")
    assert(
        popupInfo.id and popupInfo.text and popupInfo.button1Text and popupInfo.button2Text
        and popupInfo.acceptCallback and popupInfo.cancelCallback and popupInfo.hideOnEscape,
        "Invalid variable `popupInfo`: Missing required fields"
    )

    StaticPopupDialogs[popupInfo.id] = {
        text           = popupInfo.text,
        button1        = popupInfo.button1Text,
        button2        = popupInfo.button2Text,
        OnAccept       = popupInfo.acceptCallback,
        OnCancel       = popupInfo.cancelCallback,
        hideOnEscape   = popupInfo.hideOnEscape,
        timeout        = popupInfo.timeout or 0,
        preferredIndex = 3
    }
end

function Utils_Blizzard.ShowPopup(popupId, ...)
    StaticPopup_Show(popupId, ...)
end

function Utils_Blizzard.HidePopup(popupId)
    StaticPopup_Hide(popupId)
end
