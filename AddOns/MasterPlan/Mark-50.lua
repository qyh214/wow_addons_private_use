select(2, ...).Mark = select(4,GetBuildInfo()) == 60200 and 50

function GarrisonMissionFrame_SelectTab(id)
	local mainFrame = GarrisonMissionFrame
	PlaySound("UI_Garrison_Nav_Tabs");
	PanelTemplates_SetTab(mainFrame, id);
	mainFrame:SelectTab(id);
end
do
	local skip
	function GarrisonFollowerList_Update(self)
		if skip then
			skip = false
		else
			self.FollowerList:UpdateData()
		end
	end
	local function OnUpdateData(self)
		skip = true
		GarrisonFollowerList_Update(self:GetParent())
	end
	hooksecurefunc(GarrisonMissionFrame.FollowerList, "UpdateData", OnUpdateData)
	hooksecurefunc(GarrisonLandingPage.FollowerList, "UpdateData", OnUpdateData)
end
local OnShowFollower do
	local skip
	function GarrisonFollowerPage_ShowFollower(self, id)
		if skip then
			skip = false
		else
			self.followerList:ShowFollower(id)
		end
	end
	function OnShowFollower(self, ...)
		skip = true
		return GarrisonFollowerPage_ShowFollower(self.followerTab, ...)
	end
end
hooksecurefunc(GarrisonMissionFrame.FollowerList, "ShowFollower", OnShowFollower)
hooksecurefunc(GarrisonLandingPage.FollowerList, "ShowFollower", OnShowFollower)
