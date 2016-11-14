local _G, pairs, type = _G, pairs, type

local MovAny = _G.MovAny

local m = {
	var = "scale",
	orgVar = "orgScale",
	IsValidObject = function(self, o)
		return (o.SetScale)
	end,
	Enable = function(self)
	end,
	Apply = function(self, e, f, opt)
		opt = opt or e.userData or MovAny:GetUserData(e.name)
		if not opt or not self:CanBeScaled(f, e) then
			return
		end
		MovAny:UnlockScale(f)
		if f.GetName and e.scaleWH then
			if opt.width or opt.height then
				if opt.width and opt.orgWidth == nil then
					opt.orgWidth = f:GetWidth()
				end
				if opt.height and opt.orgHeight == nil then
					opt.orgHeight = f:GetHeight()
				end
				if e.hideOnScale then
					for i, v in pairs(e.hideOnScale) do
						MovAny:LockVisibility(v)
					end
				end
				if type(opt.width) == "number" and opt.width > 0 then
					f:SetWidth(opt.width)
				end
				if type(opt.height) == "number" and opt.height > 0 then
					f:SetHeight(opt.height)
				end
				MovAny:LockScale(f)
				if f == e.f and e.linkedScaling then
					local le
					for i, v in pairs(e.linkedScaling) do
						le = MovAny.API:GetElement(v)
						if le and not le:IsModified() then
							le.userData[self.var] = opt[self.var]
							self:Apply(le, _G[v])
						else
							self:Apply(e, _G[v])
						end
					end
				end
				if f.OnMAScale then
					f.OnMAScale(f, opt.width, opt.height)
				end
			end
		elseif opt.scale ~= nil and opt.scale >= 0 then
			if not opt.orgScale then
				opt.orgScale = f:GetScale()
			end
			f:SetScale(opt.scale)
			MovAny:LockScale(f)
			if f == e.f then
				if e.hideOnScale then
					for i, v in pairs(e.hideOnScale) do
						MovAny:LockVisibility(v)
					end
				end
				if f.attachedChildren and not f.MADontScaleChildren then
					local le
					for i, v in pairs(f.attachedChildren) do
						le = MovAny.API:GetElement(v)
						if not le or not le:IsModified() then
							self:Apply(e, v)
						end
					end
				end
				if e.linkedScaling then
					for i, v in pairs(e.linkedScaling) do
						if not MovAny:IsModified(v) then
							self:Apply(e, _G[v])
						end
					end
				end
			end
			if f.OnMAScale then
				f.OnMAScale(f, opt.scale)
			end
		end
	end,
	Reset = function(self, e, f, readOnly, opt, noLinkedScaling)
		opt = opt or e.userData or MovAny:GetUserData(e.name)
		-- XX: should prolly change the second following condition to self:CanBeScaled(f, e)
		if not opt or (f.GetName and e.noScale) then
			return
		end
		MovAny:UnlockScale(f)
		if e.scaleWH then
			if (opt.orgWidth and f:GetWidth() ~= opt.orgWidth) or (opt.orgHeight and f:GetHeight() ~= opt.orgHeight) then
				if opt.orgWidth ~= nil and opt.orgWidth > 0 then
					f:SetWidth(opt.orgWidth)
				end
				if opt.orgHeight ~= nil and opt.orgHeight > 0 then
					f:SetHeight(opt.orgHeight)
				end
				if f == e.f then
					if e.hideOnScale then
						for i, v in pairs(e.hideOnScale) do
							MovAny:UnlockVisibility(v)
						end
					end
					if not noLinkedScaling and e.linkedScaling then
						local lf
						for i, v in pairs(e.linkedScaling) do
							if not MovAny:IsModified(v) then
								lf = _G[v]
								if self:CanBeScaled(lf, e) then
									if MovAny:IsProtected(lf) and InCombatLockdown() then
										MovAny.pendingFrames[v] = e
									else
										self:Reset(e, lf, true, opt, true)
									end
								end
							end
						end
					end
				end
				if f.OnMAScale then
					f.OnMAScale(f, opt.width, opt.height)
				end
			end
			if not readOnly then
				opt.orgWidth = nil
				opt.orgHeight = nil
				opt.width = nil
				opt.height = nil
			end
		elseif self:CanBeScaled(f, e, true) then
			if not opt.scale then
				return
			end
			local scale = opt.orgScale or 1
			if scale == nil then
				return
			end
			if scale ~= f:GetScale() then
				f:SetScale(scale)
			end
			if f == e.f then
				if e.hideOnScale then
					for i, v in pairs(e.hideOnScale) do
						MovAny:UnlockVisibility(v)
					end
				end
				if f.attachedChildren and not f.MADontScaleChildren then
					for i, v in pairs(f.attachedChildren) do
						if not e:IsModified(v) then
							if self:CanBeScaled(v, e) then
								if MovAny:IsProtected(v) and InCombatLockdown() then
									MovAny.pendingFrames[v:GetName()] = e
								else
									self:Reset(e, v, true, opt, true)
								end
							end
						end
					end
				end
				if e.linkedScaling then
					local lf
					for i, v in pairs(e.linkedScaling) do
						lf = _G[v]
						if lf then
							self:Reset(e, lf, true)
						end
					end
				end
			end
			if f.OnMAScale then
				f.OnMAScale(f, scale)
			end
			if not readOnly then
				opt.scale = nil
				opt.orgScale = nil
			end
		end
	end,
	CanBeScaled = function(self, f, e, mode)
		e = e or (f.GetName and MovAny.API:GetElement(f:GetName())) or nil
		if not e then
			return nil
		end
		if not mode and e.scaleWH then
			return true
		end
		if not f or not f.GetScale or e.noScale or f:GetObjectType() == "FontString" then
			return nil
		end
		return true
	end
}

MovAny:AddModule("Scale", m)