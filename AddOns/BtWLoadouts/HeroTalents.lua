local ADDON_NAME,Internal = ...
local L = Internal.L

BTWLOADOUTS_HERO_TALENTS_ACTIVE = Internal.IsTheWarWithinOrBeyond

BtWLoadoutsHeroTalentTreeDropDownMixin = {}
function BtWLoadoutsHeroTalentTreeDropDownMixin:OnShow()
	if not self.initialized then
		UIDropDownMenu_Initialize(self, self.Init);
		self.initialized = true
	end
end
function BtWLoadoutsHeroTalentTreeDropDownMixin:Init(level, menuList)
	local info = UIDropDownMenu_CreateInfo();
	local selectedTraitTreeID, selectedClassID = self:GetValue();

	info.func = function (button, arg1, arg2, checked)
		self:SetValue(button, arg1, arg2, checked)
	end

	if (level or 1) == 1 then
		if self.includeNone then
			info.text = L["None"];
			info.checked = selectedTraitTreeID == nil;
			UIDropDownMenu_AddButton(info, level);
		end

		info.func = nil;
		for classIndex=1,GetNumClasses() do
			if GetNumSpecializationsForClassID(classIndex) > 0 then
				local className, classFile = GetClassInfo(classIndex);
				local classColor = C_ClassColor.GetClassColor(classFile);
				info.text = classColor and classColor:WrapTextInColorCode(className) or className;
				info.hasArrow, info.menuList = true, classIndex;
				info.keepShownOnClick = true;
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	else
		local classID = menuList;

		for _,treeID in ipairs(Internal.GetHeroTalentTreeIDsByClassID(classID)) do
            local tree = C_Traits.GetSubTreeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, treeID)
			info.text = tree.name;
			info.icon = tree.iconElementID;
			info.arg1 = treeID;
			info.arg2 = classID;
			info.checked = selectedTraitTreeID == treeID;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end
-- Override. return specID, classID (classID only needed if includeClass = true).
function BtWLoadoutsHeroTalentTreeDropDownMixin:GetValue()
end
-- Override.
function BtWLoadoutsHeroTalentTreeDropDownMixin:SetValue(button, specID, classID, checked)
end

local GetSpellCooldown = C_Spell and C_Spell.GetSpellCooldown and function (spellID)
    local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID);
    if spellCooldownInfo then
        return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate;
    end
end or GetSpellCooldown;

local function CompareSets(a, b)
    if a.treeID ~= b.treeID then
        return false
    end

    if not tCompare(a.nodes, b.nodes, 10) then
        return false
    end
    if type(a.restrictions) ~= type(b.restrictions) and not tCompare(a.restrictions, b.restrictions, 10) then
        return false
    end

    return true
end

local function GetSelectedHeroSubTree()
    local subTreeIDs = C_ClassTalents.GetHeroTalentSpecsForClassSpec();
    if not subTreeIDs then
        return nil
    end

    local configID = C_ClassTalents.GetActiveConfigID();
    if configID ~= nil then
        for _,id in ipairs(subTreeIDs) do
            local tree = C_Traits.GetSubTreeInfo(configID, id)
            if tree.isActive then
                return tree
            end
        end
    end
    return C_Traits.GetSubTreeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, subTreeIDs[1])
end

local function UpdateSetFilters(set)
    set.filters = set.filters or {}

    Internal.UpdateRestrictionFilters(set)

    local filters = set.filters
    filters.herotalents = set.subTreeID
    filters.spec = filters.spec or {unpack(Internal.GetSpecIDsByHeroTalentTreeID(set.subTreeID))} -- Clone the table
    
    local specID = filters.spec
    if type(specID) == "table" then
        filters.role = {}
        for _,specID in ipairs(specID) do
            filters.role[#filters.role+1], filters.class = select(5, GetSpecializationInfoByID(specID))
        end
    elseif specID then
        filters.role, filters.class = select(5, GetSpecializationInfoByID(specID))
    else
        filters.role, filters.class = nil, nil
    end

    -- Rebuild character list
    if type(filters.character) ~= "table" then
        filters.character = {}
    end
    if set.character then
        filters.character = {set.character}
    else
        filters.character = filters.character or {}
        local characters = filters.character
        table.wipe(characters)
        local class = filters.class
        for _,character in Internal.CharacterIterator() do
            if class == Internal.GetCharacterInfo(character).class then
                characters[#characters+1] = character
            end
        end
    end

    return set
end
local function RefreshSet(set)
    local nodes = set.nodes or {};
    local tree = GetSelectedHeroSubTree()
    if tree ~= nil and tree.ID == set.subTreeID then
        wipe(nodes);

        local configID = C_ClassTalents.GetActiveConfigID();
        if not configID then
            return
        end

        local configInfo = C_Traits.GetConfigInfo(configID);
        
        local nodeIDs = C_Traits.GetTreeNodes(configInfo.treeIDs[1]);
        for _,nodeID in ipairs(nodeIDs) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
            if nodeInfo.subTreeID == tree.ID then
                if #nodeInfo.entryIDs > 1 then
                    if nodeInfo.activeEntry then
                        for index,entryID in ipairs(nodeInfo.entryIDs) do
                            if entryID == nodeInfo.activeEntry.entryID then
                                nodes[nodeID] = index;
                                break;
                            end
                        end
                    end
                end
            end
        end
    end
    set.nodes = nodes;
    
	Internal.Call("HeroTalentSetUpdated", set.setID);

    return UpdateSetFilters(set)
end
local function AddSet()
    local subTree = GetSelectedHeroSubTree();
    local set = Internal.AddSet("herotalents", RefreshSet({
        subTreeID = subTree.ID,
        name = format(L["New %s Set"], subTree.name),
        nodes = {},
        useCount = 0,
    }))
    Internal.Call("HeroTalentSetCreated", set.setID);
    return set
end
local function DeleteSet(id)
    Internal.DeleteSet(BtWLoadoutsSets.herotalents, id);

    if type(id) == "table" then
        id = id.setID;
    end
    for _,set in pairs(BtWLoadoutsSets.profiles) do
        if type(set) == "table" then
            for index,setID in ipairs(set.herotalents) do
                if setID == id then
                    table.remove(set.herotalents, index)
                end
            end
        end
    end
    
	Internal.Call("HeroTalentSetDeleted", id);

    local frame = BtWLoadoutsFrame.HeroTalents;
    local set = frame.set;
    if set.setID == id then
        frame.set = nil
        BtWLoadoutsFrame:Update(true);
    end
end
local function GetSet(id)
    if type(id) == "table" then
        return id;
    else
        return BtWLoadoutsSets.herotalents[id]
    end
end
local function GetSets(id, ...)
    if id ~= nil then
        return GetSet(id), GetSets(...);
    end
end
-- In General, For Player, For Player Spec
local function SetIsValid(set)
	set = GetSet(set);

	local playerSpecID = GetSpecializationInfo(GetSpecialization());
	local playerClass = select(2, UnitClass("player"));
	local specClass = select(6, GetSpecializationInfoByID(Internal.GetSpecIDsByHeroTalentTreeID(set.subTreeID)[1]));

	return true, (playerClass == specClass), Internal.IsHeroTalentTreeValidForSpecID(set.subTreeID, playerSpecID)
end
local function GetByName(name)
    return Internal.GetSetByName(BtWLoadoutsSets.herotalents, name, SetIsValid)
end
local function GetSelectionNode(configID, subTreeID)
    local subTreeInfo = C_Traits.GetSubTreeInfo(configID, subTreeID);
    if subTreeInfo and subTreeInfo.subTreeSelectionNodeIDs then
        for _, selectionNodeID in ipairs(subTreeInfo.subTreeSelectionNodeIDs) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, selectionNodeID);
            if nodeInfo and nodeInfo.isVisible and nodeInfo.isAvailable then
                return nodeInfo;
            end
        end
    end
end
local function IsSetActive(set)
    local configID = C_ClassTalents.GetActiveConfigID();
    if not configID then -- New character without an active config?
        return true
    end

    local nodeInfo = GetSelectionNode(configID, set.subTreeID);
    if not nodeInfo then
        return true
    end

    local specID = GetSpecializationInfo(GetSpecialization());
    local _, requiredPlayerLevel = C_ClassTalents.GetHeroTalentSpecsForClassSpec(configID, specID);
    if UnitLevel("player") < requiredPlayerLevel then
        return true
    end

    for _,entryID in ipairs(nodeInfo.entryIDs) do
        local entryInfo = C_Traits.GetEntryInfo(configID, entryID);
        if entryInfo.subTreeID == set.subTreeID then
            if nodeInfo.activeEntry and nodeInfo.activeEntry.entryID ~= entryID then
                return false
            else
                break
            end
        end
    end

    for nodeID,value in pairs(set.nodes) do
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
        if not nodeInfo then -- Does this mean we cant activate this set at all?
            return false;
        end
        if not nodeInfo.isVisible then
            return false;
        end

        if #nodeInfo.entryIDs > 1 then
            if not nodeInfo.activeEntry then
                return false;
            end
            if nodeInfo.activeEntry.entryID ~= nodeInfo.entryIDs[value] then
                return false;
            end
        end
    end

    return not (C_ClassTalents.HasUnspentHeroTalentPoints());
end
local function IsNodeEntryOnCooldown(nodeEntryID)
    local configID = C_ClassTalents.GetActiveConfigID();
    if not configID then
        return false;
    end
    local entryInfo = C_Traits.GetEntryInfo(configID, nodeEntryID);
    local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID);
    
    local spellID = definitionInfo.spellID;
    if spellID then
        spellID = FindSpellOverrideByID(spellID);
        local start, duration = GetSpellCooldown(spellID);
        if start ~= 0 then -- Talent spell on cooldown, we need to wait before switching
            Internal.DirtyAfter((start + duration) - GetTime() + 1);
            return true;
        end
    end

    return false;
end
local function SetRequirements(set)
    local isActive, waitForCooldown = true, false

    local configID = C_ClassTalents.GetActiveConfigID();
    if not configID then
        return true
    end

    local specID = GetSpecializationInfo(GetSpecialization());
    local _, requiredPlayerLevel = C_ClassTalents.GetHeroTalentSpecsForClassSpec(configID, specID);
    if UnitLevel("player") < requiredPlayerLevel then
        return true
    end

    local configInfo = C_Traits.GetConfigInfo(configID);
    local nodeIDs = C_Traits.GetTreeNodes(configInfo.treeIDs[1]);

    for _,nodeID in ipairs(nodeIDs) do
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
        if nodeInfo.isVisible and nodeInfo.subTreeID == set.subTreeID then
            local value = set.nodes[nodeID];
            if #nodeInfo.entryIDs > 1 then
                if nodeInfo.activeEntry and nodeInfo.activeEntry.entryID and (not value or nodeInfo.entryIDs[value] ~= nodeInfo.activeEntry.entryID) then
                    isActive = false;
                    waitForCooldown = waitForCooldown or IsNodeEntryOnCooldown(nodeInfo.activeEntry.entryID);
                    if waitForCooldown then
                        break -- We dont actually need to check anything more
                    end
                else
                    if nodeInfo.ranksPurchased ~= 1 or not nodeInfo.activeEntry or nodeInfo.activeEntry.entryID ~= nodeInfo.entryIDs[value] then
                        isActive = false;
                    end
                end
            end
        end
    end

    return isActive, waitForCooldown
end
local function CombineSets(result, state, ...)
    result = result or {};

    local temp = {}
	for i=1,select('#', ...) do
        local set = GetSet(select(i, ...));
        temp[set.subTreeID] = temp[set.subTreeID] or {};

        for nodeID, value in pairs(set.nodes) do
            temp[set.subTreeID][nodeID] = value;
        end
    end

    local active = GetSelectedHeroSubTree()
    if active and temp[active.ID] then
        result.subTreeID = active.ID
        result.nodes = temp[active.ID]
    else
        result.subTreeID, result.nodes = next(temp)
    end

    if state then
        local isActive, waitForCooldown, anySelected = SetRequirements(result)

        if not isActive then
            if state.blockers then
                state.blockers[Internal.GetSpellCastingBlocker()] = true
                state.blockers[Internal.GetCombatBlocker()] = true
                state.blockers[Internal.GetMythicPlusBlocker()] = true
                state.blockers[Internal.GetJailersChainBlocker()] = true
            end

            state.customWait = state.customWait or (waitForCooldown and L["Waiting for talent cooldown"])
        end
    end

    return result;
end
local function ActivateSet(set, state)
    -- Let the DF talents handle hero talents
    if state.dfTalents then
        if not IsSetActive(set) then
            state.heroTalents = set
        end
        return true
    else
        local complete = true;

        local spellId = select(9, UnitCastingInfo("player"));
        if spellId == 384255 then
            complete = false;
        elseif not IsSetActive(set) and not state.dfTalentsAttempted then
            Internal.LogMessage("Activate hero talent tree");

            complete = false;
    
            local specID = GetSpecializationInfo(GetSpecialization());

            if ClassTalentFrame then
                ClassTalentFrame.TalentsTab:ClearLastSelectedConfigID();
                ClassTalentFrame.TalentsTab:MarkTreeDirty();
            end
            C_ClassTalents.UpdateLastSelectedSavedConfigID(specID, 0) -- Set active loadout to "Default Loadout"
            
            local configID = C_ClassTalents.GetActiveConfigID();
            if configID then
                local configInfo = C_Traits.GetConfigInfo(configID);
                
                local nodeInfo = GetSelectionNode(configID, set.subTreeID);
                if nodeInfo then
                    for index, entryID in ipairs(nodeInfo.entryIDs) do
                        local entryInfo = C_Traits.GetEntryInfo(configID, entryID);
                        if entryInfo.subTreeID == set.subTreeID then
                            set.nodes[nodeInfo.ID] = index

                            for _,nodeID in ipairs(C_Traits.GetTreeNodes(configInfo.treeIDs[1])) do
                                local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
                                if nodeInfo.subTreeID == set.subTreeID and #nodeInfo.entryIDs == 1 then
                                    set.nodes[nodeID] = 1
                                end
                            end

                            break;
                        end
                    end
                end

                local done = {};
                local a, b = {}, {};
                local function PurchaseNode(nodeID)
                    if not done[nodeID] and set.nodes[nodeID] then
                        local nodeInfo = Internal.GetNodeInfoBySpecID(specID, nodeID);
                        local incomingEdges = nodeInfo.incomingEdgesBySpecID and nodeInfo.incomingEdgesBySpecID[specID] or nodeInfo.incomingEdges
                        if incomingEdges then
                            for _,sourceNode in ipairs(incomingEdges) do
                                PurchaseNode(sourceNode);
                            end
                        end

                        if nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection then
                            local entryIndex = set.nodes[nodeID];
                            local success = C_Traits.SetSelection(configID, nodeID, nodeInfo.entryIDs[entryIndex]);
                            Internal.LogMessage("Set talent choice to %d for node %d (%s)", nodeInfo.entryIDs[entryIndex], nodeID, success and "true" or "false");
                            if not success then
                                b[nodeID] = true;
                                return;
                            end
                        else
                            local points = set.nodes[nodeID];
                            for i=1,points do
                                local success = C_Traits.PurchaseRank(configID, nodeID);
                                Internal.LogMessage("Purchase talent point %d of %d for node %d (%s)", i, points, nodeID, success and "true" or "false");
                                if not success then
                                    b[nodeID] = true;
                                    return;
                                end
                            end
                        end

                        done[nodeID] = true;
                    end
                end
                for nodeID in pairs(set.nodes) do
                    a[nodeID] = true;
                end
                local tries = 10;
                while next(a) and tries > 0 do
                    Internal.LogMessage("Talent loop %d", 11 - tries);
                    wipe(b);
                    for nodeID in pairs(a) do
                        PurchaseNode(nodeID);
                    end
                    b, a = a, b;
                    tries = tries - 1;
                end

                state.dfTalentsAttempted = true
                local success = C_ClassTalents.CommitConfig(configID);
                Internal.LogMessage("Commit talent config (%s)", success and "true" or "false");
                if not success then
                    complete = true;
                end
            else
                complete = true; -- Cant change talents without an active config ID
            end
        end

        if complete then
            local specID = GetSpecializationInfo(GetSpecialization());
            if ClassTalentFrame then
                ClassTalentFrame.TalentsTab:ClearLastSelectedConfigID();
                ClassTalentFrame.TalentsTab:MarkTreeDirty();
            end
            C_ClassTalents.UpdateLastSelectedSavedConfigID(specID, 0) -- Set active loadout to "Default Loadout"
        end

        return complete
    end
end
local function CheckErrors(errorState, set)
    set = GetSet(set)

    if errorState.specID and not Internal.IsHeroTalentTreeValidForSpecID(set.subTreeID, errorState.specID) then
        return L["Incompatible Specialization"]
    end

    if not Internal.AreRestrictionsValidFor(set.restrictions, errorState.specID) then
        return L["Incompatible Restrictions"]
    end
end

-- Initializes the set dropdown menu for the Loadouts page
local function SetDropDownInit(self, set, index)
    Internal.SetDropDownInit(self, set, index, "herotalents", BtWLoadoutsFrame.HeroTalents)
end

Internal.AddLoadoutSegment({
    id = "herotalents",
    name = L["Hero Talents"],
    events = "TRAIT_CONFIG_UPDATED",
    enabled = BTWLOADOUTS_HERO_TALENTS_ACTIVE,
    add = AddSet,
    get = GetSets,
    getByName = GetByName,
    isActive = IsSetActive,
    combine = CombineSets,
    activate = ActivateSet,
    checkerrors = CheckErrors,
    dropdowninit = SetDropDownInit,

    export = function (set)
        return {
            version = 1,
            name = set.name,
            subTreeID = set.subTreeID,
            nodes = set.nodes,
            restrictions = set.restrictions,
        }
    end,
    import = function (source, version, name, ...)
        assert(version == 1)

        return Internal.AddSet("herotalents", UpdateSetFilters({
            subTreeID = source.subTreeID,
            name = name or source.name,
            nodes = source.nodes,
            restrictions = source.restrictions,
            useCount = 0,
        }))
    end,
    getByValue = function (set)
        return Internal.GetSetByValue(BtWLoadoutsSets.herotalents, set, CompareSets)
    end,
    verify = function (source, ...)
        -- local specID, classID = ...

        -- specID = source.specID or specID
        -- if not specID or not GetSpecializationInfoByID(specID) then
        --     return false, L["Invalid specialization"]
        -- end

        -- classID = source.classID or classID
        -- local classFile = select(6, GetSpecializationInfoByID(specID))
        -- if not classID or Internal.GetClassID(classFile) ~= classID then
        --     return false, L["Invalid class"]
        -- end

        -- local nodes = C_Traits.GetTreeNodes(source.treeID)
        -- if next(nodes) == nil then
        --     return false, L["Invalid talent tree"]
        -- end
        -- if  type(source.nodes) ~= "table" then
        --     return false, L["Invalid nodes"]
        -- end
        -- if source.restrictions ~= nil and type(source.restrictions) ~= "table" then
        --     return false, L["Missing restrictions"]
        -- end

        -- local nodeIDs = {}
        -- for _,nodeID in ipairs(nodes) do
        --     nodeIDs[nodeID] = true
        -- end

        -- for nodeID in pairs(source.nodes) do
        --     if not nodeIDs[nodeID] then
        --         return false, L["Invalid nodes"]
        --     end
        -- end

        return true
    end,
})

local HeroTalentButtonMixin = CreateFromMixins(TalentButtonSpendMixin or {})
function HeroTalentButtonMixin:OnLoad()
	TalentButtonSpendMixin.OnLoad(self);

    self.sizingAdjustment = {
        { region = "Icon", adjust = 0, },
        { region = "DisabledOverlay", adjust = 0, },
        { region = "StateBorder", adjust = 0, },
        { region = "StateBorderHover", adjust = 0, },
        { region = "IconMask", adjust = 0, },
        { region = "DisabledOverlayMask", adjust = 0, },
        { region = "Shadow", adjust = 0, },
    }
end
local HeroTalentButtonSplitMixin = CreateFromMixins(TalentButtonSplitSelectMixin or {});
function HeroTalentButtonSplitMixin:OnLoad()
	TalentButtonSplitSelectMixin.OnLoad(self);

    self.sizingAdjustment = {
        { region = "Icon", adjust = 0, },
        { region = "Icon2", adjust = 0, },
        { region = "DisabledOverlay", adjust = 0, },
        { region = "IconMask", adjust = 0, },
        { region = "Icon2Mask", adjust = 0, },
        { region = "IconSplitMask", adjust = 0, },
        { region = "DisabledOverlayMask", adjust = 0, },
        { region = "Shadow", adjust = 0, },
    }
end
function HeroTalentButtonSplitMixin:ApplySize(width, height)
	TalentButtonBasicArtMixin.ApplySize(self, width, height);
    self.StateBorder:SetSize(width + 18, height + 12);
    self.StateBorderHover:SetSize(width + 18, height + 12);
end
local HeroTalentSelectionChoiceMixin = CreateFromMixins(TalentSelectionChoiceMixin or {});

local function GetSpecializedMixin(nodeInfo, talentType)
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection) then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return HeroTalentButtonSplitMixin;
		end
	end
    return HeroTalentButtonMixin;
end

BtWLoadoutsHeroTalentFrameBaseButtonsParentMixin = CreateFromMixins(TalentFrameBaseButtonsParentMixin or {})
BtWLoadoutsHeroTalentSelectionChoiceFrameMixin = CreateFromMixins(TalentSelectionChoiceFrameMixin or {})
BtWLoadoutsHeroTalentSelectionChoiceFrameMixin.OnLoad = BtWLoadoutsHeroTalentSelectionChoiceFrameMixin.OnLoad or function () end
BtWLoadoutsHeroTalentSelectionChoiceFrameMixin.OnShow = BtWLoadoutsHeroTalentSelectionChoiceFrameMixin.OnShow or function () end
BtWLoadoutsHeroTalentSelectionChoiceFrameMixin.OnHide = BtWLoadoutsHeroTalentSelectionChoiceFrameMixin.OnHide or function () end
BtWLoadoutsHeroTalentSelectionChoiceFrameMixin.OnEvent = BtWLoadoutsHeroTalentSelectionChoiceFrameMixin.OnEvent or function () end

BtWLoadoutsHeroTalentsMixin = CreateFromMixins(TalentFrameBaseMixin or CallbackRegistryMixin)
function BtWLoadoutsHeroTalentsMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

    if not C_ClassTalents then
        return
    end

	self:SetBasePanOffset(0, 0);

    self.Scroll:RegisterForDrag("LeftButton");
    self.RestrictionsDropDown:SetSupportedTypes("spec", "race")
    self.RestrictionsDropDown:SetScript("OnChange", function ()
        Internal.Call("HeroTalentSetUpdated", self.set.setID);
        self:Update()
    end)

    self.temp = {}

	self.talentButtonCollection = CreateFramePoolCollection();
	self.talentDislayFramePool = CreateFramePoolCollection();
	self.edgePool = CreateFramePoolCollection();
	self.gatePool = CreateFramePool("FRAME", self.Scroll:GetScrollChild(), "BtWLoadoutsHeroTalentFrameGateTemplate");
	self.nodeIDToButton = {};
	self.buttonsWithDirtyEdges = {};
	self.treeInfoDirty = false;
	self.definitionInfoCache = {};
	self.dirtyDefinitionIDSet = {};
	self.entryInfoCache = {};
	self.dirtyEntryIDSet = {};
	self.nodeInfoCache = {};
	self.dirtyNodeIDSet = {};
	self.condInfoCache = {};
	self.dirtyCondIDSet = {};
	self.panOffsetX = 0;
	self.panOffsetY = 0;

    self.ButtonsParent = self.Scroll:GetScrollChild():GetChildren();

    if self.SelectionChoiceFrame.SetTalentFrame then
	    self.SelectionChoiceFrame:SetTalentFrame(self);
    end

    self.getSpecializedMixin = GetSpecializedMixin;
end
function BtWLoadoutsHeroTalentsMixin:OnShow()
    if not self.initialized then
		self.HeroTreeDropDown.includeNone = false;
        UIDropDownMenu_SetWidth(self.HeroTreeDropDown, 170);
        UIDropDownMenu_JustifyText(self.HeroTreeDropDown, "LEFT");

        self.HeroTreeDropDown.GetValue = function ()
            if self.set then
                return self.set.subTreeID
            end
        end
        self.HeroTreeDropDown.SetValue = function (_, _, arg1, arg2)
            CloseDropDownMenus();

            local set = self.set;
            if set then
                local temp = self.temp;

                temp[set.subTreeID] = set.nodes;

                set.subTreeID = arg1;
                set.classID = arg2;

                set.nodes = temp[set.subTreeID] or {};
                
	            Internal.Call("HeroTalentSetUpdated", set.setID);

                self:Update(true);
            end
        end

        self.initialized = true;
    end

    -- self:Update(true);
end
function BtWLoadoutsHeroTalentsMixin:OnUpdate(...)
    self:UpdateTreeCurrencyInfo();
    TalentFrameBaseMixin.OnUpdate(self, ...);
end
function BtWLoadoutsHeroTalentsMixin:ChangeSet(set)
    self.set = set
    wipe(self.temp);
    self:Update(true)
end
function BtWLoadoutsHeroTalentsMixin:UpdateSetName(value)
    if self.set and self.set.name ~= not value then
        if self.set.configID then
            return
        end
        self.set.name = value;
        Internal.Call("HeroTalentSetUpdated", self.set.setID);
        self:Update(false, true);
    end
end
function BtWLoadoutsHeroTalentsMixin:OnButtonClick(button)
    CloseDropDownMenus()
    if button.isAdd then
        BtWLoadoutsHelpTipFlags["TUTORIAL_NEW_SET"] = true;

        self.Name:ClearFocus()
        self:ChangeSet(AddSet())
        C_Timer.After(0, function ()
            self.Name:HighlightText()
            self.Name:SetFocus()
        end)
    elseif button.isDelete then
        local set = self.set
        if set.configID then
            return
        end
        if set.useCount > 0 then
            StaticPopup_Show("BTWLOADOUTS_DELETEINUSESET", set.name, nil, {
                set = set,
                func = DeleteSet,
            })
        else
            StaticPopup_Show("BTWLOADOUTS_DELETESET", set.name, nil, {
                set = set,
                func = DeleteSet,
            })
        end
    elseif button.isRefresh then
        local set = self.set;
        if set.configID then
            return
        end
        RefreshSet(set)
        self:Update()
    elseif button.isExport then
        local set = self.set;
        self:GetParent():SetExport(Internal.Export("herotalents", set.setID))
    elseif button.isActivate then
        local set = self.set;
        -- if select(6, GetSpecializationInfoByID(set.specID)) == select(2, UnitClass("player")) then
            Internal.ActivateProfile({
                herotalents = {set.setID}
            });
        -- end
    end
end
function BtWLoadoutsHeroTalentsMixin:OnSidebarItemClick(button)
    CloseDropDownMenus()
    if button.isHeader then
        button.collapsed[button.id] = not button.collapsed[button.id]
        self:Update()
    else
        if IsModifiedClick("SHIFT") then
            local set = GetSet(button.id);
            if select(6, GetSpecializationInfoByID(set.specID)) == select(2, UnitClass("player")) then
                Internal.ActivateProfile({
                    herotalents = {button.id}
                });
            end
        else
            self.Name:ClearFocus();
            self:ChangeSet(GetSet(button.id))
        end
    end
end
function BtWLoadoutsHeroTalentsMixin:OnSidebarItemDoubleClick(button)
    CloseDropDownMenus()
    if button.isHeader then
        return
    end

    local set = GetSet(button.id);
    if select(6, GetSpecializationInfoByID(set.specID)) == select(2, UnitClass("player")) then
        Internal.ActivateProfile({
            herotalents = {button.id}
        });
    end
end
function BtWLoadoutsHeroTalentsMixin:OnSidebarItemDragStart(button)
    CloseDropDownMenus()
    if button.isHeader then
        return
    end

    local icon = "INV_Misc_QuestionMark";
    local set = GetSet(button.id);
    local command = format("/btwloadouts activate herotalents %d", button.id);
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
function BtWLoadoutsHeroTalentsMixin:Update(updatePosition, skipUpdateTree)
    self:GetParent():SetTitle(L["Hero Talents"]);
    local sidebar = BtWLoadoutsFrame.Sidebar

    sidebar:SetSupportedFilters("herotalents", "spec", "class", "role", "character", "covenant", "race")
    sidebar:SetSets(BtWLoadoutsSets.herotalents)
    sidebar:SetCollapsed(BtWLoadoutsCollapsed.herotalents)
    sidebar:SetCategories(BtWLoadoutsCategories.herotalents)
    sidebar:SetFilters(BtWLoadoutsFilters.herotalents)
    sidebar:SetSelected(self.set)

    sidebar:Update()
    self.set = sidebar:GetSelected()
    local set = self.set
    
    local showingNPE = BtWLoadoutsFrame:SetNPEShown(set == nil, L["Hero Talents"], L["Create different hero talent layouts for the type of content you wish to do."])
        
    self:GetParent().ExportButton:SetEnabled(true)
    self:GetParent().DeleteButton:SetEnabled(true);

    if not showingNPE then
        local subTreeID = set.subTreeID
        local specID = Internal.GetSpecIDsByHeroTalentTreeID(subTreeID)[1]

        local treeInfo = Internal.GetTreeInfoBySpecID(specID);
        local treeID = treeInfo.ID

		local configID = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID; -- C_ClassTalents.GetActiveConfigID();
		C_ClassTalents.InitializeViewLoadout(specID, GetMaxLevelForPlayerExpansion());
		C_ClassTalents.ViewLoadout({});
        Internal.UpdateTraitInfoFromConfig(specID, configID)
        
        local subTreeInfo = C_Traits.GetSubTreeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, subTreeID)

        local nodes = C_Traits.GetTreeNodes(treeID)
        local oldNodes = set.nodes
        set.nodes = {}
        for _,nodeID in ipairs(nodes) do
            set.nodes[nodeID] = oldNodes[nodeID]
        end

        UpdateSetFilters(set)
        sidebar:Update()
        
        set.restrictions = set.restrictions or {}
        self.RestrictionsDropDown:SetSelections(set.restrictions)
        self.RestrictionsDropDown:SetLimitations("herotalents", subTreeID)
        self.RestrictionsButton:SetEnabled(true);

        if not self.Name:HasFocus() then
            self.Name:SetText(set.name or "");
        end
        UIDropDownMenu_SetText(self.HeroTreeDropDown, subTreeInfo.name);

        self.specID = specID;
        self.talentTreeID = treeID;
        self.subTreeID = subTreeID;
        self:UpdateTreeInfo(true);

        if not skipUpdateTree then
            self:LoadTalentTreeInternal();
        end

        local active = GetSelectedHeroSubTree()
        self:GetParent().RefreshButton:SetEnabled(active and active.ID == subTreeID)
        self:GetParent().ActivateButton:SetEnabled(Internal.IsHeroTalentTreeValidForSpecID(subTreeID,(GetSpecializationInfo(GetSpecialization()))));
    else
        local active = GetSelectedHeroSubTree()

        self.Name:SetText(format(L["New %s Set"], active.name));

        UIDropDownMenu_SetText(self.HeroTreeDropDown, active.name);
    end
end
function BtWLoadoutsHeroTalentsMixin:SetSetByID(setID)
    self.set = GetSet(setID)
end
function BtWLoadoutsHeroTalentsMixin:OnDrag()
    local scroll = self.Scroll;

    if self.Scroll:GetWidth() >= 1000 then -- Lock showing both trees
        local scrollX = scroll:GetHorizontalScroll();
        local scrollY = scroll:GetVerticalScroll();
        local targetX = self.centerOffset - 20;
        if ApproximatelyEqual(scrollX, targetX, 0.1) then
            scrollX = targetX;
            self.DragHandler:Hide();
        else
            scrollX = FrameDeltaLerp(scrollX, targetX, 0.1);
        end

        self.SpecTreeButton:SetAlpha(0);
        self.ClassTreeButton:SetAlpha(0);

        scroll:SetHorizontalScroll(scrollX)
        scroll:SetVerticalScroll(scrollY)
    elseif self.Scroll:GetWidth() >= 620 then -- Lock showing both trees
        local maxXScroll, maxYScroll = scroll:GetHorizontalScrollRange(), scroll:GetVerticalScrollRange()
        local minXScroll = self.leftOffset;
        local maxXScroll = self.rightOffset;

        local scrollX = scroll:GetHorizontalScroll();
        local scrollY = scroll:GetVerticalScroll();
        
        if self.endScrolling then
            self.DragHandler:Hide();
        else
            local mouseX, mouseY = GetCursorPosition()
            local scale = scroll:GetScrollChild():GetEffectiveScale()
            mouseX, mouseY = mouseX / scale, mouseY / scale
    
            scrollX = min(max(self.mouseX - mouseX + self.scrollX, minXScroll), maxXScroll)
            scrollY = min(max(mouseY - self.mouseY + self.scrollY, 0), maxYScroll)
        end

        self.SpecTreeButton:SetAlpha(0);
        self.ClassTreeButton:SetAlpha(0);

        scroll:SetHorizontalScroll(scrollX)
        scroll:SetVerticalScroll(scrollY)
    else
        local maxXScroll, maxYScroll = scroll:GetHorizontalScrollRange(), scroll:GetVerticalScrollRange()
        local minXScroll = self.leftOffset;
        local maxXScroll = self.rightOffset;

        local scrollX, scrollY

        if self.endScrolling then -- Maybe check which direction the drag was going in before hand?
            scrollX = scroll:GetHorizontalScroll();
            scrollY = scroll:GetVerticalScroll();
            if self.scrollDelta then
                if self.scrollDelta < 0 then
                    if ApproximatelyEqual(scrollX, minXScroll, 0.1) then
                        scrollX = minXScroll;
                        self.DragHandler:Hide();
                    else
                        scrollX = FrameDeltaLerp(scrollX, minXScroll, 0.1);
                    end
                else
                    if ApproximatelyEqual(scrollX, maxXScroll, 0.1) then
                        scrollX = maxXScroll;
                        self.DragHandler:Hide();
                    else
                        scrollX = FrameDeltaLerp(scrollX, maxXScroll, 0.1);
                    end
                end
            elseif ApproximatelyEqual(scrollX, minXScroll, 0.1) then
                scrollX = minXScroll;
                self.DragHandler:Hide();
            elseif ApproximatelyEqual(scrollX, maxXScroll, 0.1) then
                scrollX = maxXScroll;
                self.DragHandler:Hide();
            else
                local halfWay = maxXScroll * 0.5;
                if scrollX < maxXScroll * 0.5 then
                    scrollX = FrameDeltaLerp(scrollX, minXScroll, 0.1);
                else
                    scrollX = FrameDeltaLerp(scrollX, maxXScroll, 0.1);
                end
            end
        else
            local mouseX, mouseY = GetCursorPosition()
            local scale = scroll:GetScrollChild():GetEffectiveScale()
            mouseX, mouseY = mouseX / scale, mouseY / scale

            scrollX = self.mouseX - mouseX + self.scrollX
            scrollY = mouseY - self.mouseY + self.scrollY
        end

        scrollX = min(max(scrollX, minXScroll), maxXScroll)
        scrollY = min(max(scrollY, 0), maxYScroll)

        self.SpecTreeButton:SetAlpha(math.max(1 - math.abs(scrollX - self.leftOffset) * 0.005, 0))
        self.ClassTreeButton:SetAlpha(math.max(1 - math.abs(scrollX - self.rightOffset) * 0.005, 0))

        scroll:SetHorizontalScroll(scrollX)
        scroll:SetVerticalScroll(scrollY)
    end
end
function BtWLoadoutsHeroTalentsMixin:BeginScrollDrag()
    local scroll = self.Scroll;

    self.scrollX, self.scrollY = scroll:GetHorizontalScroll(), scroll:GetVerticalScroll()
    self.mouseX, self.mouseY = GetCursorPosition()

    local scale = scroll:GetScrollChild():GetEffectiveScale()
    self.mouseX, self.mouseY = self.mouseX / scale, self.mouseY / scale

    self.scrollDelta = nil;
    self.endScrolling = false;
    self.DragHandler:Show();
end
function BtWLoadoutsHeroTalentsMixin:EndScrollDrag()
    self.endScrolling = true;
end
function BtWLoadoutsHeroTalentsMixin:OnVerticalScroll(scroll, offset)
    self.SpecTreeButton:SetPoint("TOP", 0, -offset)
    self.ClassTreeButton:SetPoint("TOP", 0, -offset)
end
function BtWLoadoutsHeroTalentsMixin:ScrollToClassTree()
    self.scrollDelta = -1;
    self.endScrolling = true;
    self.DragHandler:Show();
end
function BtWLoadoutsHeroTalentsMixin:ScrollToSpecTree()
    self.scrollDelta = 1;
    self.endScrolling = true;
    self.DragHandler:Show();
end
function BtWLoadoutsHeroTalentsMixin:UpdateTreeInfo(skipButtonUpdates)
	self.talentTreeInfo = Internal.GetTreeInfoBySpecID(self.specID)
	self:UpdateTreeCurrencyInfo(skipButtonUpdates);

	if not skipButtonUpdates then
		self:RefreshGates();
	end
end
function BtWLoadoutsHeroTalentsMixin:UpdateTreeCurrencyInfo(skipButtonUpdates)
    local treeInfo = self:GetTreeInfo();
    
	self.treeCurrencyInfoMap = {};
    for _,currency in ipairs(treeInfo.currencies) do
        if GetMaxLevelForPlayerExpansion() == 60 then
            self.treeCurrencyInfoMap[currency.traitCurrencyID] = {
                traitCurrencyID = currency.traitCurrencyID,
                maxQuantity = currency.maxQuantity - 5,
                quantity = currency.maxQuantity - 5,
                spent = 0,
            }
        else
            currency.quantity = currency.maxQuantity;
            currency.spent = 0;
            self.treeCurrencyInfoMap[currency.traitCurrencyID] = currency;
        end
    end
    
    -- Calculate spent currencies
    for _,nodeID in ipairs(treeInfo.nodes) do
        -- local nodeInfo = self:GetAndCacheNodeInfo(nodeID);
        -- if nodeInfo and nodeInfo.ranksPurchased > 0 then
        --     for _,cost in ipairs(nodeInfo.costs) do
        --         self.treeCurrencyInfoMap[cost.ID].spent = self.treeCurrencyInfoMap[cost.ID].spent + (cost.amount * nodeInfo.ranksPurchased);
        --         self.treeCurrencyInfoMap[cost.ID].quantity = self.treeCurrencyInfoMap[cost.ID].quantity - (cost.amount * nodeInfo.ranksPurchased);
        --     end
        -- end
        local value = self.set.nodes[nodeID];
        if value then
            local nodeInfo = Internal.GetNodeInfoBySpecID(self.specID, nodeID);
            if #nodeInfo.entryIDs > 1 then
                value = 1;
            end
            if nodeInfo.costs then
                for _,cost in ipairs(nodeInfo.costs) do
                    self.treeCurrencyInfoMap[cost.ID].spent = self.treeCurrencyInfoMap[cost.ID].spent + (cost.amount * value);
                    self.treeCurrencyInfoMap[cost.ID].quantity = self.treeCurrencyInfoMap[cost.ID].quantity - (cost.amount * value);
                end
            end
        end
    end

	if not skipButtonUpdates then
		for condID, condInfo in pairs(self.condInfoCache) do
			if condInfo.isGate then
				self:MarkCondInfoCacheDirty(condID);
				self:ForceCondInfoUpdate(condID);
			end
		end

		self:RefreshGates();
	end
end
function BtWLoadoutsHeroTalentsMixin:GetAndCacheSubTreeInfo(subTreeID)
	local function GetSubTreeInfoCallback()
		return C_Traits.GetSubTreeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, subTreeID);
	end

	return GetOrCreateTableEntryByCallback(self.subTreeInfoCache, subTreeID, GetSubTreeInfoCallback);
end
function BtWLoadoutsHeroTalentsMixin:GetAndCacheNodeInfo(nodeID)
    if not self.set then
        return
    end

    local function GetNodeInfoCallback()
        local result = CopyTable(Internal.GetNodeInfoBySpecID(self.specID, nodeID), true);

        result.isAvailable = true; -- Not Gated
        result.meetsEdgeRequirements = true; -- Not Locked

        if #result.entryIDs == 1 then
            result.canPurchaseRank = false;
            result.canRefundRank = false;
            result.activeRank = 1;
            result.currentRank = 1;
            result.ranksPurchased = 1;
            result.activeEntry.rank = 1;
        else
            result.canPurchaseRank = true;
            result.canRefundRank = true;

            if self.set.nodes[nodeID] then
                result.activeRank = 1;
                result.currentRank = 1;
                result.ranksPurchased = 1;
                result.activeEntry = {
                    entryID = result.entryIDs[self.set.nodes[nodeID]],
                    rank = 1,
                }
            else
                result.activeRank = 0;
                result.currentRank = 0;
                result.ranksPurchased = 0;
                result.activeEntry = nil
            end
        end

        if result.subTreeID == self.subTreeID then
            result.subTreeActive = true
        end

        return result;
    end

    return GetOrCreateTableEntryByCallback(self.nodeInfoCache, nodeID, GetNodeInfoCallback);
end
function BtWLoadoutsHeroTalentsMixin:GetAndCacheDefinitionInfo(definitionID)
	local function GetDefinitionInfoCallback()
		-- self.dirtyDefinitionIDSet[definitionID] = nil;
		return C_Traits.GetDefinitionInfo(definitionID);
	end

	return GetOrCreateTableEntryByCallback(self.definitionInfoCache, definitionID, GetDefinitionInfoCallback);
end
function BtWLoadoutsHeroTalentsMixin:GetAndCacheEntryInfo(entryID)
	local function GetEntryInfoCallback()
		-- self.dirtyEntryIDSet[entryID] = nil;
		local entryInfo = C_Traits.GetEntryInfo(C_ClassTalents.GetActiveConfigID() or Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, entryID);
        entryInfo.isDisplayError = nil;
        return entryInfo
	end

	return GetOrCreateTableEntryByCallback(self.entryInfoCache, entryID, GetEntryInfoCallback);
end
function BtWLoadoutsHeroTalentsMixin:GetAndCacheCondInfo(condID)
    local function GetCondInfoCallback()
        local tree = self:GetTreeInfo();
        for _,gate in ipairs(tree.gates) do
            if gate.conditionID == condID then
                local result = {
                    isGate = true,
                    isAlwaysMet = false,

                    condID = gate.conditionID,
                    spentAmountRequired = gate.spentAmountRequired,
                    traitCurrencyID = gate.traitCurrencyID,
                }

                local spent = 0;
                for _,nodeID in ipairs(C_Traits.GetTreeNodes(tree.ID)) do
                    local nodeInfo = Internal.GetNodeInfoBySpecID(self.specID, nodeID);
                    if nodeInfo and self.set.nodes[nodeID] and not tContains(nodeInfo.conditionIDs, gate.conditionID) then
                        local purchased = #nodeInfo.entryIDs == 1 and self.set.nodes[nodeID] or 1;
                        if nodeInfo.costs then
                            for _,cost in ipairs(nodeInfo.costs) do
                                if cost.ID == gate.traitCurrencyID then
                                    spent = spent + (cost.amount * purchased);
                                end
                            end
                        end
                    end
                end
                result.spentAmountRequired = math.max(0, result.spentAmountRequired - spent);
                result.isMet = result.spentAmountRequired == 0;

                return result;
            end
        end
	end

	return GetOrCreateTableEntryByCallback(self.condInfoCache, condID, GetCondInfoCallback);
end
function BtWLoadoutsHeroTalentsMixin:GetNodeCost(nodeID)
    local nodeInfo = self:GetAndCacheNodeInfo(nodeID)
    return nodeInfo.costs;
end
function BtWLoadoutsHeroTalentsMixin:AddConditionsToTooltip()
    
end
function BtWLoadoutsHeroTalentsMixin:MarkNodeDirty(nodeID)
    local nodeInfo = self:GetAndCacheNodeInfo(nodeID);
    for _,edge in ipairs(nodeInfo.visibleEdges) do
        self:MarkNodeDirty(edge.targetNode);
    end
    self:MarkNodeInfoCacheDirty(nodeID);
end
function BtWLoadoutsHeroTalentsMixin:PurchaseRank(nodeID)
end
function BtWLoadoutsHeroTalentsMixin:RefundRank(nodeID)
end
function BtWLoadoutsHeroTalentsMixin:GetSpecializedSelectionChoiceMixin(entryInfo, talentType)
	return HeroTalentSelectionChoiceMixin;
end
function BtWLoadoutsHeroTalentsMixin:SetSelection(nodeID, entryID)
    if self.set.configID then
        return
    end

    if entryID == nil then
        self.set.nodes[nodeID] = nil;
    else
        local nodeInfo = self:GetAndCacheNodeInfo(nodeID)
        for index,nodeEntryID in ipairs(nodeInfo.entryIDs) do
            if nodeEntryID == entryID then
                self.set.nodes[nodeID] = index;
            end
        end
    end
	Internal.Call("HeroTalentSetUpdated", self.set.setID);
    -- self:MarkNodeDirty(nodeID);
    self:Update();
end
function BtWLoadoutsHeroTalentsMixin:InstantiateTalentButton(nodeID, nodeInfo)
	nodeInfo = nodeInfo or self:GetAndCacheNodeInfo(nodeID);

    if nodeInfo.subTreeID ~= self.subTreeID then
        return nil;
    end
	if not nodeInfo.isVisible and not self:ShouldInstantiateInvisibleButtons() then
		return nil;
	end

	local activeEntryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil;
	local entryInfo = (activeEntryID ~= nil) and self:GetAndCacheEntryInfo(activeEntryID) or nil;
	local talentType = (entryInfo ~= nil) and entryInfo.type or nil;
	local function InitTalentButton(newTalentButton)
		newTalentButton:SetNodeID(nodeID);

        if #newTalentButton.nodeInfo.entryIDs == 1 then
            newTalentButton.StateBorder:SetAlpha(0.5);
            newTalentButton.DisabledOverlay:SetAlpha(0.5);
            newTalentButton.DisabledOverlay:Show();
            newTalentButton.StateBorderHover:SetAlpha(0);
        end
        
        newTalentButton["SpendText"]:Hide()
        for i=1,4 do
            newTalentButton["SpendTextShadow"..i]:Hide()
        end
	end

	local newTalentButton = self:AcquireTalentButton(nodeInfo, talentType, nil, nil, InitTalentButton);

	if newTalentButton then
        local scale = 0.75-- self.Scroll:GetEffectiveScale()
        local posX, posY = TalentFrameUtil.GetNormalizedSubTreeNodePosition(self, nodeInfo)

        posX = posX + (self.Scroll:GetWidth() / scale) * 10 * 0.5
        posY = posY - 1200 + (self.Scroll:GetHeight() / scale) * 10 * 0.5

		TalentButtonUtil.ApplyPosition(newTalentButton, self, posX, posY);

		local frameLevel = newTalentButton:GetParent():GetFrameLevel() + self:GetFrameLevelForButton(nodeInfo);
		self:SetElementFrameLevel(newTalentButton, frameLevel);
		newTalentButton:Show();
	end

	return newTalentButton;
end

local function GetSetsForCharacter(tbl, slug)
	tbl = tbl or {}
	for _,set in pairs(BtWLoadoutsSets.herotalents) do
		if type(set) == "table" and set.character == slug then
			tbl[#tbl+1] = set
		end
	end
	return tbl
end
-- Character deletion
Internal.OnEvent("CharacterDeleted", function (event, slug)
	local sets = GetSetsForCharacter({}, slug)
	for _,set in ipairs(sets) do
		DeleteSet(set.setID)
	end
end)
