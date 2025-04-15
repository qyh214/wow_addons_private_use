---
--- Contains functionality to handle the manipulation of data within ATT
--- Dependencies: Runner, Callback
---

local appName, app = ...

local ipairs,pairs,rawget,tonumber,GetTimePreciseSec
	= ipairs,pairs,rawget,tonumber,GetTimePreciseSec

local DelayedCallback = app.CallbackHandlers.DelayedCallback
local Runner = app.CreateRunner("update")
app.UpdateRunner = Runner

-- Update Group Data
local DefaultGroupVisibility, DefaultThingVisibility
local UpdateGroups
local RecursiveGroupRequirementsFilter, GroupFilter, GroupVisibilityFilter, ThingVisibilityFilter, TrackableFilter
local FilterSet, FilterGet, Filters_ItemUnbound, ItemUnboundSetting
-- local debug
-- Local caches for some heavily used functions within updates
local function CacheFilterFunctions()
	local FilterApi = app.Modules.Filter
	FilterSet = FilterApi.Set
	FilterGet = FilterApi.Get
	Filters_ItemUnbound = FilterApi.Filters.ItemUnbound
	ItemUnboundSetting = FilterGet.ItemUnbound()
	RecursiveGroupRequirementsFilter = app.RecursiveGroupRequirementsFilter
	GroupFilter = app.GroupFilter
	GroupVisibilityFilter, ThingVisibilityFilter = app.GroupVisibilityFilter, app.CollectedItemVisibilityFilter
	TrackableFilter = app.ShowTrackableThings
	DefaultGroupVisibility, DefaultThingVisibility = app.DefaultGroupFilter(), app.DefaultThingFilter()
	-- app.PrintDebug("CacheFilterFunctions","DG",DefaultGroupVisibility,"DT",DefaultThingVisibility)
	-- app.PrintDebug("ItemUnboundSetting",ItemUnboundSetting)
end
-- TODO: test perf when instead using an array of ordered visibility checkers which is defined via settings changes
-- similar to information types
local function SetGroupVisibility(parent, group)
	local forceShowParent
	-- Set visible initially based on the global 'default' visibility, or whether the group should inherently be shown
	local visible = DefaultGroupVisibility
	-- Need to check all possible reasons a group could be visible, from simplest to more complex
	-- Force show
	if not visible and group.forceShow then
		visible = true
		group.forceShow = nil
		-- Continue the forceShow visibility outward
		forceShowParent = true
	end
	-- Total
	if not visible and group.total > 0 then
		visible = group.progress < group.total or GroupVisibilityFilter(group)
	end
	-- Cost
	if not visible and ((group.costTotal or 0) > 0) then
		visible = true
		-- app.PrintDebug("SGV.cost",group.hash,visible,group.costTotal)
	end
	-- Upgrade
	if not visible and ((group.upgradeTotal or 0) > 0) then
		visible = true
		-- if debug then print("SGV.hasUpgrade",group.hash,visible) end
	end
	-- Trackable
	if not visible and TrackableFilter(group) then
		visible = not group.saved or GroupVisibilityFilter(group)
		forceShowParent = visible
	end
	-- Custom Visibility
	if not visible and group.OnSetVisibility then
		visible = group:OnSetVisibility()
	end
	-- Apply the visibility to the group
	if visible then
		group.visible = true
		-- source ignored group which is determined to be visible should ensure the parent is also visible
		if not forceShowParent and group.sourceIgnored then
			forceShowParent = true
			-- app.PrintDebug("SGV:ForceParent",parent.text,"via Source Ignored",group.text)
		end
	end
	if parent and forceShowParent then
		parent.forceShow = forceShowParent
	end
end
local function SetThingVisibility(parent, group)
	local forceShowParent
	local visible = DefaultThingVisibility
	-- Need to check all possible reasons a group could be visible, from simplest to more complex
	-- Force show
	if not visible and group.forceShow then
		visible = true
		group.forceShow = nil
		-- Continue the forceShow visibility outward
		forceShowParent = true
		-- if debug then print("forceshow",visible) end
	end
	-- Total
	if not visible and group.total > 0 then
		visible = group.progress < group.total or ThingVisibilityFilter(group)
		-- app.PrintDebug("STV.total",group.hash,visible,group.progress,group.total,ThingVisibilityFilter(group))
	end
	-- Cost
	if not visible and ((group.costTotal or 0) > 0) then
		visible = true
		-- app.PrintDebug("STV.cost",group.hash,visible,group.costTotal)
	end
	-- Upgrade
	if not visible and ((group.upgradeTotal or 0) > 0) then
		visible = true
		-- if debug then print("STV.hasUpgrade",group.hash,visible) end
	end
	-- Trackable
	if not visible and TrackableFilter(group) then
		visible = not group.saved or ThingVisibilityFilter(group)
		forceShowParent = visible
		-- if debug then print("trackable",visible) end
	end
	-- Custom Visibility
	if not visible and group.OnSetVisibility then
		visible = group:OnSetVisibility()
	end
	-- Loot Mode
	if not visible then
		if ((group.itemID and group.f) or group.sym) and app.Settings.Collectibles.Loot then
			visible = true
		end
		forceShowParent = visible
	end
	-- Apply the visibility to the group
	if visible then
		group.visible = true
		-- source ignored group which is determined to be visible should ensure the parent is also visible
		if not forceShowParent and group.sourceIgnored then
			forceShowParent = true
			-- app.PrintDebug("STV:ForceParent",parent.text,"via Source Ignored",group.text)
		end
	end
	if parent and forceShowParent then
		parent.forceShow = forceShowParent
	end
end
local function UpdateGroup(group, parent)
	group.visible = nil

	-- debug = group.itemID and group.factionID == 2045
	-- if debug then print("UG",group.hash,parent and parent.hash) end

	-- Determine if this user can enter the instance or acquire the item and item is equippable/usable
	-- Things which are determined to be a cost for something else which meets user filters will
	-- be shown anyway, so don't need to undergo a filtering pass
	local valid = group.isCost or group.forceShow
	-- if valid then
		-- app.PrintDebug("Pre-valid group as from cost/upgrade",group.isCost,group.isUpgrade,app:SearchLink(group))
	-- end
	-- A group with a source parent means it has a different 'real' heirarchy than in the current window
	-- so need to verify filtering based on that instead of only itself
	if not valid then
		if group.sourceParent then
			valid = RecursiveGroupRequirementsFilter(group)
			-- if debug then print("UG.RGRF",valid,"=>",group.sourceParent.hash) end
		else
			valid = GroupFilter(group)
			-- if debug then print("UG.GF",valid) end
		end
	end

	if valid then
		-- Set total/progress for this object using its cost/custom information if any
		local customTotal = group.customTotal or 0
		local customProgress = customTotal > 0 and group.customProgress or 0
		local total, progress = customTotal, customProgress

		-- if debug then print("UG.Init","custom",customProgress,customTotal,"=>",progress,total) end

		-- If this item is collectible, then mark it as such.
		if group.collectible then
			total = total + 1
			if group.collected then
				progress = progress + 1
			end
		end

		-- Set the total/progress on the group
		-- if debug then print("UG.prog",progress,total,group.collectible) end
		group.progress = progress
		group.total = total
		group.costTotal = group.isCost and 1 or 0
		group.upgradeTotal = group.isUpgrade and 1 or 0

		-- Check if this is a group
		local g = group.g
		if g then
			-- if debug then print("UpdateGroup.g",group.progress,group.total,group.__type) end

			-- skip Character filtering for sub-groups if this Item meets the Ignore BoE filter logic, since it can be moved to the designated character
			-- local ItemBindFilter, NoFilter = app.ItemBindFilter, app.NoFilter
			if ItemUnboundSetting and Filters_ItemUnbound(group) then
				-- app.ItemBindFilter = NoFilter
				-- Toggle only Account-level filtering within this Item and turn off the ItemUnboundSetting to ignore sub-checks for the same logic
				ItemUnboundSetting = nil
				FilterSet.ItemUnbound(nil, true)
				-- app.PrintDebug("Within BoE",group.hash,group.link)
				-- Update the subgroups recursively...
				UpdateGroups(group, g)
				-- reapply the previous BoE filter
				-- app.PrintDebug("Leaving BoE",group.hash,group.link)
				FilterSet.ItemUnbound(true)
				ItemUnboundSetting = true
				-- app.ItemBindFilter = ItemBindFilter
			else
				UpdateGroups(group, g)
			end

			-- app.PrintDebug("UpdateGroup.g.Updated",group.progress,group.total,group.__type)
			SetGroupVisibility(parent, group)
		else
			SetThingVisibility(parent, group)
		end

		-- Increment the parent group's totals if the group is not ignored for sources
		if parent and not group.sourceIgnored then
			parent.total = (parent.total or 0) + group.total
			parent.progress = (parent.progress or 0) + group.progress
			parent.costTotal = (parent.costTotal or 0) + (group.costTotal or 0)
			parent.upgradeTotal = (parent.upgradeTotal or 0) + (group.upgradeTotal or 0)
		-- else
			-- print("Ignoring progress/total",group.progress,"/",group.total,"for group",group.text)
		end
	end

	-- if debug then print("UpdateGroup.Done",group.progress,group.total,group.visible,group.__type) end
	-- debug = nil
	-- return group.visible
end
UpdateGroups = function(parent, g)
	if g then
		for _,group in ipairs(g) do
			if group.OnUpdate then
				if not group:OnUpdate(parent, UpdateGroup) then
					UpdateGroup(group, parent)
				elseif group.visible then
					group.total = nil
					group.progress = nil
					UpdateGroups(group, group.g)
				end
			else
				UpdateGroup(group, parent)
			end
		end
	end
end
app.UpdateGroups = UpdateGroups
-- Adjusts the progress/total of the group's parent chain, and refreshes visibility based on the new values
local function AdjustParentProgress(group, progChange, totalChange, costChange, upgradeChange)
	-- rawget, .parent will default to sourceParent in some cases
	local parent = group and not group.sourceIgnored and rawget(group, "parent")
	if parent then
		-- app.PrintDebug("APP:",parent.text)
		-- app.PrintDebug("CUR:",parent.progress,parent.total)
		-- app.PrintDebug("CHG:",progChange,totalChange)
		parent.total = (parent.total or 0) + totalChange
		parent.progress = (parent.progress or 0) + progChange
		parent.costTotal = (parent.costTotal or 0) + costChange
		parent.upgradeTotal = (parent.upgradeTotal or 0) + upgradeChange
		-- Assign cost cache
		-- app.PrintDebug("END:",parent.progress,parent.total)
		-- verify visibility of the group, always a 'group' since it is already a parent of another group, as long as it's not the root window data
		if not parent.window then
			parent.visible = nil
			SetGroupVisibility(rawget(parent, "parent"), parent)
		end
		AdjustParentProgress(parent, progChange, totalChange, costChange, upgradeChange)
	end
end


-- For directly applying the full Update operation for the top-level data group within a window
local function TopLevelUpdateGroup(group)
	group.TLUG = GetTimePreciseSec()
	group.total = nil
	group.progress = nil
	group.costTotal = nil
	group.upgradeTotal = nil
	CacheFilterFunctions()
	-- app.PrintDebug("TLUG",group.hash)
	-- Root data in Windows should ALWAYS be visible
	if group.window then
		-- app.PrintDebug("Root Group",group.text)
		group.forceShow = true
	end
	if group.OnUpdate then
		if not group:OnUpdate(nil, UpdateGroup) then
			UpdateGroup(group)
		elseif group.visible then
			group.total = nil
			group.progress = nil
			UpdateGroups(group, group.g)
		end
	else
		UpdateGroup(group)
	end
	-- app.PrintDebugPrior("TLUG",group.hash)
end
app.TopLevelUpdateGroup = TopLevelUpdateGroup
local DGUDelay = 0.5
-- Allows changing the Delayed group update frequency between 0 - 2 seconds, mainly for testing
app.SetDGUDelay = function(delay)
	DGUDelay = math.min(2, math.max(0, tonumber(delay)))
end
-- For directly applying the full Update operation at the specified group, and propagating the difference upwards in the parent hierarchy,
-- then triggering a delayed soft-update of the Window containing the group if any. 'got' indicates that this group was 'gotten'
-- and was the cause for the update
local function DirectGroupUpdate(group, got)
	-- DGU OnUpdate needs to run regardless of filtering
	if group.DGUOnUpdate then
		-- app.PrintDebug("DGU:OnUpdate",group.hash)
		group:DGUOnUpdate()
	end
	local window = app.GetRelativeRawWithField(group, "window")
	if window then window:ToggleExtraFilters(true) end
	local wasHidden = app.GetRawRelativeField(group, "visible")
	-- starting an update from a non-top-level group means we need to verify this group should even handle updates based on current filters first
	if wasHidden and not app.RecursiveDirectGroupRequirementsFilter(group) then
		-- app.PrintDebug("DGU:Filtered",group.visible,app:SearchLink(group))
		if window then window:ToggleExtraFilters() end
		return
	end
	local prevTotal, prevProg, prevCost, prevUpgrade
		= group.total or 0, group.progress or 0, group.costTotal or 0, group.upgradeTotal or 0
	TopLevelUpdateGroup(group)
	local progChange, totalChange, costChange, upgradeChange
		= group.progress - prevProg, group.total - prevTotal, group.costTotal - prevCost, group.upgradeTotal - prevUpgrade
	-- Something to change for a visible group prior to the DGU or changed in visibility
	if progChange ~= 0 or totalChange ~= 0 or costChange ~= 0 or upgradeChange ~= 0 then
		local isHidden = not group.visible
		-- app.PrintDebug("DGU:Change",window.Suffix,wasHidden,"=>",isHidden,app:SearchLink(group),progChange, totalChange, costChange, upgradeChange)
		if not isHidden or isHidden ~= wasHidden then
			AdjustParentProgress(group, progChange, totalChange, costChange, upgradeChange)
		end
	end
	-- TODO: find some way to handle the link to Fill logic via an Event
	-- After completing the Direct Update, setup a soft-update on the affected Window, if any
	if window then
		-- sometimes we may want to trigger a delayed fill operation on a group, but when attempting the fill originally,
		-- the group may not yet be in a state for proper filling... so we can instead assign the group to trigger a fill
		-- once it received a direct update within a window
		-- TODO: use an Event for this check eventually
		if group.DGU_Fill then
			group.DGU_Fill = nil
			-- app.PrintDebug("DGU_Fill",app:SearchLink(group))
			app.FillGroups(group)
		end
		-- app.PrintDebug("DGU:Update",app:SearchLink(group),">",window.Suffix,window.Update,window.isQuestChain)
		DelayedCallback(window.Update, DGUDelay, window, window.isQuestChain, got)
		window:ToggleExtraFilters()
	elseif group.DGU_Fill then
		-- group wants to fill, but isn't yet in a window... so do a delayed DGU again
		if not tonumber(group.DGU_Fill) then
			group.DGU_Fill = 3
		else
			group.DGU_Fill = group.DGU_Fill - 1
		end
		-- give up after a few tries if it doesn't get into a window...
		if group.DGU_Fill <= 0 then
			group.DGU_Fill = nil
			-- app.PrintDebug("DGU_Fill ignored",app:SearchLink(group))
			return
		end
		-- app.PrintDebug("Delayed DGU_Fill",app:SearchLink(group))
		app.FillRunner.Run(DirectGroupUpdate, group)
	end
end
app.DirectGroupUpdate = DirectGroupUpdate
-- Trigger a soft-Update of the window containing the specific group, regardless of Filtering/Visibility of the group
local function DirectGroupRefresh(group)
	local window = app.GetRelativeRawWithField(group, "window")
	if window then
		-- app.PrintDebug("DGR:Refresh",group.hash,">",window.Suffix,window.Refresh)
		DelayedCallback(window.Update, DGUDelay, window)
	end
end
app.DirectGroupRefresh = DirectGroupRefresh
local LIMIT_UPDATE_SEARCH_RESULTS = 10
-- Dynamically increments the progress for the parent heirarchy of each collectible search result
local function UpdateSearchResults(searchResults)
	-- app.PrintDebug("UpdateSearchResults",searchResults and #searchResults)
	if not searchResults or #searchResults == 0 then return end
	-- in extreme cases of tons of search results to update all at once, we will split up the updates to remove the apparent stutter
	if #searchResults > LIMIT_UPDATE_SEARCH_RESULTS then
		local subresults = {}
		for i,result in ipairs(searchResults) do
			subresults[#subresults + 1] = result
			if i % LIMIT_UPDATE_SEARCH_RESULTS == 0 then
				Runner.Run(UpdateSearchResults, subresults)
				subresults = {}
			end
		end
		Runner.Run(UpdateSearchResults, subresults)
		return
	end
	-- Update all the results within visible windows
	local hashes = {}
	local found = {}
	local HandleEvent = app.HandleEvent
	-- Directly update the Source groups of the search results, and collect their hashes for updates in other windows
	for _,result in ipairs(searchResults) do
		hashes[result.hash] = true
		found[#found + 1] = result
		-- Make sure any update events are handled for this Thing
		HandleEvent("OnSearchResultUpdate", result)
	end

	-- loop through visible ATT windows and collect matching groups
	-- app.PrintDebug("Checking Windows...")
	local SearchForSpecificGroups = app.SearchForSpecificGroups
	for suffix,window in pairs(app.Windows) do
		-- Collect matching groups from the updating groups from visible windows other than Main list
		if window.Suffix ~= "Prime" and window:IsVisible() then
			-- app.PrintDebug(window.Suffix)
			for _,result in ipairs(searchResults) do
				SearchForSpecificGroups(found, window.data, hashes)
			end
		end
	end

	-- apply direct updates to all found groups
	-- app.PrintDebug("Updating",#found,"groups")
	for _,o in ipairs(found) do
		DirectGroupUpdate(o, true)
	end
	-- TODO: use event
	app.WipeSearchCache()
	-- app.PrintDebug("UpdateSearchResults Done")
end
-- Pulls all cached fields for the field/id and passes the results into UpdateSearchResults
local function UpdateRawID(field, id)
	-- app.PrintDebug("UpdateRawID",field,id)
	if field and id then
		UpdateSearchResults(app.SearchForFieldInAllCaches(field, id))
	end
end
app.UpdateRawID = UpdateRawID
-- Pulls all cached fields for the field/ids and passes the results into UpdateSearchResults
local function UpdateRawIDs(field, ids)
	-- app.PrintDebug("UpdateRawIDs",field,ids and #ids)
	if field and ids and #ids > 0 then
		UpdateSearchResults(app.SearchForManyInAllCaches(field, ids))
	end
end
app.UpdateRawIDs = UpdateRawIDs
