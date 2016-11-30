local MovAny = _G.MovAny
local alpha

local m = {
	var = "backdropAlpha",
	orgVar = "orgBackdropAlpha",
	IsValidObject = function(self, o)
		return (o.SetBackdropColor)
	end,
	Apply = function(self, e, f)
		if not e.userData or e.NoBackdrop then
			return
		end
		alpha = e.userData.backdropAlpha
		if alpha and alpha >= 0 and alpha <= 1 then
			local r, g, b
			if e.userData.orgBackdropAlpha == nil then
				r, g, b, e.userData.orgBackdropAlpha = f:GetBackdropColor()
			else
				r, g, b = f:GetBackdropColor()
			end
			f:SetBackdropColor(r, g, b, alpha)
		end
	end,
	Reset = function(self, e, f, readOnly)
		if not e.userData or e.NoBackdrop then
			return
		end
		alpha = e.userData.orgBackdropAlpha
		if alpha and alpha >= 0 and alpha <= 1 then
			local r, g, b = f:GetBackdropColor()
			f:SetBackdropColor(r, g, b, alpha)
		end
		
		if not readOnly then
			e.userData.backdropAlpha = nil
			e.userData.orgBackdropAlpha = nil
		end
	end,
}

MovAny:AddModule("Backdrop", m)
