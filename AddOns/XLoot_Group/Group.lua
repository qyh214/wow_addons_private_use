-- Create module
local addon, L = XLoot:NewModule("Group")
-- Prepare global
XLootGroup = addon
-- Grab locals
local opt, anchor, alert_anchor, mouse_focus, Skinner
local rolls = {}
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS
local GetLootRollItemInfo, GetLootRollItemLink, GetLootRollTimeLeft, RollOnLoot, UnitGroupRolesAssigned, print, string_format
	= GetLootRollItemInfo, GetLootRollItemLink, GetLootRollTimeLeft, RollOnLoot, UnitGroupRolesAssigned, print, string.format
local HistoryGetItem, HistoryGetPlayerInfo, HistoryGetNumItems
	= C_LootHistory.GetItem, C_LootHistory.GetPlayerInfo, C_LootHistory.GetNumItems
local CanEquipItem, IsItemUpgrade, FancyPlayerName = XLoot.CanEquipItem, XLoot.IsItemUpgrade, XLoot.FancyPlayerName
local RollFramePrototype


-------------------------------------------------------------------------------
-- Settings

local defaults = {
	profile = {
		role_icon = true,
		win_icon = false,
		show_decided = true,
		show_undecided = false,
		show_time_remaining = false,
		text_ilvl = false,

		equip_prefix = true,
		prefix_equippable = "*",
		prefix_upgrade = "+",

		hook_alert = false,
		alert_skin = true,
		alert_alpha = 1,
		alert_scale = 1,
		alert_offset = 4,
		alert_background = false,
		alert_icon_frame = false,

		hook_bonus = false,
		bonus_skin = true,

		roll_button_size = 28,
		roll_width = 325,

		font = STANDARD_TEXT_FONT,
		font_flag = "OUTLINE",

		roll_anchor = {
			direction = 'up',
			spacing = 2,
			offset = 0,
			visible = true,
			draggable = true,
			scale = 1.0,
			x = UIParent:GetWidth() * .75,
			y = UIParent:GetHeight() * .4
		},

		alert_anchor = {
			visible = true,
			direction = 'up',
			draggable = true,
			scale = 1.0,
			x = AlertFrame:GetLeft(),
			y = AlertFrame:GetTop()
		},

		track_all = false,
		track_player_roll = false,
		track_by_threshold = true,
		track_threshold = 3,

		expire_won = 20,
		expire_lost = 10,
		shown_hook_warning = false
	}
}

opt = defaults.profile

-------------------------------------------------------------------------------
-- Module init

local eframe = CreateFrame("Frame")
function addon:OnInitialize()
	self:InitializeModule(defaults, eframe)
	opt = self.db.profile
	XLootGroup.opt = opt
	-- Extra slash command
	XLoot:SetSlashCommand("xlg", self.SlashHandler)
end

function addon:OnEnable()
	-- Register events
	eframe:RegisterEvent('START_LOOT_ROLL')
	eframe:RegisterEvent('LOOT_HISTORY_ROLL_CHANGED')
	eframe:RegisterEvent('LOOT_HISTORY_ROLL_COMPLETE')
	eframe:RegisterEvent('LOOT_ROLLS_COMPLETE')
	eframe:RegisterEvent('MODIFIER_STATE_CHANGED')

	-- Disable default frame
	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

	-- Set up skins
	Skinner = {}
	XLoot:MakeSkinner(Skinner, {
		anchor = { r = .4, g = .4, b = .4, a = .6, gradient = false },
		anchor_pretty = { r = .6, g = .6, b = .6, a = .8 },
		row = { gradient = false },
		item = { backdrop = false },
		alert = { gradient = true },
		alert_item = { gradient = true, backdrop = false },
		bonus = { }
	}, 'row')

	-- Create Roll anchor
	anchor = XLoot.Stack:CreateStaticStack(function() return RollFramePrototype:New() end, L.anchor, opt.roll_anchor)
	anchor:SetFrameLevel(7)
	anchor:Scale(opt.roll_anchor.scale)
	addon.anchor = anchor

	-- Create alert anchor
	alert_anchor = XLoot.Stack:CreateAnchor(L.alert_anchor, opt.alert_anchor)
	alert_anchor:SetFrameLevel(7)
	addon.alert_anchor = alert_anchor
	--  DISABLED-PATCH: LEGION PRE-PATCH
	alert_anchor.Show = alert_anchor.Hide
	alert_anchor:Hide()

	-- Skin anchor
	Skinner:Skin(anchor, XLoot.opt.skin_anchors and 'anchor_pretty' or 'anchor')
	Skinner:Skin(alert_anchor, XLoot.opt.skin_anchors and 'anchor_pretty' or 'anchor')

	-- Row fader
	local fader = CreateFrame('Frame')
	local timer = 0
	fader:SetScript('OnUpdate', function(self, elapsed)
		if timer < 1 then
			timer = timer + elapsed
		else
			timer = 0
			local time = GetTime()
			-- Extend expiration for mouseovered frames
			if mouse_focus and mouse_focus.aexpire and (mouse_focus.aexpire - time) < 5 then
				mouse_focus.aexpire = time + 5
			end
			for i=#anchor.expiring,1,-1 do
				local frame = anchor.expiring[i]
				if frame.aexpire and time > frame.aexpire then
					anchor:Pop(frame)
					table.remove(anchor.expiring, i)
				end
			end
			if not next(anchor.expiring) then
				self:Hide()
			end
		end
	end)
	anchor.expiring = {}
	function anchor:Expire(frame, time)
		fader:Show()
		table.insert(self.expiring, frame)
		frame.aexpire = GetTime() + time
	end

	-- Find and show active rolls
	if IsInGroup() and (GetLootMethod() == 'group' or GetLootMethod() == 'needbeforegreed') then
		for i=1,300 do
			local time = GetLootRollTimeLeft(i)
			if time > 0 and time <  300000 then
				self:START_LOOT_ROLL(i, time, true)
			end
		end
	end

	--[[ DISABLED-PATCH: LEGION PRE-PATCH
	-- Hook alert actions
	if opt.hook_alert then
		hooksecurefunc('LootUpgradeFrame_SetUp', self.AlertFrameHook)
		hooksecurefunc('LootWonAlertFrame_SetUp', self.AlertFrameHook)
		hooksecurefunc('MoneyWonAlertFrame_SetUp', self.AlertFrameHook)
		local SetLootWonAnchors = AlertFrame_SetLootWonAnchors
		local SetLootUpgradeFrameAnchors = AlertFrame_SetLootUpgradeFrameAnchors
		local SetMoneyWonAnchors = AlertFrame_SetMoneyWonAnchors

		local function SetAnchorPassthrough(alertAnchor)
			return alertAnchor
		end

		AlertFrame_SetLootWonAnchors = SetAnchorPassthrough
		AlertFrame_SetLootUpgradeFrameAnchors = SetAnchorPassthrough
		AlertFrame_SetMoneyWonAnchors = SetAnchorPassthrough

		hooksecurefunc('AlertFrame_FixAnchors', self.FixAnchors)
	end
	-- hooksecurefunc('BonusRollFrame_StartBonusRoll', self.BonusRollFrame_StartBonusRoll)
	-- hooksecurefunc('BonusRollFrame_FinishedFading', self.BonusRollFrame_Hide)
	-- BonusRollFrame._SetPoint, BonusRollFrame.SetPoint = BonusRollFrame.SetPoint, addon.BonusRollFrame_SetPoint
	if opt.hook_bonus then
		hooksecurefunc(BonusRollFrame, 'SetPoint', self.BonusRollFrame_SetPoint)
		hooksecurefunc(BonusRollFrame, 'Show', self.BonusRollFrame_Show)
		hooksecurefunc(BonusRollFrame, 'Hide', self.BonusRollFrame_Hide)
	end

	if (opt.hook_alert or opt.hook_bonus) and not opt.shown_hook_warning then
		local function gprint(text) print(('%s: %s'):format('|c2244dd22XLoot Group|r', text)) end
		gprint("The 'Modify bonus rolls' or 'Modify loot alerts' options are currently enabled, but are now disabled by default.")
		gprint("I cannot guarantee that you will not experience any issues with bonus rolls with these options enabled.")
		gprint("If you do not accept that risk, please disable those options or XLoot Group entirely. You should only see this message once.")
		opt.shown_hook_warning = true
	end
	]]
end

-------------------------------------------------------------------------------
-- Frame helpers

-------------------------------------------------------------------------------
-- Event handlers

addon.bars = {}
local type_strings = {
	need = NEED,
	greed = GREED,
	disenchant = ROLL_DISENCHANT,
	pass = PASS
}
local rtypes = { [0] = 'pass', 'need', 'greed', 'disenchant' } -- Tekkub. Writing smaller addons than me since ever.

function addon:START_LOOT_ROLL(id, length, uid, ongoing)
	local icon, name, count, quality, bop, need, greed, de, reason_need, reason_greed, reason_de, de_skill = GetLootRollItemInfo(id)
	local link = GetLootRollItemLink(id)
	local r, g, b = GetItemQualityColor(quality)

	local start = length
	if ongoing then
		if quality == 2 then
			length = 60000
		else
			length = 180000
		end
	end
	length, start = length/1000, start/1000

	local frame = anchor:Push()
	rolls[id] = frame

	frame.need:Show()
	frame.greed:Show()
	frame.disenchant:Show()
	frame.pass:Show()
	frame.text_status:Hide()
	frame.text_status:SetText()
	frame.text_time:SetShown(opt.show_time_remaining)

	frame.need.texture_special:SetTexture()
	frame.greed.texture_special:SetTexture()

	if opt.equip_prefix then
		local canequip, isupgrade = CanEquipItem(link), IsItemUpgrade(link)
		if canequip or isupgrade then
			name = string_format("|cFF%s%s|r%s", isupgrade and "44FF22" or "BBBBBB", isupgrade and opt.prefix_upgrade or opt.prefix_equippable, name)
			if isupgrade then
				(need and frame.need or frame.greed).texture_special:SetTexture([[Interface\AddOns\Pawn\Textures\UpgradeArrow.tga]])
			end
		end
	end
	frame.need:Toggle(need)
	frame.greed:Toggle(greed)
	frame.disenchant:Toggle(de)

	frame.need:SetText()
	frame.greed:SetText()
	frame.pass:SetText()
	frame.disenchant:SetText()

	frame.need.reason = reason_need ~= 0 and reason_need or nil
	frame.greed.reason = reason_greed ~= 0 and reason_greed or nil
	frame.disenchant.reason = reason_de ~= 0 and reason_de or nil
	frame.disenchant.skill = de_skill ~= 0 and de_skill or nil

	local bar = frame.bar
	bar.length = length
	bar.expires = GetTime() + start

	frame.link = link
	frame.rollid = id
	frame.rollended = nil
	frame.quality = quality
	frame.expires = bar.expires
	frame.over = nil
	frame.have_rolled = false
	frame.lead_type = 'pass'

	frame.text_bind:SetText(bop and '|cffff4422BoP' or '')
	frame.text_loot:SetText(name)
	local ilvl = GetDetailedItemLevelInfo(link)
	frame.text_ilvl:SetText(ilvl > 1 and ilvl or nil)

	frame.text_loot:SetVertexColor(r, g, b)
	frame.overlay:SetBorderColor(r, g, b)
	frame.icon_frame:SetBorderColor(r, g, b)
	bar:SetStatusBarColor(r, g, b, .7)
	frame.icon:SetTexture(icon)

	bar:SetMinMaxValues(0, length)
	bar:SetValue(start)


	return frame
end

local tidx = { [0] = 1, [3] = 2, [2] = 2, [1] = 3 }
function addon:LOOT_HISTORY_ROLL_COMPLETE()
	-- Locate history item
	local hid, frame, rollid, players, done, _ = 1
	while true do
		rollid, _, players, done = HistoryGetItem(hid)
		if not rollid or (rolls[rollid] and rolls[rollid].over) then
			return
		elseif done and rolls[rollid] then
			frame = rolls[rollid]
			break
		end
		hid = hid+1
	end

	-- Active frame found
	frame.over = true
	local top_type, top_roll, top_pid, top_is_me = 0, 0
	for j=1, players do
		local name, class, rtype, roll, is_winner, is_me = HistoryGetPlayerInfo(hid, j)
		-- roll = roll and roll or true
		if is_winner then
			top_pid = j
			top_is_me = is_me
			break
		elseif rtype ~= 0 and tidx[rtype] >= tidx[top_type] and (not roll or roll > top_roll) then
			top_type = rtype
			top_roll = roll
			top_pid = j
		end
	end

	-- Winner or lead
	if top_pid then
		local name, class = HistoryGetPlayerInfo(hid, top_pid)
		local player, r, g, b = FancyPlayerName(name, class, opt)
		if opt.win_icon then
			if top_type == 'need' then
				player = [[|TInterface\Buttons\UI-GroupLoot-Dice-Up:16:16:-1:-1|t]]..player
			elseif top_type == 'greed' then
				player = [[|TInterface\Buttons\UI-GroupLoot-Coin-Up:16:16:-1:-2|t]]..player
			elseif top_type == 'disenchant' then
				player = [[|TInterface\Buttons\UI-GroupLoot-DE-Up:16:16:-1:-1|t]]..player
			end
		end
		frame.text_status:SetText(player)
		frame.text_status:SetTextColor(r, g, b)
		frame.bar.expires = GetTime()
		anchor:Expire(frame, top_is_me and opt.expire_won or opt.expire_lost)
	else
	-- No winner/lead
		frame.text_status:SetText(string_format('%s: %s', PASS, ALL))
		frame.text_status:SetTextColor(.7, .7, .7)
		frame.bar.expires = GetTime()
		anchor:Expire(frame, opt.expire_lost)
	end
	-- Refresh tooltip
	if frame and mouse_focus == frame then
		frame:OnEnter()
	end
end
addon.LOOT_ROLLS_COMPLETE = addon.LOOT_HISTORY_ROLL_COMPLETE

local rweights = { need = 3, greed = 2, disenchant = 2, pass = 1 }
function addon:LOOT_HISTORY_ROLL_CHANGED(hid, pid)
	-- Acquire roll information and frame
	local rollid, link, players, done = HistoryGetItem(hid)
	local frame = rolls[rollid]
	if not frame or frame.rollid ~= rollid or not frame:IsShown() then
		return nil
	end
	
	-- Acquire player information
	local name, class, rtypeid, roll, winner, is_me = HistoryGetPlayerInfo(hid, pid)
	local rtype = rtypes[rtypeid]

	-- Transition or expire frame on player roll
	if is_me then
		if 	opt.track_all
			or (opt.track_player_roll and rtype ~= 'pass')
			or (opt.track_by_threshold and frame.quality >= opt.track_threshold) then
			frame.need:Hide()
			frame.greed:Hide()
			frame.disenchant:Hide()
			frame.pass:Hide()
			frame.text_status:Show()
			frame.have_rolled = true
		else
			anchor:Pop(frame)
			return
		end
	end

	-- Update post-player-roll status text
	if frame.have_rolled then
		local rtype = rtype == 'disenchant' and 'greed' or rtype
		-- Roll of leading type or higher
		if rweights[rtype] >= rweights[frame.lead_type] then
			frame.lead_type = rtype
			local bracket, mtype = 0, nil
			for i=1, players do
				local _, _, ptype, _, _, is_me = HistoryGetPlayerInfo(hid, i)
				local ptype = rtypes[ptype == 3 and 2 or ptype]
				if ptype == rtype then
					bracket = bracket + 1
				end
				if is_me then
					mtype = ptype
				end
			end

			local r, g, b = .7, .7, .7
			if mtype == rtype then
				r, g, b = .2, 1, .1
			elseif mtype and mtype ~= 0 then
				r, g, b = 1, .2, .1
			end
			frame.text_status:SetText(string_format('%s: %s', type_strings[rtype], bracket))
			frame.text_status:SetTextColor(r, g, b)
		end

	-- Update roll button counters
	else
		local bracket = 0
		for i=1, players do
			local _, _, thistype = HistoryGetPlayerInfo(hid, i)
			if thistype == rtypeid then
				bracket = bracket + 1
			end
		end
		frame[rtype]:SetText(bracket)
	end

	-- Refresh tooltip
	if frame and mouse_focus == frame then
		frame:OnEnter()
	end
end

function addon:MODIFIER_STATE_CHANGED()
	if mouse_focus and MouseIsOver(mouse_focus) and mouse_focus.OnEnter then
		mouse_focus:OnEnter()
	end
end

local alert_frames = {}
function addon.AlertFrameHook(alert)
	-- Reskin toast
	local elements = alert_frames[alert]
	if not elements then
		elements = {}
		if not (opt.alert_background and opt.alert_icon_frame) then
			local name
			if alert.ItemName then
				name = alert.ItemName
				alert.Label:ClearAllPoints()
				alert.Label:SetPoint('TOPLEFT', alert.Icon, 'TOPRIGHT', 15, -5)
			elseif alert.BaseQualityItemName then
				name = alert.BaseQualityItemName
				alert.TitleText:ClearAllPoints()
				alert.TitleText:SetPoint('TOPLEFT', alert.Icon, 'TOPRIGHT', 15, -2)
			elseif alert.Amount then
				name = alert.Amount
				alert.Label:ClearAllPoints()
				alert.Label:SetPoint('TOPLEFT', alert.Icon, 'TOPRIGHT', 15, -2)
			end
			name:ClearAllPoints()
			name:SetPoint('LEFT', alert.Icon, 'RIGHT', 10, -6)
		end
		if opt.alert_skin then
			local overlay = CreateFrame('Frame', nil, alert, BackdropTemplateMixin and "BackdropTemplate")
			overlay:SetPoint('TOPLEFT', 11, -11)
			overlay:SetPoint('BOTTOMRIGHT', -11, 11)
			overlay:SetFrameLevel(alert:GetFrameLevel())
			elements.overlay = overlay
			Skinner:Skin(overlay, 'alert')
			if opt.alert_background then
				local backdrop = CreateFrame('Frame', nil, alert, BackdropTemplateMixin and "BackdropTemplate")
				backdrop:SetAllPoints(overlay)
				backdrop:SetFrameLevel(alert:GetFrameLevel()-1)
				overlay.gradient:SetParent(backdrop)
			end

			local icon_frame = CreateFrame('Frame', nil, alert, BackdropTemplateMixin and "BackdropTemplate")
			icon_frame:SetPoint('CENTER', alert.Icon, 'CENTER', 0, 0)
			icon_frame:SetWidth(alert.Icon:GetWidth() + 4)
			icon_frame:SetHeight(alert.Icon:GetHeight() + 4)
			elements.icon_frame = icon_frame
			Skinner:Skin(icon_frame, 'alert_item')
		end

		alert_frames[alert] = elements
	end
	alert.Background:SetShown(opt.alert_background)
	alert.IconBorder:SetShown(opt.alert_icon_frame)
	alert.BaseQualityBorder:SetShown(opt.alert_icon_frame)
	alert.UpgradeQualityBorder:SetShown(opt.alert_icon_frame)
	alert:SetAlpha(opt.alert_alpha)
	alert:SetScale(opt.alert_scale)

	-- Update toast
	if opt.alert_skin then
		local c
		if alert.hyperlink then
			local _, _, rarity = GetItemInfo(alert.hyperlink)
			c = ITEM_QUALITY_COLORS[rarity]
		else
			c = {r = 1, g = .8, b = 0.1}
		end
		if type(c) == "table" then -- Sanity check due to 5.4.1 reported error
			elements.overlay:SetGradientColor(c.r, c.g, c.b, .2)
			elements.icon_frame:SetGradientColor(c.r, c.g, c.b, .2)
			elements.overlay:SetBorderColor(c.r, c.g, c.b)
			elements.icon_frame:SetBorderColor(c.r, c.g, c.b)
		end
	end
end

local AlertFrameTables = {
	'LOOT_WON_ALERT_FRAMES',
	'LOOT_UPGRADE_ALERT_FRAMES',
	'MONEY_WON_ALERT_FRAMES'
}

function addon.FixAnchors(frames, anchor)
	local anchor = alert_anchor
	local up, first, x, y = opt.alert_anchor.direction == 'up', true, 44, -10
	for ix=1, #AlertFrameTables do
		local t = _G[AlertFrameTables[ix]]
		for i=1, #t do
			local frame = t[i]
			if frame:IsShown() then
				frame:ClearAllPoints()
				if up then
					frame:SetPoint("BOTTOM", anchor, "TOP", x, y)
				else
					frame:SetPoint("TOP", anchor, "BOTTOM", x, -y)
				end
				anchor = frame
				if first then
					first, x, y = false, 0, opt.alert_offset - 20
				end
			end
		end
	end
end

-- function addon.BonusRollFrame_StartBonusRoll()
-- 	if BonusRollFrame:IsShown() then
-- 		addon.BonusRollFrame_Show()
-- 	end
-- end

function addon.BonusRollFrame_SetPoint(self, _, frame)
	if frame ~= anchor then
		self:ClearAllPoints()
	end
end

local bonus_elements
function addon.BonusRollFrame_Show()
	local frame = BonusRollFrame
	if not bonus_elements then
		bonus_elements = {}

		frame.active = true -- Prevent anchor from acquiring as child
		frame.scale_mod = 0.9 -- Anchor's scale modifier
		if opt.bonus_skin then
			frame.Background:Hide()
			local overlay = CreateFrame('Frame', nil, frame, BackdropTemplateMixin and "BackdropTemplate")
			overlay:SetAllPoints()
			overlay:SetFrameLevel(frame:GetFrameLevel()-1)
			Skinner:Skin(overlay, 'bonus')
			overlay:SetGradientColor(.5, .5, .5, .4)
			overlay:SetBorderColor(1, .8, .1)
			bonus_elements.overlay = overlay
		end
	end

	if anchor.children[1] ~= BonusRollFrame then
		table.insert(anchor.children, 1, frame) -- Force in first position
	end
	anchor:Restack()
end

function addon.BonusRollFrame_Hide()
	if anchor.children[1] == BonusRollFrame then
		table.remove(anchor.children, 1)
		anchor:Restack()
	end
end

function addon.SlashHandler(msg)
	if msg == 'reset' then
		anchor:Position()
		alert_anchor:Position()
	elseif msg == 'opt' or msg == 'options' then
		addon.ShowOptions()
	else
		addon.ToggleAnchors()
	end
end

function addon:UpdateAnchors()
	anchor:SetShown(opt.roll_anchor.visible)
	alert_anchor:SetShown(opt.alert_anchor.visible)
end

function addon.ToggleAnchors()
	local state = anchor:IsShown()
	anchor:SetShown(not state)
	alert_anchor:SetShown(not state)
end

-------------------------------------------------------------------------------
-- Frame creation

do
	local sf = string.format
	-- Add a specific roll type to the tooltip
	local function RollLines(list, hid)
		for _,pid in pairs(list) do
			local name, class, rtype, roll, is_winner, is_me = HistoryGetPlayerInfo(hid, pid)
			-- TODO- ACCOUNT FOR MISSING PLAYERS BETTER
			if not name then return nil end
			local text, r, g, b, color = FancyPlayerName(name, class, opt)
			if roll ~= nil then
				if is_winner then
					color = '44ff22'
				elseif is_me then
					color = 'ff2244'
				else
					color = 'CCCCCC'
				end
				GameTooltip:AddLine(sf('   |cff%s%s|r  %s', color, roll, text), r, g, b)
			else
				GameTooltip:AddLine('   '..text, r, g, b)
			end
		end
	end

	-- Add roll status or summary to tooltip
	local tneed, tgreed, tpass, trolls, tnone, table_sort
		= {}, {}, {}, {}, {}, table.sort
	local function rsort(a, b)
		a, b = trolls[a] or 0, trolls[b] or 0
		return a > b and true or false
	end

	local function AddIneligibleReason(button, r, g, b)
		GameTooltip:AddLine(string_format(_G["LOOT_ROLL_INELIGIBLE_REASON"..button.reason], button.skill), r or .6, g or .6, b or .6)
		GameTooltip:Show()
	end

	local function AddTooltipLines(self, show_all, show)
		-- Locate history item
		local rollid, hid = self.rollid, 1
		local hrollid, link, players, done
		while true do
			hrollid, link, players, done = HistoryGetItem(hid)
			if not hrollid then
				return
			elseif hrollid == rollid then
				break
			end
			hid = hid+1
		end

		-- Generate player lists
		local tneed, tgreed, tpass, tnone, trolls
			= wipe(tneed), wipe(tgreed), wipe(tpass), wipe(tnone), wipe(trolls)
		for pid=1, players do
			local _, _, rtype, roll = HistoryGetPlayerInfo(hid, pid)
			local t
			if rtype then
				if rtype == 0 then
					t = tpass
				elseif rtype == 1 then
					t = tneed
				elseif rtype == 2 or rtype == 3 then
					t = tgreed
				end
				trolls[pid] = roll
			else
				t = tnone
			end
			if t then
				t[#t+1] = pid
			end
		end

		table_sort(tneed, rsort)
		table_sort(tgreed, rsort)
		table_sort(tpass, rsort)

		-- Generate tooltip
		if show_all then
			GameTooltip:AddLine('.', 0, 0, 0)
		end
		if #tneed ~= 0 and (show_all or show == 1) then
			GameTooltip:AddLine(NEED, .2, 1, .1)
			RollLines(tneed, hid)
		end
		if #tgreed ~= 0 and (show_all or (show == 2 or show == 3)) then
			GameTooltip:AddLine(GREED, .1, .2, 1)
			RollLines(tgreed, hid)
		end
		if #tpass ~= 0 and (show_all or show == 0) then
			GameTooltip:AddLine(PASS, .7, .7, .7)
			RollLines(tpass, hid)
		end
		if show_all and opt.show_undecided then
			GameTooltip:AddLine(L.undecided, .7, .3, .2)
			RollLines(tnone, hid)
		end

		-- Force tooltip to refresh
		GameTooltip:Show()
		return true
	end

	---------------------------------------------------------------------------
	-- Roll buttons
	---------------------------------------------------------------------------
	local RollButtonPrototype = XLoot.NewPrototype()
	do
		function RollButtonPrototype:OnClick()
			RollOnLoot(self.parent.rollid, self.type)
		end
		
		function RollButtonPrototype:Toggle(status)
			if status then
				self:Enable()
				self:SetAlpha(1)
			else
				self:Disable()
				self:SetAlpha(.6)
			end
			SetDesaturation(self:GetNormalTexture(), not status)
		end

		function RollButtonPrototype:OnEnter()
			mouse_focus = self
			GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
			AddTooltipLines(self.parent, false, self.type)
			-- This isn't working for some stupid reason
			if GameTooltip:NumLines() == 0 then
				GameTooltip:SetText(self.label, unpack(self.label_colors))
				GameTooltip:Show()
			end
			-- This is for those people who think they should be able
			--  to roll on something, can't, and then come complain to me.
			if self.reason then
				AddIneligibleReason(self, 1, .2, 0)
			end
		end

		function RollButtonPrototype:OnLeave()
			mouse_focus = nil
			GameTooltip:Hide()
		end

		function RollButtonPrototype:SetText(text)
			if text and text > 0 then
				self.text:SetText(text)
			else
				self.text:SetText()
			end
		end

		local path = [[Interface\Buttons\UI-GroupLoot-%s-%s]]
		function RollButtonPrototype:New(parent, roll, label, tex, anchor_to, x, y, label_colors)
			local b = self:_New(CreateFrame('Button', nil, parent))
			b:SetPoint('LEFT', anchor_to, 'RIGHT', x, y)
			b:SetNormalTexture(path:format(tex, 'Up'))
			if tex ~= 'Pass' then
				b:SetHighlightTexture(path:format(tex, 'Highlight'))
				b:SetPushedTexture(path:format(tex, 'Down'))
			else
				b:SetHighlightTexture(path:format(tex, 'Up'))
				b:GetNormalTexture():SetVertexColor(0.8, 0.7, 0.7)
				b:GetHighlightTexture():SetAlpha(0.5)
			end
			b.parent = parent

			local texture_special = b:CreateTexture(nil, 'OVERLAY')
			texture_special:SetAllPoints(b)
			texture_special:SetAlpha(0.5)
			b.texture_special = texture_special

			local text = b:CreateFontString(nil, 'OVERLAY')
			text:SetPoint("CENTER", -x + 1, tex == 'DE' and -y +2 or -y)
			b.text = text

			b:SetScript('OnEnter', self.OnEnter)
			b:SetScript('OnLeave', self.OnLeave)
			b:SetScript('OnClick', self.OnClick)
			b:SetMotionScriptsWhileDisabled(true)
			b:Enable()
			b.type = roll
			b.label = label
			b.label_colors = label_colors

			b:ApplyOptions()

			return b
		end

		function RollButtonPrototype:ApplyOptions()
			self.text:SetFont(opt.font, 12, opt.font_flag)
			self:SetWidth(opt.roll_button_size)
			self:SetHeight(opt.roll_button_size)
		end
	end

	---------------------------------------------------------------------------
	-- Roll frames
	---------------------------------------------------------------------------
	RollFramePrototype = XLoot.NewPrototype()
	-- Events
	function RollFramePrototype:OnEnter()
		mouse_focus = self
		GameTooltip:SetOwner(self.icon_frame, 'ANCHOR_TOPLEFT', 28, 0)
		GameTooltip:SetHyperlink(self.link)
		if opt.show_decided or opt.show_undecided then
			AddTooltipLines(self, true)
			if self.need.reason then
				AddIneligibleReason(self.need, 1, .2, 0)
			end
			if self.greed.reason and self.greed.reason ~= self.need.reason then
				AddIneligibleReason(self.greed, .8, .1, 0)
			end
			if self.disenchant.reason then
				AddIneligibleReason(self.disenchant, .6, .05, 0)
			end
		end
		if IsShiftKeyDown() then
			GameTooltip_ShowCompareItem()
		end
		if IsModifiedClick('DRESSUP') then
			ShowInspectCursor()
		else
			ResetCursor()
		end
	end

	function RollFramePrototype:OnLeave()
		mouse_focus = nil
		GameTooltip:Hide()
	end

	function RollFramePrototype:OnClick(button)
		if IsControlKeyDown() then
			DressUpItemLink(self.link)
		elseif IsShiftKeyDown() then
			ChatEdit_InsertLink(self.link)
		end
	end

	-- Status bar update
	local max = math.max
	function RollFramePrototype:OnBarUpdate()
		local parent = self.parent
		if parent.over then
			self.spark:Hide()
			self:SetValue(0)
			parent.text_time:SetText()
			return
		end
		local time = GetTime()
		-- TODO: Remove?
		local status, result = pcall(GetLootRollTimeLeft, parent.rollid)
		if not status or result == 0 then
			local ended = parent.rollended
			if ended then
				if time - ended > 10 then
					anchor:Pop(parent)
				end
			else
				parent.rollended = time
			end
		end
		-- /TODO
		local remaining = self.expires - time
		if remaining < -4 then
			anchor:Pop(parent)
		else
			local now, length = max(remaining, -1), self.length
			self.spark:SetPoint('CENTER', self, 'LEFT', (now / length) * self:GetWidth(), 0)
			self:SetValue(now)
			self.spark:Show()
			if opt.show_time_remaining then
				if remaining >= 0 then
					parent.text_time:SetText(sf('%.0f', max(0, remaining)))
					parent.text_time:Show()
				else
					parent.text_time:Hide()
				end
			end
		end
	end

	function RollFramePrototype:Popped()
		rolls[self.rollid] = nil
	end

	-- Create roll frame
	function RollFramePrototype:New()
		-- Base frame
		local frame = self:_New(CreateFrame('Button', nil, UIParent))
		frame:SetFrameLevel(anchor:GetFrameLevel())
		frame:SetHeight(24)
		frame:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		frame:SetScript('OnEnter', self.OnEnter)
		frame:SetScript('OnLeave', self.OnLeave)
		frame:SetScript('OnClick', self.OnClick)
		
		-- Overlay (For skin border)
		local overlay = CreateFrame('frame', nil, frame, BackdropTemplateMixin and "BackdropTemplate")
		overlay:SetFrameLevel(frame:GetFrameLevel())
		overlay:SetAllPoints()
		frame.overlay = overlay
		local skin = Skinner:Skin(overlay, 'row')

		-- Item icon (For skin border)
		local icon_frame = CreateFrame('Frame', nil, frame)
		icon_frame:SetPoint('LEFT', 0, 0)
		icon_frame:SetWidth(28)
		icon_frame:SetHeight(28)
		frame.icon_frame = icon_frame
		Skinner:Skin(icon_frame, 'item')

		-- Item texture
		local icon = icon_frame:CreateTexture(nil, 'BACKGROUND')
		icon:SetPoint('TOPLEFT', 3, -3)
		icon:SetPoint('BOTTOMRIGHT', -3, 3)
		icon:SetTexCoord(.07,.93,.07,.93)
		frame.icon = icon
		
		-- Timer bar
		local bar = CreateFrame('StatusBar', nil, frame)
		bar:SetFrameLevel(frame:GetFrameLevel())
		local pad = skin.padding or 2
		bar:SetPoint('TOPRIGHT', -pad - 3, -pad - 3)
		bar:SetPoint('BOTTOMRIGHT', -pad - 3, pad + 3)
		bar:SetPoint('LEFT', icon_frame, 'RIGHT', -pad, 0)
		bar:SetStatusBarTexture(skin.bar_texture)
		bar:SetScript('OnUpdate', self.OnBarUpdate)
		bar.parent = frame
		frame.bar = bar
		-- Reference bar for quick re-skinning when XLoot skin changes
		table.insert(addon.bars, bar)
		
		local spark = bar:CreateTexture(nil, 'OVERLAY')
		spark:SetWidth(14)
		spark:SetHeight(38)
		spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		spark:SetBlendMode('ADD')
		bar.spark = spark

		-- Bind text
		local bind = icon_frame:CreateFontString(nil, 'OVERLAY')
		bind:SetPoint('BOTTOM', 0, 1)
		frame.text_bind = bind

		-- Time text
		local time = icon_frame:CreateFontString(nil, 'OVERLAY')
		time:SetPoint('CENTER', 0, 2)
		frame.text_time = time

		-- Item level
		local ilvl = icon_frame:CreateFontString(nil, 'OVERLAY')
		ilvl:SetPoint('TOPLEFT', 3, -3)
		frame.text_ilvl = ilvl

		-- Roll buttons
		local n = RollButtonPrototype:New(frame, 1, NEED, 'Dice', icon_frame, 3, -1, {.2, 1, .1})
		local g = RollButtonPrototype:New(frame, 2, GREED, 'Coin', n, 0, -2, {.1, .2, 1})
		local d = RollButtonPrototype:New(frame, 3, ROLL_DISENCHANT, 'DE', g, 0, 2, {.1, .2, 1})
		local p = RollButtonPrototype:New(frame, 0, PASS, 'Pass', d, 0, 2, {.7, .7, .7})
		frame.need, frame.greed, frame.disenchant, frame.pass = n, g, d, p

		-- Roll status text
		local status = frame:CreateFontString(nil, 'OVERLAY')
		status:SetHeight(16)
		status:SetJustifyH('LEFT')
		status:SetPoint('LEFT', icon_frame, 'RIGHT', 1, 0)
		status:SetPoint('RIGHT', p, 'RIGHT', 2, 0)
		frame.text_status = status

		-- Loot name/link
		local loot = frame:CreateFontString(nil, 'OVERLAY')
		loot:SetHeight(16)
		loot:SetJustifyH('LEFT')
		loot:SetPoint('LEFT', p, 'RIGHT', 3, -1)
		loot:SetPoint('RIGHT', frame, 'RIGHT', -5, 0)
		frame.text_loot = loot

		frame:ApplyOptions()

		return frame
	end

	function RollFramePrototype:ApplyOptions()
		self:SetWidth(opt.roll_width)

		-- Status bar is reskinned with SkinUpdate

		self.need:ApplyOptions()
		self.greed:ApplyOptions()
		self.disenchant:ApplyOptions()
		self.pass:ApplyOptions()

		self.text_ilvl:SetFont(opt.font, 8, 'OUTLINE')
		self.text_bind:SetFont(opt.font, 8, 'THICKOUTLINE')
		self.text_time:SetFont(opt.font, 12, 'OUTLINE')
		self.text_status:SetFont(opt.font, 12, opt.font_flag)
		self.text_loot:SetFont(opt.font, 12, opt.font_flag)

		self.text_time:SetShown(opt.show_time_remaining)
		self.text_ilvl:SetShown(opt.text_ilvl)
	end
end

---------------------------------------------------------------------------
-- AddOn setup and events
---------------------------------------------------------------------------

-- Update skins when XLoot skin changes
function addon:SkinUpdate()
	local skin = Skinner:Reskin()
	local padding = skin.padding or 2
	local p, n = padding + 3, -padding - 3
	for _,bar in pairs(addon.bars) do
		bar:ClearAllPoints()
		bar:SetPoint('TOPRIGHT', n, n)
		bar:SetPoint('BOTTOMRIGHT', n, p)
		bar:SetPoint('LEFT', bar.parent.icon_frame, 'RIGHT', -padding, 0)
		bar:SetStatusBarTexture(skin.bar_texture)
		local link = bar.parent.link
		if link then
			local r, g, b = GetItemQualityColor(select(3, GetItemInfo(link)))
			bar.parent.overlay:SetBorderColor(r, g, b)
			bar.parent.icon_frame:SetBorderColor(r, g, b)
		end
	end

end

-- Move anchors when scale changes
function addon:ApplyOptions()
	opt = self.opt

	anchor:UpdateSVData(opt.roll_anchor)
	alert_anchor:UpdateSVData(opt.alert_anchor)

	self:SkinUpdate()

	anchor:Restack()

	for _,frame in pairs(anchor.children) do
		if frame.ApplyOptions then
			frame:ApplyOptions()
		end
	end
end


