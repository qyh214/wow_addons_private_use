-- Create module
local addon, L = XLoot:NewModule("Monitor")
local XLootMonitor = CreateFrame("Frame", "XLootMonitor", UIParent)
XLootMonitor.addon = addon
-- Grab locals
local print, opt, eframe, anchor = print
local CopperToString, FancyPlayerName = XLoot.CopperToString, XLoot.FancyPlayerName
local table_insert, table_remove = table.insert, table.remove
local me = UnitName("player")

-------------------------------------------------------------------------------
-- Settings

local defaults = {
	profile = {
		anchor = {
			direction = "up",
			alignment = "left",
			visible = true,
			scale = 1.0,
			draggable = true,
			offset = 0,
			spacing = 2,
			x = UIParent:GetWidth() * .75,
			y = UIParent:GetHeight() * .15,
		},
		name_width = 50,
		gradients = false,

		threshold_own = 2,
		threshold_other = 3,
		show_coin = false,
		show_currency = true,
		show_crafted = false,

		show_totals = false,
		totals_delay = 0.5,
		use_altoholic = true,
		show_ilvl = false,

		fade_own = 10,
		fade_other = 5,
		
		font = STANDARD_TEXT_FONT,
		font_size_loot = 12,
		font_size_quantity = 10,
		font_size_ilvl = 8,
		font_flag = "OUTLINE",
	}
}


----------------------------------------------------------------------
-- Helpers

local numberize = function(v)
	if v <= 9999 then return v end
	if v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 10000 then
		local value = string.format("%.0fk", v/1000)
		return value
	end
end

-------------------------------------------------------------------------------
-- Module init

function addon:OnInitialize()
	eframe = CreateFrame("Frame")
	self:InitializeModule(defaults, eframe)
	XLoot:SetSlashCommand("xlm", self.SlashHandler)
	opt = self.db.profile
end

function addon:OnEnable()
	-- Register for loot events
	LibStub("LootEvents"):RegisterLootCallback(self.LOOT_EVENT)
	eframe:RegisterEvent("MODIFIER_STATE_CHANGED")
	-- Set up skins
	XLoot:MakeSkinner(self, {
		default = { gradient = opt.gradients },
		anchor = { r = .4, g = .4, b = .4, a = .6, gradient = false },
		anchor_pretty = { r = .6, g = .6, b = .6, a = .8 },
		item = { backdrop = false, gradient = opt.gradients },
		item_highlight = { type = "highlight", layer = "overlay" },
		row_highlight = { type = "highlight" }
	})
	-- Set up anchor
	anchor = XLoot.Stack:CreateStaticStack(self.CreateRow, L.anchor, opt.anchor)
	self:Skin(anchor, XLoot.opt.skin_anchors and 'anchor_pretty' or 'anchor')
end

function addon:ApplyOptions()
	opt = self.opt
	anchor:UpdateSVData(opt.anchor)
	addon:Restack()
end

local events = {}
function events.item(player, link, num)
	if link and link:match("|Hitem:") then -- Proper items	
		local name, _, quality, level, _, _, _, _, _, icon = GetItemInfo(link)
		if not name or type(quality) ~= "number" then
			print(name and "Quality is not a number" or "Name is nil")
			return false
		end
		if (player == me and opt.threshold_own or opt.threshold_other) > quality then
			return -- Doesn't meet threshold requirements
		end
		local r, g, b = GetItemQualityColor(quality)
		local nr, ng, nb
		if player ~= me then
			player, nr, ng, nb = FancyPlayerName(player, select(2, UnitClass(player)), opt)
		else
			player = nil
		end
		local row = addon:AddRow(icon, (player and opt.fade_other or opt.fade_own), r, g, b)
		local num = tonumber(num) or 1
		row:SetTexts(player, num > 1 and ("%sx%d"):format(link, num) or link, nil, nr, ng, nb)
		if opt.show_totals then
			row.timeToTotal = opt.totals_delay
		end
		if opt.show_ilvl and level > 1 then
			local ilvl = GetDetailedItemLevelInfo(link)
			row.ilvl:SetText(ilvl)
		end
		row.item = link
	elseif link and link:match("|Hbattlepet:") then -- Battlepets. Really?
		-- local _, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit(":", link)
	else
		-- print("Unknown or invalid link type")
		-- return false
	end
end

function events.coin(coin_string, copper)
	if opt.show_coin then
		addon:AddRow(GetCoinIcon(copper), opt.fade_own, .5, .5, .5, .5, .5, .5):SetTexts(nil, CopperToString(copper))
	end
end

function events.currency(id, num)
	-- Not sure what event is causing us to capture nothing for (%d+), this isn't ideal
	if id ~= nil and opt.show_currency then
		local num = tonumber(num) or 1
		local c = C_CurrencyInfo.GetCurrencyInfo(id)
		if c then
			addon:AddRow(c.iconFileID, opt.fade_own, 1, 1, 1, 1, 1, 1):SetTexts(nil,  num > 1 and ("%s x%d"):format(c.name, num) or c.name, c.quantity)
		end
	end
end

function events.crafted(link, num)
	if opt.show_crafted then
		events.item(me, link, num)
	end
end

function addon.LOOT_EVENT(event, pattern, ...)
	if events[event] and events[event](...) == false then
		print("XLoot Monitor: Error handling event", event, pattern, ...)
	end
end

local mouse_focus
function addon:MODIFIER_STATE_CHANGED(self, modifier, state)
	if mouse_focus and MouseIsOver(mouse_focus) then
		mouse_focus:ShowTooltip()
	end
end

local pool, stack, active = {}, {}, false
stack[0] = anchor

local timer = 0
function addon.EframeUpdate(self, elapsed)
	timer = timer + elapsed
	for i,row in ipairs(stack) do
		-- Deferred total calculation due to GetItemCount reliability
		local ttt = row.timeToTotal
		if ttt then
			ttt = ttt - elapsed
			if ttt <= 0 then
				ttt = nil
				local total
				if opt.use_altoholic and Altoholic then
					total = Altoholic:GetItemCount(Altoholic:GetIDFromLink(row.item))
				else
					total = GetItemCount(row.item)
				end
				if total and total > 1 then
					row.total:SetText(numberize(total))
				end
			end
			row.timeToTotal = ttt
		end
		-- Animation
		local remaining = row.expires - timer
		if remaining < 0 then
			row:SetAlpha(0)
			addon:RemoveRow(row)
		elseif remaining <= .5 then
			row:SetAlpha(remaining * 2)
		else
			local since = timer - row.started
			if since <= .5 then
				row:SetAlpha(since * 2)
			end
		end
	end
end

function addon:RemoveRow(row)
	row:Hide()
	for i,v in ipairs(stack) do
		if v == row then
			table_remove(stack, i)
			table_insert(pool, row)
			if stack[i] then
				anchor:AnchorChild(stack[i], stack[i-1])
			end
			break
		end
	end

	-- Disable OnUpdate
	if #stack == 0 then
		active, timer = false, 0
		eframe:SetScript("OnUpdate", nil)
	end
end

function addon:AddRow(icon, fade_time, ir, ig, ib, rr, rg, rb)
	-- Acquire
	local row = table_remove(pool)
	if not row then
		row = self.CreateRow()
	end

	-- Set up row
	row.icon:SetTexture(icon)
	row.icon_frame:SetBorderColor(ir, ig, ib)
	row:SetBorderColor(rr or ir, rg or ig, rb or ib)
	row.expires = timer + fade_time
	row.started = timer
	row.item = nil

	-- Anchor
	anchor:AnchorChild(row)
	table_insert(stack, 1, row)
	-- Reanchor second newest
	if stack[2] then
		anchor:AnchorChild(stack[2], row)
	end
	row:Show()

	-- Enable OnUpdate
	if not active then
		active = true
		eframe:SetScript("OnUpdate", self.EframeUpdate)
	end
	return row
end

function addon:Restack()
	for i,v in ipairs(stack) do
		anchor:AnchorChild(v, i > 1 and stack[i-1] or nil)
		v:ApplyOptions()
	end
end

-------------------------------------------------------------------------------
-- Frame methods
do
	local function ShowTooltip(self)
		if self.item then
			GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 28, 0)
			GameTooltip:SetHyperlink(self.item)
			CursorUpdate(self)
		end
	end

	local function OnEnter(self)
		mouse_focus = self
		if self._highlights then
			self.icon_frame:ShowHighlight()
		end
		self:ShowTooltip()
	end

	local function OnLeave(self)
		mouse_focus = nil
		if self._highlights then
			self.icon_frame:HideHighlight()
		end
		GameTooltip:Hide()
		ResetCursor()
	end

	local function OnClick(self, button)
		if IsModifiedClick() and self.item then
			HandleModifiedItemClick(self.item)
		end
	end

	local function FitToText(self)
		self:SetWidth(self.name:GetWidth() + self.text:GetWidth() + 8 + self.icon_frame:GetWidth())
	end

	local function SetTexts(self, name, text, total, nr, ng, nb, tr, tg, tb)
		self.name:SetText(name and name.." " or nil)
		self.text:SetText(text)
		self.ilvl:SetText()
		-- Show total after 0.5 seconds to get a valid count
		self.total:SetText()
		self.name:SetVertexColor(nr or 1, ng or 1, nb or 1)
		self.text:SetVertexColor(nr or 1, ng or 1, nb or 1)
		if name then
			self.name:SetWidth(opt.name_width)
		else
			self.name:SetWidth(0)
		end
		self:FitToText()
	end

	local widgets = {
		{ "icon_frame", 0 },
		{ "name", 2 },
		{ "text", 0 },
	}

	local function ApplyOptions(self)
		local a, b, xmod = "LEFT", "RIGHT", 1
		if opt.anchor.alignment == "right" then
			a, b, xmod = b, a, -1
		end
		self.icon_frame:ClearAllPoints()
		self.icon_frame:SetPoint(a)

		self.name:ClearAllPoints()
		self.name:SetPoint(a, self.icon_frame, b, 2 * xmod, 0)
		self.name:SetJustifyH(a)
		self.name:SetFont(opt.font, opt.font_size_loot, opt.font_flag)

		self.text:ClearAllPoints()
		self.text:SetPoint(a, self.name, b)
		self.text:SetJustifyH(a)
		self.text:SetFont(opt.font, opt.font_size_loot, opt.font_flag)

		self.ilvl:SetFont(opt.font, opt.font_size_ilvl, opt.font_flag)
		self.total:SetFont(opt.font, opt.font_size_quantity, opt.font_flag)

		self:FitToText()
	end

	function addon.CreateRow()
		local frame = CreateFrame("Button", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
		frame:SetFrameLevel(anchor:GetFrameLevel())
		frame:SetHeight(24)
		frame:SetWidth(250)

		addon:Skin(frame)
		addon:Highlight(frame, "row_highlight")
		frame:SetHighlightColor(.8, .8, .8)

		frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		frame:SetScript("OnClick", OnClick)
		frame:SetScript("OnEnter", OnEnter)
		frame:SetScript("OnLeave", OnLeave)

		-- Item icon (For skin border)
		local icon_frame = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
		icon_frame:SetWidth(28)
		icon_frame:SetHeight(28)
		addon:Skin(icon_frame, "item")
		addon:Highlight(icon_frame, "item_highlight")
		frame.icon_frame = icon_frame

		-- Item texture
		local icon = icon_frame:CreateTexture(nil, "BACKGROUND")
		icon:SetPoint("TOPLEFT", 3, -3)
		icon:SetPoint("BOTTOMRIGHT", -3, 3)
		icon:SetTexCoord(.07,.93,.07,.93)
		frame.icon = icon

		local ilvl = icon_frame:CreateFontString(nil, "OVERLAY")
		ilvl:SetPoint("BOTTOM", icon_frame, "BOTTOM", 0, 0)
		ilvl:SetJustifyH("CENTER")
		frame.ilvl = ilvl

		frame.name = frame:CreateFontString(nil, "OVERLAY")

		frame.text = frame:CreateFontString(nil, "OVERLAY")

		local total = icon_frame:CreateFontString(nil, "OVERLAY")
		total:SetPoint("CENTER", icon_frame, "CENTER", 0, 0)
		total:SetJustifyH("CENTER")
		frame.total = total

		frame.FitToText = FitToText
		frame.SetTexts = SetTexts
		frame.ShowTooltip = ShowTooltip
		frame.ApplyOptions = ApplyOptions

		frame:ApplyOptions()

		return frame
	end
end

function addon:UpdateAnchors(...)
	if opt.anchor.visible then
		anchor:Show()
	else
		anchor:Hide()
	end
end

function addon.SlashHandler(msg)
	if anchor:IsShown() then
		anchor:Hide()
	else
		anchor:Show()
	end
end

local items = {
	{ 52722 },
	{ 31304 },
	{ 37254 },
	{ 13262 },
	{ 15487 },
	{ 72120 },
	{ 2589 }
}
local currencies = {
	81,
	1728
}
for i,v in ipairs(items) do
	GetItemInfo(v[1])
end

local players = {
	{ UnitName("player"), select(2, UnitClass('player')) },
	{ 'Player1', 'MAGE' },
	{ 'Player2', 'PRIEST' },
	{ 'Player3', 'WARRIOR' },
	{ 'Player4', 'SHAMAN' }
}

local random = math.random
local function random_player(is_me)
	return is_me and players[1][1] or players[random(2, 5)][1]
end

local function random_item_num(max)
	return random(1, 2) == 2 and random(1, max or 20) or 1
end

local function random_item_link()
	return select(2, GetItemInfo(items[random(1, #items)][1]))
end

local function test_item(event, is_me)
	addon.LOOT_EVENT('item', event, random_player(is_me), random_item_link(), random_item_num())
end

local function test_coin(event, is_me)
	addon.LOOT_EVENT('coin', event, random_player(is_me), random(1, 500000), "TODO")
end

local function test_currency(event)
	for _,id in ipairs(currencies) do
		addon.LOOT_EVENT('currency', event, id, random_item_num(5))
	end
end

local function test_crafted(event)
	addon.LOOT_EVENT('crafted', event, random_item_link(), random_item_num())
end

local function test_battlepet(event)
	print("Testing battlepet event")
	addon.LOOT_EVENT('item', "LOOT_ITEM_PUSHED_SELF", random_player(true), "|cff0070dd|Hbattlepet:868:1:3:158:10:12:0x0000000000000000|h[Pandaren Water Spirit]|h|r", 1)
end

local tests = {
	{ test_item, "LOOT_ITEM" },
	{ test_item, "LOOT_ITEM_SELF", true },
	{ test_item, "LOOT_ITEM_MULTIPLE" },
	{ test_item, "LOOT_ITEM_SELF_MULTIPLE", true },
	{ test_item, "LOOT_ITEM_PUSHED_SELF", true },
	{ test_item, "LOOT_ITEM_PUSHED_SELF_MULTIPLE", true },
	{ test_coin, "LOOT_MONEY" },
	{ test_coin, "LOOT_MONEY_SPLIT", true },
	{ test_coin, "YOU_LOOT_MONEY", true },
	{ test_currency, "CURRENCY_GAINED" },
	{ test_currency, "CURRENCY_GAINED_MULTIPLE" },
	{ test_crafted, "LOOT_ITEM_CREATED_SELF" },
	{ test_crafted, "CURRENCY_GAINED_MULTIPLE" },
	{ test_battlepet }

}

local queue, queueframe, tick = {}, CreateFrame("Frame"), 0

local function queue_update(self, elapsed)
	tick = tick + elapsed
	if tick > 0.5 then
		tick = 0
		local time = GetTime()
		for k,v in pairs(queue) do
			if v[1] < time then
				if v[3] then
					print("Testing "..v[3])
				end
				v[2](select(3, unpack(v)))
				queue[k] = nil
			end
		end
	end
end

local qactive = false

function XLootMonitor.TestSettings()
	local now = GetTime()
	-- for i=1,15 do
	-- 	table.insert(queue, { now + i, unpack(tests[random(1, #tests)]) })
	-- end
	if not qactive then
		queueframe:SetScript("OnUpdate", queue_update)
		qactive = true
	end
	for i,v in ipairs(tests) do
		table.insert(queue, { now + i * .5, unpack(v) })
	end
end

XLoot:SetSlashCommand("xlmd", XLootMonitor.TestSettings)
