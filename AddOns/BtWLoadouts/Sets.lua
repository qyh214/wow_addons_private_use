--[[
    Generic Set handling functions
]]

local _,Internal = ...
local L = Internal.L

local function GetNextSetID(sets)
    if type(sets) == "string" then
        sets = BtWLoadoutsSets[sets]
    end

	local nextID = sets.nextID or 1
	while sets[nextID] ~= nil do
		nextID = nextID + 1
	end
	sets.nextID = nextID
	return nextID;
end
local function GetSet(sets, id)
	if type(id) == "table" then
		return id
	end
	if type(sets) == "string" then
        sets = BtWLoadoutsSets[sets]
    end

    return sets[id]
end
local function GetSetsByName(tbl, sets, name)
	name = name:lower():trim()
    if type(sets) == "string" then
        sets = BtWLoadoutsSets[sets]
    end

	for _,set in pairs(sets) do
		if type(set) == "table" and set.name:lower():trim() == name then
			tbl[#tbl+1] = set;
		end
	end
	return tbl
end
local GetSetByName
do
	local comparisons = {}
	function GetSetByName(sets, name, validCallback)
		if type(sets) == "string" then
			sets = BtWLoadoutsSets[sets]
		end

		if validCallback then
			local sets = GetSetsByName({}, sets, name)

			wipe(comparisons)
			for _,set in ipairs(sets) do
				local valid, validForClass, validForSpec = validCallback(set)
				comparisons[set] = (valid and 1 or 0) + (validForClass and 1 or 0) + (validForSpec and 1 or 0)
			end

			sort(sets, function (a,b)
				if comparisons[a] == comparisons[b] then
					-- Would do name, but they all have the same name, and this should be the most consistent
					return a.setID < b.setID
				end

				return comparisons[a] > comparisons[b]
			end)

			return sets[1]
		else -- When we cant compare the validity of the sets we just return the first one we encounter
			name = name:lower():trim()
			for _,set in pairs(sets) do
				if type(set) == "table" and set.name:lower():trim() == name then
					return set;
				end
			end
		end
	end
end
local function GetSetByValue(sets, value, callback)
    if type(sets) == "string" then
        sets = BtWLoadoutsSets[sets]
	end

	for _,set in pairs(sets) do
		if type(set) == "table" and callback(set, value) then
			return set;
		end
	end
end
local function AddSet(sets, set)
    if type(sets) == "string" then
        sets = BtWLoadoutsSets[sets]
    end

    if not set.setID then
        set.setID = GetNextSetID(sets)
	end
	set.useCount = set.useCount or 0
    sets[set.setID] = set
    return set
end
local function DeleteSet(sets, id)
    if type(sets) == "string" then
        sets = BtWLoadoutsSets[sets]
    end

	if type(id) == "table" then
		if id.setID then
			DeleteSet(sets, id.setID);
		else
			for k,v in pairs(sets) do
				if v == id then
					sets[k] = nil;
					break;
				end
			end
		end
	else
		sets[id] = nil;
		if sets.nextID == nil or id < sets.nextID then
			sets.nextID = id;
		end
	end
end
Internal.GetNextSetID = GetNextSetID;
Internal.GetSet = GetSet;
Internal.GetSetByName = GetSetByName;
Internal.GetSetsByName = GetSetsByName;
Internal.GetSetByValue = GetSetByValue;
Internal.AddSet = AddSet;
Internal.DeleteSet = DeleteSet;

--[[ Loadouts tab generic drop handler ]]
local function SetDropDownInit(self, set, index, segment, tab)
    self:SetSelected(index and set[segment][index] or nil)
    self:SetSets(BtWLoadoutsSets[segment])
    self:SetFilters(BtWLoadoutsFilters[segment])
    self:SetCategories(BtWLoadoutsCategories[segment])
	self:SetIncludeNone(index ~= nil)
    self:OnItemClick(function (self, setID)
		local index = index or (#set[segment] + 1)

		if set[segment][index] then
			local subset = Internal.GetLoadoutSegment(segment).get(set[segment][index]);
			subset.useCount = (subset.useCount or 1) - 1;
		end

        if setID == "none" then
			table.remove(set[segment], index);
        elseif setID == "new" then
            local subset = Internal.GetLoadoutSegment(segment).add();
            set[segment][index] = subset.setID;

            tab.set = subset;
            PanelTemplates_SetTab(BtWLoadoutsFrame, tab:GetID());
        
            BtWLoadoutsHelpTipFlags["TUTORIAL_CREATE_TALENT_SET"] = true;
        else -- Change to a specific set
            set[segment][index] = setID;
        end
    
        if set[segment][index] then
            local subset = Internal.GetLoadoutSegment(segment).get(set[segment][index]);
            subset.useCount = (subset.useCount or 0) + 1;
        end

		self:SetSelected(set[segment][index])

		Internal.Call("LoadoutUpdated", set.setID);

		CloseDropDownMenus()
        BtWLoadoutsFrame:Update();
    end)
end
Internal.SetDropDownInit = SetDropDownInit

--[[ Sets filtering functions ]]

local function FilterSetsBySearch(result, query, sets)
	for _,set in pairs(sets) do
		if type(set) == "table" then
			if query == nil or set.name:lower():find(query) ~= nil then
				result[#result+1] = set;
			end
		end
	end

	return result
end
local function ContainsOrMatches(tbl, value)
	if type(tbl) == "table" then
		for _,v in pairs(tbl) do
			if v == value then
				return true
			end
		end
	elseif (tbl or 0) == value then
		return true
	end
	return false
end
local function FiltersMatch(filters, setFilters)
	for filter,value in pairs(filters) do
		if not ContainsOrMatches(setFilters[filter], value) then
			return false
		end
	end
	return true
end
local function FilterSets(result, filters, sets)
	for _,set in pairs(sets) do
		if type(set) == "table" and FiltersMatch(filters, set.filters) then
			result[#result+1] = set;
		end
	end

	return result
end
local function OrganiseSetsByFilter(result, sets, filter)
	if filter == nil then
		for _,set in pairs(sets) do
			if type(set) == "table" then
				result[#result+1] = set;
			end
		end
	else
		for setID,set in pairs(sets) do
			if type(set) == "table" then
				local value = set.filters and set.filters[filter] or 0
				if type(value) == "table" then
					for _,v in pairs(value) do
						result[v] = result[v] or {};
						result[v][#result[v] + 1] = set;
					end
				else
					result[value] = result[value] or {};
					result[value][#result[value] + 1] = set;
				end
			end
		end
	end

	return result
end
--[[
	... is a list of filters, eg spec, role, class, character, instanceType, etc.
]]
local function CategoriesSets(sets, ...)
	local tbl = OrganiseSetsByFilter({}, sets, ...)
	if select('#', ...) > 1 then
		for k,v in pairs(tbl) do
			tbl[k] = CategoriesSets(v, select(2, ...))
		end
	end
	return tbl
end
local function SortSets(o)
	local function padnum(d)
		local dec, n = string.match(d, "(%.?)0*(.+)")
		return #dec > 0 and ("%.12f"):format(d) or ("%s%03d%s"):format(dec, #n, n)
	end
	table.sort(o, function(a,b)
		if (a.order or 0) == (b.order or 0) then
			return tostring(a.name):gsub("%.?%d+", padnum)..("%3d"):format(#b.name)
				 < tostring(b.name):gsub("%.?%d+", padnum)..("%3d"):format(#a.name)
		end
		return (a.order or 0) < (b.order or 0)
	end)
	return o
end

Internal.FilterSetsBySearch = FilterSetsBySearch
Internal.FilterSets = FilterSets
Internal.CategoriesSets = CategoriesSets
Internal.SortSets = SortSets
