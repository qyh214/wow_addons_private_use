-- App locals
local appName, app = ...;
local L = app.L

local wipe,ipairs,pairs,math,pcall,rawget,tostring,select,CreateFrame,GetCursorPosition,SetPortraitTexture
	= wipe,ipairs,pairs,math,pcall,rawget,tostring,select,CreateFrame,GetCursorPosition,SetPortraitTexture

---@class ATTGameTooltip: GameTooltip
local GameTooltip = GameTooltip
local RETRIEVING_DATA = RETRIEVING_DATA
local SetPortraitTextureFromDisplayID = SetPortraitTextureFromCreatureDisplayID

local GetTradeSkillTexture = app.WOWAPI.GetTradeSkillTexture
local Callback = app.CallbackHandlers.Callback
local AfterCombatOrDelayedCallback = app.CallbackHandlers.AfterCombatOrDelayedCallback
local DelayedCallback = app.CallbackHandlers.DelayedCallback
local IsRetrieving = app.Modules.RetrievingData.IsRetrieving
local Colorize = app.Modules.Color.Colorize
local GetProgressColorText = app.Modules.Color.GetProgressColorText
local AssignChildren = app.AssignChildren
local GetDisplayID = app.GetDisplayID
local Push = app.Push
local GetSpecsString = app.GetSpecsString
local GetClassesString = app.GetClassesString
local TryColorizeName = app.TryColorizeName

app.Windows = {};

-- allows resetting a given ATT window
local function ResetWindow(suffix)
	app.Windows[suffix] = nil;
	if suffix ~= "awp" then	-- don't spam for this window for now
		app.print("Reset Window",suffix);
	end
end
local function SetVisible(self, show, forceUpdate)
	-- app.PrintDebug("SetVisible",self.Suffix,show,forceUpdate)
	if show then
		self:Show();
		-- apply window position from profile
		app.Settings.SetWindowFromProfile(self.Suffix);
		self:Update(forceUpdate);
	else
		self:Hide();
	end
end
local function Toggle(self, forceUpdate)
	return SetVisible(self, not self:IsVisible(), forceUpdate);
end

local SkipAutoExpands = {
	-- Specific HeaderID values should not expand
	headerID = {
		[app.HeaderConstants.ZONE_DROPS] = true,
		[app.HeaderConstants.COMMON_BOSS_DROPS] = true,
		[app.HeaderConstants.HOLIDAYS] = true
	},
	-- Item/Difficulty as Headers should not expand
	itemID = true,
	difficultyID = true,
}
local function SkipAutoExpand(group)
	local key = group.key;
	local skipKey = SkipAutoExpands[key];
	if not skipKey then return; end
	return skipKey == true or skipKey[group[key]];
end
local function ExpandGroupsRecursively(group, expanded, manual)
	-- expand if there is any sub-group
	if group.g then
		-- app.PrintDebug("EGR",group.hash,expanded,manual);
		-- if manually expanding
		if (manual or (
				-- not a skipped group for auto-expansion
				not SkipAutoExpand(group) and
				-- incomplete things actually exist below itself
				((group.total or 0) > (group.progress or 0)) and
				-- account/debug mode is active or it is not a 'saved' thing for this character
				(app.MODE_DEBUG_OR_ACCOUNT or not group.saved))
			) then
			-- app.PrintDebug("EGR:expand");
			group.expanded = expanded;
			for _,subgroup in ipairs(group.g) do
				ExpandGroupsRecursively(subgroup, expanded, manual);
			end
		end
	end
end
local VisibilityFilter, SortGroup
local function ProcessGroup(data, object)
	if not VisibilityFilter(object) then return end
	data[#data + 1] = object
	local g = object.g
	if g and object.expanded then
		-- Delayed sort operation for this group prior to being shown
		local sortType = object.SortType;
		if sortType then SortGroup(object, sortType); end
		for _,group in ipairs(g) do
			ProcessGroup(data, group);
		end
	end
end
local function UpdateWindow(self, force, got)
	local data = self.data;
	-- TODO: remove IsReady check when Windows have OnInit capability
	if not data or not app.IsReady then return end
	local visible = self:IsVisible();
	-- either by Setting or by special windows apply ad-hoc logic
	local adhoc = self.AdHoc or app.Settings:GetTooltipSetting("Updates:AdHoc")
	force = force or self.HasPendingUpdate;
	-- hidden adhoc window is set for pending update instead of forced
	if adhoc and force and not visible then
		self.HasPendingUpdate = true;
		force = nil;
	end
	-- app.PrintDebug(Colorize("Update:", app.Colors.ATT),self.Suffix,
	-- 	force and "FORCE" or "SOFT",
	-- 	visible and "VISIBLE" or "HIDDEN",
	-- 	got and "COLLECTED" or "PASSIVE",
	-- 	self.HasPendingUpdate and "PENDING" or "")
	if force or visible then
		-- clear existing row data for the update
		local rowData = self.rowData
		if not rowData then rowData = {} self.rowData = rowData end
		wipe(rowData)

		data.expanded = true;
		if not self.doesOwnUpdate and force then
			self:ToggleExtraFilters(true)
			app.PrintDebug(Colorize("TLUG", app.Colors.Time),self.Suffix)
			app.TopLevelUpdateGroup(data);
			self.HasPendingUpdate = nil;
			app.PrintDebugPrior("Done")
			self:ToggleExtraFilters()
		end

		-- Should the groups in this window be expanded prior to processing the rows for display
		if self.ExpandInfo then
			-- print("ExpandInfo",self.Suffix,self.ExpandInfo.Expand,self.ExpandInfo.Manual)
			ExpandGroupsRecursively(data, self.ExpandInfo.Expand, self.ExpandInfo.Manual);
			self.ExpandInfo = nil;
		end

		-- cache a couple heavily referenced functions within ProcessGroup
		VisibilityFilter, SortGroup = app.VisibilityFilter, app.SortGroup
		ProcessGroup(rowData, data);
		-- app.PrintDebug("Update:RowData",#rowData)

		-- Does this user have everything?
		if data.total then
			if data.total <= data.progress then
				if #rowData < 1 then
					data.back = 1;
					rowData[#rowData + 1] = data
				end
				if self.missingData then
					if got and visible then app.Audio:PlayCompleteSound(); end
					self.missingData = nil;
				end
				-- only add this info row if there is actually nothing visible in the list
				-- always a header row
				-- print("any data",#self.Container,#rowData,#data)
				if #rowData < 2 then
					rowData[#rowData + 1] = app.CreateRawText(L.NO_ENTRIES, {
						description = L.NO_ENTRIES_DESC,
						collectible = 1,
						collected = 1,
						back = 0.7,
						OnClick = app.UI.OnClick.IgnoreRightClick
					})
				end
			else
				self.missingData = true;
			end
		else
			self.missingData = nil;
		end

		self:Refresh();
		-- app.PrintDebugPrior("Update:Done")
		return true;
	else
		local expireTime = self.ExpireTime;
		-- print("check ExpireTime",self.Suffix,expireTime)
		if expireTime and expireTime > 0 and expireTime < time() then
			-- app.PrintDebug(self.Suffix,"window is expired, removing from window cache")
			self:RemoveEventHandlers()
			app.Windows[self.Suffix] = nil;
		end
	end
	-- app.PrintDebugPrior("Update:None")
end
local function ClearRowData(self)
	self.__ref = self.ref
	self.ref = nil;
	self.Background:Hide();
	self.Texture:Hide();
	self.Texture.Background:Hide();
	self.Texture.Border:Hide();
	self.Indicator:Hide();
	self.Summary:Hide();
	self.Label:Hide();
end
local function CalculateRowIndent(data)
	if data.indent then return data.indent; end
	if data.parent then
		return CalculateRowIndent(data.parent) + 1;
	else
		return 0;
	end
end
local function CalculateRowBack(data)
	if data.back then return data.back; end
	if data.parent then
		return CalculateRowBack(data.parent) * 0.5;
	else
		return 0;
	end
end
local PortaitSettingsCache = setmetatable({}, {__index = app.ReturnTrue })
do
	local function CachePortraitSettings()
		PortaitSettingsCache.ALL = app.Settings:GetTooltipSetting("IconPortraits")
		PortaitSettingsCache.questID = app.Settings:GetTooltipSetting("IconPortraitsForQuests")
	end
	app.AddEventHandler("OnStartup", CachePortraitSettings)
	app.AddEventHandler("OnRenderDirty", CachePortraitSettings)
end
local function SetPortraitIcon(self, data)
	if PortaitSettingsCache.ALL and PortaitSettingsCache[data.key] then
		local displayID = GetDisplayID(data);
		if displayID then
			SetPortraitTextureFromDisplayID(self, displayID);
			self:SetTexCoord(0, 1, 0, 1);
			return true;
		elseif data.unit and not data.icon then
			SetPortraitTexture(self, data.unit);
			self:SetTexCoord(0, 1, 0, 1);
			return true;
		end
	end

	-- Fallback to a traditional icon.
	if data.atlas then
		self:SetAtlas(data.atlas);
		self:SetTexCoord(0, 1, 0, 1);
		if data["atlas-background"] then
			self.Background:SetAtlas(data["atlas-background"]);
			self.Background:SetWidth(self:GetHeight());
			self.Background:Show();
		end
		if data["atlas-border"] then
			self.Border:SetAtlas(data["atlas-border"]);
			self.Border:SetWidth(self:GetHeight());
			self.Border:Show();
			if data["atlas-color"] then
				local swatches = data["atlas-color"];
				self.Border:SetVertexColor(swatches[1], swatches[2], swatches[3], swatches[4] or 1.0);
			else
				self.Border:SetVertexColor(1, 1, 1, 1.0);
			end
		end
		return true;
	elseif data.icon then
		self:SetTexture(data.icon);
		local texcoord = data.texcoord;
		if texcoord then
			self:SetTexCoord(texcoord[1], texcoord[2], texcoord[3], texcoord[4]);
		else
			self:SetTexCoord(0, 1, 0, 1);
		end
		return true;
	end
	-- anything without an icon ends up with weird spacing in lists
	self:SetTexture(QUESTION_MARK_ICON);
	return true
end
local function SetIndicatorIcon(self, data)
	local texture = app.GetIndicatorIcon(data);
	if texture then
		self:SetTexture(texture);
		return true;
	end
end
local function GetReagentIcon(data, iconOnly)
	if data.filledReagent then
		return L[iconOnly and "REAGENT_ICON" or "REAGENT_TEXT"];
	end
end
local function GetUpgradeIconForRow(data, iconOnly)
	-- upgrade only for filled groups, or if itself is an upgrade
	if data.filledUpgrade or data.isUpgrade or (data.progress == data.total and ((data.upgradeTotal or 0) > 0)) then
		return L[iconOnly and "UPGRADE_ICON" or "UPGRADE_TEXT"];
	end
end
local function GetCostIconForRow(data, iconOnly)
	-- cost only for filled groups, or if itself is a cost
	if data.filledCost or data.isCost or (data.progress == data.total and ((data.costTotal or 0) > 0)) then
		return L[iconOnly and "COST_ICON" or "COST_TEXT"];
	end
end
local function GetCollectibleIcon(data, iconOnly)
	if data.collectible then
		local collected = data.collected
		if not collected and data.collectedwarband then
			return iconOnly and L.COLLECTED_WARBAND_ICON or L.COLLECTED_WARBAND;
		end
		return iconOnly and app.GetCollectionIcon(collected) or app.GetCollectionText(collected);
	end
end
local function GetTrackableIcon(data, iconOnly, forSaved)
	if data.trackable then
		local saved = data.saved;
		-- only show if the data is saved, or is not repeatable
		if saved or not rawget(data, "repeatable") then
			if forSaved then
				-- if for saved, we ignore if it is un-saved for less clutter
				if saved then
					return iconOnly and app.GetCompletionIcon(saved) or app.GetSavedText(saved);
				end
			else
				return iconOnly and app.GetCompletionIcon(saved) or app.GetCompletionText(saved);
			end
		end
	end
end
local function GetProgressTextForRow(data)
	-- build the row text from left to right with possible info
	local text = {}
	-- Reagent (show reagent icon)
	local icon = GetReagentIcon(data, true);
	if icon then
		text[#text + 1] = icon
	end
	-- Cost (show cost icon)
	icon = GetCostIconForRow(data, true);
	if icon then
		text[#text + 1] = icon
	end
	-- Upgrade (show upgrade icon)
	icon = GetUpgradeIconForRow(data, true);
	if icon then
		text[#text + 1] = icon
	end
	-- Progress Achievement
	local statistic = data.statistic
	if statistic then
		text[#text + 1] = "["..statistic.."]"
	end
	-- Collectible
	local stateIcon = GetCollectibleIcon(data, true)
	if stateIcon then
		text[#text + 1] = stateIcon
	end
	-- Container
	local total = data.total;
	local isContainer = total and (total > 1 or (total > 0 and not data.collectible));
	if isContainer then
		local textContainer = GetProgressColorText(data.progress or 0, total)
		text[#text + 1] = textContainer
	end
	-- Non-collectible/total Container (only contains visible, non-collectibles...)
	local g = data.g;
	if not stateIcon and not isContainer and g and #g > 0 then
		local headerText;
		if data.expanded then
			headerText = "---";
		else
			headerText = "+++";
		end
		text[#text + 1] = headerText
	end

	-- Trackable (Only if no other text available)
	if #text == 0 then
		stateIcon = GetTrackableIcon(data, true)
		if stateIcon then
			text[#text + 1] = stateIcon
		end
	end

	return app.TableConcat(text, nil, "", " ");
end
local function BuildDataSummary(data)
	local summary = {}
	local requireSkill = data.requireSkill
	if requireSkill then
		local profIcon = GetTradeSkillTexture(requireSkill)
		if profIcon then
			summary[#summary + 1] = "|T"..profIcon..":0|t "
		end
	end
	-- TODO: races
	local specs = data.specs;
	if specs and #specs > 0 then
		summary[#summary + 1] = GetSpecsString(specs, false, false)
	else
		local classes = data.c
		if classes and #classes > 0 then
			summary[#summary + 1] = GetClassesString(classes, false, false)
		end
	end
	summary[#summary + 1] = GetProgressTextForRow(data) or "---"
	return app.TableConcat(summary, nil, "", "")
end
local function SetRowData(self, row, data)
	ClearRowData(row);
	if data then
		local text = data.text;
		if IsRetrieving(text) then
			text = RETRIEVING_DATA;
			self.processingLinks = true;
		end
		local leftmost, relative, rowPad = row, "LEFT", 8;
		local x = CalculateRowIndent(data) * rowPad + rowPad;
		row.indent = x;
		local back = CalculateRowBack(data);
		row.ref = data;
		if back then
			row.Background:SetAlpha(back or 0.2);
			row.Background:Show();
		end
		local rowTexture = row.Texture;
		-- this will always be true due to question mark fallback
		if SetPortraitIcon(rowTexture, data) then
			rowTexture.Background:SetPoint("TOPLEFT", rowTexture);
			rowTexture.Border:SetPoint("TOPLEFT", rowTexture);
			rowTexture:SetPoint("LEFT", leftmost, relative, x, 0);
			rowTexture:Show();
			leftmost = rowTexture;
			relative = "RIGHT";
			x = rowPad / 4;
		end
		local rowIndicator = row.Indicator;
		-- indicator is always attached to the Texture
		if SetIndicatorIcon(rowIndicator, data) then
			rowIndicator:SetPoint("RIGHT", rowTexture, "LEFT")
			rowIndicator:Show();
		end
		local rowSummary = row.Summary;
		local rowLabel = row.Label;
		rowSummary:SetText(BuildDataSummary(data));
		-- for whatever reason, the Client does not properly align the Points when textures are used within the 'text' of the object, with each texture added causing a 1px offset on alignment
		-- 2022-03-15 It seems as of recently that text with textures now render properly without the need for a manual adjustment. Will leave the logic in here until confirmed for others as well
		-- 2023-07-25 The issue is caused due to ATT list scaling. With scaling other than 1 applied, the icons within the text shift relative to the number of icons
		-- rowSummary:SetPoint("RIGHT", iconAdjust, 0);
		rowSummary:Show();
		rowLabel:SetText(TryColorizeName(data, text));
		rowLabel:SetPoint("LEFT", leftmost, relative, x, 0);
		rowLabel:SetPoint("RIGHT");
		rowLabel:Show();
		rowLabel:SetPoint("RIGHT", rowSummary, "LEFT");
		if data.font then
			rowLabel:SetFontObject(data.font);
			rowSummary:SetFontObject(data.font);
		else
			rowLabel:SetFontObject("GameFontNormal");
			rowSummary:SetFontObject("GameFontNormal");
		end
		row:Show();
	else
		row:Hide();
	end
end
local function AdjustRowIndent(row, indentAdjust)
	-- only ever LEFT point set
	if not row.Texture:IsShown() then return end
	local _, _, _, x = row.Texture:GetPointByName("LEFT")
	local offset = x - indentAdjust
	-- app.PrintDebug("row texture at",x,indentAdjust,offset)
	row.Texture:SetPoint("LEFT", row, "LEFT", offset, 0);
end
local function ClearRowData(self)
	self.__ref = self.ref
	self.ref = nil;
	self.Background:Hide();
	self.Texture:Hide();
	self.Texture.Background:Hide();
	self.Texture.Border:Hide();
	self.Indicator:Hide();
	self.Summary:Hide();
	self.Label:Hide();
end
local function Refresh(self)
	if not self:IsVisible() then return; end
	-- app.PrintDebug(Colorize("Refresh:", app.Colors.TooltipDescription),self.Suffix)
	local height = self:GetHeight();
	if height > 80 then
		self.ScrollBar:Show();
		self.CloseButton:Show();
	elseif height > 40 then
		self.ScrollBar:Hide();
		self.CloseButton:Show();
	else
		self.ScrollBar:Hide();
		self.CloseButton:Hide();
	end

	-- If there is no raw data, then return immediately.
	local rowData = self.rowData;
	if not rowData then return; end

	-- Make it so that if you scroll all the way down, you have the ability to see all of the text every time.
	local totalRowCount = #rowData;
	if totalRowCount <= 0 then return; end

	-- Fill the remaining rows up to the (visible) row count.
	local container, windowPad, minIndent = self.Container, 0, nil;
	local current = math.max(1, math.min(self.ScrollBar.CurrentValue, totalRowCount)) + 1

	-- Ensure that the first row doesn't move out of position.
	local row = container.rows[1]
	SetRowData(self, row, rowData[1]);

	local containerHeight = container:GetHeight();
	local rowHeight = row:GetHeight()
	local rowCount = math.floor(containerHeight / rowHeight)

	for i=2,rowCount do
		row = container.rows[i]
		SetRowData(self, row, rowData[current]);
		-- track the minimum indentation within the set of rows so they can be adjusted later
		if row.indent and (not minIndent or row.indent < minIndent) then
			minIndent = row.indent;
			-- print("new minIndent",minIndent)
		end
		current = current + 1;
	end

	-- Readjust the indent of visible rows
	-- if there's actually an indent to adjust on top row (due to possible indicator)
	row = container.rows[1];
	if row.indent ~= windowPad then
		AdjustRowIndent(row, row.indent - windowPad);
		-- increase the window pad extra for sub-rows so they will indent slightly more than the header row with indicator
		windowPad = windowPad + 8;
	else
		windowPad = windowPad + 4;
	end
	-- local headerAdjust = 0;
	-- if startIndent ~= 8 then
	--	-- header only adjust
	-- 	headerAdjust = startIndent - 8;
	-- 	print("header adjust",headerAdjust)
	-- 	row = container.rows[1];
	-- 	AdjustRowIndent(row, headerAdjust);
	-- end
	-- adjust remaining rows to align on the left
	if minIndent and minIndent ~= windowPad then
		-- print("minIndent",minIndent,windowPad)
		local adjust = minIndent - windowPad;
		for i=2,rowCount do
			row = container.rows[i];
			AdjustRowIndent(row, adjust);
		end
	end

	-- Hide the extra rows if any exist
	for i=math.max(2, rowCount + 1),#container.rows do
		row = container.rows[i];
		ClearRowData(row);
		row:Hide();
	end

	-- Every possible row is visible
	if totalRowCount - rowCount < 1 then
		-- app.PrintDebug("Hide scrollbar")
		self.ScrollBar:SetMinMaxValues(1, 1);
		self.ScrollBar:SetStepsPerPage(0);
		self.ScrollBar:Hide();
	else
		-- self.ScrollBar:Show();
		totalRowCount = totalRowCount + 1;
		self.ScrollBar:SetMinMaxValues(1, totalRowCount - rowCount);
		self.ScrollBar:SetStepsPerPage(rowCount - 2);
	end

	-- If this window has an UpdateDone method which should process after the Refresh is complete
	if self.UpdateDone then
		-- print("Refresh-UpdateDone",self.Suffix)
		Callback(self.UpdateDone, self);
	-- If the rows need to be processed again, do so next update.
	elseif self.processingLinks then
		-- print("Refresh-processingLinks",self.Suffix)
		Callback(self.Refresh, self);
		self.processingLinks = nil;
	end
	-- app.PrintDebugPrior("Refreshed:",self.Suffix)
	if GameTooltip and GameTooltip:IsVisible() then
		local row = GameTooltip:GetOwner()
		if row and row.__ref ~= row.ref then
			-- app.PrintDebug("owner.ref",app:SearchLink(row.ref))
			-- force tooltip to refresh since the scroll has changed for but the tooltip is still visible
			local OnLeave = row:GetScript("OnLeave")
			local OnEnter = row:GetScript("OnEnter")
			OnLeave(row)
			OnEnter(row)
		end
	end
end
local StoreWindowPosition = function(self)
	if AllTheThingsProfiles then
		local key = app.Settings:GetProfile();
		local profile = AllTheThingsProfiles.Profiles[key];
		-- not entirely sure how this is able to happen, but just ignore for now
		if not profile then return end
		if self.isLocked or self.lockPersistable then
			if not profile.Windows then profile.Windows = {}; end
			-- re-save the window position by point anchors
			local points = {};
			profile.Windows[self.Suffix] = points;
			for i=1,self:GetNumPoints() do
				local point, _, refPoint, x, y = self:GetPoint(i);
				points[i] = { Point = point, PointRef = refPoint, X = math.floor(x), Y = math.floor(y) };
			end
			points.Width = math.floor(self:GetWidth());
			points.Height = math.floor(self:GetHeight());
			points.Locked = self.isLocked or nil;
			-- print("saved window",self.Suffix)
			-- app.PrintTable(points)
		else
			-- a window which was potentially saved due to being locked, but is now being unlocked (unsaved)
			-- print("removing stored window",self.Suffix)
			if profile.Windows then
				profile.Windows[self.Suffix] = nil;
			end
		end
	end
end
-- Allows a Window to set the root data object to itself and link the Window to the root data, if data exists
local function SetData(self, data)
	-- app.PrintDebug("Window:SetData",self.Suffix,data.text)
	self.data = data;
	if data then
		data.window = self;
	end
end
-- Allows a Window to build the groups hierarcy if it has .data
local function BuildData(self)
	local data = self.data;
	if data then
		-- app.PrintDebug("Window:BuildData",self.Suffix,data.text)
		AssignChildren(data);
	end
end
-- returns a Runner specific to the 'self' window
local function GetRunner(self)
	local Runner = self.__Runner
	if Runner then return Runner end
	Runner = app.CreateRunner(self.Suffix)
	self.__Runner = Runner
	return Runner
end
local function ToggleExtraFilters(self, active)
	local filters = self.Filters
	if not filters then return end
	local Set = app.Modules.Filter.Set
	local Setter
	for name,_ in pairs(filters) do
		Setter = Set[name]
		if Setter then Setter(active) end
	end
end
local function OnScrollBarMouseWheel(self, delta)
	self.ScrollBar:SetValue(self.ScrollBar.CurrentValue - delta);
end
local function StopMovingOrSizing(self)
	self:StopMovingOrSizing();
	self.isMoving = nil;
	-- store the window position if the window is visible (this is called on new popouts prior to becoming visible for some reason)
	if self:IsVisible() then
		self:StorePosition();
	end
end
local function StartMovingOrSizing(self, fromChild)
	if not (self:IsMovable() or self:IsResizable()) or self.isLocked then
		return
	end
	if self.isMoving then
		StopMovingOrSizing(self);
	else
		self.isMoving = true;
		if ((select(2, GetCursorPosition()) / self:GetEffectiveScale()) < math.max(self:GetTop() - 40, self:GetBottom() + 10)) then
			self:StartSizing();
			Push(self, "StartMovingOrSizing (Sizing)", function()
				if self.isMoving then
					-- keeps the rows within the window fitting to the window as it resizes
					self:Refresh();
					return true;
				end
			end);
		elseif self:IsMovable() then
			self:StartMoving();
		end
	end
end
local backdrop = {
	bgFile = 137056,
	edgeFile = 137057,
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
};
-- Shared Panel Functions
local function OnCloseButtonPressed(self)
	self:GetParent():Hide();
end
local function OnScrollBarValueChanged(self, value)
	if self.CurrentValue ~= value then
		self.CurrentValue = value;
		local window = self:GetParent()
		Callback(window.Refresh, window)
	end
end

local NewWindowRowContainer
do
local HandleEvent = app.HandleEvent
local function RowOnClick(self, button)
	HandleEvent("RowOnClick", self, button)
end
local function RowOnEnter(self)
	HandleEvent("RowOnEnter", self)
end
local function RowOnLeave(self)
	HandleEvent("RowOnLeave", self)
end
local function CreateRow(rows, i)
	local container, index = rows.__container, i - 1
	---@class ATTRowButtonClass: Button
	local row = CreateFrame("Button", nil, container);
	row.index = index
	rows[i] = row
	if index == 0 then
		-- This means relative to the parent.
		row:SetPoint("TOPLEFT");
		row:SetPoint("TOPRIGHT");
	else
		-- This means relative to the row above this one.
		local aboveRow = rows[index] or CreateRow(rows, index)
		row:SetPoint("TOPLEFT", aboveRow, "BOTTOMLEFT");
		row:SetPoint("TOPRIGHT", aboveRow, "BOTTOMRIGHT");
	end

	-- Setup highlighting and event handling
	row:SetHighlightTexture(136810, "ADD");
	row:RegisterForClicks("LeftButtonDown","RightButtonDown");
	row:SetScript("OnClick", RowOnClick);
	row:SetScript("OnEnter", RowOnEnter);
	row:SetScript("OnLeave", RowOnLeave);
	row:EnableMouse(true);

	-- Label is the text information you read.
	row.Label = row:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	row.Label:SetJustifyH("LEFT");
	row.Label:SetPoint("BOTTOM");
	row.Label:SetPoint("TOP");
	row:SetHeight(select(2, row.Label:GetFont()) + 4);
	local rowHeight = row:GetHeight()

	-- Summary is the completion summary information. (percentage text)
	row.Summary = row:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	row.Summary:SetJustifyH("RIGHT");
	row.Summary:SetPoint("BOTTOM");
	row.Summary:SetPoint("RIGHT");
	row.Summary:SetPoint("TOP");

	-- Background is used by the Map Highlight functionality.
	row.Background = row:CreateTexture(nil, "BACKGROUND");
	row.Background:SetAllPoints();
	row.Background:SetPoint("LEFT", 4, 0);
	row.Background:SetTexture(136810);

	-- Indicator is used by the Instance Saves functionality.
	row.Indicator = row:CreateTexture(nil, "ARTWORK");
	row.Indicator:SetPoint("BOTTOM");
	row.Indicator:SetPoint("TOP");
	row.Indicator:SetWidth(rowHeight);

	-- Texture is the icon.
	---@class ATTRowButtonTextureClass: Texture
	row.Texture = row:CreateTexture(nil, "ARTWORK");
	row.Texture:SetPoint("BOTTOM");
	row.Texture:SetPoint("TOP");
	row.Texture:SetWidth(rowHeight);
	row.Texture.Background = row:CreateTexture(nil, "BACKGROUND");
	row.Texture.Background:SetPoint("BOTTOM");
	row.Texture.Background:SetPoint("TOP");
	row.Texture.Background:SetWidth(rowHeight);
	row.Texture.Border = row:CreateTexture(nil, "BORDER");
	row.Texture.Border:SetPoint("BOTTOM");
	row.Texture.Border:SetPoint("TOP");
	row.Texture.Border:SetWidth(rowHeight);

	-- Forced/External Update of a Tooltip produced by an ATT row to use the same function which created it
	row.UpdateTooltip = RowOnEnter;

	-- Clear the Row Data Initially
	ClearRowData(row);
	return row;
end
NewWindowRowContainer = function(container)
	return setmetatable({__container=container}, { __index = function(t,i)
		return CreateRow(t,i)
	end})
end
end

-- allows a window to keep track of any specific custom handler functions it creates
local function AddEventHandler(self, event, handler)
	self.Handlers = self.Handlers or {}
	app.AddEventHandler(event, handler)
	self.Handlers[#self.Handlers + 1] = handler
end
-- allows a window to remove all event handlers it created
local function RemoveEventHandlers(self)
	if self.Handlers then
		for _,handler in ipairs(self.Handlers) do
			app.RemoveEventHandler(handler)
		end
	end
end
-- allows a window to stop being moved/resized by the cursor
local function StopATTMoving(self)
	self:StopMovingOrSizing();
	self.isMoving = nil;
	-- store the window position if the window is visible (this is called on new popouts prior to becoming visible for some reason)
	if self:IsVisible() then
		self:StorePosition()
	end
end
local function SelfMoveRefresher(self)
	if self.isMoving then
		-- keeps the rows within the window fitting to the window as it resizes
		self:Refresh()
		return true
	end
end
local function ToggleATTMoving(self)
	if self.isMoving then
		self:StopATTMoving()
		return
	end

	if not (self:IsMovable() or self:IsResizable()) or self.isLocked then
		return
	end

	if ((select(2, GetCursorPosition()) / self:GetEffectiveScale()) < math.max(self:GetTop() - 40, self:GetBottom() + 10)) then
		self:StartSizing()
		self.isMoving = true
		Push(self, "StartMovingOrSizing (Sizing)", SelfMoveRefresher)
	elseif self:IsMovable() then
		self:StartMoving()
		self.isMoving = true
	end
end
function app:GetWindow(suffix, parent, onUpdate)
	if app.GetCustomWindowParam(suffix, "reset") then
		ResetWindow(suffix);
	end
	local window = app.Windows[suffix];
	if window then return window end

	-- Create the window instance.
	-- app.PrintDebug("GetWindow",suffix)
	---@class ATTWindowFrameForRetail: BackdropTemplate, Frame
	window = CreateFrame("Frame", appName .. "-Window-" .. suffix, parent or UIParent, BackdropTemplateMixin and "BackdropTemplate");
	app.Windows[suffix] = window;
	window.Suffix = suffix;
	window.Toggle = Toggle;
	local updateFunc = onUpdate or app:CustomWindowUpdate(suffix) or UpdateWindow;
	-- Update/Refresh functions can be called through callbacks, so they need to be distinct functions
	window.BaseUpdate = function(...) UpdateWindow(...) end;
	window.Update = function(...) updateFunc(...) end;
	window.Refresh = function(...) Refresh(...) end;
	window.StopATTMoving = StopATTMoving
	window.ToggleATTMoving = ToggleATTMoving
	window.SetVisible = SetVisible;
	window.StorePosition = StoreWindowPosition;
	window.SetData = SetData;
	window.BuildData = BuildData;
	window.GetRunner = GetRunner;
	window.ToggleExtraFilters = ToggleExtraFilters

	window:SetScript("OnMouseWheel", OnScrollBarMouseWheel);
	window:SetScript("OnMouseDown", StartMovingOrSizing);
	window:SetScript("OnMouseUp", StopMovingOrSizing);
	window:SetScript("OnHide", StopMovingOrSizing);
	window:SetBackdrop(backdrop);
	window:SetBackdropBorderColor(1, 1, 1, 1);
	window:SetBackdropColor(0, 0, 0, 1);
	window:SetClampedToScreen(true);
	window:SetToplevel(true);
	window:EnableMouse(true);
	window:SetMovable(true);
	window:SetResizable(true);
	window:SetPoint("CENTER");
	window:SetResizeBounds(96, 32);
	window:SetSize(300, 300);

	-- set the scaling for the new window if settings have been initialized
	local scale = app.Settings and app.Settings._Initialize and (suffix == "Prime" and app.Settings:GetTooltipSetting("MainListScale") or app.Settings:GetTooltipSetting("MiniListScale")) or 1;
	window:SetScale(scale);

	window:SetUserPlaced(true);
	window.data = {}

	-- set whether this window lock is persistable between sessions
	if suffix == "Prime" or suffix == "CurrentInstance" or suffix == "RaidAssistant" or suffix == "WorldQuests" then
		window.lockPersistable = true;
	end

	window:Hide();

	-- The Close Button. It's assigned as a local variable so you can change how it behaves.
	window.CloseButton = CreateFrame("Button", nil, window, "UIPanelCloseButton");
	window.CloseButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", -1, -1);
	window.CloseButton:SetSize(20, 20);
	window.CloseButton:SetScript("OnClick", OnCloseButtonPressed);

	-- The Scroll Bar.
	---@class ATTWindowScrollBar: Slider
	local scrollbar = CreateFrame("Slider", nil, window, "UIPanelScrollBarTemplate");
	scrollbar:SetPoint("TOP", window.CloseButton, "BOTTOM", 0, -15);
	scrollbar:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -4, 36);
	scrollbar:SetScript("OnValueChanged", OnScrollBarValueChanged);
	scrollbar.back = scrollbar:CreateTexture(nil, "BACKGROUND");
	scrollbar.back:SetColorTexture(0.1,0.1,0.1,1);
	scrollbar.back:SetAllPoints(scrollbar);
	scrollbar:SetMinMaxValues(1, 1);
	scrollbar:SetValueStep(1);
	scrollbar:SetValue(1);
	scrollbar:SetObeyStepOnDrag(true);
	scrollbar.CurrentValue = 1;
	scrollbar:SetWidth(16);
	scrollbar:EnableMouseWheel(true);
	window:EnableMouseWheel(true);
	window.ScrollBar = scrollbar;

	-- The Corner Grip. (this isn't actually used, but it helps indicate to players that they can do something)
	local grip = window:CreateTexture(nil, "ARTWORK");
	grip:SetTexture(app.asset("grip"));
	grip:SetSize(16, 16);
	grip:SetTexCoord(0,1,0,1);
	grip:SetPoint("BOTTOMRIGHT", -5, 5);
	window.Grip = grip;

	-- The Row Container. This contains all of the row frames.
	---@class ATTWindowContainer: Frame
	local container = CreateFrame("Frame", nil, window);
	container:SetPoint("TOPLEFT", window, "TOPLEFT", 5, -5);
	container:SetPoint("RIGHT", scrollbar, "LEFT", -1, 0);
	container:SetPoint("BOTTOM", window, "BOTTOM", 0, 6);
	-- container:SetClipsChildren(true);
	window.Container = container;
	container.rows = NewWindowRowContainer(container)
	container:Show();

	-- Setup the Event Handlers
	-- TODO: review how necessary this actually is in Retail
	local handlers = {};
	window:SetScript("OnEvent", function(self, e, ...)
		local handler = handlers[e];
		if handler then
			handler(self, ...);
		else
			app.PrintDebug("Unhandled Window Event",e,...)
			self:Update();
		end
	end);
	local refreshWindow = function() DelayedCallback(window.Refresh, 0.25, window) end;
	handlers.ACHIEVEMENT_EARNED = refreshWindow;
	handlers.QUEST_DATA_LOAD_RESULT = refreshWindow;
	handlers.QUEST_ACCEPTED = refreshWindow;
	handlers.QUEST_REMOVED = refreshWindow;
	window:RegisterEvent("ACHIEVEMENT_EARNED");
	window:RegisterEvent("QUEST_ACCEPTED");
	window:RegisterEvent("QUEST_DATA_LOAD_RESULT");
	window:RegisterEvent("QUEST_REMOVED");

	window.AddEventHandler = AddEventHandler
	window.RemoveEventHandlers = RemoveEventHandlers

	-- Some Window functions should be triggered from ATT events
	window:AddEventHandler("OnUpdateWindows", function(...)
		window:Update(...)
	end)
	window:AddEventHandler("OnRefreshWindows", function(...)
		window:Refresh(...)
	end)

	-- Ensure the window updates itself when opened for the first time
	window.HasPendingUpdate = true;
	-- TODO: eventually remove this when Windows are re-designed to have an OnInit/OnUpdate distinction for Retail
	window:Update();
	return window;
end

-- TODO: Refactoring
-- Some windows still new to be 'loaded' so they can setup their logic about when to show/hide
app.AddEventHandler("OnReady", function()
	app:GetWindow("AuctionData")
	app:GetWindow("Tradeskills")
end)

local function ToggleMiniListForCurrentZone()
	local window = app:GetWindow("CurrentInstance");
	if window:IsVisible() then
		window:Hide();
	else
		window.RefreshLocation(true);
	end
end
app.ToggleMiniListForCurrentZone = ToggleMiniListForCurrentZone;

local function LocationTrigger(forceNewMap)
	if not app.InWorld or not app.IsReady then return end
	local window = app:GetWindow("CurrentInstance");
	if not window:IsVisible() then return end
	-- app.PrintDebug("LocationTrigger-Callback")
	if forceNewMap then
		-- this allows minilist to rebuild itself
		wipe(window.CurrentMaps)
	end
	AfterCombatOrDelayedCallback(window.RefreshLocation, 0.25);
end
app.LocationTrigger = LocationTrigger;
app.AddEventHandler("OnCurrentMapIDChanged", LocationTrigger);

app.ToggleMainList = function()
	app:GetWindow("Prime"):Toggle();
end

-- TODO: figure out why minilist doesn't re-show itself sometimes, then make auto-hiding of windows configurable in some way...
-- app.AddEventRegistration("PET_BATTLE_OPENING_START", function(...)
-- 	-- check for open ATT windows
-- 	for _,window in pairs(app.Windows) do
-- 		if window:IsVisible() then
-- 			if not app.PetBattleClosed then app.PetBattleClosed = {}; end
-- 			tinsert(app.PetBattleClosed, window);
-- 			window:Toggle();
-- 		end
-- 	end
-- end)
-- this fires twice when pet battle ends
-- app.AddEventRegistration("PET_BATTLE_CLOSE", function(...)
-- 	-- app.PrintDebug("PET_BATTLE_CLOSE",app.PetBattleClosed and #app.PetBattleClosed)
-- 	if app.PetBattleClosed then
-- 		for _,window in ipairs(app.PetBattleClosed) do
-- 			-- special open for Current Instance list
-- 			if window.Suffix == "CurrentInstance" then
-- 				DelayedCallback(app.ToggleMiniListForCurrentZone, 1);
-- 			else
-- 				window:Toggle();
-- 			end
-- 		end
-- 		app.PetBattleClosed = nil;
-- 	end
-- end)