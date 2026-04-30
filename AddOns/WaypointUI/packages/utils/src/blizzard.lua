local env = select(2, ...)
local Utils_Blizzard = env.modules:New("packages\\utils\\blizzard")

local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetContainerItemID = C_Container.GetContainerItemID
local GetContainerItemLink = C_Container.GetContainerItemLink
local GetItemInfo = C_Item.GetItemInfo
local ColorPickerFrame = ColorPickerFrame
local StaticPopup_Show = StaticPopup_Show
local StaticPopup_Hide = StaticPopup_Hide
local assert = assert
local lower = string.lower
local band = bit.band
local GetServerTime = GetServerTime
local date = date


do -- Bags
    function Utils_Blizzard.FindItemInInventory(itemName)
        if not itemName then return nil, nil end

        local targetName = lower(itemName)

        for bagIndex = 0, 4 do
            for slotIndex = 1, GetContainerNumSlots(bagIndex) do
                local itemID = GetContainerItemID(bagIndex, slotIndex)
                local itemLink = GetContainerItemLink(bagIndex, slotIndex)

                if itemLink then
                    local bagItemName = GetItemInfo(itemLink)
                    if bagItemName and lower(bagItemName) == targetName then
                        return itemID, itemLink
                    end
                end
            end
        end

        return nil
    end
end

do -- Color Picker
    function Utils_Blizzard.ShowColorPicker(initialColor, callback, opacityCallback, confirmCallback, cancelCallback)
        ColorPickerFrame:SetupColorPickerAndShow(initialColor)
        ColorPickerFrame.opacity = initialColor.a
        ColorPickerFrame.func = callback
        ColorPickerFrame.opacityFunc = opacityCallback
        ColorPickerFrame.swatchFunc = confirmCallback
        ColorPickerFrame.cancelFunc = cancelCallback
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end

    function Utils_Blizzard.HideColorPicker()
        ColorPickerFrame:Hide()
    end
end

do -- Popups
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
end

do -- GUID
    local SPAWN_TIME_MASK = 0x7FFFFF
    local SPAWN_TIME_MOD = 0x800000

    local function ParseGUID(guid)
        if not guid then return end
        local typeStr, typeID, serverID, instanceID, zoneUID, unitID, spawnUID = strsplit("-", guid)
        return typeStr, typeID, serverID, instanceID, zoneUID, unitID, spawnUID
    end

    local function ResolveSpawnEpoch(spawnSeconds)
        if not spawnSeconds then return end
        local now = GetServerTime()
        if not now then return spawnSeconds end

        local base = now - (now % SPAWN_TIME_MOD) + spawnSeconds

        if base > (now + SPAWN_TIME_MOD / 2) then
            base = base - SPAWN_TIME_MOD
        elseif base < (now - SPAWN_TIME_MOD / 2) then
            base = base + SPAWN_TIME_MOD
        end

        return base
    end

    local function GetSpawnTimeFromSpawnUID(spawnUID)
        if not spawnUID then return end
        local numericSpawn = tonumber(spawnUID, 16) or tonumber(spawnUID)
        if not numericSpawn then return end
        return band(numericSpawn, SPAWN_TIME_MASK)
    end

    function Utils_Blizzard.ParseUnitGUID(guid)
        local typeStr, typeID, serverID, instanceID, zoneUID, unitID, spawnUID = ParseGUID(guid)
        return typeStr, typeID, serverID, instanceID, zoneUID, unitID, spawnUID
    end

    function Utils_Blizzard.ParseGameObjectGUID(guid)
        local typeStr, typeID, serverID, instanceID, zoneUID, gameObjectID, spawnUID = ParseGUID(guid)
        if typeStr ~= "GameObject" then return end
        return typeStr, typeID, serverID, instanceID, zoneUID, gameObjectID, spawnUID
    end

    function Utils_Blizzard.ParseVignetteGUID(guid)
        local typeStr, typeID, serverID, instanceID, zoneUID, vignetteID, spawnUID = ParseGUID(guid)
        if typeStr ~= "Vignette" then return end
        return typeStr, typeID, serverID, instanceID, zoneUID, vignetteID, spawnUID
    end

    function Utils_Blizzard.ParsePlayerGUID(guid)
        if not guid then return end
        local typeStr, serverID, playerUID = strsplit("-", guid)
        if typeStr ~= "Player" then return end
        return typeStr, serverID, playerUID
    end

    function Utils_Blizzard.ParseItemGUID(guid)
        if not guid then return end
        local typeStr, serverID, itemUID = strsplit("-", guid)
        if typeStr ~= "Item" then return end
        return typeStr, serverID, itemUID
    end

    function Utils_Blizzard.ParseCorpseGUID(guid)
        local typeStr, typeID, serverID, instanceID, zoneUID, corpseID, spawnUID = ParseGUID(guid)
        if typeStr ~= "Corpse" then return end
        return typeStr, typeID, serverID, instanceID, zoneUID, corpseID, spawnUID
    end

    function Utils_Blizzard.GetSpawnTimeFromGUID(guid)
        local _, _, _, _, _, _, spawnUID = ParseGUID(guid)
        if not spawnUID then return end
        return GetSpawnTimeFromSpawnUID(spawnUID)
    end

    function Utils_Blizzard.GetSpawnTimeFromGUID_Epoch(guid)
        local spawnSeconds = Utils_Blizzard.GetSpawnTimeFromGUID(guid)
        if not spawnSeconds then return end
        return ResolveSpawnEpoch(spawnSeconds)
    end
    
    function Utils_Blizzard.GetSpawnTimeFromGUID_String(guid, formatString)
        local epoch = Utils_Blizzard.GetSpawnEpochFromGUID(guid)
        if not epoch then return end
        return date(formatString or "%Y-%m-%d %H:%M:%S", epoch)
    end
end
