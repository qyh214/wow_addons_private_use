local _G = _G

local MovAny = _G.MovAny
local MOVANY = _G.MOVANY
local curModule
local curElement
local elemMetaTable
local catMetaTable

local m = {
	customCat = nil,
	Init = function(self)
		self.compile = true

		self.all = { }
		self.allCount = 0

		self.elems = { }
		self.elemsN = { }
		self.elemIDNext = 0

		self.cats = { }
		self.catsN = { }
		self.catIDNext = 0
	end,
	Enable = function() end,
	CompileList = function(self)
		self.allCount = 0
		table.wipe(self.all)
		for ci, c in pairs(self.cats) do
			if not c.hidden and not c.disabled then
				self.allCount = self.allCount + 1
				tinsert(self.all, self.allCount, c)
				for ei, e in ipairs(c.elems) do
					if not e.hidden and not e.disabled then
						self.allCount = self.allCount + 1
						tinsert(self.all, self.allCount, e)
					end
				end
			end
		end
		self.compile = nil
	end,
	GetItem = function(self, idx)
		return self.all[idx]
	end,
	ClearElementsUserData = function(self)
		for i, v in ipairs(self.elems) do
			v:SetUserData(nil)
		end
	end,
	AddElement = function(self, e, ...)
		if type(e) ~= "table" then
			return
		end
		setmetatable(e, elemMetaTable)
		self.elemIDNext = self.elemIDNext + 1
		self.elems[self.elemIDNext] = e
		self.elemsN[e.name] = e
		e.default = self.default
		if not e.displayName then
			e.displayName = e.name
		end
		local gotCat = nil
		if select("#",...) > 0 then
			local c
			for i = 1, select("#",...), 1 do
				c = select(i, ...)
				if c then
					c:AddElement(e)
					gotCat = true
				end
			end
		end
		if not gotCat then
			e:AddCategory(MovAny.API.customCat)
		end
		return e
	end,
	GetElement = function(self, idx)
		return type(idx) == "number" and self.elems[idx] or self.elemsN[idx]
	end,
	AddElementIfNew = function(self, name, displayName, cat)
		local e = self:GetElement(name)
		if not e then
			displayName = displayName or name
			e = self:AddElement({name = name, displayName = displayName}, cat)
			if MovAny.inited then
				if MovAny.userData[name] then
					e:SetUserData(MovAny.userData[name])
				end
				self.compile = true
				MovAny.guiLines = -1
				MovAny:UpdateGUIIfShown()
			end
		end
		return e
	end,
	SyncElement = function(self, name, forceSync)
		local e = self:GetElement(name)
		if e then
			if forceSync and e.refuseSync then
				e.refuseSync = nil
			end
			e:Sync()
		end
	end,
	ElementIsDefault = function(self, f)
		if not f.GetName then
			return
		end
		local e = self:GetElement(f:GetName())
		return e and e.default or nil
	end,
	RemoveCustomElement = function(self, fn)
		local e = self:GetElement(fn)
		if not e.default then
			e:Delete()
		end
	end,
	AddCategory = function(self, c)
		if type(c) ~= "table" then
			return
		end
		setmetatable(c, catMetaTable)
		self.catIDNext = self.catIDNext + 1
		self.cats[self.catIDNext] = c
		self.catsN[c.name] = c
		c.default = self.default
		c.elems = { }
		c.collapsed = MovAny.collapsed
		return c
	end,
	GetCategory = function(self, idx)
		return type(idx) == "number" and self.cats[idx] or self.catsN[idx]
	end
}

elemMetaTable = {__index = {
	--[[ToggleEnable = function(self)
		if self.disabled then
			self.disabled = nil
		else
			self.disabled = true
		end
	end,]]
	AddCategory = function(self, c)
		tinsert(c.elems, self)
	end,
	DeleteCategory = function(self, c)
		for i, v in ipairs(c.elems) do
			if v == self then
				tremove(c.elems, i)
				break
			end
		end
	end,
	Delete = function(self)
		for ci, c in ipairs(m.cats) do
			for i, v in ipairs(c.elems) do
				if v == self then
					tremove(c.elems, i)
					break
				end
			end
		end
		m.elemsN[self.name] = nil
		for i, v in ipairs(m.elems) do
			if v == self then
				tremove(m.elems, i)
			end
		end
	end,
	GetCategories = function(self)
		local res = { }
		for ci, c in ipairs(m.cats) do
			for i, v in ipairs(c.elems) do
				if v == self then
					tinsert(res, c)
				end
			end
		end
		return res
	end,
	GetCategory = function(self, idx)
		idx = idx or 1
		local count = 0
		for ci, c in ipairs(m.cats) do
			for i, v in ipairs(c.elems) do
				if v == self then
					count = count + 1
					if count == idx then
						return c
					end
				end
			end
		end
	end,
	GetAllIndex = function(self)
		for i, v in ipairs(m.all) do
			if v == self then
				return i
			end
		end
	end,
	IsModified = function(self, var)
		self.userData = self.userData or self:SetUserData(MovAny:GetUserData(self.name))
		if self.userData then
			local opt = self.userData
			if var then
				if opt[var] then
					return true
				end
			elseif opt.pos or opt.hidden or opt.scale ~= nil or opt.alpha ~= nil or opt.frameStrata ~= nil or opt.disableLayerArtwork ~= nil or opt.disableLayerBackground ~= nil or opt.disableLayerBorder ~= nil or opt.disableLayerHighlight ~= nil or opt.disableLayerOverlay ~= nil or opt.unregisterAllEvents ~= nil or opt.groups ~= nil or opt.forcedLock ~= nil then
				return true
			end
		end
	end,
	Sync = function(e, f)
		if not e:IsModified() then
			return
		end
		if e.runOnce then
			if not e:runOnce() then
				e.runOnce = nil
			else
				return
			end
		end
		if not e.userData.disabled and not e.refuseSync then
			if not e.runBeforeInteract or not e:runBeforeInteract() then
				if not f then
					if e.f then
						f = e.f
					else
						f = _G[e.name]
						e.f = f
					end
				end
				if f and MovAny:IsValidObject(f, true) then
					if not MovAny:IsProtected(f) or not InCombatLockdown() then
						if f.MAHooked then
							e:Reset(f, true, e.userData, true)
						end

						if MovAny:HookFrame(e, f, nil, true) then
							e:Apply(f, e.userData)

							if e.runAfterInteract then
								e:runAfterInteract()
							end
							return true
						end
					end
				end
				if not MovAny.syncingFrames then
					MovAny.pendingFrames[e.name] = e
				end
			end
		end
	end,
	Apply = function(e, f, opt)
		e.anyFailure = nil
		for i, v in ipairs(MovAny.modules) do
			curModule = v
			curElement = f
			e.success = xpcall(function()
				return v:Apply(e, f, opt)
			end, e.ApplyErrorHandler, e)
			e.anyFailure = e.anyFailure or (e.success == false)
		end
		curModule = nil
		curElement = nil
		return e.anyFailure
	end,
	ApplyErrorHandler = function(msg, frame, stack, ...)
		if MADB.disableErrorMessages then
			return
		end
		stack = stack or debugstack(2, 20, 20)
		local funcs = ""
		for m in string.gmatch(stack, "function (%b`')") do
			if m ~= "xpcall" then
				if funcs == "" then
					funcs = m
				else
					funcs = funcs..", "..m
				end
			end
		end
		maPrint(string.format(MOVANY.ERROR_MODULE_FAILED, curModule.name, curElement:GetName(), curElement:GetName(), curModule.name, GetAddOnMetadata("MoveAnything", "Version"), msg, funcs))
		local errorHandler = geterrorhandler()
		if type(errorHandler) == "function" and errorHandler ~= _ERRORMESSAGE then
			errorHandler(msg, frame, stack, ...)
		end
	end,
	Reset = function(e, f, readOnly, opt, dontResetHide)
		if f and f.MAHooked and f.SetUserPlaced and f:IsUserPlaced() and (f:IsMovable() or f:IsResizable()) then
			if f:IsUserPlaced() then
				if f.MAWasUserPlaced then
					f.MAWasUserPlaced = nil
				else
					f:SetUserPlaced(false)
				end
			end
			if f:IsMovable() then
				if f.MAWasMovable then
					f.MAWasMovable = nil
				else
					f:SetMovable(false)
				end
			end
			if f:IsResizable() then
				if f.MAWasResizable then
					f.MAWasResizable = nil
				else
					f:SetResizable(false)
				end
			end
		end
		if f.OnMAPreReset then
			f:OnMAPreReset(readOnly, opt, e)
		end
		for i, m in ipairs(MovAny.modules) do
			--if not exclude or not exclude[v.name] then
			if not dontResetHide or m.name ~= "Hide" then
				m:Reset(e, f, readOnly, opt)
			end
		end
		f.MAHooked = nil
		if f.OnMAPostReset then
			f:OnMAPostReset(readOnly, opt, e)
		end
	end,
	SetUserData = function(e, ud)
		e.userData = ud
		local f = e.f or _G[e.name]
		if f and f.MAEVM then
			f.opt = ud
		end
		return ud
	end
}}

catMetaTable = {__index = {
	ToggleEnable = function(self)
		if self.disabled then
			self.disabled = nil
		else
			self.disabled = true
		end
	end,
	ToggleHide = function(self)
		--store in MADB
		if self.hidden then
			self.hidden = nil
		else
			self.hidden = true
		end
	end,
	TogglePurge = function(self)
		--store in MADB
		if self.purge then
			self.purge = nil
		else
			self.purged = true
			--purge category
		end
	end,
	AddElement = function(self, e)
		if e then
			tinsert(self.elems, e)
		end
		return e
	end,
	DeleteElement = function(self, e)
		for i, v in ipairs(self.elems) do
			if v == e then
				tremove(self.elems, i)
				break
			end
		end
	end,
	GetAllIndex = function(self)
		for i, v in ipairs(m.all) do
			if v == self then
				return i
			end
		end
	end,
}}

MovAny:AddCore("API", m)