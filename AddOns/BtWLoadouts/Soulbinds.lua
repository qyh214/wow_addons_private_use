local ADDON_NAME,Internal = ...
local L = Internal.L

local GetActiveCovenantID = C_Covenants.GetActiveCovenantID
local GetCovenantData = C_Covenants.GetCovenantData
local ActivateSoulbind = C_Soulbinds.ActivateSoulbind
local GetActiveSoulbindID = C_Soulbinds.GetActiveSoulbindID
local GetSoulbindData = C_Soulbinds.GetSoulbindData
local GetSoulbindNode = C_Soulbinds.GetNode
local SelectSoulbindNode = C_Soulbinds.SelectNode

local HelpTipBox_Anchor = Internal.HelpTipBox_Anchor;
local HelpTipBox_SetText = Internal.HelpTipBox_SetText;

local function CompareSets(a, b)
    if a.soulbindID ~= b.soulbindID then
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

--[[ SOULBIND DROPDOWN ]]

BtWLoadoutsSoulbindDropDownMixin = {}
function BtWLoadoutsSoulbindDropDownMixin:OnShow()
	if not self.initialized then
		UIDropDownMenu_Initialize(self, self.Init);
		self.initialized = true
	end
end
function BtWLoadoutsSoulbindDropDownMixin:Init(level, menuList)
	local info = UIDropDownMenu_CreateInfo();
	local selected = self:GetValue();

	info.func = function (button, arg1, arg2, checked)
		self:SetValue(button, arg1, arg2, checked)
	end
	if (level or 1) == 1 then
		if self.includeNone then
			info.text = L["None"];
			info.checked = selected == nil;
			UIDropDownMenu_AddButton(info, level);
		end

        for covenantID = 1,4 do
            local covenantData = GetCovenantData(covenantID)

            info.text = covenantData.name;
            info.hasArrow, info.menuList = true, covenantData.ID;
            info.keepShownOnClick = true;
            info.notCheckable = true;
            UIDropDownMenu_AddButton(info, level);
        end
	else
        local covenantData = GetCovenantData(menuList)
        for _,soulbindID in ipairs(covenantData.soulbindIDs) do
            local soulbindData = GetSoulbindData(soulbindID)

            info.text = soulbindData.name;
			info.arg1 = soulbindData.ID;
            info.checked = selected == soulbindData.ID;
            UIDropDownMenu_AddButton(info, level);
        end
	end
end
function BtWLoadoutsSoulbindDropDownMixin:GetValue()
end
function BtWLoadoutsSoulbindDropDownMixin:SetValue(button, classIndex, classFile, checked)
end

--[[ SET HANDLING ]]

local function UpdateSetFilters(set)
	set.filters = set.filters or {}

	local filters = set.filters
    wipe(filters)
    
    Internal.UpdateRestrictionFilters(set)

	filters.soulbind = set.soulbindID
    
    local soulbindData = GetSoulbindData(set.soulbindID)
    filters.covenant = soulbindData.covenantID
    
	set.filters = filters

    return set
end
local function RefreshSet(set)
    local nodes = set.nodes or {}
    local conduits = set.conduits or {}
    
    wipe(nodes)
    wipe(conduits)

    local soulbindData = GetSoulbindData(set.soulbindID)
    for _,node in ipairs(soulbindData.tree.nodes) do
        if node.state == Enum.SoulbindNodeState.Selected then
            nodes[node.ID] = true
        end
        local conduitID = C_Soulbinds.GetInstalledConduitID(node.ID)
        if conduitID ~= 0 then
            conduits[node.ID] = conduitID
        end
    end

    set.nodes = nodes
    set.conduits = conduits
    set.classID = select(3, UnitClass("player"))

    return UpdateSetFilters(set)
end
local function AddSet()
    local soulbindID = GetActiveSoulbindID()
    if soulbindID == 0 then
        soulbindID = 7 -- Default to pelagos because why not
    end
    local soulbindData = GetSoulbindData(soulbindID)
    local set = Internal.AddSet("soulbinds", RefreshSet({
        soulbindID = soulbindID,
		name = format(L["New %s Set"], soulbindData.name),
		useCount = 0,
        nodes = {},
    }))
    Internal.Call("SoulbindSetCreated", set.setID);
    return set
end
local function DeleteSet(id)
	Internal.DeleteSet(BtWLoadoutsSets.soulbinds, id);

	if type(id) == "table" then
		id = id.setID;
	end
	for _,set in pairs(BtWLoadoutsSets.profiles) do
        if type(set) == "table" then
            for index,setID in ipairs(set.soulbinds) do
                if setID == id then
                    table.remove(set.soulbinds, index)
                end
            end
		end
	end
    
	Internal.Call("SoulbindSetDeleted", id);

	local frame = BtWLoadoutsFrame.Soulbinds;
	local set = frame.set;
	if set.setID == id then
		frame.set = nil
		BtWLoadoutsFrame:Update();
	end
end
local function GetSet(id)
    if type(id) == "table" then
		return id;
    elseif id < 0 then -- Fake a soulbind set
        local set = GetSoulbindData(math.abs(id))
        set.soulbindID = set.ID
        set.setID = -set.ID
        set.ID = nil
        return set
    else
		return BtWLoadoutsSets.soulbinds[id]
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

    local soulbindData = GetSoulbindData(set.soulbindID)
    local playerCovenantID = GetActiveCovenantID()

	return true, (soulbindData.covenantID ==playerCovenantID )
end
local function GetByName(name)
    return Internal.GetSetByName("soulbinds", name, SetIsValid)
end
local function IsSetActive(set, ignoreConduits)
    if set.soulbindID then
        local covenantID = GetActiveCovenantID()
        if covenantID then
            local soulbindID = GetActiveSoulbindID()
            local soulbindData = GetSoulbindData(set.soulbindID)
            -- The target soulbind is unlocked, is for the players covenant, so is valid for the character
            if soulbindData.unlocked and soulbindData.covenantID == covenantID then
                if set.soulbindID ~= soulbindID then
                    return false
                end
                if set.nodes then
                    for nodeID in pairs(set.nodes) do
                        local node = GetSoulbindNode(nodeID)
                        if node.state ~= Enum.SoulbindNodeState.Selected and node.state ~= Enum.SoulbindNodeState.Unavailable then
                            return false
                        end
                    end
                    if set.conduits and not ignoreConduits then
                        for nodeID,conduitID in pairs(set.conduits) do
                            local node = GetSoulbindNode(nodeID)
                            if C_Soulbinds.GetInstalledConduitID(nodeID) ~= conduitID and node.state ~= Enum.SoulbindNodeState.Unavailable then
                                return false
                            end
                        end
                    end
                end
            end
        end
    end

    return true;
end
local function IsSetConduitsActive(set)
    if set.conduits and next(set.conduits) then
        for nodeID,conduitID in pairs(set.conduits) do
            local node = GetSoulbindNode(nodeID)
            if node and node.state ~= Enum.SoulbindNodeState.Unavailable and C_Soulbinds.GetInstalledConduitID(nodeID) ~= conduitID then
                return false
            end
        end
    end

    return true;
end
local function CombineSets(result, state, ...)
	result = result or {};

    local classID = select(3, UnitClass("player"))
    local covenantID = GetActiveCovenantID()
    if covenantID then
        for i=1,select('#', ...) do
            local set = select(i, ...);
            local soulbindData = GetSoulbindData(set.soulbindID)
            if soulbindData.covenantID == covenantID and soulbindData.unlocked and (set.classID == nil or set.classID == classID) and Internal.AreRestrictionsValidForPlayer(set.restrictions) then
                result.soulbindID = set.soulbindID
                result.nodes = set.nodes
                result.conduits = set.conduits
            end
        end

        if state and state.blockers and not IsSetActive(result) then
            local conduitsActive = IsSetConduitsActive(result)
            if not conduitsActive then
                state.blockers[Internal.GetForgeOfBondsBlocker()] = IsSetActive(result, true)
            end
            -- If the conduits are already set we wont need to go to a forge so we may need a tome or rested area
            -- If we need to swap conduits but allowPartial has been set we may need a tome or rested area
            if not C_Soulbinds.CanSwitchActiveSoulbindTreeBranch() and (conduitsActive or state.allowPartial) then
                state.blockers[Internal.GetRestedTomeBlocker()] = true
            end
            state.blockers[Internal.GetCombatBlocker()] = true
            state.blockers[Internal.GetMythicPlusBlocker()] = true
            state.blockers[Internal.GetJailersChainBlocker()] = true
        end
    end

	return result;
end
local function ActivateSet(set, state)
    local complete = true;

    if not IsSetActive(set) then
        local soulbindData = GetSoulbindData(set.soulbindID)
        if C_Soulbinds.GetActiveSoulbindID() ~= set.soulbindID then
            Internal.LogMessage("Switching soulbind to %s", soulbindData.name)
            ActivateSoulbind(set.soulbindID)
        end

        if set.nodes and C_Soulbinds.CanSwitchActiveSoulbindTreeBranch() then
            for nodeID in pairs(set.nodes) do
                local node = GetSoulbindNode(nodeID)
                if node.state ~= Enum.SoulbindNodeState.Selected and node.state ~= Enum.SoulbindNodeState.Unavailable then
                    Internal.LogMessage("Switching soulbind tree node to %d", nodeID)
                    SelectSoulbindNode(nodeID)
                    complete = false
                end
            end
            local socketedAny = false
            if set.conduits and C_Soulbinds.CanModifySoulbind() then
                for nodeID,conduitID in pairs(set.conduits) do
                    local node = GetSoulbindNode(nodeID)
                    if C_Soulbinds.GetInstalledConduitID(nodeID) ~= conduitID and node.state ~= Enum.SoulbindNodeState.Unavailable then
                        Internal.LogMessage("Socket conduit %d into node %d", conduitID, nodeID)
                        C_Soulbinds.ModifyNode(nodeID, conduitID, Enum.SoulbindConduitTransactionType.Install)
                        socketedAny = true
                    end
                end
            end

            if socketedAny then
                C_Soulbinds.CommitPendingConduitsInSoulbind(set.soulbindID)
                complete = false
            end
        end
    end

	return complete
end
local function CheckErrors(errorState, set)
    set = GetSet(set)

	if not Internal.AreRestrictionsValidFor(set.restrictions, errorState.specID) then
        return L["Incompatible Restrictions"]
	end
end

local genericSoulbindSets = {}
for covenantID = 1,4 do
    local covenantData = GetCovenantData(covenantID)
    for index,soulbindID in ipairs(covenantData.soulbindIDs) do
        local soulbindData = GetSoulbindData(soulbindID)

        genericSoulbindSets[#genericSoulbindSets+1] = UpdateSetFilters({
            setID = -soulbindData.ID,
            name = soulbindData.name,
            soulbindID = soulbindData.ID,
            covenantID = covenantID,
            order = -20 + (index * 4 + covenantID),
        })
    end
end
-- Initializes the set dropdown menu for the Loadouts page
local function SetDropDownInit(self, set, index)
    local temp = {}
    for _,set in pairs(genericSoulbindSets) do
        temp[set.setID] = set
    end
    for _,set in pairs(BtWLoadoutsSets.soulbinds) do
        if type(set) == "table" then
            temp[set.setID] = set
        end
    end
    self:SetSelected(index and set.soulbinds[index] or nil)
    self:SetSets(temp)
    self:SetFilters(BtWLoadoutsFilters.soulbinds)
    self:SetCategories(BtWLoadoutsCategories.soulbinds)
	self:SetIncludeNone(index ~= nil)
    self:OnItemClick(function (self, setID)
		local index = index or (#set.soulbinds + 1)

		if set.soulbinds[index] then
            local subset = GetSet(set.soulbinds[index]);
            subset.useCount = (subset.useCount or 1) - 1;
		end

        if setID == "none" then
			table.remove(set.soulbinds, index);
        elseif setID == "new" then
            local subset = AddSet();
            set.soulbinds[index] = subset.setID;

            BtWLoadoutsFrame.Soulbinds.set = subset;
            PanelTemplates_SetTab(BtWLoadoutsFrame, BtWLoadoutsFrame.Soulbinds:GetID());
        
            BtWLoadoutsHelpTipFlags["TUTORIAL_CREATE_TALENT_SET"] = true;
        else -- Change to a specific set
            set.soulbinds[index] = setID;
        end
    
        if set.soulbinds[index] then
            local subset = GetSet(set.soulbinds[index]);
            subset.useCount = (subset.useCount or 0) + 1;
        end

		self:SetSelected(set.soulbinds[index])

		CloseDropDownMenus()
        BtWLoadoutsFrame:Update();
    end)
end

Internal.AddLoadoutSegment({
    id = "soulbinds",
    name = L["Soulbinds"],
    events = "SOULBIND_ACTIVATED",
    add = AddSet,
    get = GetSets,
    getByName = GetSets,
    combine = CombineSets,
    isActive = IsSetActive,
	activate = ActivateSet,
    dropdowninit = SetDropDownInit,
	checkerrors = CheckErrors,

    export = function (set)
        return {
            version = 1,
            name = set.name,
            soulbindID = set.soulbindID,
            nodes = set.nodes,
            restrictions = set.restrictions,
        }
    end,
    import = function (source, version, name, ...)
        assert(version == 1)

        local soulbindID = source.soulbindID or ...
        return Internal.AddSet("soulbinds", UpdateSetFilters({
			soulbindID = soulbindID,
			name = name or source.name,
			useCount = 0,
			nodes = source.nodes,
			restrictions = source.restrictions,
        }))
    end,
    getByValue = function (set)
        -- If the nodes is missing then we just want the faux set
        if set.nodes == nil then
            return GetSet(-set.soulbindID)
        else
            return Internal.GetSetByValue(BtWLoadoutsSets.soulbinds, set, CompareSets)
        end
    end,
    verify = function (source, ...)
        local soulbindID = source.soulbindID or ...
        if not soulbindID or not GetSoulbindData(soulbindID) then
            return false, L["Invalid soulbind"]
        end
        if source.nodes ~= nil and type(source.nodes) ~= "table" then
            return false, L["Invalid nodes"]
        end
        if source.restrictions ~= nil and type(source.restrictions) ~= "table" then
            return false, L["Missing restrictions"]
        end

        -- @TODO verify talent ids?

        return true
    end,
})

-- [[ TAB UI ]]

local function GetConduitName(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return CONDUIT_POTENCY;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return CONDUIT_ENDURANCE;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return CONDUIT_FINESSE;
	end
end
local function GetConduitEmblemAtlas(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return "Soulbinds_Tree_Conduit_Icon_Attack";
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return "Soulbinds_Tree_Conduit_Icon_Protect";
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return "Soulbinds_Tree_Conduit_Icon_Utility";
	end
end
local function GetConduitIconScale(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return 1.0;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return 1.0;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return 1.0;
	end
end

local conduits = {
    { -- Stalwart Guardian
        conduitID = 5,
        conduitType = 2,
        conduitSpecSetID = 168,
        covenantID = 0,
        conduitItemID = 180842,
    },
    { -- Brutal Vitality
        conduitID = 7,
        conduitType = 2,
        conduitSpecSetID = 168,
        covenantID = 0,
        conduitItemID = 180844,
    },
    { -- Inspiring Presence
        conduitID = 8,
        conduitType = 0,
        conduitSpecSetID = 168,
        covenantID = 0,
        conduitItemID = 180847,
    },
    { -- Safeguard
        conduitID = 9,
        conduitType = 0,
        conduitSpecSetID = 168,
        covenantID = 0,
        conduitItemID = 180896,
    },
    { -- Fueled by Violence
        conduitID = 10,
        conduitType = 2,
        conduitSpecSetID = 42,
        covenantID = 0,
        conduitItemID = 180932,
    },
    { -- Ashen Juggernaut
        conduitID = 11,
        conduitType = 1,
        conduitSpecSetID = 168,
        covenantID = 0,
        conduitItemID = 180933,
    },
    { -- Crash the Ramparts
        conduitID = 12,
        conduitType = 1,
        conduitSpecSetID = 40,
        covenantID = 0,
        conduitItemID = 180935,
    },
    { -- Cacophonous Roar
        conduitID = 13,
        conduitType = 0,
        conduitSpecSetID = 168,
        covenantID = 0,
        conduitItemID = 180943,
    },
    { -- Merciless Bonegrinder
        conduitID = 14,
        conduitType = 1,
        conduitSpecSetID = 40,
        covenantID = 0,
        conduitItemID = 180944,
    },
    { -- Harm Denial
        conduitID = 15,
        conduitType = 2,
        conduitSpecSetID = 164,
        covenantID = 0,
        conduitItemID = 181373,
    },
    { -- Inner Fury
        conduitID = 16,
        conduitType = 1,
        conduitSpecSetID = 26,
        covenantID = 0,
        conduitItemID = 181376,
    },
    { -- Unrelenting Cold
        conduitID = 17,
        conduitType = 1,
        conduitSpecSetID = 22,
        covenantID = 0,
        conduitItemID = 181383,
    },
    { -- Shivering Core
        conduitID = 18,
        conduitType = 1,
        conduitSpecSetID = 22,
        covenantID = 0,
        conduitItemID = 181389,
    },
    { -- Calculated Strikes
        conduitID = 19,
        conduitType = 1,
        conduitSpecSetID = 26,
        covenantID = 0,
        conduitItemID = 181435,
    },
    { -- Icy Propulsion
        conduitID = 20,
        conduitType = 1,
        conduitSpecSetID = 22,
        covenantID = 0,
        conduitItemID = 181455,
    },
    { -- Ice Bite
        conduitID = 21,
        conduitType = 1,
        conduitSpecSetID = 22,
        covenantID = 0,
        conduitItemID = 181461,
    },
    { -- Coordinated Offensive
        conduitID = 22,
        conduitType = 1,
        conduitSpecSetID = 26,
        covenantID = 0,
        conduitItemID = 181462,
    },
    { -- Winter's Protection
        conduitID = 23,
        conduitType = 0,
        conduitSpecSetID = 162,
        covenantID = 0,
        conduitItemID = 181464,
    },
    { -- Xuen's Bond
        conduitID = 24,
        conduitType = 1,
        conduitSpecSetID = 26,
        covenantID = 0,
        conduitItemID = 181465,
    },
    { -- Grounding Breath
        conduitID = 25,
        conduitType = 2,
        conduitSpecSetID = 164,
        covenantID = 0,
        conduitItemID = 181466,
    },
    { -- Flow of Time
        conduitID = 26,
        conduitType = 0,
        conduitSpecSetID = 162,
        covenantID = 0,
        conduitItemID = 181467,
    },
    { -- Indelible Victory
        conduitID = 27,
        conduitType = 2,
        conduitSpecSetID = 168,
        covenantID = 0,
        conduitItemID = 181469,
    },
    { -- Jade Bond
        conduitID = 28,
        conduitType = 1,
        conduitSpecSetID = 25,
        covenantID = 0,
        conduitItemID = 181495,
    },
    { -- Grounding Surge
        conduitID = 29,
        conduitType = 0,
        conduitSpecSetID = 162,
        covenantID = 0,
        conduitItemID = 181498,
    },
    { -- Infernal Cascade
        conduitID = 30,
        conduitType = 1,
        conduitSpecSetID = 23,
        covenantID = 0,
        conduitItemID = 181504,
    },
    { -- Resplendent Mist
        conduitID = 31,
        conduitType = 1,
        conduitSpecSetID = 25,
        covenantID = 0,
        conduitItemID = 181505,
    },
    { -- Master Flame
        conduitID = 32,
        conduitType = 1,
        conduitSpecSetID = 23,
        covenantID = 0,
        conduitItemID = 181506,
    },
    { -- Fortifying Ingredients
        conduitID = 33,
        conduitType = 2,
        conduitSpecSetID = 164,
        covenantID = 0,
        conduitItemID = 181508,
    },
    { -- Arcane Prodigy
        conduitID = 34,
        conduitType = 1,
        conduitSpecSetID = 21,
        covenantID = 0,
        conduitItemID = 181509,
    },
    { -- Lingering Numbness
        conduitID = 35,
        conduitType = 0,
        conduitSpecSetID = 164,
        covenantID = 0,
        conduitItemID = 181510,
    },
    { -- Nether Precision
        conduitID = 36,
        conduitType = 1,
        conduitSpecSetID = 21,
        covenantID = 0,
        conduitItemID = 181511,
    },
    { -- Dizzying Tumble
        conduitID = 37,
        conduitType = 0,
        conduitSpecSetID = 164,
        covenantID = 0,
        conduitItemID = 181512,
    },
    { -- Discipline of the Grove
        conduitID = 38,
        conduitType = 1,
        conduitSpecSetID = 162,
        covenantID = 3,
        conduitItemID = 181539,
    },
    { -- Gift of the Lich
        conduitID = 39,
        conduitType = 1,
        conduitSpecSetID = 162,
        covenantID = 4,
        conduitItemID = 181553,
    },
    { -- Ire of the Ascended
        conduitID = 40,
        conduitType = 1,
        conduitSpecSetID = 162,
        covenantID = 1,
        conduitItemID = 181600,
    },
    { -- Swift Transference
        conduitID = 41,
        conduitType = 0,
        conduitSpecSetID = 164,
        covenantID = 0,
        conduitItemID = 181624,
    },
    { -- Tumbling Technique
        conduitID = 42,
        conduitType = 0,
        conduitSpecSetID = 164,
        covenantID = 0,
        conduitItemID = 181640,
    },
    { -- Siphoned Malice
        conduitID = 43,
        conduitType = 1,
        conduitSpecSetID = 162,
        covenantID = 2,
        conduitItemID = 181639,
    },
    { -- Rising Sun Revival
        conduitID = 44,
        conduitType = 1,
        conduitSpecSetID = 25,
        covenantID = 0,
        conduitItemID = 181641,
    },
    { -- Cryo-Freeze
        conduitID = 45,
        conduitType = 2,
        conduitSpecSetID = 162,
        covenantID = 0,
        conduitItemID = 181698,
    },
    { -- Scalding Brew
        conduitID = 46,
        conduitType = 1,
        conduitSpecSetID = 24,
        covenantID = 0,
        conduitItemID = 181700,
    },
    { -- Celestial Effervescence
        conduitID = 47,
        conduitType = 2,
        conduitSpecSetID = 24,
        covenantID = 0,
        conduitItemID = 181705,
    },
    { -- Diverted Energy
        conduitID = 48,
        conduitType = 2,
        conduitSpecSetID = 162,
        covenantID = 0,
        conduitItemID = 181707,
    },
    { -- Unnerving Focus
        conduitID = 49,
        conduitType = 2,
        conduitSpecSetID = 42,
        covenantID = 0,
        conduitItemID = 181709,
    },
    { -- Depths of Insanity
        conduitID = 50,
        conduitType = 1,
        conduitSpecSetID = 41,
        covenantID = 0,
        conduitItemID = 181712,
    },
    { -- Magi's Brand
        conduitID = 51,
        conduitType = 1,
        conduitSpecSetID = 21,
        covenantID = 0,
        conduitItemID = 181734,
    },
    { -- Hack and Slash
        conduitID = 52,
        conduitType = 1,
        conduitSpecSetID = 41,
        covenantID = 0,
        conduitItemID = 181735,
    },
    { -- Flame Accretion
        conduitID = 53,
        conduitType = 1,
        conduitSpecSetID = 23,
        covenantID = 0,
        conduitItemID = 181736,
    },
    { -- Nourishing Chi
        conduitID = 54,
        conduitType = 1,
        conduitSpecSetID = 25,
        covenantID = 0,
        conduitItemID = 181737,
    },
    { -- Artifice of the Archmage
        conduitID = 55,
        conduitType = 1,
        conduitSpecSetID = 21,
        covenantID = 0,
        conduitItemID = 181738,
    },
    { -- Evasive Stride
        conduitID = 56,
        conduitType = 2,
        conduitSpecSetID = 24,
        covenantID = 0,
        conduitItemID = 181740,
    },
    { -- Walk with the Ox
        conduitID = 57,
        conduitType = 1,
        conduitSpecSetID = 24,
        covenantID = 0,
        conduitItemID = 181742,
    },
    { -- Incantation of Swiftness
        conduitID = 58,
        conduitType = 0,
        conduitSpecSetID = 162,
        covenantID = 0,
        conduitItemID = 181756,
    },
    { -- Strike with Clarity
        conduitID = 59,
        conduitType = 1,
        conduitSpecSetID = 164,
        covenantID = 1,
        conduitItemID = 181759,
    },
    { -- Bone Marrow Hops
        conduitID = 60,
        conduitType = 1,
        conduitSpecSetID = 164,
        covenantID = 4,
        conduitItemID = 181770,
    },
    { -- Tempest Barrier
        conduitID = 61,
        conduitType = 2,
        conduitSpecSetID = 162,
        covenantID = 0,
        conduitItemID = 181769,
    },
    { -- Imbued Reflections
        conduitID = 62,
        conduitType = 1,
        conduitSpecSetID = 164,
        covenantID = 2,
        conduitItemID = 181774,
    },
    { -- Way of the Fae
        conduitID = 63,
        conduitType = 1,
        conduitSpecSetID = 164,
        covenantID = 3,
        conduitItemID = 181775,
    },
    { -- Vicious Contempt
        conduitID = 64,
        conduitType = 1,
        conduitSpecSetID = 41,
        covenantID = 0,
        conduitItemID = 181776,
    },
    { -- Eternal Hunger
        conduitID = 65,
        conduitType = 1,
        conduitSpecSetID = 7,
        covenantID = 0,
        conduitItemID = 181786,
    },
    { -- Translucent Image
        conduitID = 66,
        conduitType = 2,
        conduitSpecSetID = 166,
        covenantID = 0,
        conduitItemID = 181826,
    },
    { -- Move with Grace
        conduitID = 67,
        conduitType = 0,
        conduitSpecSetID = 166,
        covenantID = 0,
        conduitItemID = 181827,
    },
    { -- Chilled Resilience
        conduitID = 68,
        conduitType = 0,
        conduitSpecSetID = 43,
        covenantID = 0,
        conduitItemID = 181834,
    },
    { -- Clear Mind
        conduitID = 69,
        conduitType = 0,
        conduitSpecSetID = 166,
        covenantID = 0,
        conduitItemID = 181837,
    },
    { -- Spirit Drain
        conduitID = 70,
        conduitType = 0,
        conduitSpecSetID = 43,
        covenantID = 0,
        conduitItemID = 181836,
    },
    { -- Charitable Soul
        conduitID = 71,
        conduitType = 2,
        conduitSpecSetID = 166,
        covenantID = 0,
        conduitItemID = 181838,
    },
    { -- Light's Inspiration
        conduitID = 72,
        conduitType = 2,
        conduitSpecSetID = 166,
        covenantID = 0,
        conduitItemID = 181840,
    },
    { -- Power Unto Others
        conduitID = 73,
        conduitType = 0,
        conduitSpecSetID = 166,
        covenantID = 0,
        conduitItemID = 181842,
    },
    { -- Reinforced Shell
        conduitID = 74,
        conduitType = 2,
        conduitSpecSetID = 43,
        covenantID = 0,
        conduitItemID = 181841,
    },
    { -- Shining Radiance
        conduitID = 75,
        conduitType = 1,
        conduitSpecSetID = 31,
        covenantID = 0,
        conduitItemID = 181843,
    },
    { -- Pain Transformation
        conduitID = 76,
        conduitType = 1,
        conduitSpecSetID = 31,
        covenantID = 0,
        conduitItemID = 181844,
    },
    { -- Exaltation
        conduitID = 77,
        conduitType = 1,
        conduitSpecSetID = 31,
        covenantID = 0,
        conduitItemID = 181845,
    },
    { -- Lasting Spirit
        conduitID = 78,
        conduitType = 1,
        conduitSpecSetID = 32,
        covenantID = 0,
        conduitItemID = 181847,
    },
    { -- Accelerated Cold
        conduitID = 79,
        conduitType = 1,
        conduitSpecSetID = 6,
        covenantID = 0,
        conduitItemID = 181848,
    },
    { -- Withering Plague
        conduitID = 80,
        conduitType = 1,
        conduitSpecSetID = 5,
        covenantID = 0,
        conduitItemID = 181866,
    },
    { -- Swift Penitence
        conduitID = 81,
        conduitType = 1,
        conduitSpecSetID = 31,
        covenantID = 0,
        conduitItemID = 181867,
    },
    { -- Focused Mending
        conduitID = 82,
        conduitType = 1,
        conduitSpecSetID = 32,
        covenantID = 0,
        conduitItemID = 181942,
    },
    { -- Eradicating Blow
        conduitID = 83,
        conduitType = 1,
        conduitSpecSetID = 6,
        covenantID = 0,
        conduitItemID = 181943,
    },
    { -- Resonant Words
        conduitID = 84,
        conduitType = 1,
        conduitSpecSetID = 32,
        covenantID = 0,
        conduitItemID = 181944,
    },
    { -- Mental Recovery
        conduitID = 85,
        conduitType = 0,
        conduitSpecSetID = 166,
        covenantID = 0,
        conduitItemID = 181962,
    },
    { -- Blood Bond
        conduitID = 86,
        conduitType = 2,
        conduitSpecSetID = 5,
        covenantID = 0,
        conduitItemID = 181963,
    },
    { -- Courageous Ascension
        conduitID = 87,
        conduitType = 1,
        conduitSpecSetID = 166,
        covenantID = 1,
        conduitItemID = 181974,
    },
    { -- Hardened Bones
        conduitID = 88,
        conduitType = 2,
        conduitSpecSetID = 43,
        covenantID = 0,
        conduitItemID = 181975,
    },
    { -- Embrace Death
        conduitID = 89,
        conduitType = 1,
        conduitSpecSetID = 7,
        covenantID = 0,
        conduitItemID = 181980,
    },
    { -- Festering Transfusion
        conduitID = 90,
        conduitType = 1,
        conduitSpecSetID = 166,
        covenantID = 4,
        conduitItemID = 181981,
    },
    { -- Everfrost
        conduitID = 91,
        conduitType = 1,
        conduitSpecSetID = 6,
        covenantID = 0,
        conduitItemID = 181982,
    },
    { -- Astral Protection
        conduitID = 92,
        conduitType = 2,
        conduitSpecSetID = 13,
        covenantID = 0,
        conduitItemID = 182105,
    },
    { -- Refreshing Waters
        conduitID = 93,
        conduitType = 2,
        conduitSpecSetID = 13,
        covenantID = 0,
        conduitItemID = 182106,
    },
    { -- Vital Accretion
        conduitID = 94,
        conduitType = 2,
        conduitSpecSetID = 13,
        covenantID = 0,
        conduitItemID = 182107,
    },
    { -- Thunderous Paws
        conduitID = 95,
        conduitType = 0,
        conduitSpecSetID = 13,
        covenantID = 0,
        conduitItemID = 182108,
    },
    { -- Totemic Surge
        conduitID = 96,
        conduitType = 0,
        conduitSpecSetID = 13,
        covenantID = 0,
        conduitItemID = 182109,
    },
    { -- Crippling Hex
        conduitID = 97,
        conduitType = 0,
        conduitSpecSetID = 13,
        covenantID = 0,
        conduitItemID = 182110,
    },
    { -- Spiritual Resonance
        conduitID = 98,
        conduitType = 0,
        conduitSpecSetID = 13,
        covenantID = 0,
        conduitItemID = 182111,
    },
    { -- Fleeting Wind
        conduitID = 99,
        conduitType = 0,
        conduitSpecSetID = 43,
        covenantID = 0,
        conduitItemID = 182113,
    },
    { -- Pyroclastic Shock
        conduitID = 100,
        conduitType = 1,
        conduitSpecSetID = 11,
        covenantID = 0,
        conduitItemID = 182125,
    },
    { -- Fae Fermata
        conduitID = 101,
        conduitType = 1,
        conduitSpecSetID = 166,
        covenantID = 3,
        conduitItemID = 182129,
    },
    { -- High Voltage
        conduitID = 102,
        conduitType = 1,
        conduitSpecSetID = 11,
        covenantID = 0,
        conduitItemID = 182126,
    },
    { -- Shake the Foundations
        conduitID = 103,
        conduitType = 1,
        conduitSpecSetID = 11,
        covenantID = 0,
        conduitItemID = 182127,
    },
    { -- Call of Flame
        conduitID = 104,
        conduitType = 1,
        conduitSpecSetID = 11,
        covenantID = 0,
        conduitItemID = 182128,
    },
    { -- Shattered Perceptions
        conduitID = 105,
        conduitType = 1,
        conduitSpecSetID = 166,
        covenantID = 2,
        conduitItemID = 182130,
    },
    { -- Unending Grip
        conduitID = 106,
        conduitType = 0,
        conduitSpecSetID = 43,
        covenantID = 0,
        conduitItemID = 182132,
    },
    { -- Haunting Apparitions
        conduitID = 107,
        conduitType = 1,
        conduitSpecSetID = 33,
        covenantID = 0,
        conduitItemID = 182131,
    },
    { -- Insatiable Appetite
        conduitID = 108,
        conduitType = 2,
        conduitSpecSetID = 43,
        covenantID = 0,
        conduitItemID = 182133,
    },
    { -- Unruly Winds
        conduitID = 109,
        conduitType = 1,
        conduitSpecSetID = 12,
        covenantID = 0,
        conduitItemID = 182134,
    },
    { -- Focused Lightning
        conduitID = 110,
        conduitType = 1,
        conduitSpecSetID = 12,
        covenantID = 0,
        conduitItemID = 182135,
    },
    { -- Magma Fist
        conduitID = 111,
        conduitType = 1,
        conduitSpecSetID = 12,
        covenantID = 0,
        conduitItemID = 182137,
    },
    { -- Chilled to the Core
        conduitID = 112,
        conduitType = 1,
        conduitSpecSetID = 12,
        covenantID = 0,
        conduitItemID = 182136,
    },
    { -- Mind Devourer
        conduitID = 113,
        conduitType = 1,
        conduitSpecSetID = 33,
        covenantID = 0,
        conduitItemID = 182138,
    },
    { -- Rabid Shadows
        conduitID = 114,
        conduitType = 1,
        conduitSpecSetID = 33,
        covenantID = 0,
        conduitItemID = 182139,
    },
    { -- Dissonant Echoes
        conduitID = 115,
        conduitType = 1,
        conduitSpecSetID = 33,
        covenantID = 0,
        conduitItemID = 182140,
    },
    { -- Holy Oration
        conduitID = 116,
        conduitType = 1,
        conduitSpecSetID = 32,
        covenantID = 0,
        conduitItemID = 182141,
    },
    { -- Embrace of Earth
        conduitID = 117,
        conduitType = 1,
        conduitSpecSetID = 4,
        covenantID = 0,
        conduitItemID = 182142,
    },
    { -- Swirling Currents
        conduitID = 118,
        conduitType = 1,
        conduitSpecSetID = 4,
        covenantID = 0,
        conduitItemID = 182143,
    },
    { -- Heavy Rainfall
        conduitID = 119,
        conduitType = 1,
        conduitSpecSetID = 4,
        covenantID = 0,
        conduitItemID = 182145,
    },
    { -- Nature's Focus
        conduitID = 120,
        conduitType = 1,
        conduitSpecSetID = 4,
        covenantID = 0,
        conduitItemID = 182144,
    },
    { -- Meat Shield
        conduitID = 121,
        conduitType = 2,
        conduitSpecSetID = 5,
        covenantID = 0,
        conduitItemID = 182187,
    },
    { -- Unleashed Frenzy
        conduitID = 122,
        conduitType = 1,
        conduitSpecSetID = 6,
        covenantID = 0,
        conduitItemID = 182201,
    },
    { -- Debilitating Malady
        conduitID = 123,
        conduitType = 1,
        conduitSpecSetID = 5,
        covenantID = 0,
        conduitItemID = 182203,
    },
    { -- Convocation of the Dead
        conduitID = 124,
        conduitType = 1,
        conduitSpecSetID = 7,
        covenantID = 0,
        conduitItemID = 182206,
    },
    { -- Lingering Plague
        conduitID = 125,
        conduitType = 1,
        conduitSpecSetID = 7,
        covenantID = 0,
        conduitItemID = 182208,
    },
    { -- Impenetrable Gloom
        conduitID = 126,
        conduitType = 1,
        conduitSpecSetID = 43,
        covenantID = 2,
        conduitItemID = 182288,
    },
    { -- Brutal Grasp
        conduitID = 127,
        conduitType = 1,
        conduitSpecSetID = 43,
        covenantID = 4,
        conduitItemID = 182292,
    },
    { -- Proliferation
        conduitID = 128,
        conduitType = 1,
        conduitSpecSetID = 43,
        covenantID = 1,
        conduitItemID = 182295,
    },
    { -- Divine Call
        conduitID = 129,
        conduitType = 2,
        conduitSpecSetID = 30,
        covenantID = 0,
        conduitItemID = 182304,
    },
    { -- Fel Defender
        conduitID = 130,
        conduitType = 2,
        conduitSpecSetID = 8,
        covenantID = 0,
        conduitItemID = 182316,
    },
    { -- Viscous Ink
        conduitID = 131,
        conduitType = 2,
        conduitSpecSetID = 8,
        covenantID = 0,
        conduitItemID = 182318,
    },
    { -- Shattered Restoration
        conduitID = 132,
        conduitType = 2,
        conduitSpecSetID = 8,
        covenantID = 0,
        conduitItemID = 182317,
    },
    { -- Shielding Words
        conduitID = 133,
        conduitType = 2,
        conduitSpecSetID = 30,
        covenantID = 0,
        conduitItemID = 182307,
    },
    { -- Felfire Haste
        conduitID = 134,
        conduitType = 0,
        conduitSpecSetID = 8,
        covenantID = 0,
        conduitItemID = 182324,
    },
    { -- Ravenous Consumption
        conduitID = 135,
        conduitType = 0,
        conduitSpecSetID = 8,
        covenantID = 0,
        conduitItemID = 182325,
    },
    { -- Enfeebled Mark
        conduitID = 137,
        conduitType = 1,
        conduitSpecSetID = 163,
        covenantID = 1,
        conduitItemID = 182321,
    },
    { -- Demonic Parole
        conduitID = 138,
        conduitType = 0,
        conduitSpecSetID = 8,
        covenantID = 0,
        conduitItemID = 182330,
    },
    { -- Empowered Release
        conduitID = 139,
        conduitType = 1,
        conduitSpecSetID = 163,
        covenantID = 2,
        conduitItemID = 182331,
    },
    { -- Spirit Attunement
        conduitID = 140,
        conduitType = 1,
        conduitSpecSetID = 163,
        covenantID = 3,
        conduitItemID = 182335,
    },
    { -- Golden Path
        conduitID = 141,
        conduitType = 2,
        conduitSpecSetID = 30,
        covenantID = 0,
        conduitItemID = 182336,
    },
    { -- Pure Concentration
        conduitID = 142,
        conduitType = 0,
        conduitSpecSetID = 30,
        covenantID = 0,
        conduitItemID = 182338,
    },
    { -- Necrotic Barrage
        conduitID = 143,
        conduitType = 1,
        conduitSpecSetID = 163,
        covenantID = 4,
        conduitItemID = 182339,
    },
    { -- Fel Celerity
        conduitID = 144,
        conduitType = 0,
        conduitSpecSetID = 167,
        covenantID = 0,
        conduitItemID = 182340,
    },
    { -- Lost in Darkness
        conduitID = 145,
        conduitType = 0,
        conduitSpecSetID = 8,
        covenantID = 0,
        conduitItemID = 182344,
    },
    { -- Elysian Dirge
        conduitID = 146,
        conduitType = 1,
        conduitSpecSetID = 13,
        covenantID = 1,
        conduitItemID = 182345,
    },
    { -- Tumbling Waves
        conduitID = 147,
        conduitType = 1,
        conduitSpecSetID = 13,
        covenantID = 4,
        conduitItemID = 182346,
    },
    { -- Essential Extraction
        conduitID = 148,
        conduitType = 1,
        conduitSpecSetID = 13,
        covenantID = 3,
        conduitItemID = 182347,
    },
    { -- Lavish Harvest
        conduitID = 149,
        conduitType = 1,
        conduitSpecSetID = 13,
        covenantID = 2,
        conduitItemID = 182348,
    },
    { -- Relentless Onslaught
        conduitID = 150,
        conduitType = 1,
        conduitSpecSetID = 9,
        covenantID = 0,
        conduitItemID = 182368,
    },
    { -- Dancing with Fate
        conduitID = 151,
        conduitType = 1,
        conduitSpecSetID = 9,
        covenantID = 0,
        conduitItemID = 182383,
    },
    { -- Serrated Glaive
        conduitID = 152,
        conduitType = 1,
        conduitSpecSetID = 9,
        covenantID = 0,
        conduitItemID = 182384,
    },
    { -- Growing Inferno
        conduitID = 153,
        conduitType = 1,
        conduitSpecSetID = 8,
        covenantID = 0,
        conduitItemID = 182385,
    },
    { -- Piercing Verdict
        conduitID = 154,
        conduitType = 1,
        conduitSpecSetID = 168,
        covenantID = 1,
        conduitItemID = 182440,
    },
    { -- Marksman's Advantage
        conduitID = 157,
        conduitType = 2,
        conduitSpecSetID = 163,
        covenantID = 0,
        conduitItemID = 182441,
    },
    { -- Veteran's Repute
        conduitID = 158,
        conduitType = 1,
        conduitSpecSetID = 168,
        covenantID = 4,
        conduitItemID = 182442,
    },
    { -- Light's Barding
        conduitID = 159,
        conduitType = 0,
        conduitSpecSetID = 30,
        covenantID = 0,
        conduitItemID = 182448,
    },
    { -- Resolute Barrier
        conduitID = 160,
        conduitType = 2,
        conduitSpecSetID = 167,
        covenantID = 0,
        conduitItemID = 182449,
    },
    { -- Wrench Evil
        conduitID = 161,
        conduitType = 0,
        conduitSpecSetID = 30,
        covenantID = 0,
        conduitItemID = 182456,
    },
    { -- Accrued Vitality
        conduitID = 162,
        conduitType = 2,
        conduitSpecSetID = 167,
        covenantID = 0,
        conduitItemID = 182460,
    },
    { -- Echoing Blessings
        conduitID = 163,
        conduitType = 0,
        conduitSpecSetID = 30,
        covenantID = 0,
        conduitItemID = 182461,
    },
    { -- Expurgation
        conduitID = 164,
        conduitType = 1,
        conduitSpecSetID = 29,
        covenantID = 0,
        conduitItemID = 182462,
    },
    { -- Harrowing Punishment
        conduitID = 165,
        conduitType = 1,
        conduitSpecSetID = 168,
        covenantID = 2,
        conduitItemID = 182463,
    },
    { -- Harmony of the Tortollan
        conduitID = 166,
        conduitType = 2,
        conduitSpecSetID = 163,
        covenantID = 0,
        conduitItemID = 182464,
    },
    { -- Truth's Wake
        conduitID = 167,
        conduitType = 1,
        conduitSpecSetID = 29,
        covenantID = 0,
        conduitItemID = 182465,
    },
    { -- Shade of Terror
        conduitID = 168,
        conduitType = 0,
        conduitSpecSetID = 167,
        covenantID = 0,
        conduitItemID = 182466,
    },
    { -- Mortal Combo
        conduitID = 169,
        conduitType = 1,
        conduitSpecSetID = 40,
        covenantID = 0,
        conduitItemID = 182468,
    },
    { -- Rejuvenating Wind
        conduitID = 170,
        conduitType = 2,
        conduitSpecSetID = 163,
        covenantID = 0,
        conduitItemID = 182469,
    },
    { -- Demonic Momentum
        conduitID = 171,
        conduitType = 0,
        conduitSpecSetID = 167,
        covenantID = 0,
        conduitItemID = 182470,
    },
    { -- Soul Furnace
        conduitID = 172,
        conduitType = 1,
        conduitSpecSetID = 10,
        covenantID = 0,
        conduitItemID = 182471,
    },
    { -- Resilience of the Hunter
        conduitID = 173,
        conduitType = 2,
        conduitSpecSetID = 163,
        covenantID = 0,
        conduitItemID = 182476,
    },
    { -- Corrupting Leer
        conduitID = 174,
        conduitType = 1,
        conduitSpecSetID = 37,
        covenantID = 0,
        conduitItemID = 182478,
    },
    { -- Reversal of Fortune
        conduitID = 175,
        conduitType = 0,
        conduitSpecSetID = 163,
        covenantID = 0,
        conduitItemID = 182480,
    },
    { -- Templar's Vindication
        conduitID = 176,
        conduitType = 1,
        conduitSpecSetID = 29,
        covenantID = 0,
        conduitItemID = 182559,
    },
    { -- Enkindled Spirit
        conduitID = 177,
        conduitType = 1,
        conduitSpecSetID = 27,
        covenantID = 0,
        conduitItemID = 182582,
    },
    { -- Cheetah's Vigor
        conduitID = 178,
        conduitType = 0,
        conduitSpecSetID = 163,
        covenantID = 0,
        conduitItemID = 182584,
    },
    { -- Demon Muzzle
        conduitID = 179,
        conduitType = 2,
        conduitSpecSetID = 10,
        covenantID = 0,
        conduitItemID = 182598,
    },
    { -- Roaring Fire
        conduitID = 180,
        conduitType = 2,
        conduitSpecSetID = 10,
        covenantID = 0,
        conduitItemID = 182604,
    },
    { -- Tactical Retreat
        conduitID = 181,
        conduitType = 0,
        conduitSpecSetID = 163,
        covenantID = 0,
        conduitItemID = 182605,
    },
    { -- Virtuous Command
        conduitID = 182,
        conduitType = 1,
        conduitSpecSetID = 29,
        covenantID = 0,
        conduitItemID = 182608,
    },
    { -- Ferocious Appetite
        conduitID = 183,
        conduitType = 1,
        conduitSpecSetID = 44,
        covenantID = 0,
        conduitItemID = 182610,
    },
    { -- Resplendent Light
        conduitID = 184,
        conduitType = 1,
        conduitSpecSetID = 27,
        covenantID = 0,
        conduitItemID = 182622,
    },
    { -- One With the Beast
        conduitID = 185,
        conduitType = 1,
        conduitSpecSetID = 44,
        covenantID = 0,
        conduitItemID = 182621,
    },
    { -- Show of Force
        conduitID = 186,
        conduitType = 1,
        conduitSpecSetID = 42,
        covenantID = 0,
        conduitItemID = 182624,
    },
    { -- Repeat Decree
        conduitID = 187,
        conduitType = 1,
        conduitSpecSetID = 8,
        covenantID = 1,
        conduitItemID = 182646,
    },
    { -- Sharpshooter's Focus
        conduitID = 188,
        conduitType = 1,
        conduitSpecSetID = 14,
        covenantID = 0,
        conduitItemID = 182648,
    },
    { -- Brutal Projectiles
        conduitID = 189,
        conduitType = 1,
        conduitSpecSetID = 14,
        covenantID = 0,
        conduitItemID = 182649,
    },
    { -- Destructive Reverberations
        conduitID = 190,
        conduitType = 1,
        conduitSpecSetID = 168,
        covenantID = 3,
        conduitItemID = 182651,
    },
    { -- Disturb the Peace
        conduitID = 191,
        conduitType = 0,
        conduitSpecSetID = 168,
        covenantID = 0,
        conduitItemID = 182656,
    },
    { -- Deadly Chain
        conduitID = 192,
        conduitType = 1,
        conduitSpecSetID = 14,
        covenantID = 0,
        conduitItemID = 182657,
    },
    { -- Focused Light
        conduitID = 193,
        conduitType = 1,
        conduitSpecSetID = 27,
        covenantID = 0,
        conduitItemID = 182667,
    },
    { -- Untempered Dedication
        conduitID = 194,
        conduitType = 1,
        conduitSpecSetID = 27,
        covenantID = 0,
        conduitItemID = 182675,
    },
    { -- Vengeful Shock
        conduitID = 195,
        conduitType = 1,
        conduitSpecSetID = 28,
        covenantID = 0,
        conduitItemID = 182681,
    },
    { -- Punish the Guilty
        conduitID = 196,
        conduitType = 1,
        conduitSpecSetID = 28,
        covenantID = 0,
        conduitItemID = 182677,
    },
    { -- Resolute Defender
        conduitID = 197,
        conduitType = 2,
        conduitSpecSetID = 28,
        covenantID = 0,
        conduitItemID = 182684,
    },
    { -- Increased Scrutiny
        conduitID = 198,
        conduitType = 1,
        conduitSpecSetID = 8,
        covenantID = 2,
        conduitItemID = 182685,
    },
    { -- Powerful Precision
        conduitID = 199,
        conduitType = 1,
        conduitSpecSetID = 14,
        covenantID = 0,
        conduitItemID = 182686,
    },
    { -- Brooding Pool
        conduitID = 200,
        conduitType = 1,
        conduitSpecSetID = 8,
        covenantID = 4,
        conduitItemID = 182706,
    },
    { -- Rolling Agony
        conduitID = 201,
        conduitType = 1,
        conduitSpecSetID = 37,
        covenantID = 0,
        conduitItemID = 182736,
    },
    { -- Focused Malignancy
        conduitID = 202,
        conduitType = 1,
        conduitSpecSetID = 37,
        covenantID = 0,
        conduitItemID = 182743,
    },
    { -- Withering Bolt
        conduitID = 203,
        conduitType = 1,
        conduitSpecSetID = 37,
        covenantID = 0,
        conduitItemID = 182747,
    },
    { -- Borne of Blood
        conduitID = 204,
        conduitType = 1,
        conduitSpecSetID = 39,
        covenantID = 0,
        conduitItemID = 182748,
    },
    { -- Carnivorous Stalkers
        conduitID = 205,
        conduitType = 1,
        conduitSpecSetID = 39,
        covenantID = 0,
        conduitItemID = 182750,
    },
    { -- Tyrant's Soul
        conduitID = 206,
        conduitType = 1,
        conduitSpecSetID = 39,
        covenantID = 0,
        conduitItemID = 182751,
    },
    { -- Fel Commando
        conduitID = 207,
        conduitType = 1,
        conduitSpecSetID = 39,
        covenantID = 0,
        conduitItemID = 182752,
    },
    { -- Duplicitous Havoc
        conduitID = 208,
        conduitType = 1,
        conduitSpecSetID = 38,
        covenantID = 0,
        conduitItemID = 182754,
    },
    { -- Royal Decree
        conduitID = 209,
        conduitType = 2,
        conduitSpecSetID = 28,
        covenantID = 0,
        conduitItemID = 182753,
    },
    { -- The Long Summer
        conduitID = 210,
        conduitType = 1,
        conduitSpecSetID = 30,
        covenantID = 3,
        conduitItemID = 182767,
    },
    { -- Ashen Remains
        conduitID = 211,
        conduitType = 1,
        conduitSpecSetID = 38,
        covenantID = 0,
        conduitItemID = 182755,
    },
    { -- Combusting Engine
        conduitID = 212,
        conduitType = 1,
        conduitSpecSetID = 38,
        covenantID = 0,
        conduitItemID = 182769,
    },
    { -- Righteous Might
        conduitID = 213,
        conduitType = 1,
        conduitSpecSetID = 30,
        covenantID = 4,
        conduitItemID = 182770,
    },
    { -- Infernal Brand
        conduitID = 214,
        conduitType = 1,
        conduitSpecSetID = 38,
        covenantID = 0,
        conduitItemID = 182772,
    },
    { -- Hallowed Discernment
        conduitID = 215,
        conduitType = 1,
        conduitSpecSetID = 30,
        covenantID = 2,
        conduitItemID = 182777,
    },
    { -- Ringing Clarity
        conduitID = 216,
        conduitType = 1,
        conduitSpecSetID = 30,
        covenantID = 1,
        conduitItemID = 182778,
    },
    { -- Soul Tithe
        conduitID = 217,
        conduitType = 1,
        conduitSpecSetID = 167,
        covenantID = 1,
        conduitItemID = 182960,
    },
    { -- Fatal Decimation
        conduitID = 218,
        conduitType = 1,
        conduitSpecSetID = 167,
        covenantID = 4,
        conduitItemID = 182961,
    },
    { -- Catastrophic Origin
        conduitID = 219,
        conduitType = 1,
        conduitSpecSetID = 167,
        covenantID = 2,
        conduitItemID = 182962,
    },
    { -- Soul Eater
        conduitID = 220,
        conduitType = 1,
        conduitSpecSetID = 167,
        covenantID = 3,
        conduitItemID = 182964,
    },
    { -- Kilrogg's Cunning
        conduitID = 221,
        conduitType = 0,
        conduitSpecSetID = 167,
        covenantID = 0,
        conduitItemID = 183044,
    },
    { -- Diabolic Bloodstone
        conduitID = 222,
        conduitType = 2,
        conduitSpecSetID = 167,
        covenantID = 0,
        conduitItemID = 183076,
    },
    { -- Echoing Call
        conduitID = 223,
        conduitType = 1,
        conduitSpecSetID = 44,
        covenantID = 0,
        conduitItemID = 183132,
    },
    { -- Strength of the Pack
        conduitID = 224,
        conduitType = 1,
        conduitSpecSetID = 20,
        covenantID = 0,
        conduitItemID = 183167,
    },
    { -- Reverberation
        conduitID = 225,
        conduitType = 1,
        conduitSpecSetID = 165,
        covenantID = 1,
        conduitItemID = 183492,
    },
    { -- Stinging Strike
        conduitID = 226,
        conduitType = 1,
        conduitSpecSetID = 20,
        covenantID = 0,
        conduitItemID = 183184,
    },
    { -- Sudden Fractures
        conduitID = 227,
        conduitType = 1,
        conduitSpecSetID = 165,
        covenantID = 4,
        conduitItemID = 183493,
    },
    { -- Septic Shock
        conduitID = 228,
        conduitType = 1,
        conduitSpecSetID = 165,
        covenantID = 3,
        conduitItemID = 183494,
    },
    { -- Lashing Scars
        conduitID = 229,
        conduitType = 1,
        conduitSpecSetID = 165,
        covenantID = 2,
        conduitItemID = 183495,
    },
    { -- Nimble Fingers
        conduitID = 230,
        conduitType = 2,
        conduitSpecSetID = 165,
        covenantID = 0,
        conduitItemID = 183496,
    },
    { -- Recuperator
        conduitID = 231,
        conduitType = 2,
        conduitSpecSetID = 165,
        covenantID = 0,
        conduitItemID = 183497,
    },
    { -- Cloaked in Shadows
        conduitID = 232,
        conduitType = 2,
        conduitSpecSetID = 165,
        covenantID = 0,
        conduitItemID = 183498,
    },
    { -- Quick Decisions
        conduitID = 233,
        conduitType = 0,
        conduitSpecSetID = 165,
        covenantID = 0,
        conduitItemID = 183499,
    },
    { -- Fade to Nothing
        conduitID = 234,
        conduitType = 0,
        conduitSpecSetID = 165,
        covenantID = 0,
        conduitItemID = 183500,
    },
    { -- Rushed Setup
        conduitID = 235,
        conduitType = 0,
        conduitSpecSetID = 165,
        covenantID = 0,
        conduitItemID = 183501,
    },
    { -- Prepared for All
        conduitID = 236,
        conduitType = 0,
        conduitSpecSetID = 165,
        covenantID = 0,
        conduitItemID = 183502,
    },
    { -- Poisoned Katar
        conduitID = 237,
        conduitType = 1,
        conduitSpecSetID = 34,
        covenantID = 0,
        conduitItemID = 183503,
    },
    { -- Well-Placed Steel
        conduitID = 238,
        conduitType = 1,
        conduitSpecSetID = 34,
        covenantID = 0,
        conduitItemID = 183504,
    },
    { -- Maim, Mangle
        conduitID = 239,
        conduitType = 1,
        conduitSpecSetID = 34,
        covenantID = 0,
        conduitItemID = 183505,
    },
    { -- Lethal Poisons
        conduitID = 240,
        conduitType = 1,
        conduitSpecSetID = 34,
        covenantID = 0,
        conduitItemID = 183506,
    },
    { -- Triple Threat
        conduitID = 241,
        conduitType = 1,
        conduitSpecSetID = 35,
        covenantID = 0,
        conduitItemID = 183507,
    },
    { -- Ambidexterity
        conduitID = 242,
        conduitType = 1,
        conduitSpecSetID = 35,
        covenantID = 0,
        conduitItemID = 183508,
    },
    { -- Sleight of Hand
        conduitID = 243,
        conduitType = 1,
        conduitSpecSetID = 35,
        covenantID = 0,
        conduitItemID = 183509,
    },
    { -- Count the Odds
        conduitID = 244,
        conduitType = 1,
        conduitSpecSetID = 35,
        covenantID = 0,
        conduitItemID = 183510,
    },
    { -- Deeper Daggers
        conduitID = 245,
        conduitType = 1,
        conduitSpecSetID = 36,
        covenantID = 0,
        conduitItemID = 183511,
    },
    { -- Planned Execution
        conduitID = 246,
        conduitType = 1,
        conduitSpecSetID = 36,
        covenantID = 0,
        conduitItemID = 183512,
    },
    { -- Stiletto Staccato
        conduitID = 247,
        conduitType = 1,
        conduitSpecSetID = 36,
        covenantID = 0,
        conduitItemID = 183513,
    },
    { -- Perforated Veins
        conduitID = 248,
        conduitType = 1,
        conduitSpecSetID = 36,
        covenantID = 0,
        conduitItemID = 183514,
    },
    { -- Controlled Destruction
        conduitID = 249,
        conduitType = 1,
        conduitSpecSetID = 23,
        covenantID = 0,
        conduitItemID = 183197,
    },
    { -- Withering Ground
        conduitID = 250,
        conduitType = 1,
        conduitSpecSetID = 43,
        covenantID = 3,
        conduitItemID = 183199,
    },
    { -- Deadly Tandem
        conduitID = 251,
        conduitType = 1,
        conduitSpecSetID = 20,
        covenantID = 0,
        conduitItemID = 183202,
    },
    { -- Flame Infusion
        conduitID = 252,
        conduitType = 1,
        conduitSpecSetID = 20,
        covenantID = 0,
        conduitItemID = 183396,
    },
    { -- Bloodletting
        conduitID = 253,
        conduitType = 1,
        conduitSpecSetID = 44,
        covenantID = 0,
        conduitItemID = 183402,
    },
    { -- Tough as Bark
        conduitID = 254,
        conduitType = 2,
        conduitSpecSetID = 48,
        covenantID = 0,
        conduitItemID = 183464,
    },
    { -- Ursine Vigor
        conduitID = 255,
        conduitType = 2,
        conduitSpecSetID = 48,
        covenantID = 0,
        conduitItemID = 183465,
    },
    { -- Innate Resolve
        conduitID = 256,
        conduitType = 2,
        conduitSpecSetID = 48,
        covenantID = 0,
        conduitItemID = 183466,
    },
    { -- Tireless Pursuit
        conduitID = 257,
        conduitType = 0,
        conduitSpecSetID = 48,
        covenantID = 0,
        conduitItemID = 183467,
    },
    { -- Born Anew
        conduitID = 258,
        conduitType = 0,
        conduitSpecSetID = 48,
        covenantID = 0,
        conduitItemID = 183468,
    },
    { -- Front of the Pack
        conduitID = 259,
        conduitType = 0,
        conduitSpecSetID = 48,
        covenantID = 0,
        conduitItemID = 183469,
    },
    { -- Born of the Wilds
        conduitID = 260,
        conduitType = 0,
        conduitSpecSetID = 48,
        covenantID = 0,
        conduitItemID = 183470,
    },
    { -- Stellar Inspiration
        conduitID = 261,
        conduitType = 1,
        conduitSpecSetID = 15,
        covenantID = 0,
        conduitItemID = 183476,
    },
    { -- Precise Alignment
        conduitID = 262,
        conduitType = 1,
        conduitSpecSetID = 15,
        covenantID = 0,
        conduitItemID = 183477,
    },
    { -- Fury of the Skies
        conduitID = 263,
        conduitType = 1,
        conduitSpecSetID = 15,
        covenantID = 0,
        conduitItemID = 183478,
    },
    { -- Umbral Intensity
        conduitID = 264,
        conduitType = 1,
        conduitSpecSetID = 15,
        covenantID = 0,
        conduitItemID = 183479,
    },
    { -- Taste for Blood
        conduitID = 265,
        conduitType = 1,
        conduitSpecSetID = 16,
        covenantID = 0,
        conduitItemID = 183480,
    },
    { -- Incessant Hunter
        conduitID = 266,
        conduitType = 1,
        conduitSpecSetID = 16,
        covenantID = 0,
        conduitItemID = 183481,
    },
    { -- Sudden Ambush
        conduitID = 267,
        conduitType = 1,
        conduitSpecSetID = 16,
        covenantID = 0,
        conduitItemID = 183482,
    },
    { -- Carnivorous Instinct
        conduitID = 268,
        conduitType = 1,
        conduitSpecSetID = 16,
        covenantID = 0,
        conduitItemID = 183483,
    },
    { -- Unchecked Aggression
        conduitID = 269,
        conduitType = 1,
        conduitSpecSetID = 17,
        covenantID = 0,
        conduitItemID = 183484,
    },
    { -- Savage Combatant
        conduitID = 270,
        conduitType = 1,
        conduitSpecSetID = 17,
        covenantID = 0,
        conduitItemID = 183485,
    },
    { -- Well-Honed Instincts
        conduitID = 271,
        conduitType = 2,
        conduitSpecSetID = 48,
        covenantID = 0,
        conduitItemID = 183486,
    },
    { -- Layered Mane
        conduitID = 272,
        conduitType = 2,
        conduitSpecSetID = 17,
        covenantID = 0,
        conduitItemID = 183487,
    },
    { -- Unstoppable Growth
        conduitID = 273,
        conduitType = 1,
        conduitSpecSetID = 18,
        covenantID = 0,
        conduitItemID = 183488,
    },
    { -- Flash of Clarity
        conduitID = 274,
        conduitType = 1,
        conduitSpecSetID = 18,
        covenantID = 0,
        conduitItemID = 183489,
    },
    { -- Floral Recycling
        conduitID = 275,
        conduitType = 1,
        conduitSpecSetID = 18,
        covenantID = 0,
        conduitItemID = 183490,
    },
    { -- Ready for Anything
        conduitID = 276,
        conduitType = 1,
        conduitSpecSetID = 18,
        covenantID = 0,
        conduitItemID = 183491,
    },
    { -- Deep Allegiance
        conduitID = 277,
        conduitType = 1,
        conduitSpecSetID = 48,
        covenantID = 1,
        conduitItemID = 183471,
    },
    { -- Evolved Swarm
        conduitID = 278,
        conduitType = 1,
        conduitSpecSetID = 48,
        covenantID = 4,
        conduitItemID = 183472,
    },
    { -- Conflux of Elements
        conduitID = 279,
        conduitType = 1,
        conduitSpecSetID = 48,
        covenantID = 3,
        conduitItemID = 183473,
    },
    { -- Endless Thirst
        conduitID = 280,
        conduitType = 1,
        conduitSpecSetID = 48,
        covenantID = 2,
        conduitItemID = 183474,
    },
    { -- Unnatural Malice
        conduitID = 281,
        conduitType = 1,
        conduitSpecSetID = 8,
        covenantID = 3,
        conduitItemID = 183463,
    },
    { -- Ambuscade
        conduitID = 282,
        conduitType = 0,
        conduitSpecSetID = 163,
        covenantID = 0,
        conduitItemID = 184587,
    },
    { -- Condensed Anima Sphere
        conduitID = 283,
        conduitType = 2,
        conduitSpecSetID = 2,
        covenantID = 0,
        conduitItemID = 187506,
    },
    { -- Adaptive Armor Fragment
        conduitID = 284,
        conduitType = 1,
        conduitSpecSetID = 1,
        covenantID = 0,
        conduitItemID = 187507,
    },
}
local conduitsByID = {}
local conduitsByItemID = {}
for _,conduit in ipairs(conduits) do
    conduit.conduitRank = 11
    conduit.conduitItemLevel = 278
    
    local specIDs = C_SpecializationInfo.GetSpecIDs(conduit.conduitSpecSetID)
    if #specIDs == 1 then
        conduit.conduitSpecName = select(2, GetSpecializationInfoByID(specIDs[1]))
    end

    conduitsByID[conduit.conduitID] = conduit
    conduitsByItemID[conduit.conduitItemID] = conduit
end

local function GetConduitByID(itemID)
    return conduitsByID[itemID]
end
local function GetConduitByItemID(itemID)
    return conduitsByItemID[itemID]
end
local function CheckConduitCovenant(conduitData, covenantID)
    return conduitData.covenantID == 0 or conduitData.covenantID == covenantID
end
local function CheckConduitClass(conduitData, classID)
    local specIDs = C_SpecializationInfo.GetSpecIDs(conduitData.conduitSpecSetID)

    if conduitData.conduitID == 284 then -- Tank only conduit
        local classInfo = C_CreatureInfo.GetClassInfo(classID)
        for _,specID in ipairs(specIDs) do
            local classFile = select(6, GetSpecializationInfoByID(specID))
            if classInfo.classFile == classFile then
                conduitData.conduitSpecName = select(2, GetSpecializationInfoByID(specID))
                return true
            end
        end
        return false
    end

    if #specIDs == 0 or #specIDs > 4 then
        return true
    end
    local classInfo = C_CreatureInfo.GetClassInfo(classID)
    local classFile = select(6, GetSpecializationInfoByID(specIDs[1]))
    return classInfo.classFile == classFile
end

local function GetConduitCollection(classID, covenantID, conduitType)
    local results = {}
    if classID ~= nil then
        for _,conduit in ipairs(conduits) do
            if conduit.conduitType == conduitType and CheckConduitCovenant(conduit, covenantID) and CheckConduitClass(conduit, classID) then
                results[#results+1] = conduit
            end
        end
    end
    return results
end


local ConduitTypeCollapsed = {}

BtWLoadoutsConduitListCategoryButtonMixin = {};
function BtWLoadoutsConduitListCategoryButtonMixin:Init(conduitType, collapsed)
	local name = self.Container.Name;
	name:SetText(GetConduitName(conduitType));
	name:SetWidth(name:GetStringWidth() + 40);

	local icon = self.Container.ConduitIcon;
	icon:SetAtlas(GetConduitEmblemAtlas(conduitType));
	icon:SetScale(GetConduitIconScale(conduitType));
	icon:SetPoint("LEFT", name, "RIGHT", -40, -1);

	self.collapsed = collapsed;
	self:SetCollapsedVisuals(collapsed);
end
function BtWLoadoutsConduitListCategoryButtonMixin:OnEnter()
	for index, texture in ipairs(self.Container.Hovers) do
		texture:Show();
	end
end
function BtWLoadoutsConduitListCategoryButtonMixin:OnLeave()
	for index, texture in ipairs(self.Container.Hovers) do
		texture:Hide();
	end
	GameTooltip_Hide();
end
function BtWLoadoutsConduitListCategoryButtonMixin:OnMouseDown()
	self.Container:AdjustPointsOffset(1, -1);
end
function BtWLoadoutsConduitListCategoryButtonMixin:OnMouseUp()
	self.Container:AdjustPointsOffset(-1, 1);
end
function BtWLoadoutsConduitListCategoryButtonMixin:SetCollapsedVisuals(collapsed)
	if collapsed then
		self.Container.ExpandableIcon:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand", TextureKitConstants.UseAtlasSize);
	else
		self.Container.ExpandableIcon:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse", TextureKitConstants.UseAtlasSize);
	end
end
function BtWLoadoutsConduitListCategoryButtonMixin:SetCollapsed(collapsed)
	local changed = self.collapsed ~= collapsed;
	if not changed then
		return;
	end
	self.collapsed = collapsed;

    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);

	self:SetCollapsedVisuals(collapsed);
end

BtWLoadoutsConduitListConduitButtonMixin = {};
BtWLoadoutsConduitListConduitButtonMixin.State = {
	Uninstalled = 1,
	Installed = 2,
	Pending = 3,
}
function BtWLoadoutsConduitListConduitButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end
function BtWLoadoutsConduitListConduitButtonMixin:Init(owner, conduitData)
    self.owner = owner
	self.conduitData = conduitData;

	local itemID = conduitData.conduitItemID;
	local item = Item:CreateFromItemID(itemID);
	local itemCallback = function()
		self.ConduitName:SetSize(150, 30);
		self.ConduitName:SetText(item:GetItemName());
		self.ConduitName:SetHeight(self.ConduitName:GetStringHeight());
		
		local yOffset = self.ConduitName:GetNumLines() > 1 and -6 or 0;
		self.ConduitName:ClearAllPoints();
		self.ConduitName:SetPoint("BOTTOMLEFT", self.Icon, "RIGHT", 10, yOffset);
		self.ConduitName:SetWidth(150);

		self.ItemLevel:SetPoint("TOPLEFT", self.ConduitName, "BOTTOMLEFT", 0, 0);
		self.ItemLevel:SetText(conduitData.conduitItemLevel);
	end;
	item:ContinueOnItemLoad(itemCallback);

	local icon = item:GetItemIcon();
	self.Icon:SetTexture(icon);
	self.Icon2:SetTexture(icon);
	self.IconPulse:SetTexture(icon);

	local conduitQuality = C_Soulbinds.GetConduitQuality(conduitData.conduitID, conduitData.conduitRank);
	local color = ITEM_QUALITY_COLORS[conduitQuality];
	local r, g, b = color.r, color.g, color.b;
	self.IconOverlay:SetVertexColor(r, g, b);
	self.IconOverlay2:SetVertexColor(r, g, b);
	self.IconOverlayDark:SetVertexColor(0, 0, 0);
	self.ConduitName:SetTextColor(r, g, b);

	local conduitSpecName = conduitData.conduitSpecName;
	if conduitSpecName then
		local specIDs = C_SpecializationInfo.GetSpecIDs(conduitData.conduitSpecSetID);
		self.Spec.Icon:SetTexture(select(4, GetSpecializationInfoByID(specIDs[1])));

		self.Spec:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.Spec, "ANCHOR_RIGHT");
			GameTooltip_AddHighlightLine(GameTooltip, conduitSpecName);
			GameTooltip:Show();
		end);
		self.Spec:SetScript("OnLeave", function()
			GameTooltip_Hide();
		end);
		self.Spec:Show();
	else
		self.Spec:Hide();
		self.Spec:SetScript("OnEnter", nil);
		self.Spec:SetScript("OnLeave", nil);
	end

	self:Update();
end
function BtWLoadoutsConduitListConduitButtonMixin:OnEvent(event, ...)
	if event == "CURSOR_CHANGED" then
        local cursorType, itemID = GetCursorInfo()
        local pending = cursorType == "item" and itemID == self.conduitData.conduitItemID;
        self.PendingBackground:SetShown(pending);
	end
end
function BtWLoadoutsConduitListConduitButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, {
        "CURSOR_CHANGED",
    });
end
function BtWLoadoutsConduitListConduitButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, {
        "CURSOR_CHANGED",
    });
end
function BtWLoadoutsConduitListConduitButtonMixin:MatchesID(conduitID)
	return self.conduitData.conduitID == conduitID;
end
function BtWLoadoutsConduitListConduitButtonMixin:UpdateVisuals(state)
	local installed = state == BtWLoadoutsConduitListConduitButtonMixin.State.Installed;
	local pending = state == BtWLoadoutsConduitListConduitButtonMixin.State.Pending;
	local dark = installed or pending;
	self.ConduitName:SetAlpha(dark and .5 or 1);
	self.ItemLevel:SetAlpha(dark and .2 or 1);
	self.IconOverlayDark:SetShown(dark);
	self.IconDark:SetShown(dark);
	
	self.Pending:SetShown(pending);
end
function BtWLoadoutsConduitListConduitButtonMixin:Update()
	self:UpdateVisuals(self:GetState());
end
function BtWLoadoutsConduitListConduitButtonMixin:GetState()
    if self.owner and self.conduitData then
        local installed = self.owner:IsConduitSlotted(self.conduitData.conduitID)
        if installed then
            return BtWLoadoutsConduitListConduitButtonMixin.State.Installed;
        end
    end

	-- local soulbindID = Soulbinds.GetOpenSoulbindID();
	-- local conduitID = self.conduitData.conduitID;
	
	-- local pendingInstallNodeID = C_Soulbinds.FindNodeIDPendingInstall(soulbindID, conduitID);
	-- if pendingInstallNodeID > 0 then
	-- 	return BtWLoadoutsConduitListConduitButtonMixin.State.Pending;
	-- end

	-- local pendingUninstallNodeID = C_Soulbinds.FindNodeIDPendingUninstall(soulbindID, conduitID);
	-- if pendingUninstallNodeID > 0 then
	-- 	return BtWLoadoutsConduitListConduitButtonMixin.State.Uninstalled;
	-- end

	-- local installed = C_Soulbinds.IsConduitInstalledInSoulbind(soulbindID, conduitID);
	-- if installed then
	-- 	return BtWLoadoutsConduitListConduitButtonMixin.State.Installed;
	-- end

	return BtWLoadoutsConduitListConduitButtonMixin.State.Uninstalled;
end
function BtWLoadoutsConduitListConduitButtonMixin:OnClick(buttonName)
	if buttonName == "LeftButton" then
		local linked = false;
		if IsModifiedClick("CHATLINK") then
            local link = C_Soulbinds.GetConduitHyperlink(self.conduitData.conduitID, self.conduitData.conduitRank);
			linked = HandleModifiedItemClick(link);
		end

		if not linked then
			self:CreateCursor();
		end
	elseif buttonName == "RightButton" then
		--@TODO highlight conduit within tree?
	end
end
function BtWLoadoutsConduitListConduitButtonMixin:OnDragStart()
	self:CreateCursor();
end
function BtWLoadoutsConduitListConduitButtonMixin:CreateCursor()
	SetCursorVirtualItem(self.conduitData.conduitItemID, Enum.UICursorType.ConduitCollectionItem);
end
function BtWLoadoutsConduitListConduitButtonMixin:OnEnter()
	for index, texture in ipairs(self.Hovers) do
		texture:Show();
	end
    
    GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 178, 0);
    if IsModifiedClick("SHIFT") then
        GameTooltip:SetEnhancedConduit(self.conduitData.conduitID, self.conduitData.conduitRank);
    else
        GameTooltip:SetConduit(self.conduitData.conduitID, self.conduitData.conduitRank);
    end
    GameTooltip:Show();
end
function BtWLoadoutsConduitListConduitButtonMixin:OnLeave()
	if self.conduitOnSpellLoadCb then
		self.conduitOnSpellLoadCb();
		self.conduitOnSpellLoadCb = nil;
	end

	GameTooltip_Hide();

	for index, texture in ipairs(self.Hovers) do
		texture:Hide();
	end
end

BtWLoadoutsConduitListSectionMixin = {}
function BtWLoadoutsConduitListSectionMixin:OnLoad()
	self.CategoryButton:SetScript("OnClick", function(button, buttonName, down)
		local newCollapsed = self.Container:IsShown();
		self:GetElementData().collapsed = newCollapsed;
		self:SetCollapsed(newCollapsed);
	end);

	self.pool = CreateFramePool("BUTTON", self.Container, "BtWLoadoutsConduitListConduitButtonTemplate");
end
function BtWLoadoutsConduitListSectionMixin:Init(owner, elementData)
	self.pool:ReleaseAll();

    self.owner = owner

	local conduitDatas = CopyTable(elementData.conduitDatas);
	self.conduitType = elementData.conduitType;

	local frames = {};
	local count = #conduitDatas;
	local function FactoryFunction(index)
		if index > count then
			return nil;
		end

		local frame = self.pool:Acquire();
		table.insert(frames, frame);
		frame:SetPoint("LEFT", self.Container, "LEFT", 0, 0);
		frame:SetPoint("RIGHT", self.Container, "RIGHT", 0, 0);
		frame:Show();
		return frame;
	end

	local direction, stride, x, y, paddingX, paddingY = GridLayoutMixin.Direction.TopLeftToBottomRight, 1, 0, 1, 0, 0;
	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.Container, "TOPLEFT");
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
	AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, count, anchor, layout);
	
	self.CategoryButton:Init(self.conduitType, elementData.collapsed);

	self:SetCollapsed(elementData.collapsed);

	if self.currentContinuable then
		self.currentContinuable:Cancel();
	end
	self.currentContinuable = ContinuableContainer:Create();

	for index, conduitData in ipairs(conduitDatas) do
		if not conduitData.conduitSpecName then
			conduitData.sortingCategory = 1;
		else
			conduitData.sortingCategory = 2;
		end

		conduitData.item = Item:CreateFromItemID(conduitData.conduitItemID);
		self.currentContinuable:AddContinuable(conduitData.item);
	end
	
	self.currentContinuable:ContinueOnLoad(function()
		local sorter = function(lhs, rhs)
			if lhs.sortingCategory == rhs.sortingCategory then
				if (not lhs.conduitSpecName or not rhs.conduitSpecName) or lhs.conduitSpecName == rhs.conduitSpecName then
					if lhs.conduitRank ~= rhs.conduitRank then
						return lhs.conduitRank > rhs.conduitRank;
					end
					return lhs.item:GetItemName() < rhs.item:GetItemName();
				else
					return lhs.conduitSpecName < rhs.conduitSpecName;
				end
			else
				return lhs.sortingCategory < rhs.sortingCategory;
			end
		end;
		table.sort(conduitDatas, sorter);

		for index, conduitData in ipairs(conduitDatas) do
			frames[index]:Init(self.owner, conduitData);
		end
		
		local newConduitData = elementData.newConduitData;
		if newConduitData then
			elementData.newConduitData = nil;
			self:PlayUpdateAnim(newConduitData);
		end
	end);
end
function BtWLoadoutsConduitListSectionMixin:Update()
	for conduitButton in self.pool:EnumerateActive() do
		conduitButton:Update();
	end
end
function BtWLoadoutsConduitListSectionMixin:FindConduitButton(conduitID)
	for conduitButton in self.pool:EnumerateActive() do
		if conduitButton:MatchesID(conduitID) then
			return conduitButton;
		end
	end
end
function BtWLoadoutsConduitListSectionMixin:IsCollapsed()
	return self:GetElementData().collapsed;
end
function BtWLoadoutsConduitListSectionMixin:SetCollapsed(collapsed)
    ConduitTypeCollapsed[self.conduitType] = collapsed
	self.CategoryButton:SetCollapsed(collapsed);

	local shown = not collapsed;
	self.Container:SetShown(shown);
	self.Spacer:SetShown(shown);
	self:Layout();
end

BtWLoadoutsConduitListMixin = {}
function BtWLoadoutsConduitListMixin:OnLoad()
	local buttonHeight = 42;
	local topSpacer = 10;
	local bottomSpacer = 5;
	local catButtonExtent = 23;
	local containerOffset = 5;
	local expandedExtent = catButtonExtent + topSpacer + bottomSpacer + containerOffset;
	local collapsedExtent = catButtonExtent + topSpacer;

	local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if elementData.collapsed then
			return collapsedExtent;
		else
			return (#elementData.conduitDatas * buttonHeight) + expandedExtent;
		end
	end);
    if Internal.IsDragonflightOrBeyond then
        view:SetElementInitializer("BtWLoadoutsConduitListSectionTemplate", function(list, elementData)
            list:Init(self.owner, elementData);
        end);
    else
        view:SetElementInitializer("EventFrame", "BtWLoadoutsConduitListSectionTemplate", function(list, elementData)
            list:Init(self.owner, elementData);
        end);
    end

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	ScrollUtil.AddResizableChildrenBehavior(self.ScrollBox);
end
function BtWLoadoutsConduitListMixin:Init(owner, classID, covenantID)
    if self.classID == classID and self.covenantID == covenantID then
        return
    end

    self.owner = owner
    self.classID = classID
    self.covenantID = covenantID

	local conduitTypes = {
		Enum.SoulbindConduitType.Endurance,
		Enum.SoulbindConduitType.Finesse,
		Enum.SoulbindConduitType.Potency,
	};

	local listDatas = {};
	for i, conduitType in ipairs(conduitTypes) do
		local conduitDatas = GetConduitCollection(classID, covenantID, conduitType);
		if #conduitDatas > 0 then
			table.insert(listDatas, {conduitDatas = conduitDatas, conduitType = conduitType, collapsed = ConduitTypeCollapsed[conduitType]});
		end
	end

	local dataProvider = CreateDataProvider(listDatas);
	self.ScrollBox:SetDataProvider(dataProvider);
end
function BtWLoadoutsConduitListMixin:Update()
	self.ScrollBox:ForEachFrame(function(list)
		list:Update();
	end);
end

BtWLoadoutsSoulbindNodeMixin = {}
function BtWLoadoutsSoulbindNodeMixin:Init(owner, node)
    self.owner = owner
    self.node = node
    self.Icon:SetTexture(node.icon)

    if node.conduitType ~= nil then
        local atlas = GetConduitEmblemAtlas(node.conduitType);

        self.Emblem:Show()
        self.EmblemBg:Show()
        self.Emblem:SetAtlas(atlas);
        self.EmblemBg:SetAtlas(atlas)
        self.EmblemBg:SetVertexColor(0, 0, 0);

		self.Icon:Hide();
		self.Ring:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
    else
        self.Emblem:Hide()
        self.EmblemBg:Hide()
		self.Icon:Show();
		self.Ring:SetAtlas("Soulbinds_Tree_Ring", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Ring", false);
	end
end
function BtWLoadoutsSoulbindNodeMixin:SetSelected(selected)
    if not selected then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Show();
		self.Ring:SetDesaturated(true);
		self.MouseOverlay:SetDesaturated(true);
	else
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Hide();
		self.Ring:SetDesaturated(false);
		self.MouseOverlay:SetDesaturated(false);
	end
end
function BtWLoadoutsSoulbindNodeMixin:SetConduit(conduitID)
    if conduitID and conduitID ~= 0 then
        local conduit = GetConduitByID(conduitID)
        
        local spellID = C_Soulbinds.GetConduitSpellID(conduit.conduitID, conduit.conduitRank)
        self.Icon:SetTexture(GetSpellTexture(spellID))
        self.Icon:Show()
        
        self.conduit = conduit
    else
        self.Icon:SetShown(self.node.conduitType == nil)

        self.conduit = nil
    end
end
function BtWLoadoutsSoulbindNodeMixin:OnClick(button)
    local node = self.node

    if node.conduitType ~= nil then
        local cursorType, itemID = GetCursorInfo()
        local conduit = cursorType == "item" and GetConduitByItemID(itemID)
        if conduit then
            if conduit.conduitType == node.conduitType then
                if self.owner:SetNodeConduit(node.ID, conduit.conduitID) then
                    ClearCursor()
                end
                -- self:SetConduit(node.ID)
            end
            return
        end
    end
    if button == "LeftButton" then
        self.owner:ToggleNode(node.ID)
    else
        if node.conduitType ~= nil then
            self.owner:SetNodeConduit(node.ID, nil)
            -- self:SetConduit(nil)
        end
    end
end
function BtWLoadoutsSoulbindNodeMixin:OnEnter()
	self.MouseOverlay:Show();
    if self.node.spellID ~= 0 then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetSpellByID(self.node.spellID);
        GameTooltip:Show();
    elseif self.conduit then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        if IsModifiedClick("SHIFT") then
            GameTooltip:SetEnhancedConduit(self.conduit.conduitID, self.conduit.conduitRank);
        else
            GameTooltip:SetConduit(self.conduit.conduitID, self.conduit.conduitRank);
        end
        GameTooltip:Show();
    end
end
function BtWLoadoutsSoulbindNodeMixin:OnLeave()
	self.MouseOverlay:Hide();
    GameTooltip:Hide();
end

local SoulbindTreeLinkDirections = {
	Vertical = 1,
	Converge = 2,
	Diverge = 3,
};

BtWLoadoutsSoulbindTreeNodeLinkMixin = {}
function BtWLoadoutsSoulbindTreeNodeLinkMixin:Init(direction, angle)
	if direction == SoulbindTreeLinkDirections.Vertical then
		self.Background:SetAtlas("Soulbinds_Tree_Connector_Vertical", true);
		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Vertical_Mask", true);
	elseif direction == SoulbindTreeLinkDirections.Converge then
		self.Background:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Close", true);
		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Close_Mask", true);
	elseif direction == SoulbindTreeLinkDirections.Diverge then
		self.Background:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Far", true);
		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Far_Mask", true);
	end

	self:RotateTextures(angle);
end
function BtWLoadoutsSoulbindTreeNodeLinkMixin:OnHide()
	self.FlowAnim1:Stop();
	self.FlowAnim2:Stop();
	self.FlowAnim3:Stop();
	self.FlowAnim4:Stop();
	self.FlowAnim5:Stop();
	self.FlowAnim6:Stop();
end
function BtWLoadoutsSoulbindTreeNodeLinkMixin:Reset()
	self:SetState(Enum.SoulbindNodeState.Unselected);
end
function BtWLoadoutsSoulbindTreeNodeLinkMixin:SetState(state)
	self.state = state;

	if state == Enum.SoulbindNodeState.Unselected or state == Enum.SoulbindNodeState.Unavailable then
		self:DesaturateHierarchy(1);
		for _, foreground in ipairs(self.foregrounds) do
			foreground:SetShown(false);
		end
		self.FlowAnim1:Stop();
		self.FlowAnim2:Stop();
		self.FlowAnim3:Stop();
		self.FlowAnim4:Stop();
		self.FlowAnim5:Stop();
		self.FlowAnim6:Stop();
	elseif state == Enum.SoulbindNodeState.Selectable then
		self:DesaturateHierarchy(0);
		for _, foreground in ipairs(self.foregrounds) do
			foreground:SetShown(true);
			foreground:SetVertexColor(.3, .3, .3);
		end
		self.FlowAnim1:Play();
		self.FlowAnim2:Play();
		self.FlowAnim3:Play();
		self.FlowAnim4:Play();
		self.FlowAnim5:Play();
		self.FlowAnim6:Play();
	elseif state == Enum.SoulbindNodeState.Selected then
		self:DesaturateHierarchy(0);
		for _, foreground in ipairs(self.foregrounds) do
			foreground:SetShown(true);
			foreground:SetVertexColor(.192, .686, .941);
		end
		self.FlowAnim1:Play();
		self.FlowAnim2:Play();
		self.FlowAnim3:Play();
		self.FlowAnim4:Play();
		self.FlowAnim5:Play();
		self.FlowAnim6:Play();
	end
end
function BtWLoadoutsSoulbindTreeNodeLinkMixin:GetState()
	return self.state;
end

BtWLoadoutsSoulbindsMixin = {}
function BtWLoadoutsSoulbindsMixin:OnLoad()
    self.RestrictionsDropDown:SetSupportedTypes("spec", "race")
    self.RestrictionsDropDown:SetScript("OnChange", function ()
        Internal.Call("SoulbindSetUpdated", self.set.setID);
        self:Update()
    end)

    self.temp = {}
    self.tempConduits = {} -- Conduits for different classes for currently selected soulbind
    self.nodes = CreateFramePool("BUTTON", self.Scroll:GetScrollChild(), "BtWLoadoutsSoulbindNodeTemplate");
    self.links = CreateFramePool("FRAME", self.Scroll, "BtWLoadoutsSoulbindTreeNodeLinkTemplate");
    self.nodesByID = {}
end
function BtWLoadoutsSoulbindsMixin:OnShow()
    if not self.initialized then
        UIDropDownMenu_SetWidth(self.SoulbindDropDown, 170);
        UIDropDownMenu_JustifyText(self.SoulbindDropDown, "LEFT");

        self.SoulbindDropDown.GetValue = function ()
            if self.set then
                return self.set.soulbindID
            end
        end
        self.SoulbindDropDown.SetValue = function (_, _, arg1)
            CloseDropDownMenus();

            local set = self.set;
            if set then
                local soulbindID = set.soulbindID
                local classID = set.classID

                local temp = self.temp;
                local tempConduits = self.tempConduits

                if classID then
                    if tempConduits[classID] then
                        wipe(tempConduits[classID]);
                    else
                        tempConduits[classID] = {};
                    end
                    for nodeID,conduitID in pairs(set.conduits) do
                        tempConduits[classID][nodeID] = conduitID
                    end
                end

                if temp[soulbindID] then
                    wipe(temp[soulbindID].nodes);
                else
                    temp[soulbindID] = {nodes = {}};
                end
                for nodeID in pairs(set.nodes) do
                    temp[soulbindID].nodes[nodeID] = true;
                end
                temp[soulbindID].conduits = tempConduits
            
                soulbindID = arg1;
                set.soulbindID = soulbindID;
                
                wipe(set.nodes);
                wipe(set.conduits);
                if temp[soulbindID] then
                    for nodeID in pairs(temp[soulbindID].nodes) do
                        set.nodes[nodeID] = true;
                    end
                    self.tempConduits = temp[soulbindID].conduits
                    if self.tempConduits[classID] then
                        for nodeID,conduitID in pairs(self.tempConduits[classID]) do
                            set.conduits[nodeID] = conduitID
                        end
                    end
                else
                    self.tempConduits = {}
                end

                Internal.Call("SoulbindSetUpdated", set.setID);

                self:Update()
            end
        end
        
		self.ClassDropDown.includeNone = true;
		UIDropDownMenu_SetWidth(self.ClassDropDown, 203);
		UIDropDownMenu_JustifyText(self.ClassDropDown, "LEFT");

        self.ClassDropDown.GetValue = function ()
            if self.set then
                return self.set.classID
            end
        end
        self.ClassDropDown.SetValue = function (_, _, arg1)
            CloseDropDownMenus();

            local set = self.set;
            if set then
                local classID = set.classID

                local tempConduits = self.tempConduits
                if classID then
                    if tempConduits[classID] then
                        wipe(tempConduits[classID]);
                    else
                        tempConduits[classID] = {};
                    end
                    for nodeID,conduitID in pairs(set.conduits) do
                        tempConduits[classID][nodeID] = conduitID;
                    end
                end

                classID = arg1
                set.classID = classID

                wipe(set.conduits);
                if classID then
                    if tempConduits[classID] then
                        for nodeID,conduitID in pairs(tempConduits[classID]) do
                            set.conduits[nodeID] = conduitID;
                        end
                    end
                end

                Internal.Call("SoulbindSetUpdated", set.setID);

                self:Update()
            end
        end

        self.initialized = true;
    end
end
function BtWLoadoutsSoulbindsMixin:ChangeSet(set)
    self.set = set
    self:Update()
end
function BtWLoadoutsSoulbindsMixin:UpdateSetName(value)
	if self.set and self.set.name ~= not value then
		self.set.name = value;
        Internal.Call("SoulbindSetUpdated", self.set.setID);
		self:Update();
	end
end
function BtWLoadoutsSoulbindsMixin:OnButtonClick(button)
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
        RefreshSet(set)
        self:Update()
	elseif button.isExport then
		local set = self.set;
		self:GetParent():SetExport(Internal.Export("soulbinds", set.setID))
	elseif button.isActivate then
        local set = self.set;
        Internal.ActivateProfile({
            soulbinds = {set.setID}
        });
	end
end
function BtWLoadoutsSoulbindsMixin:OnSidebarItemClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		button.collapsed[button.id] = not button.collapsed[button.id]
		self:Update()
	else
        if IsModifiedClick("SHIFT") then
            local set = GetSet(button.id);
            Internal.ActivateProfile({
                soulbinds = {button.id}
            });
        else
            self.Name:ClearFocus();
            self:ChangeSet(GetSet(button.id))
        end
	end
end
function BtWLoadoutsSoulbindsMixin:OnSidebarItemDoubleClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		return
	end

    local set = GetSet(button.id);
    Internal.ActivateProfile({
        soulbinds = {button.id}
    });
end
function BtWLoadoutsSoulbindsMixin:OnSidebarItemDragStart(button)
	CloseDropDownMenus()
	if button.isHeader then
		return
	end

	local icon = "INV_Misc_QuestionMark";
	local set = GetSet(button.id);
	local command = format("/btwloadouts activate soulbinds %d", button.id);
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

function BtWLoadoutsSoulbindsMixin:SetSoulbind(soulbindID)
    if self.soulbind and self.soulbind.ID == soulbindID then
        return
    end

    local soulbind = GetSoulbindData(soulbindID)
    local nodes = soulbind.tree.nodes
    local nodesByID = {}

    for _,node in ipairs(nodes) do
        nodesByID[node.ID] = node
    end
    for _,node in ipairs(nodes) do
        for _,parentID in ipairs(node.parentNodeIDs) do
            local parent = nodesByID[parentID]
            if not parent.childNodeIDs then
                parent.childNodeIDs = {}
            end
            parent.childNodeIDs[#parent.childNodeIDs+1] = node.ID
        end
    end

    soulbind.tree.nodesByID = nodesByID

    self.soulbind = soulbind
end
function BtWLoadoutsSoulbindsMixin:GetSoulbind()
    return self.soulbind
end

function BtWLoadoutsSoulbindsMixin:ToggleNode(nodeID)
    local nodes = self.set and self.set.nodes
    self:SetNodeEnabled(nodeID, not nodes[nodeID])
end
function BtWLoadoutsSoulbindsMixin:SetNodeEnabled(nodeID, enabled)
    local set = self.set
    if set then
        local nodes = set.nodes

        local soulbindData = self:GetSoulbind()
        local nodesByID = soulbindData.tree.nodesByID
        local targetNode = nodesByID[nodeID]
        
        while targetNode.childNodeIDs and #targetNode.childNodeIDs == 1 do
            local childID = targetNode.childNodeIDs[1]
            local child = nodesByID[childID]
    
            if #child.parentNodeIDs ~= 1 then
                break
            end
    
            targetNode = child
        end

        if enabled then
            for _,node in pairs(nodesByID) do
                if node.row == targetNode.row then
                    nodes[node.ID] = nil
                end
            end
        end
        nodes[targetNode.ID] = enabled and true or nil
        
        while #targetNode.parentNodeIDs == 1 do
            local parentID = targetNode.parentNodeIDs[1]
            targetNode = nodesByID[parentID]

            if not targetNode.childNodeIDs or #targetNode.childNodeIDs ~= 1 then
                break
            end

            if enabled then
                for _,node in pairs(nodesByID) do
                    if node.row == targetNode.row then
                        nodes[node.ID] = nil
                    end
                end
            end
            nodes[targetNode.ID] = enabled and true or nil
        end

        Internal.Call("SoulbindSetUpdated", set.setID);
        
        self:Update()
    end
end
function BtWLoadoutsSoulbindsMixin:IsNodeEnabled(nodeID)
    local nodes = self.set and self.set.nodes
    return nodes[nodeID] and true or false
end

function BtWLoadoutsSoulbindsMixin:SetNodeConduit(nodeID, conduitID)
    if not self.set or self.set.classID == nil then
        return false
    end

    if conduitID ~= nil then
        local conduit = GetConduitByID(conduitID)
        if not CheckConduitClass(conduit, self.set.classID) then
            return false
        end
    end

    local conduits = self.set.conduits
    for nodeID,nodeConduitID in pairs(conduits) do
        if conduitID == nodeConduitID then
            conduits[nodeID] = nil
        end
    end
    conduits[nodeID] = conduitID
    
    Internal.Call("SoulbindSetUpdated", self.set.setID);
        
    self:Update()

    return true
end
function BtWLoadoutsSoulbindsMixin:IsConduitSlotted(conduitID)
    local conduits = self.set and self.set.conduits
    for _,nodeConduitID in pairs(conduits) do
        if conduitID == nodeConduitID then
            return true
        end
    end
    return false
end

function BtWLoadoutsSoulbindsMixin:Update()
    self:GetParent():SetTitle(L["Soulbinds"]);
	local sidebar = BtWLoadoutsFrame.Sidebar

	sidebar:SetSupportedFilters("covenant", "spec", "class", "role", "race")
	sidebar:SetSets(BtWLoadoutsSets.soulbinds)
	sidebar:SetCollapsed(BtWLoadoutsCollapsed.soulbinds)
	sidebar:SetCategories(BtWLoadoutsCategories.soulbinds)
	sidebar:SetFilters(BtWLoadoutsFilters.soulbinds)
	sidebar:SetSelected(self.set)

	sidebar:Update()
	self.set = sidebar:GetSelected()
	local set = self.set
	
	local showingNPE = BtWLoadoutsFrame:SetNPEShown(set == nil, L["Soulbinds"], L["Create soulbind trees for switching between soulbind paths, leave rows blank to not skip them. Conduits are not affected."])

	self:GetParent().ExportButton:SetEnabled(true)
    self:GetParent().DeleteButton:SetEnabled(true);

    if not showingNPE then
        local soulbindID = set.soulbindID;
        self:SetSoulbind(soulbindID)
        local soulbindData = self:GetSoulbind()

		UpdateSetFilters(set)
        sidebar:Update()
        
        set.restrictions = set.restrictions or {}
        self.RestrictionsDropDown:SetSelections(set.restrictions)
        self.RestrictionsDropDown:SetLimitations("class", set.classID)
		self.RestrictionsButton:SetEnabled(true);

        if not self.Name:HasFocus() then
            self.Name:SetText(set.name or "");
        end

        -- UIDropDownMenu_SetSelectedValue(self.SoulbindDropDown, soulbindID);
        UIDropDownMenu_SetText(self.SoulbindDropDown, soulbindData.name);
        UIDropDownMenu_EnableDropDown(self.SoulbindDropDown);

        if not set.conduits then
            set.conduits = {}
        end
        
        local selected = set.nodes;
        local conduits = set.conduits;

        self.nodes:ReleaseAll()
        self.links:ReleaseAll()
        wipe(self.nodesByID)
        for _,node in ipairs(soulbindData.tree.nodes) do
            local nodeFrame = self.nodes:Acquire()
            nodeFrame:SetFrameLevel(6)
            nodeFrame:SetPoint("TOP", (node.column - 1) * (nodeFrame:GetWidth() + 30), -node.row * (nodeFrame:GetHeight() + 24) - 17)
            nodeFrame:Init(self, node)
            nodeFrame:SetConduit(conduits[node.ID])
            nodeFrame:SetSelected(selected[node.ID])
            nodeFrame:Show()

            self.nodesByID[node.ID] = nodeFrame
        end
		for _, linkFromFrame in pairs(self.nodesByID) do
            if linkFromFrame.node.row > 0 then
                for _,parentID in ipairs(linkFromFrame.node.parentNodeIDs) do
                    local linkToFrame = self.nodesByID[parentID]

                    local linkFrame = self.links:Acquire()
                    linkFrame:SetFrameLevel(2)

					local toColumn = linkToFrame.node.column;
					local fromColumn = linkFromFrame.node.column;
                    local offset = toColumn - fromColumn;
					
					if offset < 0 then
						linkFrame:SetPoint("BOTTOMRIGHT", linkFromFrame, "CENTER");
						linkFrame:SetPoint("TOPLEFT", linkToFrame, "CENTER");
					elseif offset > 0 then
						linkFrame:SetPoint("BOTTOMLEFT", linkFromFrame, "CENTER");
						linkFrame:SetPoint("TOPRIGHT", linkToFrame, "CENTER");
					else
						linkFrame:SetPoint("BOTTOM", linkFromFrame, "CENTER");
						linkFrame:SetPoint("TOP", linkToFrame, "CENTER");
					end

					local direction;
					local diagonal = toColumn ~= fromColumn;
                    if diagonal then
                        direction = SoulbindTreeLinkDirections.Converge
					else
						direction = SoulbindTreeLinkDirections.Vertical;
					end

					local quarter = (math.pi * 0.5);
					local angle = RegionUtil.CalculateAngleBetween(linkToFrame, linkFromFrame) - quarter;

                    linkFrame:Init(direction, angle);
                    linkFrame:SetState((selected[linkToFrame.node.ID] and selected[linkFromFrame.node.ID]) and Enum.SoulbindNodeState.Selected or Enum.SoulbindNodeState.Unselected);
					linkFrame:Show();
                end
            end
        end

        if set.classID then
            local classInfo = C_CreatureInfo.GetClassInfo(set.classID)
            local classColor = C_ClassColor.GetClassColor(classInfo.classFile)
            UIDropDownMenu_SetText(self.ClassDropDown, classColor:WrapTextInColorCode(classInfo.className));
        else
            UIDropDownMenu_SetText(self.ClassDropDown, L["None"]);
        end
        UIDropDownMenu_EnableDropDown(self.ClassDropDown);
        self.ConduitList:Init(self, set.classID, soulbindData.covenantID)
        self.ConduitList:Update()

        local playerClassID = select(3, UnitClass("player"))
        local playerCovenantID = GetActiveCovenantID()
        local playerSoulbindID = GetActiveSoulbindID()
        self:GetParent().RefreshButton:SetEnabled(soulbindID == playerSoulbindID)
        self:GetParent().ActivateButton:SetEnabled(soulbindData.covenantID == playerCovenantID and soulbindData.unlocked and (set.classID == nil or set.classID == playerClassID));

        local helpTipBox = self:GetParent().HelpTipBox;
        helpTipBox:Hide();
    else
        local soulbindID = GetActiveSoulbindID()
        if soulbindID == 0 then
            soulbindID = 7 -- Default to pelagos because why not
        end
        local soulbindData = GetSoulbindData(soulbindID)
        
        self.Name:SetText(format(L["New %s Set"], soulbindData.name));

        self.nodes:ReleaseAll()
        self.links:ReleaseAll()
        for _,node in ipairs(soulbindData.tree.nodes) do
            local nodeFrame = self.nodes:Acquire()
            nodeFrame:SetFrameLevel(6)
            nodeFrame:SetPoint("TOP", self.Inset, "TOP", (node.column - 1) * (nodeFrame:GetWidth() + 30), -node.row * (nodeFrame:GetHeight() + 12) - 17)
            nodeFrame:Init(self, node)
            nodeFrame:SetSelected(false)
            nodeFrame:Show()

            self.nodesByID[node.ID] = nodeFrame
        end

        local helpTipBox = self:GetParent().HelpTipBox;
        helpTipBox:Hide();
    end
end
function BtWLoadoutsSoulbindsMixin:SetEnabled(value)
	BtWLoadoutsTabFrame_SetEnabled(self, value)
end
function BtWLoadoutsSoulbindsMixin:SetSetByID(setID)
	self.set = GetSet(setID)
end
