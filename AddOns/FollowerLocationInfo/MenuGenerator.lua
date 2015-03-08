
local addon, ns = ...;

ns.MenuGenerator = {};
local UIDropDownMenuDelegate = CreateFrame("FRAME");
local UIDROPDOWNMENU_MENU_LEVEL;
local UIDROPDOWNMENU_MENU_VALUE;
local UIDROPDOWNMENU_OPEN_MENU;
local self = ns.MenuGenerator;
self.menu = {};
self.controlGroups = {};

local function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

local cvarTypeFunc = {
	bool = function(d)
		if (type(d.cvar)=="table") then
			--?
		elseif (type(d.cvar)=="string") then
			d.checked = function() return (GetCVar(d.cvar)=="1") end;
			d.func = function() SetCVar(d.cvar,GetCVar(d.cvar)=="1" and "0" or "1"); end;
		end
		return d;
	end,
	slider = function(d)
		
		return d;
	end,
	num = function(d)
		
		return d;
	end,
	str = function(d)
		
		return d;
	end
};

local dbTypeFunc = {
	bool = function(d)
		if (d.subName) then
			d.checked = function() return (FollowerLocationInfoDB[d.keyName]) end;
			d.func = function() FollowerLocationInfoDB[d.subName][d.keyName] = not FollowerLocationInfoDB[d.subName][d.keyName]; end;
		else
			d.checked = function() return (FollowerLocationInfoDB[d.keyName]) end;
			d.func = function() FollowerLocationInfoDB[d.keyName] = not FollowerLocationInfoDB[d.keyName]; end;
		end
		return d;
	end,
	selectChild = function(d)
		d.checked = function() return (FollowerLocationInfoDB[d.keyName]==d.valStr); end
		d.func = function(self) FollowerLocationInfoDB[d.keyName] = d.valStr; self:GetParent():Hide(); end
		return d;
	end,
	slider = function(d)
		return d;
	end,
	num = function(d)
		return d;
	end,
	str = function(d)
		d.checked = function() return (FollowerLocationInfoDB[d.keyName]==d.valStr); end
		d.func = function() FollowerLocationInfoDB[d.keyName] = d.valStr; end
		return d;
	end
};

self.InitializeMenu = function()
	if (not self.frame) then
		self.frame = CreateFrame("Frame", addon.."EasyMenu", UIParent, "UIDropDownMenuTemplate");
	end
	self.menu={};
end

self.addEntry = function(D,P)
	local entry= {};

	if (type(D)=="table") and (#D>0) then -- numeric table = multible entries
		for i,v in ipairs(D) do
			self.addEntry(v,parent);
		end
		return;

	elseif (D.childs) then -- child elements
		local parent = self.addEntry({ label=D.label, arrow=true, tooltip=D.tooltip },P);
		for i,v in ipairs(D.childs) do
			self.addEntry(v,parent);
		end
		return;

	elseif (D.dbType=="select") then
		local parent = self.addEntry({ label=D.label, arrow=true, tooltip=D.tooltip },P);
		for k,v in pairsByKeys(D.values) do
			self.addEntry({
				label = v,
				dbType = "selectChild",
				keyName = D.keyName,
				valStr = k,
				event = D.event,
				radio = true,
			},parent);
		end
		return;

	elseif (D.groupName) and (D.optionGroup) then -- similar to childs but with group control
		if (self.controlGroups[D.groupName]==nil) then
			self.controlGroups[D.groupName] = {};
		else
			wipe(self.controlGroups[D.groupName])
		end
		local parent = self.addEntry({ label=D.label, arrow=true },P);
		parent.controlGroup=self.controlGroups[D.groupName];
		for i,v in ipairs(D.optionGroup) do
			tinsert(self.controlGroups[D.groupName],self.addEntry(v,parent));
		end
		return;

	elseif (D.separator) then -- separator line (decoration)
		entry = { text = "", dist = 0, isTitle = true, notCheckable = true, isNotRadio = true, sUninteractable = true, iconOnly = true, icon = "Interface\\Common\\UI-TooltipDivider-Transparent", tCoordLeft = 0, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 1, tFitDropDownSizeX = true, tSizeX = 0, tSizeY = 8 };
		entry.iconInfo = entry; -- looks like stupid? is necessary to work. (thats blizzard)

	else
		entry.isTitle      = D.title     or false;
		entry.hasArrow     = D.arrow     or false;
		entry.disabled     = D.disabled  or false;
		entry.notClickable = not not D.noclick;
		entry.isNotRadio   = not D.radio;

		if (D.cvarType) and (D.cvar) and (type(D.cvarType)=="string") and (cvarTypeFunc[D.cvarType]) then
			D=cvarTypeFunc[D.cvarType](D);
		end

		if (D.dbType) and (D.keyName) and (type(D.dbType)=="string") and (dbTypeFunc[D.dbType]) then
			D=dbTypeFunc[D.dbType](D);
		end

		if (D.checked~=nil) then
			entry.checked = D.checked;
			entry.keepShownOnClick = 1;
		else
			entry.notCheckable = true;
		end

		entry.text = D.label or "";

		if (D.colorCode) then
			entry.colorCode = entry.colorCode;
		end

		if (D.tooltip) and (type(D.tooltip)=="table") then
			entry.tooltipTitle = D.tooltip[1];
			entry.tooltipText = D.tooltip[2];
			entry.tooltipOnButton=1;
		end

		if (D.icon) then
			entry.text = entry.text .. "    ";
			entry.icon = D.icon;
			entry.tCoordLeft, entry.tCoordRight = 0.05,0.95;
			entry.tCoordTop, entry.tCoordBottom = 0.05,0.95;
		end

		if (D.func) then
			entry.arg1 = D.arg1;
			entry.arg2 = D.arg2;
			entry.func = function(...)
				D.func(...)
				if (type(D.event)=="function") then
					D.event();
				end
				if (P) and (not entry.keepShownOnClick) then
					if (_G["DropDownList1"]) then _G["DropDownList1"]:Hide(); end
				end
			end;
		end

		-- gxRestart
		-- gameRestart

		if (not D.title) and (not D.disabled) and (not D.arrow) and (not D.checked) and (not D.func) then
			entry.disabled = true;
		end
	end

	if (P) and (type(P)=="table") then
		if (not P.menuList) then P.menuList = {}; end
		tinsert(P.menuList, entry);
		return P.menuList[#P.menuList];
	else
		tinsert(self.menu, entry);
		return self.menu[#self.menu];
	end
	return false;
end

self.addEntries = self.addEntry;

self.ShowMenu = function(parent, anchorA, anchorB, parentX, parentY)
	local anchor, x, y, displayMode = "cursor", nil, nil, "MENU"

	if (parent) then
		anchor = parent;
		x = parentX or 0;
		y = parentY or 0;
		self.frame.point = anchorA or "TOPLEFT"
		self.frame.relativePoint=anchorB or "BOTTOMLEFT";
	end

	self.addEntry({separator=true});
	self.addEntry({label=CANCEL.."/"..CLOSE, func=function() self.frame:Hide(); end});

	UIDropDownMenu_Initialize(self.frame, EasyMenu_Initialize, displayMode, nil, self.menu);
	ToggleDropDownMenu(1, nil, self.frame, anchor, x, y, self.menu, nil, nil);
end
