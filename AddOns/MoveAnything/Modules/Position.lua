local _G, type, pairs, unpack, table, tinsert, tremove, string = _G, type, pairs, unpack, table, tinsert, tremove, string

local MovAny = _G.MovAny

local m = {
	var = "pos",
	orgVar = "orgPos",
	IsValidObject = function(self, o)
		return (o.SetPoint)
	end,
	Enable = function(self)
		if self.lSafeRelatives then
			table.wipe(self.lSafeRelatives)
		else
			self.lSafeRelatives = {}
		end
	end,
	Disable = function()
	end,
	Apply = function(self, e, f, opt)
		opt = opt or e.userData or MovAny:GetUserData(e.name)
		if not opt or e.noMove then
			return
		end
		if opt.pos then
			local relTo = opt.pos[2]
			if not relTo then
				return true
			else
				if not self.lSafeRelatives[relTo] then
					if type(relTo) == "table" and relTo.GetName then
						relTo = relTo:GetName()
					end
					if _G[relTo] then
						self.lSafeRelatives[relTo] = true
					else
						return true
					end
				end
			end
			local fn = f:GetName()
			if opt.orgPos == nil and not MovAny:IsContainer(f:GetName()) and string.match("BagFrame", f:GetName()) ~= nil then
				self:StoreOrgPoints(f, opt)
			end
			if UIPARENT_MANAGED_FRAME_POSITIONS[fn] then
				f.ignoreFramePositionManager = true
			end
			MovAny:UnlockPoint(f)
			f:ClearAllPoints()
			if f.MASetPoint then
				f:MASetPoint(unpack(opt.pos))
			else
				f:SetPoint(unpack(opt.pos))
			end
			MovAny:LockPoint(f, opt)
			if f.OnMAPosition then
				f.OnMAPosition(f)
			end
			if e.onPosition then
				e.onPosition(f)
			end
			if f.attachedChildren then
				for i, v in pairs(f.attachedChildren) do
					if not v.ignoreFramePositionManager and v.GetName and UIPARENT_MANAGED_FRAME_POSITIONS[v:GetName()] and not v.ignoreFramePositionManager and not MovAny:IsModified(v) and v.GetName and UIPARENT_MANAGED_FRAME_POSITIONS[v:GetName()] then
						v.UMFP = true
						v.ignoreFramePositionManager = true
					end
				end
			end
			if UIPanelWindows[fn] and f ~= GameMenuFrame then
				local left = GetUIPanel("left")
				local center = GetUIPanel("center")
				if f == left then
					UIParent.left = nil
					if center then
						UIParent.center = nil
						UIParent.left = center
					end
				elseif f == center then
					UIParent.center = nil
				end
				local wasShown = f:IsShown()
				if f ~= TaxiFrame and f ~= MerchantFrame and f ~= BankFrame and f ~= QuestFrame and f ~= ClassTrainerFrame and (not MovAny:IsProtected(f) or not InCombatLockdown()) then
					--[[if MovAny.rendered then
						--HideUIPanel(f)
					else]]
						--[[local sfx = GetCVar("Sound_EnableSFX")
						if sfx then
							SetCVar("Sound_EnableSFX", 0)
						end]]
						if not MovAny.rendered and wasShown then
							ShowUIPanel(f)
						end
						HideUIPanel(f)
						--[[if sfx then
							SetCVar("Sound_EnableSFX", 1)
						end]]
					--end
				end
				if opt then
					opt.UIPanelWindows = UIPanelWindows[fn]
				end
				UIPanelWindows[fn] = nil
				f:SetAttribute("UIPanelLayout-enabled", false)
				tinsert(UISpecialFrames, f:GetName())
				if wasShown and f ~= TaxiFrame and f ~= MerchantFrame and f ~= BankFrame and f ~= QuestFrame and f ~= ClassTrainerFrame and (not MovAny:IsProtected(f) or not InCombatLockdown()) then
					f:Show()
				end
			end
		end
	end,
	Reset = function(self, e, f, readOnly, opt)
		opt = opt or e.userData or MovAny:GetUserData(e.name)
		if not opt or e.noMove then
			return
		end
		MovAny:UnlockPoint(f)
		local umfp = nil
		if f.ignoreFramePositionManager then
			umfp = true
			f.ignoreFramePositionManager = nil
		end
		
		if opt.orgPos then
			self:RestoreOrgPoints(f, opt, readOnly)
		else
			--f:ClearAllPoints()
			return
		end
		--[[if not readOnly and f.MAUnanchoredRelatives then
			--dbg(f:GetName().." got unanchored relatives")
			for i, v in pairs(f.MAUnanchoredRelatives) do
				if not MovAny:IsModified(v) then
					--dbg(" restoring anchor to "..v:GetName().." ")
					MovAny:UnlockPoint(v)
					if v.MAOrgPoint then
						v:SetPoint(unpack(v.MAOrgPoint))
						v.MAOrgPoint = nil
					end
				--else
					--dbg("skipping hooked relative: "..v:GetName())
				end
			end
			f.MAUnanchoredRelatives = nil
		end]]
		if e.positionReset then
			e:positionReset(f, opt, readOnly)
		end
		if f.OnMAPositionReset then
			f.OnMAPositionReset(f, opt, readOnly)
		end
		if not readOnly then
			opt.pos = nil
		end
		if f.attachedChildren then
			for i, v in pairs(f.attachedChildren) do
				if v and not MovAny:IsModified(v) and v.GetName and v.UMFP then
					v.UMFP = nil
					v.ignoreFramePositionManager = nil
					umfp = true
				end
			end
		end
		if opt.UIPanelWindows and not readOnly then
			for i, v in pairs(UISpecialFrames) do
				if v == e.name then
					tremove(UISpecialFrames, i)
					break
				end
			end
			if not readOnly then
				UIPanelWindows[ f:GetName() ] = opt.UIPanelWindows
				opt.UIPanelWindows = nil
			end
			if not readOnly and f:IsShown() and f ~= MerchantFrame and f ~= BankFrame and f ~= QuestFrame and f ~= ClassTrainerFrame and (not MovAny:IsProtected(f) or not InCombatLockdown()) then
				f:SetAttribute("UIPanelLayout-enabled", true)
				ShowUIPanel(f)
			else
				f:SetAttribute("UIPanelLayout-enabled", true)
			end
		end
		if umfp and not InCombatLockdown() then
			UIParent_ManageFramePositions()
		end
		f.MAOrgParent = nil
	end,
	StoreOrgPoints = function(self, f, opt)
		local np = f:GetNumPoints()
		if np == 1 then
			opt.orgPos = MovAny:GetSerializedPoint(f)
		elseif np > 1 then
			opt.orgPos = {}
			for i = 1, np, 1 do
				opt.orgPos[i] = MovAny:GetSerializedPoint(f, i)
			end
		end
		if not opt.orgPos then
			if f == TargetFrameSpellBar then
				opt.orgPos = {"BOTTOM", "TargetFrame", "BOTTOM", -15, 10}
			elseif f == FocusFrameSpellBar then
				opt.orgPos = {"BOTTOM", "FocusFrame", "BOTTOM", 0, 0}
			elseif f == VehicleMenuBarHealthBar then
				opt.orgPos = {"BOTTOMLEFT", "VehicleMenuBarArtFrame", "BOTTOMLEFT", 119, 3}
			elseif f == VehicleMenuBarPowerBar then
				opt.orgPos = {"BOTTOMRIGHT", "VehicleMenuBarArtFrame", "BOTTOMRIGHT", -119, 3}
			elseif f == VehicleMenuBarLeaveButton then
				opt.orgPos = {"BOTTOMRIGHT", "VehicleMenuBar", "BOTTOMRIGHT", 177, 15}
			--[[elseif f == LFDDungeonReadyDialog then
				opt.orgPos = {"TOP", "UIParent", "TOP", 0, -135}
			elseif f == LFDDungeonReadyPopup then
				opt.orgPos = {"TOP", "UIParent", "TOP", 0, -135}
			elseif f == LFDDungeonReadyStatus then]]
			else
				--dbg("Unable to generate restore point for "..f:GetName()..". OrgPos set to default")
				opt.orgPos = {"TOP", "UIParent", "TOP", 0, -135}
			end
		end
	end,
	RestoreOrgPoints = function(self, f, opt, readOnly)
		f:ClearAllPoints()
		if opt then -- and not opt.UIPanelWindows
			if type(opt.orgPos) == "table" then
				if type(opt.orgPos[1]) == "table" then
					for i, v in pairs(opt.orgPos) do
						if f.MASetPoint then
							f:MASetPoint(unpack(v))
						else
							f:SetPoint(unpack(v))
						end
					end
				else
					if f.MASetPoint then
						f:MASetPoint(unpack(opt.orgPos))
					else
						f:SetPoint(unpack(opt.orgPos))
					end
				end
			end
			if not readOnly then
				opt.orgPos = nil
			end
		end
	end,
	GetFirstOrgPoint = function(self, opt)
		if opt then -- and not opt.UIPanelWindows
			if type(opt.orgPos) == "table" then
				if type(opt.orgPos[1]) == "table" then
					return opt.orgPos[1]
				else
					return opt.orgPos
				end
			end
		end
	end
}

MovAny:AddModule("Position", m)