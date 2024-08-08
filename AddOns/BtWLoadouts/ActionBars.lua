--[[
]]

local ADDON_NAME,Internal = ...
local L = Internal.L

local UnitClass = UnitClass
local GetActionInfo = GetActionInfo
local GetMacroBody = GetMacroBody
local trim = strtrim
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo and function (spell)
	local tbl = C_Spell.GetSpellInfo(spell);
	if not tbl then
		return nil
	end
	return tbl.name, nil, tbl.iconID, tbl.castTime, tbl.minRange, tbl.maxRange, tbl.spellID, tbl.originalIconID
end or GetSpellInfo

local HelpTipBox_Anchor = Internal.HelpTipBox_Anchor;
local HelpTipBox_SetText = Internal.HelpTipBox_SetText;

local function push(tbl, ...)
    local n = select('#', ...)
    for i=1,n do
        tbl[i] = select(i, ...)
    end
    tbl.n = n
end
local function compare(a, b)
    if a.n ~= b.n then
        return false
    end

    local n = a.n
    for i=1,n do
        if a[i] ~= b[i] then
            return false
        end
    end

    return true
end

local function CompareSets(a, b)
    if not tCompare(a.actions, b.actions, 10) then
        return false
    end
    if not tCompare(a.ignored, b.ignored, 10) then
        return false
    end
    if type(a.restrictions) ~= type(b.restrictions) and not tCompare(a.restrictions, b.restrictions, 10) then
        return false
    end

    return true
end
-- Unlike others, imported sets lack ignored values so need a slightly different comparison function
local function CompareImportSets(set, import)
    for slot = 1,181 do
        if set.ignored[slot] ~= import.ignored[slot] then
            return false
        end

        if not set.ignored[slot] and (type(set.actions[slot]) ~= type(import.actions[slot]) or (set.actions[slot] ~= import.actions[slot] and not tCompare(set.actions[slot], import.actions[slot], 10))) then
            return false
        end
    end

    return true
end

-- Track changes to macros
if false then
    local mapCreated = false
    local macros = setmetatable({}, {
        __index = function (self, key)
            local result = {}
            self[key] = result
            return result
        end
    })
    local macroNameMap = setmetatable({}, {
        __index = function (self, name)
            for index,macro in ipairs(macros) do
                if macro.name == name then
                    self[macro.name] = index
                    return index
                end
            end
        end
    }) -- Maps names to macro index
    local macroBodyMap = setmetatable({}, {
        __index = function (self, body)
            for index,macro in ipairs(macros) do
                if macro.body == body then
                    self[macro.body] = index
                    return index
                end
            end
        end
    }) -- Maps body to macro index

    local function BuildMacroMap()
        mapCreated = true
        if MacroFrame and MacroFrame:IsShown() then
            MacroFrame:Update()
        end

        local global, character = GetNumMacros()
        local macro

        wipe(macroNameMap)
        wipe(macroBodyMap)

        for i=1,global do
            macro = macros[i]

            macro.index, macro.name, macro.icon, macro.body = i, GetMacroInfo(i)
            macro.body = macro.body and trim(macro.body) -- Remove empty lines from start and end

            macroNameMap[macro.name] = i
            macroBodyMap[macro.body] = i
        end
        for i=global+1,MAX_ACCOUNT_MACROS do
            wipe(macros[i])
        end
        for i=MAX_ACCOUNT_MACROS+1,MAX_ACCOUNT_MACROS+character do
            macro = macros[i]

            macro.index, macro.name, macro.icon, macro.body = i, GetMacroInfo(i)
            macro.body = macro.body and trim(macro.body) -- Remove empty lines from start and end

            macroNameMap[macro.name] = i
            macroBodyMap[macro.body] = i
        end
        for i=MAX_ACCOUNT_MACROS+character+1,MAX_ACCOUNT_MACROS+MAX_CHARACTER_MACROS do
            wipe(macros[i])
        end
    end

    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", BuildMacroMap)
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:Hide()

    hooksecurefunc("CreateMacro", BuildMacroMap)
    hooksecurefunc("DeleteMacro", BuildMacroMap)
    
    local function EditMacroHook(id, name, icon, body)
        if type(id) == "string" then
            id = macroNameMap[id]
        end

        -- Probably means someone is using EditMacro to make a new macro or
        -- editing a macro very early in the load
        if id == nil or id == 0 or not mapCreated then
            return BuildMacroMap()
        end

        body = body and trim(body) -- Remove empty lines from start and end

        local macro = macros[id]
        local changed = (name ~= nil and name ~= macro.name) or (body ~= nil and body ~= macro.body)

        if changed then -- Update action bar sets with the new macro
            for _,set in pairs(BtWLoadoutsSets.actionbars) do
                if type(set) == "table" then
                    for _,action in pairs(set.actions) do
                        if action.type == "macro" then
                            if trim(action.macroText) == macro.body and action.name == macro.name then
                                action.macroText = body or macro.body
                                action.name = name or macro.name
                            end
                        end
                    end
                end
            end
        end

        -- Update our macro index
        if name == nil then
            macro.icon = icon or macro.icon
            if body ~= nil then -- Only the body has changed so macros wont have reordered
                if macro.body then
                    macroBodyMap[macro.body] = nil -- Setting to nil will cause the index metamethod to run if needed later
                end
                macro.body = body
                macroBodyMap[body] = id
            end
        else
            local min, max = id, GetMacroIndexByName(name)
            if min > max then
                min, max = max, min
            end

            -- Rebuild our macro index
            for i=min,max do
                macro = macros[i]

                if GetMacroInfo(i) then
                    macro.index, macro.name, macro.icon, macro.body = i, GetMacroInfo(i)
                    macro.body = macro.body and trim(macro.body)

                    if macro.name then
                        macroNameMap[macro.name] = i
                    end
                    if macro.body then
                        macroBodyMap[macro.body] = i
                    end
                else
                    wipe(macro)
                end
            end
        end
    end
    hooksecurefunc("EditMacro", EditMacroHook)
end

local function UpdateSetFilters(set)
	set.filters = set.filters or {}

    Internal.UpdateRestrictionFilters(set)

    return set
end

local covenantClassAbilities = {
    [313347] = false, -- Zone ability base spell

    -- Death Knight
    [312202] = true, -- shackle-the-unworthy
    [311648] = true, -- swarming-mist
    [315443] = true, -- abomination-limb
    [315442] = true, -- deaths-due

    -- Demon Hunter
    [306830] = true, -- elysian-decree
    [317009] = true, -- sinful-brand
    [329554] = true, -- fodder-to-the-flame
    [323639] = true, -- the-hunt

    -- Druid
    [326434] = true, -- kindred-spirits
    [323546] = true, -- ravenous-frenzy
    [325727] = true, -- adaptive-swarm
    [323764] = true, -- convoke-the-spirits

    -- Hunter
    [308491] = true, -- resonating-arrow
    [324149] = true, -- flayed-shot
    [325028] = true, -- death-chakram
    [328231] = true, -- wild-spirits

    -- Mage
    [307443] = true, -- radiant-spark
    [314793] = true, -- mirrors-of-torment
    [324220] = true, -- deathborne
    [314791] = true, -- shifting-power

    -- Monk
    [310454] = true, -- weapons-of-order
    [326860] = true, -- fallen-order
    [325216] = true, -- bonedust-brew
    [327104] = true, -- faeline-stomp

    -- Paladin
    [304971] = true, -- divine-toll
    [316958] = true, -- ashen-hallow
    [328204] = true, -- vanquishers-hammer
    [328278] = true, -- blessing-of-the-seasons

    -- Priest
    [325013] = true, -- boon-of-the-ascended
    [323673] = true, -- mindgames
    [324724] = true, -- unholy-nova
    [327661] = true, -- fae-blessings

    -- Rogue
    [323547] = true, -- echoing-reprimand
    [323654] = true, -- slaughter
    [328547] = true, -- Serrated-Bone-Spike
    [328305] = true, -- sepsis

    -- Shaman
    [324386] = true, -- vesper-totem
    [320674] = true, -- chain-harvest
    [326059] = true, -- primordial-wave
    [328923] = true, -- fae-transfusion

    -- Warlock
    [312321] = true, -- scouring-tithe
    [321792] = true, -- impending-catastrophe
    [325289] = true, -- decimating-bolt
    [325640] = true, -- soul-rot

    -- Warrior
    [307865] = true, -- spear-of-bastion
    [317349] = true, -- condemn
    [324143] = true, -- conquerors-banner
    [325886] = true, -- ancient-aftershock
}
local function IsCovenantClassAbility(id)
    return covenantClassAbilities[id] ~= nil
end
local function GetCovenantClassAbility()
    for id,valid in pairs(covenantClassAbilities) do
        if valid and IsSpellKnown(id, false) then
            return id
        end
    end

    return IsSpellKnown(313347, false) and 313347 -- Zone ability base spell
end
local covenantSignatureAbilities = {
    [326526] = false, -- Zone ability base spell, not valid to test with IsSpellKnown as its known at level 60

    [324739] = true, -- Summon Steward
    [300728] = true, -- Door of Shadows
    [324631] = true, -- Fleshcraft
    [310143] = true, -- Soulshape
}
local function IsCovenantSignatureAbility(id)
    return covenantSignatureAbilities[id] ~= nil
end
local function GetCovenantSignatureAbility()
    for id,valid in pairs(covenantSignatureAbilities) do
        if valid and IsSpellKnown(id, false) then
            return id
        end
    end

    return IsSpellKnown(326526, false) and 326526 -- Zone ability base spell
end
local function GetActionInfoTable(slot, tbl)
    local actionType, id, subType = GetActionInfo(slot)
    if not actionType and not tbl then -- If no action and tbl is missing just return
        return
    end

    tbl = tbl or {}

    -- If we use the base version of the spell it should always work
    if actionType == "spell" then
        id = FindBaseSpellByID(id) or id

        if IsCovenantSignatureAbility(id) then
            id = GetCovenantSignatureAbility() or id
        elseif IsCovenantClassAbility(id) then
            id = GetCovenantClassAbility() or id
        end
    elseif actionType == "macro" then
        PickupAction(slot)

        local cursorType, cursorId = GetCursorInfo()
        if cursorType == "macro" then
            id = cursorId
        else
            actionType = nil
            id = nil
        end

        PlaceAction(slot)
    end

    -- There are some situations where actions can be "empty" but showing as macros with id 0
    if actionType == "macro" and id == 0 then
        actionType = nil
        id = nil
    end

    tbl.type, tbl.id, tbl.subType, tbl.macroText = actionType, id, subType, nil
    tbl.icon = GetActionTexture(slot)
    tbl.name = GetActionText(slot)

    if actionType == "macro" then
        tbl.macroText = trim(GetMacroBody(id))
    end

    return tbl
end
local function GetMacroByText(text)
    if text == nil then
        return
    end

    text = trim(text)

    local global, character = GetNumMacros()
    for i=1,global do
        if trim(GetMacroBody(i)) == text then
            return i
        end
    end
    for i=MAX_ACCOUNT_MACROS+1,MAX_ACCOUNT_MACROS+character do
        if trim(GetMacroBody(i)) == text then
            return i
        end
    end
end
local function CompareSlot(slot, tbl, settings)
    local actionType, id, subType = GetActionInfo(slot)
    if actionType == "spell" then
        id = FindBaseSpellByID(id) or id

        if settings and settings.adjustCovenant then
            if IsCovenantSignatureAbility(id) then
                id = GetCovenantSignatureAbility() or id
            elseif IsCovenantClassAbility(id) then
                id = GetCovenantClassAbility() or id
            end
        end
    end

    if tbl == nil then
        return actionType == nil
    elseif actionType == "macro" and tbl.type == "macro" then
        return true -- GetActionInfo currently doesnt return the id for macros
        -- local macroText = trim(GetMacroBody(id) or "")
        -- -- Macro in the action slot has the same text as the macro we want
        -- if macroText == trim(tbl.macroText) then
        --     return true
        -- end

        -- -- There is a macro with the text we want and its not the one in the action slot
        -- if GetMacroByText(tbl.macroText) ~= nil then
        --     return false
        -- end

        -- return id == GetMacroIndexByName(tbl.name)
    elseif actionType == "companion" and subType == "MOUNT" and tbl.type == "summonmount" then
        return id == select(2, C_MountJournal.GetDisplayedMountInfo(tbl.id))
    elseif tbl.type == "companion" and tbl.subType == "MOUNT" and actionType == "summonmount" then
        return tbl.id == select(2, C_MountJournal.GetDisplayedMountInfo(id))
    else
        return tbl.type == actionType and tbl.id == id and tbl.subType == subType
    end
end
Internal.GetMacroByText = GetMacroByText
local function PickupMacroByText(text)
    local index = GetMacroByText(text)
    if index then
        PickupMacro(index)
        return true
    end
    return false
end

-- Pickup an action, when test is true the action wont actually be picked up
local function PickupActionTable(tbl, test, settings, activating)
    if tbl == nil or tbl.type == nil then
        return true, "Success"
    end

    local success, msg = true, "Success"
    local noError, err = pcall(function ()
        if tbl.type == "macro" then
            local index = GetMacroByText(tbl.macroText)
            if not index or index == 0 then
                if settings and settings.createMissingMacros then
                    msg = L["Could not find macro by text, creating as account macro"]
                    local numMacros = GetNumMacros()
                    if activating and numMacros < MAX_ACCOUNT_MACROS then
                        index = CreateMacro(tbl.name or "BtWLoadouts Missing Macro", "INV_Misc_QuestionMark", tbl.macroText)
                    else
                        index = -1
                    end
                elseif settings and settings.createMissingMacrosCharacter then
                    msg = L["Could not find macro by text, creating as character macro"]
                    local _, numMacros = GetNumMacros()
                    if activating and numMacros < MAX_CHARACTER_MACROS  then
                        index = CreateMacro(tbl.name or "BtWLoadouts Missing Macro", "INV_Misc_QuestionMark", tbl.macroText, true)
                    else
                        index = -1
                    end
                elseif tbl.name then
                    msg = L["Could not find macro by text"]
                    index = GetMacroIndexByName(tbl.name)
                end
            end

            if not index or index == 0 then
                msg = L["Could not find macro by text or name"]
                success = false
            elseif not test then
                PickupMacro(index)
            end
        elseif tbl.type == "spell" then
            -- If we use the base version of the spell it should always work
            tbl.id = FindBaseSpellByID(tbl.id) or tbl.id

            if settings and settings.adjustCovenant then
                if IsCovenantSignatureAbility(tbl.id) then
                    tbl.id = GetCovenantSignatureAbility() or tbl.id
                elseif IsCovenantClassAbility(tbl.id) then
                    tbl.id = GetCovenantClassAbility() or tbl.id
                end
            end

            local index
            success = false
            if tbl.subType == "spell" then
                if C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo then
                    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.MainSpec);
                    for spellIndex = 1,skillLineInfo.itemIndexOffset + skillLineInfo.numSpellBookItems do
                        local spellBookItem = C_SpellBook.GetSpellBookItemInfo(spellIndex, Enum.SpellBookSpellBank.Player);
                        if spellBookItem.itemType == Enum.SpellBookItemType.Spell and spellBookItem.spellID == tbl.id then
                            index = spellIndex
                            break
                        end
                    end
                else
                    for tabIndex = 1,min(2,GetNumSpellTabs()) do
                        local offset, numEntries = select(3, GetSpellTabInfo(tabIndex))
                        for spellIndex = offset,offset+numEntries do
                            local skillType, id = GetSpellBookItemInfo(spellIndex, "spell")
                            if skillType == "SPELL" and id == tbl.id then
                                index = spellIndex
                                break
                            end
                        end
                    end
                end
            else
                local spellIndex = 1
                local skillType, id = GetSpellBookItemInfo(spellIndex, tbl.subType)
                while skillType do
                    if (skillType == "SPELL" or (skillType == "PETACTION" and tbl.subType == "pet")) and id == tbl.id then
                        index = spellIndex
                        break
                    end

                    spellIndex = spellIndex + 1
                    skillType, id = GetSpellBookItemInfo(spellIndex, tbl.subType)
                end
            end
            if index then
                success = true
                if not test then
                    if C_SpellBook and C_SpellBook.PickupSpellBookItem then
                        C_SpellBook.PickupSpellBookItem(index, Enum.SpellBookSpellBank.Player)
                    else
                        PickupSpellBookItem(index, tbl.subType)
                    end
                end
            end

            if not success then
                -- In cases where we need a pvp talent but they arent active
                -- we have to pickup the talent, not the spell
                local pvptalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
                for _,talentId in ipairs(pvptalents) do
                    if select(6, GetPvpTalentInfoByID(talentId)) == tbl.id then
                        success = true
                        if not test then
                            PickupPvpTalent(talentId)
                        end
                    end
                end
            end

            if not success then
                if tbl.subType == "pet" then
                    if IsSpellKnown(tbl.id, true) then
                        success = true
                        if not test then
                            PickupPetSpell(tbl.id)
                        end
                    end
                elseif tbl.subType == "spell" then
                    if IsSpellKnown(tbl.id, false) or IsPlayerSpell(tbl.id) then
                        success = true
                        if not test then
                            if C_Spell and C_Spell.PickupSpell then
                                C_Spell.PickupSpell(tbl.id)
                            else
                                PickupSpell(tbl.id)
                            end
                        end
                    end
                end
            end

            if not success then
                msg = L["Spell not found"]
            end
        elseif tbl.type == "item" then
            local itemEquipLoc = select(4, GetItemInfoInstant(tbl.id))
            -- Allowed items on bars: toys, equipment that there is at least 1 of in bags/equipped, or usable items
            if C_ToyBox.GetToyInfo(tbl.id) or (itemEquipLoc ~= "" and GetItemCount(tbl.id) > 0) or (itemEquipLoc == "" and IsUsableItem(tbl.id)) then
                if not test then
                    PickupItem(tbl.id)
                end
            else
                success, msg = false, L["Item unavailable"]
            end
        elseif tbl.type == "summonmount" then
            if tbl.id == 0xFFFFFFF then -- Random Favourite
                if not test then
                    C_MountJournal.Pickup(0)
                end
            else
                if not select(11, C_MountJournal.GetMountInfoByID(tbl.id)) then
                    success = false
                    msg = L["Mount is not available"]
                elseif not test then
                    -- We will attempt to pickup the mount using the latest way, if that
                    -- fails because of filtering we will pickup the spell instead
                    local index = nil
                    for i=1,C_MountJournal.GetNumDisplayedMounts() do
                        if select(12,C_MountJournal.GetDisplayedMountInfo(i)) == tbl.id then
                            index = i
                            break
                        end
                    end
                    if index then
                        C_MountJournal.Pickup(index)
                    else
                        PickupSpell((select(2, C_MountJournal.GetMountInfoByID(tbl.id))))
                    end
                end
            end
        elseif tbl.type == "summonpet" then
            if not C_PetJournal.GetPetInfoByPetID(tbl.id) then
                success = false
                msg = L["Pet is not available"]
            elseif not test then
                C_PetJournal.PickupPet(tbl.id)
            end
        elseif tbl.type == "companion" then -- This is the old way of handling mounts and pets
            if not test and tbl.subType == "MOUNT" then
                PickupSpell(tbl.id)
            end
        elseif tbl.type == "equipmentset" then
            local id = C_EquipmentSet.GetEquipmentSetID(tbl.id)
            if not id then
                success = false
                msg = L["Equipment set is not available"]
            elseif not test then
                C_EquipmentSet.PickupEquipmentSet(id)
            end
        elseif tbl.type == "flyout" then
            if not GetFlyoutInfo(tbl.id) then
                success = false
                msg = L["Flyout is not available"]
            else
                local index
                -- Find the spell book index for the flyout
                if C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo then
                    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(Enum.SpellBookSkillLineIndex.MainSpec);
                    for spellIndex = 1,skillLineInfo.itemIndexOffset + skillLineInfo.numSpellBookItems do
                        local spellBookItem = C_SpellBook.GetSpellBookItemInfo(spellIndex, Enum.SpellBookSpellBank.Player);
                        if spellBookItem.itemType == Enum.SpellBookItemType.Flyout and spellBookItem.actionID == tbl.id then
                            index = spellIndex
                            break
                        end
                    end
                else
                    for tabIndex = 1,min(2,GetNumSpellTabs()) do
                        local offset, numEntries = select(3, GetSpellTabInfo(tabIndex))
                        for spellIndex = offset,offset+numEntries do
                            local skillType, id = GetSpellBookItemInfo(spellIndex, "spell")
                            if skillType == "FLYOUT" and id == tbl.id then
                                index = spellIndex
                                break
                            end
                        end
                    end
                end
                if not index then -- Couldn't find the flyout in the spell book
                    success = false
                    msg = L["Flyout is not in spell book"]
                elseif not test then
                    if C_SpellBook and C_SpellBook.PickupSpellBookItem then
                        C_SpellBook.PickupSpellBookItem(index, Enum.SpellBookSpellBank.Player)
                    else
                        PickupSpellBookItem(index, "spell")
                    end
                end
            end
        end
    end)
    if not noError then
        success = false
        msg = L["Error: "] .. err
    end

    return success, msg
end

local ActionCacheA, ActionCacheB = {}, {}
local function SetActon(slot, tbl)
    local success, done, msg = true, true, "Success"

    ClearCursor()
    success, msg = PickupActionTable(tbl)

    if success then
        if tbl == nil or tbl.type == nil then
            PickupAction(slot)
            ClearCursor()
        else
            if GetCursorInfo() then
                push(ActionCacheA, GetCursorInfo())

                PlaceAction(slot)

                push(ActionCacheB, GetCursorInfo())

                if compare(ActionCacheA, ActionCacheB) then -- Compare the cursor now to before we placed the action, if they are the same it failed
                    msg = "Failed to place action"
                    success, done = false, false
                end
            else
                msg = "Failed to pickup action"
                success, done = false, false
            end
        end
    end

    if tbl == nil or tbl.type == nil then
        Internal.LogMessage("Emptying action bar slot %d (%s, %s)", slot, success and "true" or "false", msg)
    elseif tbl.type == "macro" then
        Internal.LogMessage("Switching action bar slot %d to %s:%s:%s (%s, %s)", slot, tbl.type, tbl.id, tbl.macroText:gsub("\n", "\\ "), success and "true" or "false", msg)
    else
        Internal.LogMessage("Switching action bar slot %d to %s:%s (%s, %s)", slot, tbl.type, tbl.id, success and "true" or "false", msg)
    end

    ClearCursor()
    return success, done
end

local function IsActionBarSetActive(set)
    for slot=1,181 do
        if not set.ignored[slot] then
            local action = set.actions[slot]
            local available = PickupActionTable(action, true, set.settings)

            if available and not CompareSlot(slot, action, set.settings) then
                return false
            end
        end
    end

    return true;
end
local function ActivateActionBarSet(set, state)
    local complete = true
    for slot=1,181 do
        if not set.ignored[slot] then
            local action = set.actions[slot]

            if not CompareSlot(slot, action, set.settings) or GetActionInfo(slot) == "macro" then
                local success, done = SetActon(slot, action)
                if not done then
                    complete = false
                end
            end
        end
    end
    return complete, not complete
end
local function RefreshActionBarSet(set)
    local actions = set.actions or {}

    for slot = 1,181 do
        actions[slot] = GetActionInfoTable(slot)
    end

    set.actions = actions

    UpdateSetFilters(set)
                
    Internal.Call("ActionBarSetUpdated", set.setID);

    return set
end
local function AddActionBarSet()
    local classFile = select(2, UnitClass("player"))
    local name = format(L["New Set"]);

    local actions, ignored = {}, {}
    for slot = 1,181 do
        actions[slot] = GetActionInfoTable(slot)
    end

    local ignoredStart = 73
    if classFile == "ROGUE" then
        ignoredStart = 85 -- After Stealth Bar
    elseif classFile == "DRUID" then
        ignoredStart = 121 -- After Form Bars
    end
    for slot = ignoredStart,144 do
        ignored[slot] = true
    end

    local set = Internal.AddSet(BtWLoadoutsSets.actionbars, UpdateSetFilters({
        name = name,
        ignored = ignored,
        actions = actions,
    }))
    Internal.Call("ActionBarSetCreated", set.setID);
    return set
end
local function GetActionBarSet(id)
    local set = Internal.GetSet(BtWLoadoutsSets.actionbars, id)
    return set
end
local function GetActionBarSetByName(id)
    return Internal.GetSetByName(BtWLoadoutsSets.actionbars, id)
end
local function GetActionBarSets(id, ...)
	if id ~= nil then
		return GetActionBarSet(id), GetActionBarSets(...);
	end
end
-- Do not change the results action tables, that'll mess with the original sets
local function CombineActionBarSets(result, state, ...)
    result = result or {};
    result.actions = result.actions or {}
    result.ignored = result.ignored or {}

    wipe(result.actions)
    for slot=1,181 do
        result.ignored[slot] = true
    end

	for i=1,select('#', ...) do
		local set = select(i, ...);
        if Internal.AreRestrictionsValidForPlayer(set.restrictions) then
            for slot=1,181 do
                if not set.ignored[slot] then
                    result.ignored[slot] = false
                    if PickupActionTable(set.actions[slot], true, set.settings, state ~= nil) or result.actions[slot] == nil then
                        result.actions[slot] = set.actions[slot]
                    end
                end
            end
        end
    end
    
    if state and state.blockers and not IsActionBarSetActive(result) then
        state.blockers[Internal.GetCombatBlocker()] = true
    end

	return result;
end
local function DeleteActionBarSet(id)
	Internal.DeleteSet(BtWLoadoutsSets.actionbars, id);

	if type(id) == "table" then
		id = id.setID;
	end
	for _,set in pairs(BtWLoadoutsSets.profiles) do
        if type(set) == "table" then
            for index,setID in ipairs(set.actionbars) do
                if setID == id then
                    table.remove(set.actionbars, index)
                end
            end
        end
	end
    
	Internal.Call("ActionBarSetDeleted", id);

	local frame = BtWLoadoutsFrame.ActionBars;
	local set = frame.set;
	if set.setID == id then
		frame.set = nil
		BtWLoadoutsFrame:Update()
	end
end
local function CheckErrors(errorState, set)
    set = GetActionBarSet(set)

	if not Internal.AreRestrictionsValidFor(set.restrictions, errorState.specID) then
        return L["Incompatible Restrictions"]
	end
end

Internal.PickupActionTable = PickupActionTable
Internal.IsActionBarSetActive = IsActionBarSetActive
Internal.ActivateActionBarSet = ActivateActionBarSet
Internal.AddActionBarSet = AddActionBarSet
Internal.RefreshActionBarSet = RefreshActionBarSet
Internal.GetActionBarSet = GetActionBarSet
Internal.GetActionBarSetByName = GetActionBarSetByName
Internal.GetActionBarSets = GetActionBarSets
Internal.CombineActionBarSets = CombineActionBarSets
Internal.DeleteActionBarSet = DeleteActionBarSet

-- Initializes the set dropdown menu for the Loadouts page
local function SetDropDownInit(self, set, index)
    Internal.SetDropDownInit(self, set, index, "actionbars", BtWLoadoutsFrame.ActionBars)
end

Internal.AddLoadoutSegment({
    id = "actionbars",
    name = L["Action Bars"],
    after = "talents,pvptalents,essences,soulbinds,equipment",
    events = "ACTIONBAR_SLOT_CHANGED",
    add = AddActionBarSet,
    get = GetActionBarSets,
    getByName = GetActionBarSetByName,
    combine = CombineActionBarSets,
    isActive = IsActionBarSetActive,
    activate = ActivateActionBarSet,
    dropdowninit = SetDropDownInit,
	checkerrors = CheckErrors,

    export = function (set)
        local result = {
            version = 1,
            name = set.name,
            actions = CopyTable(set.actions),
            ignored = set.ignored,
            restrictions = set.restrictions,
        }
        for index,ignored in pairs(result.ignored) do
            if ignored then
                result.actions[index] = nil
            end
        end
        return result
    end,
    import = function (source, version, name, ...)
        assert(version == 1)

        return Internal.AddSet("actionbars", UpdateSetFilters({
			name = name or source.name,
			useCount = 0,
			actions = source.actions,
			ignored = source.ignored,
            restrictions = source.restrictions,
        }))
    end,
    getByValue = function (set)
        return Internal.GetSetByValue(BtWLoadoutsSets.actionbars, set, CompareImportSets)
    end,
    verify = function (source, ...)
        if type(source.actions) ~= "table" then
            return false, L["Missing actions"]
        end
        if type(source.ignored) ~= "table" then
            return false, L["Missing ignored"]
        end
        if source.restrictions ~= nil and type(source.restrictions) ~= "table" then
            return false, L["Missing restrictions"]
        end

        -- @TODO verify table values?

        return true
    end,
})

BtWLoadoutsActionButtonMixin = {}
function BtWLoadoutsActionButtonMixin:GetActionBarFrame()
	return self:GetParent():GetParent():GetParent()
end
function BtWLoadoutsActionButtonMixin:OnClick(...)
	local cursorType = GetCursorInfo()
	if cursorType then
		self:SetActionToCursor(GetCursorInfo())
    elseif IsModifiedClick("CTRL") then
        local set = self:GetActionBarFrame().set;
        local slot = self:GetID();
        local tbl = set.actions[slot];
        if tbl.type == "macro" then
			local index = Internal.GetMacroByText(tbl.macroText)
            if not index then
                CreateMacro(tbl.name, "INV_Misc_QuestionMark", tbl.macroText, IsModifiedClick("SHIFT"));
            end
        end
        BtWLoadoutsFrame:Update()
	elseif IsModifiedClick("SHIFT") then
		local set = self:GetActionBarFrame().set;
		self:SetIgnored(not set.ignored[self:GetID()]);
	else
		self:SetAction(nil);
	end
end
function BtWLoadoutsActionButtonMixin:OnReceiveDrag()
	local cursorType = GetCursorInfo()
	if self:GetActionBarFrame().set and cursorType then
		self:SetActionToCursor(GetCursorInfo())
	end
end
function BtWLoadoutsActionButtonMixin:SetActionToCursor(...)
	local cursorType = ...
	if cursorType then
		if cursorType == "battlepet" then
			local id = select(2, ...)
			self:SetAction("summonpet", id)
		elseif cursorType == "mount" then
			local id = select(2, ...)
			self:SetAction("summonmount", id)
		elseif cursorType == "petaction" then
			local id = select(2, ...)
			self:SetAction("spell", id, "pet")
		elseif cursorType == "spell" then
			local subType, id = select(3, ...)
			id = FindBaseSpellByID(id) or id

            if IsCovenantSignatureAbility(id) then
                id = GetCovenantSignatureAbility() or id
            elseif IsCovenantClassAbility(id) then
                id = GetCovenantClassAbility() or id
            end

            self:SetAction("spell", id, subType)
		elseif cursorType == "equipmentset" then
			local id = select(2, ...)
			local icon, name
			do
				local id = C_EquipmentSet.GetEquipmentSetID(id)
				name, icon = C_EquipmentSet.GetEquipmentSetInfo(id)
			end
			self:SetAction("equipmentset", id, nil, icon, name)
		elseif cursorType == "macro" then
			local id = select(2, ...)
			local macroText = trim(GetMacroBody(id))
			local name, icon = GetMacroInfo(id)
			self:SetAction("macro", id, nil, icon, name, macroText)
		elseif cursorType == "flyout" then
			local id, icon = select(2, ...)
			self:SetAction("flyout", id, nil, icon)
		elseif cursorType == "item" then
			self:SetAction(cursorType, (select(2, ...)))
		-- else -- Anything else isnt supported
		end
		ClearCursor()
	end
end
function BtWLoadoutsActionButtonMixin:SetAction(actionType, ...)
	local set = self:GetActionBarFrame().set;
	if actionType == nil then -- Clearing slot
		set.actions[self:GetID()] = nil;
        
        Internal.Call("ActionBarSetUpdated", set.setID);

		self:Update();
		return true;
	else
		local tbl = set.actions[self:GetID()] or {}

		tbl.type, tbl.id, tbl.subType, tbl.icon, tbl.name, tbl.macroText = actionType, ...

		set.actions[self:GetID()] = tbl;
        
        Internal.Call("ActionBarSetUpdated", set.setID);
		self:Update()
	end
end
function BtWLoadoutsActionButtonMixin:SetIgnored(ignored)
	local set = self:GetActionBarFrame().set;
	set.ignored[self:GetID()] = ignored and true or nil;
    Internal.Call("ActionBarSetUpdated", set.setID);
	self:Update();
end
function BtWLoadoutsActionButtonMixin:Update()
	local set = self:GetActionBarFrame().set;
	local slot = self:GetID();
	local errors = nil
	local ignored = set and set.ignored[slot];
	local tbl = set and set.actions[slot];
	if tbl and tbl.type ~= nil then
        if not ignored then
            local success, msg = Internal.PickupActionTable(tbl, true, set.settings)
            if not success then
                errors = msg
            end
        end

        local icon, name = tbl.icon, tbl.name
        if tbl.type == "item" then
			icon = select(5, GetItemInfoInstant(tbl.id))
		elseif tbl.type == "spell" then
			icon = select(3, GetSpellInfo(tbl.id))
		elseif tbl.type == "summonmount" then
			if tbl.id == 0xFFFFFFF then
				icon = 413588
			else
				icon = select(3, C_MountJournal.GetMountInfoByID(tbl.id))
			end
		elseif tbl.type == "summonpet" then
			icon = select(9, C_PetJournal.GetPetInfoByPetID(tbl.id))
		elseif tbl.type == "macro" then
			local index = Internal.GetMacroByText(tbl.macroText)
			if index then
				name, icon = GetMacroInfo(index)
            elseif not ignored then
				errors = L["Macro missing\n|rCtrl+Left Click to create macro\nCtrl+Shift+Left Click to create character macro"]
			end
		elseif tbl.type == "equipmentset" then
			local id = C_EquipmentSet.GetEquipmentSetID(tbl.id)
			if id then
				name, icon = C_EquipmentSet.GetEquipmentSetInfo(id)
            elseif not ignored then
				errors = L["Equipment set missing"]
			end
		else
			-- print(tbl.type, tbl.id)
		end

		if not icon then
			icon = 134400
		end
		
		self.Name:SetText(name)
		self.Icon:SetTexture(icon)
        self.Icon:SetDesaturated(ignored)
        self.Icon:SetAlpha(ignored and 0.8 or 1)
	else
		self.Name:SetText(nil)
		self.Icon:SetTexture(nil)
    end

	self.errors = errors -- For tooltip display
	self.ErrorBorder:SetShown(errors ~= nil)
	self.ErrorOverlay:SetShown(errors ~= nil)
	self.ignoreTexture:SetShown(ignored);
end
function BtWLoadoutsActionButtonMixin:OnEnter()
	local set = self:GetActionBarFrame().set;
    local tbl = set and set.actions[self:GetID()]

    if tbl and tbl.type == "macro" then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddDoubleLine(tbl.name or L["Macro"], string.format(L["Slot %d"], self:GetID()), 1, 1, 1, 1, 1, 1)
        for line in string.gmatch(tbl.macroText, "([^\r\n]*)\r?\n?") do
            if #line > 40 then
                local first = true
                local section = "";
                for item,separator in string.gmatch(line, "([^%s;%]]*)(%]?;?%s?)") do
                    section = section .. item .. separator;
                    if #section > 40 then
                        GameTooltip:AddLine((first and "" or "    ") .. section)
                        first = false
                        section = ""
                    end
                end
                if section ~= "" then
                    GameTooltip:AddLine("    " .. section)
                end
            else
                GameTooltip:AddLine(line)
            end
        end
        if self.errors then
            GameTooltip:AddLine(format("\n|cffff0000%s|r", self.errors))
        end
        GameTooltip:Show()
    else
        if self.errors then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(string.format(L["Slot %d"], self:GetID()))
            GameTooltip:AddLine(format("\n|cffff0000%s|r", self.errors))
            GameTooltip:Show()
        end
    end
end
function BtWLoadoutsActionButtonMixin:OnLeave()
	GameTooltip:Hide();
end

BtWLoadoutsIgnoreActionBarMixin = {}
function BtWLoadoutsIgnoreActionBarMixin:GetActionBarFrame()
	return self:GetParent():GetParent():GetParent()
end
function BtWLoadoutsIgnoreActionBarMixin:OnClick()
	local set = self:GetActionBarFrame().set;
	local setIgnored = true
	for id=self.startID,self.endID do
		if set.ignored[id] then
			setIgnored = false
			break
		end
	end
	for id=self.startID,self.endID do
		set.ignored[id] = setIgnored
		self:GetParent().Slots[id]:Update()
	end
        
    Internal.Call("ActionBarSetUpdated", set.setID);
end

local function DropDown_Initialize(self, level, menuList)
    local set = BtWLoadoutsFrame.ActionBars.set
    if set then
		if (level or 1) == 1 then
            local info = UIDropDownMenu_CreateInfo()
            info.isNotRadio = true
			info.keepShownOnClick = true

            info.func = function (self, arg1, arg2, checked)
                set.settings = set.settings or {}
                set.settings.adjustCovenant = checked
                
		        Internal.Call("ActionBarSetUpdated", set.setID);

                BtWLoadoutsFrame:Update()
            end
            info.checked = set.settings and set.settings.adjustCovenant
            info.text = L["Adjust Covenant Abilities"]
            UIDropDownMenu_AddButton(info, level)

            info.isNotRadio = false
            info.func = function (self, arg1, arg2, checked)
                set.settings = set.settings or {}
                set.settings.createMissingMacros = checked
                set.settings.createMissingMacrosCharacter = false
                
		        Internal.Call("ActionBarSetUpdated", set.setID);

                BtWLoadoutsFrame:Update()
            end
            info.checked = set.settings and set.settings.createMissingMacros
            info.text = L["Create Missing Macros"]
            UIDropDownMenu_AddButton(info, level)

            info.func = function (self, arg1, arg2, checked)
                set.settings = set.settings or {}
                set.settings.createMissingMacrosCharacter = checked
                set.settings.createMissingMacros = false
                
		        Internal.Call("ActionBarSetUpdated", set.setID);

                BtWLoadoutsFrame:Update()
            end
            info.checked = set.settings and set.settings.createMissingMacrosCharacter
            info.text = L["Create Missing Macros (Character Only)"]
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator()

            info.isTitle, info.notCheckable, info.checked, info.func = true, true, false, nil
            info.text = L["Restrictions"]
            UIDropDownMenu_AddButton(info, level)
        end

        self.OrigInitFunc(self, level, menuList)
    end
end
BtWLoadoutsActionBarsMixin = {}
function BtWLoadoutsActionBarsMixin:OnLoad()
    self.SettingsDropDown:SetSupportedTypes("covenant", "spec", "race")
    self.SettingsDropDown:SetScript("OnChange", function ()
        Internal.Call("ActionBarSetUpdated", self.set.setID);

        self:Update()
    end)
end
function BtWLoadoutsActionBarsMixin:OnShow()
    if not self.initialized then
        self.SettingsDropDown.OrigInitFunc = self.SettingsDropDown.initialize
        UIDropDownMenu_Initialize(self.SettingsDropDown, DropDown_Initialize, "MENU");
        self.initialized = true
    end
end
function BtWLoadoutsActionBarsMixin:UpdateSetName(value)
	if self.set and self.set.name ~= not value then
		self.set.name = value;
        Internal.Call("ActionBarSetUpdated", self.set.setID);
		self:Update();
	end
end
function BtWLoadoutsActionBarsMixin:ChangeSet(set)
    self.set = set
    self:Update()
end
function BtWLoadoutsActionBarsMixin:OnButtonClick(button)
	CloseDropDownMenus()
	if button.isAdd then
        self.Name:ClearFocus();
		self:ChangeSet(AddActionBarSet())
        C_Timer.After(0, function ()
            self.Name:HighlightText();
            self.Name:SetFocus();
        end);
    elseif button.isDelete then
        local set = self.set;
        if set.useCount > 0 then
            StaticPopup_Show("BTWLOADOUTS_DELETEINUSESET", set.name, nil, {
                set = set,
                func = DeleteActionBarSet,
            });
        else
            StaticPopup_Show("BTWLOADOUTS_DELETESET", set.name, nil, {
                set = set,
                func = DeleteActionBarSet,
            });
        end
    elseif button.isRefresh then
        local set = self.set;
        RefreshActionBarSet(set)
        self:Update()
	elseif button.isExport then
		local set = self.set;
		self:GetParent():SetExport(Internal.Export("actionbars", set.setID))
    elseif button.isActivate then
        Internal.ActivateProfile({
            actionbars = {self.set.setID}
        });
	end
end
function BtWLoadoutsActionBarsMixin:OnSidebarItemClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		button.collapsed[button.id] = not button.collapsed[button.id]
		self:Update()
	else
		if IsModifiedClick("SHIFT") then
			Internal.ActivateProfile({
				actionbars = {button.id}
			});
		else
			self.Name:ClearFocus();
            self:ChangeSet(GetActionBarSet(button.id))
		end
	end
end
function BtWLoadoutsActionBarsMixin:OnSidebarItemDoubleClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		return
	end

	Internal.ActivateProfile({
		actionbars = {button.id}
	});
end
function BtWLoadoutsActionBarsMixin:OnSidebarItemDragStart(button)
	CloseDropDownMenus()
	if button.isHeader then
		return
	end

	local icon = "INV_Misc_QuestionMark";
	local set = GetActionBarSet(button.id);
	local command = format("/btwloadouts activate actionbars %d", button.id);

	if command then
		local macroId;
		local numMacros = GetNumMacros();
		for i=1,numMacros do
			if GetMacroBody(i):trim() == command then
				macroId = i;
				break;
			end
		end

		if not macroId then
			if numMacros == MAX_ACCOUNT_MACROS then
				print(L["Cannot create any more macros"]);
				return;
			end
			if InCombatLockdown() then
				print(L["Cannot create macros while in combat"]);
				return;
			end

			macroId = CreateMacro(set.name, icon, command, false);
		else
			-- Rename the macro while not in combat
			if not InCombatLockdown() then
				icon = select(2,GetMacroInfo(macroId))
				EditMacro(macroId, set.name, icon, command)
			end
		end

		if macroId then
			PickupMacro(macroId);
		end
	end
end
function BtWLoadoutsActionBarsMixin:Update()
	self:GetParent():SetTitle(L["Action Bars"]);
	local sidebar = BtWLoadoutsFrame.Sidebar

	sidebar:SetSupportedFilters("covenant", "spec", "class", "role", "race")
	sidebar:SetSets(BtWLoadoutsSets.actionbars)
	sidebar:SetCollapsed(BtWLoadoutsCollapsed.actionbars)
	sidebar:SetCategories(BtWLoadoutsCategories.actionbars)
	sidebar:SetFilters(BtWLoadoutsFilters.actionbars)
	sidebar:SetSelected(self.set)

	sidebar:Update()
	self.set = sidebar:GetSelected()
	local set = self.set
	
	local showingNPE = BtWLoadoutsFrame:SetNPEShown(set == nil, L["Action Bars"], L["Create different action bar layouts, including stealth, form, and stance bars. You can ignore specific action buttons or entire bars."])
        
	self:GetParent().ExportButton:SetEnabled(true);
    self:GetParent().ActivateButton:SetEnabled(true);
    self:GetParent().DeleteButton:SetEnabled(true);

	if not showingNPE then
		local slots = set.actions;

		UpdateSetFilters(set)
		sidebar:Update()

        set.restrictions = set.restrictions or {}
        self.SettingsDropDown:SetSelections(set.restrictions)
        self.SettingsDropDown:SetLimitations()

		if not self.Name:HasFocus() then
			self.Name:SetText(set.name or "");
		end

        for slot,item in pairs(self.Scroll:GetScrollChild().Slots) do
            item:SetID(slot)
            item:Update();

            local icon = item.Icon:GetTexture()
            if icon ~= nil and icon ~= 134400 then
                slots[slot].icon = icon
            end
        end

        self:GetParent().RefreshButton:SetEnabled(Internal.AreRestrictionsValidForPlayer(set.restrictions));

		local helpTipBox = self:GetParent().HelpTipBox;
        if not BtWLoadoutsHelpTipFlags["ACTIONBAR_IGNORE"] then
            helpTipBox.closeFlag = "ACTIONBAR_IGNORE";

            HelpTipBox_Anchor(helpTipBox, "RIGHT", self.Bar1Slot1);

            helpTipBox:Show();
            HelpTipBox_SetText(helpTipBox, L["Shift+Left Mouse Button to ignore a slot."]);
        else
            helpTipBox.closeFlag = nil;
            helpTipBox:Hide();
        end
	else
		self.Name:SetText(L["New Set"]);

        for slot,item in pairs(self.Scroll:GetScrollChild().Slots) do
            item:SetID(slot)
            item:Update();
		end

        local helpTipBox = self:GetParent().HelpTipBox;
        helpTipBox:Hide();
	end
end
function BtWLoadoutsActionBarsMixin:SetSetByID(setID)
	self.set = GetActionBarSet(setID)
end
