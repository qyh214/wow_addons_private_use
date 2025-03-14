-- App locals
local appName, app = ...;

local tinsert,ipairs
	= tinsert,ipairs

-- Some common UI functions (TBD)
app.UI = {
	OnClick = {
		IgnoreRightClick = function(row, button)
			return button == "RightButton";
		end
	}
}

-- TODO: this doesnt really belong in this file imo... but can move around later for both Classic/Retail
do
	local FilterBind = app.Modules.Filter.Filters.Bind
	local function SearchForMissingItemsRecursively(group, listing)
		-- app.PrintDebug("SearchForMissingItemsRecursively",app:SearchLink(group))
		if group.visible then
			if group.itemID and (group.collectible or (group.total and group.total > 0)) and not FilterBind(group) then
				tinsert(listing, group);
			end
			if group.g and group.expanded then
				-- Go through the sub groups and determine if any of them have a response.
				for i, subgroup in ipairs(group.g) do
					SearchForMissingItemsRecursively(subgroup, listing)
				end
			end
		end
	end
app.Search = {
	SearchForMissingItemsRecursively = SearchForMissingItemsRecursively
}
end