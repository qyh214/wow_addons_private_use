local _G = _G

local MovAny = _G.MovAny

local m = {
	vars = {"disableLayerArtwork", "disableLayerBackground", "disableLayerBorder", "disableLayerHighlight", "disableLayerOverlay"},
	IsValidObject = function(self, o)
		return (o.DisableDrawLayer)
	end,
	Apply = function(self, e, f, opt)
		opt = opt or e.userData or MovAny:GetUserData(e.name)
		if opt and opt.disableLayerArtwork then
			f:DisableDrawLayer("ARTWORK")
		end
		if opt and opt.disableLayerBackground then
			f:DisableDrawLayer("BACKGROUND")
		end
		if opt and opt.disableLayerBorder then
			f:DisableDrawLayer("BORDER")
		end
		if opt and opt.disableLayerHighlight then
			f:DisableDrawLayer("HIGHLIGHT")
		end
		if opt and opt.disableLayerOverlay then
			f:DisableDrawLayer("OVERLAY")
		end
	end,
	Reset = function(self, e, f, readOnly, opt)
		opt = e.userData
		if not f.EnableDrawLayer then
			if not readOnly then
				opt.disableLayerArtwork = nil
				opt.disableLayerBackground = nil
				opt.disableLayerBorder = nil
				opt.disableLayerHighlight = nil
				opt.disableLayerOverlay = nil
				return
			end
		end
		if opt and opt.disableLayerArtwork then
			f:EnableDrawLayer("ARTWORK")
			if not readOnly then
				opt.disableLayerArtwork = nil
			end
		end
		if opt and opt.disableLayerBackground then
			f:EnableDrawLayer("BACKGROUND")
			if not readOnly then
				opt.disableLayerBackground = nil
			end
		end
		if opt and opt.disableLayerBorder then
			f:EnableDrawLayer("BORDER")
			if not readOnly then
				opt.disableLayerBorder = nil
			end
		end
		if opt and opt.disableLayerHighlight then
			f:EnableDrawLayer("HIGHLIGHT")
			if not readOnly then
				opt.disableLayerHighlight = nil
			end
		end
		if opt and opt.disableLayerOverlay then
			f:EnableDrawLayer("OVERLAY")
			if not readOnly then
				opt.disableLayerOverlay = nil
			end
		end
	end
}

MovAny:AddModule("Layers", m)
