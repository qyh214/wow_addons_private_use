local _G = _G

local MovAny = _G.MovAny

local m = {
	var = "hidden",
	Apply = function(self, e, f)
		if not e.userData or e.noHide then
			return
		end
		-- HideFrame fires OnMAHide event now
		if e.userData.hidden and not f.MAHidden then
			MovAny:HideFrame(f)
		end
	end,
	Reset = function(self, e, f, readOnly)
		if not e.userData or e.noHide then
			return
		end
		local wasHidden = e.userData.hidden
		if not readOnly then
			e.userData.hidden = nil
		end
		if not wasHidden then
			return
		end
		if wasHidden then
			MovAny:ShowFrame(f, readOnly, true)
		end
		if f.OnMAHide then
			f.OnMAHide(f, nil)
		end
	end
}

MovAny:AddModule("Visibility", m)