local pairs = pairs

local MovAny = _G.MovAny
local alpha

local m = {
	var = "alpha",
	orgVar = "orgAlpha",
	IsValidObject = function(self, o)
		return (o.SetAlpha)
	end,
	Apply = function(self, e, f, opt)
		opt = opt or e.userData or MovAny:GetUserData(e.name)
		if not opt or e.noAlpha then
			return
		end
		alpha = opt.alpha
		if alpha and alpha >= 0 and alpha <= 1 then
			if opt.orgAlpha == nil then
				opt.orgAlpha = f:GetAlpha()
			end
			f:SetAlpha(alpha)
			if f.attachedChildren and not f.MADontAlphaChildren then
				for i, v in pairs(f.attachedChildren) do
					if v:GetAlpha() ~= 1 then
						v.MAOrgAlpha = v:GetAlpha()
					end
					v:SetAlpha(alpha)
				end
			end
			if f.OnMAAlpha then
				f.OnMAAlpha(f, alpha)
			end
		end
	end,
	Reset = function(self, e, f, readOnly, opt)
		opt = opt or e.userData or MovAny:GetUserData(e.name)
		if not opt or e.noAlpha then
			return
		end
		
		alpha = opt.orgAlpha
		if alpha == nil or alpha > 1 then
			alpha = 1
		elseif alpha < 0 then
			alpha = 0
		end
		f:SetAlpha(alpha)
		if f.attachedChildren and not f.MADontAlphaChildren then
			for i, v in pairs(f.attachedChildren) do
				v:SetAlpha(alpha)
			end
		end
		if f.OnMAAlpha then
			f.OnMAAlpha(f, alpha)
		end
		if not readOnly then
			opt.alpha = nil
			opt.orgAlpha = nil
		end
	end
}

MovAny:AddModule("Alpha", m)