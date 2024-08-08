local ADDON_NAME,Internal = ...
local L = Internal.L
local Settings = Internal.Settings

local UnitClass = UnitClass;
local GetClassColor = C_ClassColor.GetClassColor;
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE;

local MAX_TALENT_TIERS = MAX_TALENT_TIERS;
local LearnTalent = LearnTalent;
local GetTalentInfo = GetTalentInfo;
local GetTalentTierInfo = GetTalentTierInfo;
local GetTalentInfoByID = GetTalentInfoByID
local GetTalentInfoForSpecID = Internal.GetTalentInfoForSpecID;

local GetSpecialization = GetSpecialization;
local GetSpecializationInfo = GetSpecializationInfo;
local GetSpecializationInfoByID = GetSpecializationInfoByID;

local UIDropDownMenu_SetText = UIDropDownMenu_SetText;
local UIDropDownMenu_EnableDropDown = UIDropDownMenu_EnableDropDown;
local UIDropDownMenu_DisableDropDown = UIDropDownMenu_DisableDropDown;
local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue;

local format = string.format

local AddSet = Internal.AddSet;
local DeleteSet = Internal.DeleteSet;

local HelpTipBox_Anchor = Internal.HelpTipBox_Anchor;
local HelpTipBox_SetText = Internal.HelpTipBox_SetText;

do -- Filter chat spam
    local filters = {
        string.gsub(ERR_LEARN_ABILITY_S, "%%s", "(.*)"),
        string.gsub(ERR_LEARN_SPELL_S, "%%s", "(.*)"),
        string.gsub(ERR_LEARN_PASSIVE_S, "%%s", "(.*)"),
        string.gsub(ERR_SPELL_UNLEARNED_S, "%%s", "(.*)"),
    }
    local function ChatFrame_FilterTalentChanges(self, event, msg, ...)
        if Settings.filterChatSpam then
            for _,pattern in ipairs(filters) do
                if string.match(msg, pattern) then
                    return true
                end
            end
        end

        return false, msg, ...
    end

    Internal.OnEvent("LoadoutActivateStart", function ()
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", ChatFrame_FilterTalentChanges)
    end)
    Internal.OnEvent("LoadoutActivateEnd", function ()
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", ChatFrame_FilterTalentChanges)
    end)
end

do -- Prevent new spells from flying to the action bar
    local WasEventRegistered
    Internal.OnEvent("LoadoutActivateStart", function ()
        WasEventRegistered = IconIntroTracker:IsEventRegistered("SPELL_PUSHED_TO_ACTIONBAR")
        IconIntroTracker:UnregisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
    end)
    Internal.OnEvent("LoadoutActivateEnd", function ()
        if WasEventRegistered then
            IconIntroTracker:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
        end
    end)
end

-- Make sure talent sets dont have incorrect id, call from GetTalentSet and the UI?
local function FixTalentSet(set)
    local temp = {}
    local changed = false
    for talentID in pairs(set.talents) do
        local tier, column = Internal.VerifyTalentForSpec(set.specID, talentID)
        if tier == nil or temp[tier] then
            set.talents[talentID] = nil
            changed = true
        else
            temp[tier] = talentID
        end
    end
    return changed
end
local function UpdateSetFilters(set)
	set.filters = set.filters or {}

    local specID = set.specID;
    local filters = set.filters

    Internal.UpdateRestrictionFilters(set)

    filters.spec = specID
    if specID then
        filters.role, filters.class = select(5, GetSpecializationInfoByID(specID))
    else
        filters.role, filters.class = nil, nil
    end

    -- Rebuild character list
    filters.character = filters.character or {}
    local characters = filters.character
    table.wipe(characters)
    local class = filters.class
    for _,character in Internal.CharacterIterator() do
        if class == Internal.GetCharacterInfo(character).class then
            characters[#characters+1] = character
        end
    end

    set.filters = filters

    return set
end
local function GetTalentSet(id)
    if type(id) == "table" then
		return id;
	else
		return BtWLoadoutsSets.talents[id];
	end;
end
-- In General, For Player, For Player Spec
local function TalentSetIsValid(set)
	set = GetTalentSet(set);

	local playerSpecID = GetSpecializationInfo(GetSpecialization());
	local playerClass = select(2, UnitClass("player"));
	local specClass = select(6, GetSpecializationInfoByID(set.specID));

	return true, (playerClass == specClass), (playerSpecID == set.specID)
end
-- Check if the talents in the table talentIDs are selected
local function IsTalentSetActive(set)
    for talentID in pairs(set.talents) do
        local _, _, _, selected, _, _, _, tier = GetTalentInfoByID(talentID, 1);
        local tierAvailable = GetTalentTierInfo(tier, 1)

        -- For lower level characters just ignore tiers over their currently available
        if tierAvailable and not selected then
            return false;
        end
    end

    return true;
end
--[[
    Activate a talent set
    return complete, dirty
]]
local function ActivateTalentSet(set, state)
	local success, complete = true, true;
    local canChangeTalents = not Internal.GetRestedTomeBlocker():IsActive()
    for talentID in pairs(set.talents) do
        local selected, _, _, _, tier = select(4, GetTalentInfoByID(talentID, 1));
        local available, currentColumn = GetTalentTierInfo(tier, 1)
        if not selected and available then
            if canChangeTalents or currentColumn == 0 then
                local slotSuccess = LearnTalent(talentID)
                success = slotSuccess and success
                complete = false

                Internal.LogMessage("Switching talent %d to %s (%s)", tier, GetTalentLink(talentID, 1), slotSuccess and "true" or "false")
            end
        end
    end

	return complete, false;
end
local function RefreshTalentSet(set)
    local talents = set.talents or {}
    local specID, specName = GetSpecializationInfo(GetSpecialization());
    if specID == set.specID then
        wipe(talents)
        for tier=1,MAX_TALENT_TIERS do
            local _, column = GetTalentTierInfo(tier, 1);
            local talentID = GetTalentInfo(tier, column, 1);
            if talentID then
                talents[talentID] = true;
            end
        end
    end
    set.talents = talents

    return UpdateSetFilters(set)
end
local function AddTalentSet()
    local specIndex = GetSpecialization()
    if specIndex == 5 then
        specIndex = 1
    end
    local specID, specName = GetSpecializationInfo(specIndex);
    local set = AddSet("talents", RefreshTalentSet({
        specID = specID,
        name = format(L["New %s Set"], specName),
        useCount = 0,
        talents = {},
    }))
    Internal.Call("TalentSetCreated", set.setID);
    return set
end
local function TalentSetDelay(set)
    for talentID in pairs(set.talents) do
        local row = select(8, GetTalentInfoByID(talentID, 1))
        local column = select(2, GetTalentTierInfo(row, 1))
        local selectedTalentID, _, _, _, _, spellID = GetTalentInfo(row, column, 1)
        if selectedTalentID ~= talentID and spellID then
			spellID = FindSpellOverrideByID(spellID)
			local start, duration = GetSpellCooldown(spellID)
			if start ~= 0 then -- Talent spell on cooldown, we need to wait before switching
				Internal.DirtyAfter((start + duration) - GetTime() + 1)
				return true
			end
        end
    end
    return false
end
--[[
    Check what is needed to activate this talent set
    return isActive, waitForCooldown, anySelected
]]
local function TalentSetRequirements(set)
    local isActive, waitForCooldown, anySelected = true, false, false

    for talentID in pairs(set.talents) do
        local row = select(8, GetTalentInfoByID(talentID, 1))
        local available, column = GetTalentTierInfo(row, 1)
        if available then
            local selectedTalentID, _, _, _, _, spellID = GetTalentInfo(row, column, 1)

            if selectedTalentID ~= talentID then
                isActive = false

                if spellID then
                    spellID = FindSpellOverrideByID(spellID)
                    local start, duration = GetSpellCooldown(spellID)
                    if start ~= 0 then -- Talent spell on cooldown, we need to wait before switching
                        Internal.DirtyAfter((start + duration) - GetTime() + 1)
                        waitForCooldown = true
                        break -- We dont actually need to check anything more
                    end
                end

                if column ~= 0 then
                    anySelected = true
                end
            end
        end
    end

    return isActive, waitForCooldown, anySelected
end
local function GetTalentSetsByName(name)
	return Internal.GetSetsByName("talents", name)
end
local function GetTalentSetByName(name)
	return Internal.GetSetByName("talents", name, TalentSetIsValid)
end
local function GetTalentSets(id, ...)
	if id ~= nil then
		return GetTalentSet(id), GetTalentSets(...);
	end
end
local function GetTalentSetIfNeeded(id)
	if id == nil then
		return;
	end

	local set = Internal.GetTalentSet(id);
	if IsTalentSetActive(set) then
		return;
	end

    return set;
end
local talentSetsByTier = {};
local function CombineTalentSets(result, state, ...)
	result = result or {};
	result.talents = {};

	wipe(talentSetsByTier);
	for i=1,select('#', ...) do
		local set = Internal.GetTalentSet(select(i, ...));
        if Internal.AreRestrictionsValidForPlayer(set.restrictions) then
            for talentID in pairs(set.talents) do
                if result.talents[talentID] == nil then
                    local tier = select(8, GetTalentInfoByID(talentID, 1));
                    if (GetTalentTierInfo(tier, 1)) then
                        if talentSetsByTier[tier] then
                            result.talents[talentSetsByTier[tier]] = nil;
                        end

                        result.talents[talentID] = true;
                        talentSetsByTier[tier] = talentID;
                    end
                end
            end
        end
    end

    if state then
        local isActive, waitForCooldown, anySelected = TalentSetRequirements(result)

        if not isActive then
            if state.blockers then
                state.blockers[Internal.GetRestedTomeBlocker()] = true
                state.blockers[Internal.GetCombatBlocker()] = true
                state.blockers[Internal.GetMythicPlusBlocker()] = true
                state.blockers[Internal.GetJailersChainBlocker()] = true
            end
            
            state.customWait = state.customWait or (waitForCooldown and L["Waiting for talent cooldown"])
        end
    end

	return result;
end
local function DeleteTalentSet(id)
	Internal.DeleteSet(BtWLoadoutsSets.talents, id);

	if type(id) == "table" then
		id = id.setID;
	end
	for _,set in pairs(BtWLoadoutsSets.profiles) do
        if type(set) == "table" then
            for index,setID in ipairs(set.talents) do
                if setID == id then
                    table.remove(set.talents, index)
                end
            end
		end
	end
    
	Internal.Call("TalentSetDeleted", id);

	local frame = BtWLoadoutsFrame.Talents;
	local set = frame.set;
	if set.setID == id then
		frame.set = nil;-- = select(2,next(BtWLoadoutsSets.talents)) or {};
		BtWLoadoutsFrame:Update();
	end
end
local function CheckErrors(errorState, set)
    set = GetTalentSet(set)
    errorState.specID = errorState.specID or set.specID

    if errorState.specID ~= set.specID then
        return L["Incompatible Specialization"]
    end

	if not Internal.AreRestrictionsValidFor(set.restrictions, errorState.specID) then
        return L["Incompatible Restrictions"]
	end
end

Internal.FixTalentSet = FixTalentSet
Internal.GetTalentSet = GetTalentSet
Internal.GetTalentSets = GetTalentSets
Internal.GetTalentSetIfNeeded = GetTalentSetIfNeeded
Internal.GetTalentSetsByName = GetTalentSetsByName
Internal.GetTalentSetByName = GetTalentSetByName
Internal.TalentSetDelay = TalentSetDelay
Internal.AddTalentSet = AddTalentSet
Internal.RefreshTalentSet = RefreshTalentSet
Internal.DeleteTalentSet = DeleteTalentSet
Internal.ActivateTalentSet = ActivateTalentSet
Internal.IsTalentSetActive = IsTalentSetActive
Internal.CombineTalentSets = CombineTalentSets
Internal.GetTalentSets = GetTalentSets

-- Initializes the set dropdown menu for the Loadouts page
local function SetDropDownInit(self, set, index)
    Internal.SetDropDownInit(self, set, index, "talents", BtWLoadoutsFrame.Talents)
end

local function CompareSets(a, b)
    if not tCompare(a.talents, b.talents, 10) then
        return false
    end
    if type(a.restrictions) ~= type(b.restrictions) and not tCompare(a.restrictions, b.restrictions, 10) then
        return false
    end

    return true
end

Internal.AddLoadoutSegment({
    id = "talents",
    name = L["Talents"],
    events = "PLAYER_TALENT_UPDATE",
    enabled = select(4, GetBuildInfo()) < 100000,
    add = AddTalentSet,
    get = GetTalentSets,
    getByName = GetTalentSetByName,
    combine = CombineTalentSets,
    isActive = IsTalentSetActive,
    activate = ActivateTalentSet,
    dropdowninit = SetDropDownInit,
    checkerrors = CheckErrors,

    export = function (set)
        return {
            version = 1,
            name = set.name,
            specID = set.specID,
            talents = set.talents,
            restrictions = set.restrictions,
        }
    end,
    import = function (source, version, name, ...)
        assert(version == 1)

        local specID = source.specID or ...
        return AddSet("talents", UpdateSetFilters({
			specID = specID,
			name = name or source.name,
			useCount = 0,
			talents = source.talents,
            restrictions = source.restrictions,
        }))
    end,
    getByValue = function (set)
        return Internal.GetSetByValue(BtWLoadoutsSets.talents, set, CompareSets)
    end,
    verify = function (source, ...)
        local specID = source.specID or ...
        if not specID or not GetSpecializationInfoByID(specID) then
            return false, L["Invalid specialization"]
        end
        if type(source.talents) ~= "table" then
            return false, L["Missing talents"]
        end
        if source.restrictions ~= nil and type(source.restrictions) ~= "table" then
            return false, L["Missing restrictions"]
        end

        -- @TODO verify talent ids?

        return true
    end,
})

BtWLoadoutsTalentsMixin = {}
function BtWLoadoutsTalentsMixin:OnLoad()
    self.RestrictionsDropDown:SetSupportedTypes("covenant", "race")
    self.RestrictionsDropDown:SetScript("OnChange", function ()
        self:Update()
    end)

    self.temp = {}; -- Stores talents for currently unselected specs incase the user switches to them
    self.talentIDs = {}
    for tier=1,MAX_TALENT_TIERS do
        self.talentIDs[tier] = {}
    end
end
function BtWLoadoutsTalentsMixin:OnShow()
    if not self.initialized then
		self.SpecDropDown.includeNone = false;
		self.SpecDropDown.includeClass = false;
		UIDropDownMenu_SetWidth(self.SpecDropDown, 170);
		UIDropDownMenu_JustifyText(self.SpecDropDown, "LEFT");

        self.SpecDropDown.GetValue = function ()
            if self.set then
                return self.set.specID
            end
        end
        self.SpecDropDown.SetValue = function (_, _, arg1)
            CloseDropDownMenus();

            local set = self.set;
            if set then
                local temp = self.temp;
                -- @TODO: If we always access talents by set.talents then we can just swap tables in and out of
                -- the temp table instead of copying the talentIDs around
        
                -- We are going to copy the currently selected talents for the currently selected spec into
                -- a temporary table incase the user switches specs back
                local specID = set.specID;
                if temp[specID] then
                    wipe(temp[specID]);
                else
                    temp[specID] = {};
                end
                for talentID in pairs(set.talents) do
                    temp[specID][talentID] = true;
                end
        
                -- Clear the current talents and copy back the previously selected talents if they exist
                specID = arg1;
                set.specID = specID;
                wipe(set.talents);
                if temp[specID] then
                    for talentID in pairs(temp[specID]) do
                        set.talents[talentID] = true;
                    end
                end

                self:Update()
            end
        end

        self.initialized = true;
    end
end
function BtWLoadoutsTalentsMixin:ChangeSet(set)
    self.set = set
    wipe(self.temp);
    self:Update()
end
function BtWLoadoutsTalentsMixin:UpdateSetName(value)
	if self.set and self.set.name ~= not value then
		self.set.name = value;
		self:Update();
	end
end
function BtWLoadoutsTalentsMixin:OnButtonClick(button)
	CloseDropDownMenus()
	if button.isAdd then
		BtWLoadoutsHelpTipFlags["TUTORIAL_NEW_SET"] = true;

		self.Name:ClearFocus()
        self:ChangeSet(AddTalentSet())
		C_Timer.After(0, function ()
			self.Name:HighlightText()
			self.Name:SetFocus()
		end)
	elseif button.isDelete then
		local set = self.set
		if set.useCount > 0 then
			StaticPopup_Show("BTWLOADOUTS_DELETEINUSESET", set.name, nil, {
				set = set,
				func = DeleteTalentSet,
			})
		else
			StaticPopup_Show("BTWLOADOUTS_DELETESET", set.name, nil, {
				set = set,
				func = DeleteTalentSet,
			})
		end
	elseif button.isRefresh then
        local set = self.set;
        RefreshTalentSet(set)
        self:Update()
	elseif button.isExport then
		local set = self.set;
		self:GetParent():SetExport(Internal.Export("talents", set.setID))
	elseif button.isActivate then
        local set = self.set;
        if select(6, GetSpecializationInfoByID(set.specID)) == select(2, UnitClass("player")) then
            Internal.ActivateProfile({
                talents = {set.setID}
            });
        end
	end
end
function BtWLoadoutsTalentsMixin:OnSidebarItemClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		button.collapsed[button.id] = not button.collapsed[button.id]
		self:Update()
	else
        if IsModifiedClick("SHIFT") then
            local set = GetTalentSet(button.id);
            if select(6, GetSpecializationInfoByID(set.specID)) == select(2, UnitClass("player")) then
                Internal.ActivateProfile({
                    talents = {button.id}
                });
            end
        else
            self.Name:ClearFocus();
            self:ChangeSet(GetTalentSet(button.id))
        end
	end
end
function BtWLoadoutsTalentsMixin:OnSidebarItemDoubleClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		return
	end

    local set = GetTalentSet(button.id);
    if select(6, GetSpecializationInfoByID(set.specID)) == select(2, UnitClass("player")) then
        Internal.ActivateProfile({
            talents = {button.id}
        });
    end
end
function BtWLoadoutsTalentsMixin:OnSidebarItemDragStart(button)
	CloseDropDownMenus()
	if button.isHeader then
		return
	end

	local icon = "INV_Misc_QuestionMark";
	local set = GetTalentSet(button.id);
	local command = format("/btwloadouts activate talents %d", button.id);
	if set.specID then
		icon = select(4, GetSpecializationInfoByID(set.specID));
	end

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
function BtWLoadoutsTalentsMixin:Update()
    self:GetParent():SetTitle(L["Talents"]);
	local sidebar = BtWLoadoutsFrame.Sidebar

	sidebar:SetSupportedFilters("spec", "class", "role", "character", "covenant", "race")
	sidebar:SetSets(BtWLoadoutsSets.talents)
	sidebar:SetCollapsed(BtWLoadoutsCollapsed.talents)
	sidebar:SetCategories(BtWLoadoutsCategories.talents)
	sidebar:SetFilters(BtWLoadoutsFilters.talents)
	sidebar:SetSelected(self.set)

	sidebar:Update()
	self.set = sidebar:GetSelected()
	local set = self.set
	
	local showingNPE = BtWLoadoutsFrame:SetNPEShown(set == nil, L["Talents"], L["Create different talent layouts for the type of content you wish to do. Leave rows blank to skip the tier."])
        
	self:GetParent().ExportButton:SetEnabled(true)
    self:GetParent().DeleteButton:SetEnabled(true);

    if not showingNPE then
        local specID = set.specID

		UpdateSetFilters(set)
        sidebar:Update()
        
        set.restrictions = set.restrictions or {}
        self.RestrictionsDropDown:SetSelections(set.restrictions)
        self.RestrictionsDropDown:SetLimitations()
		self.RestrictionsButton:SetEnabled(true);

        local selected = set.talents;

        if not self.Name:HasFocus() then
            self.Name:SetText(set.name or "");
        end

        local _, specName, _, icon, _, classID = GetSpecializationInfoByID(specID);
        local className = LOCALIZED_CLASS_NAMES_MALE[classID];
        local classColor = GetClassColor(classID);
        UIDropDownMenu_SetText(self.SpecDropDown, format("%s: %s", classColor:WrapTextInColorCode(className), specName));

        for tier=1,MAX_TALENT_TIERS do
            local row = self.talentIDs[tier]
            wipe(row)
            for column=1,3 do
                row[column] = GetTalentInfoForSpecID(specID, tier, column)
            end

            self.rows[tier]:SetTalents(row);
        end

        local playerSpecIndex = GetSpecialization()
        self:GetParent().RefreshButton:SetEnabled(playerSpecIndex and specID == GetSpecializationInfo(playerSpecIndex))
        self:GetParent().ActivateButton:SetEnabled(classID == select(2, UnitClass("player")));

        local helpTipBox = self:GetParent().HelpTipBox;
        helpTipBox:Hide();
        
	    BtWLoadoutsHelpTipFlags["TUTORIAL_CREATE_TALENT_SET"] = true;
    else
        local specIndex = GetSpecialization()
        if not specIndex or specIndex == 5 then
            specIndex = 1
        end

        local specID, specName = GetSpecializationInfo(specIndex);

        self.Name:SetText(format(L["New %s Set"], specName));
        
        local _, specName, _, icon, _, classID = GetSpecializationInfoByID(specID);
        local className = LOCALIZED_CLASS_NAMES_MALE[classID];
        local classColor = GetClassColor(classID);
        UIDropDownMenu_SetText(self.SpecDropDown, format("%s: %s", classColor:WrapTextInColorCode(className), specName));

        for tier=1,MAX_TALENT_TIERS do
            local row = self.talentIDs[tier]
            wipe(row)
            for column=1,3 do
                row[column] = GetTalentInfoForSpecID(specID, tier, column)
            end

            self.rows[tier]:SetTalents(row);
        end

        local helpTipBox = self:GetParent().HelpTipBox;
        helpTipBox:Hide();
    end
end
function BtWLoadoutsTalentsMixin:SetSetByID(setID)
	self.set = GetTalentSet(setID)
end
