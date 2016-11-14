local pairs = pairs

local MovAny = _G.MovAny

local m = {
	vars = {"frameStrata", "clampToScreen", "enableMouse", "movable", "unregisterAllEvents"},
	orgVars = {"orgFrameStrata", "orgClampToScreen", "orgEnableMouse", "orgMovable"},
	Apply = function(self, e, f, opt, level)
		opt = opt or e.userData
		if not opt then
			return
		end
		level = level or 1
		if level == 1 and opt.frameStrata then
			if not opt.orgFrameStrata then
				opt.orgFrameStrata = f:GetFrameStrata()
			end
			f:SetFrameStrata(opt.frameStrata)
		end
		if opt.clampToScreen and f.IsClampedToScreen then
			if not opt.orgClampToScreen then
				opt.orgClampToScreen = f:IsClampedToScreen()
			end
			f:SetClampedToScreen(opt.clampToScreen)
		end
		if opt.enableMouse ~= nil then
			opt.orgEnableMouse = f:IsMouseEnabled()
			f:EnableMouse(opt.enableMouse)
		end
		if opt.movable ~= nil then
			opt.orgMovable = f:IsMovable()
			f:SetMovable(opt.movable)
		end
		if opt.unregisterAllEvents and f.UnregisterAllEvents then
			f:UnregisterAllEvents()
		end
		if f.attachedChildren then
			level = level + 1
			for i, v in pairs(f.attachedChildren) do
				self:Apply(e, v, opt, level)
			end
		end
	end,
	Reset = function(self, e, f, readOnly, opt, level)
		opt = opt or e.userData
		if not opt then
			return
		end
		level = level or 1
		if level == 1 and opt.orgFrameStrata then
			f:SetFrameStrata(opt.orgFrameStrata)
			if not readOnly then
				opt.frameStrata = nil
				opt.orgFrameStrata = nil
			end
		end
		if opt.orgClampToScreen and f.IsClampedToScreen then
			f:SetClampedToScreen(opt.orgClampToScreen)
			if not readOnly then
				opt.clampToScreen = nil
				opt.orgClampToScreen = nil
			end
		end
		if opt.orgEnableMouse then
			f:EnableMouse(opt.orgEnableMouse)
			if not readOnly then
				opt.orgEnableMouse = nil
				opt.enableMouse = nil
			end
		end
		if opt.orgMovable then
			f:SetMovable(opt.orgMovable)
			if not readOnly then
				opt.orgMovable = nil
				opt.movable = nil
			end
		end
		if not readOnly then
			opt.unregisterAllEvents = nil
		end
		if f.attachedChildren then
			level = level + 1
			for i, v in pairs(f.attachedChildren) do
				self:Reset(e, v, true, opt, level)
			end
		end
	end
}

MovAny:AddModule("Misc", m)