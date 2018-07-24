local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local M = E:GetModule('MiscEnh')

-- Based on ElvUI_TransparentMovers by: Dandruff @ Whisperwind

function M:UpdateMoverTransparancy()
	local mover
	for name, _ in pairs(E.CreatedMovers) do
		mover = _G[name]
		if mover then
			mover:SetAlpha(E.db.general.movertransparancy)
		end
	end
end

function M:LoadMoverTransparancy()
	-- hook create function for movers created after this method has run
	hooksecurefunc(E, 'CreateMover', function(self, parent)
	  parent.mover:SetAlpha(E.db.general.movertransparancy)
	end)
	
	-- update transparancy of all created movers
	self:UpdateMoverTransparancy()
end
