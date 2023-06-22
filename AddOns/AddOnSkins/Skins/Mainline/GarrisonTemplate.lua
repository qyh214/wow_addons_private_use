local AS, L, S, R = unpack(AddOnSkins)

local _G = _G
local hooksecurefunc = hooksecurefunc
local C_Garrison_GetFollowerInfo = C_Garrison.GetFollowerInfo
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

function R:Blizzard_GarrisonTemplates()
	if not AS:IsSkinEnabled('Blizzard_GarrisonTemplates', 'orderhall') then return end
	if not AS:IsSkinEnabled('Blizzard_GarrisonTemplates', 'garrison') then return end

	hooksecurefunc(_G.GarrisonFollowerTabMixin, 'ShowFollower', function(s, followerID)
		local followerInfo = followerID and C_Garrison_GetFollowerInfo(followerID)
		if not followerInfo then return end

		if not s.PortraitFrameStyled then
			S:HandleGarrisonPortrait(s.PortraitFrame)
			s.PortraitFrameStyled = true
		end

		local color = followerInfo.quality and ITEM_QUALITY_COLORS[followerInfo.quality]
		if color then
			if s.PortraitFrame.backdrop then
				s.PortraitFrame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
			end
			s.Name:SetVertexColor(color.r, color.g, color.b)
		end

		s.XPBar:ClearAllPoints()
		S:Point(s.XPBar, 'BOTTOMLEFT', s.PortraitFrame, 'BOTTOMRIGHT', 7, -15)
	end)
end

AS:RegisterSkin('Blizzard_GarrisonTemplates', nil, 'ADDON_LOADED')
