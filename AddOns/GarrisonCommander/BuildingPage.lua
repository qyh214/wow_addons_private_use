--[[
GarrisonBuildingFrame.MapFrame.TownHall
GarrisonBuildingFrame.MapFrame.Plots
Plots[*]={
buildingID=28
plotID=23
followerTooltip="colore + nome del follower"
size= level
Plot=framde del piedistallino
Icon e IconRing contenuto e nordo dell'iconcina
--]]
local me,ns=...
local pp=print
ns.Configure()
local addon=addon
local GBF=GarrisonBuildingFrame
local GBFMap=GBF.MapFrame
local CreateFrame=CreateFrame
local GARRISON_FOLLOWER_MAX_LEVEL=GARRISON_FOLLOWER_MAX_LEVEL
local new,del=ns.new,ns.del
local module=addon:NewSubClass("BuildingPage") --#module
function module:OnInitialize()
	--module:SafeHookScript(GBFMap,"OnShow","AddFollowersToMap")
	module:SafeSecureHook("GarrisonBuildingList_Show","AddCheckBox")
	module:SafeSecureHook("GarrisonPlot_UpdateBuilding","RefreshPlot")
end
function module:AddCheckBox()
	if (not GBFMap.hideFollower) then
		local ck=self:GetFactory():Checkbox(GBFMap,addon:GetToggle("HF"),addon:GetVarInfo("HF"))
		ck:SetPoint("BOTTOMLEFT",5,20)
		ck:Show()
		ck:SetScript("OnClick",function(this)
			addon:SetBoolean("HF",this:GetChecked())
			module:AddFollowersToMap()
		end)
		GBFMap.hideFollower=ck
	end
end
function module:RefreshPlot(plotID)
	for i=1,#GBFMap.Plots do
		if	GBFMap.Plots[i].plotID==plotID then
			return self:AddFollowerToPlot(GBFMap.Plots[i])
		end
	end
end
function module:AddFollowerToPlot(plot)
	if (not plot.followerIcon) then
		plot.followerIcon=CreateFrame("Frame",nil,plot,"GarrisonCommanderMissionPageFollowerTemplateSmall")
		plot.followerIcon:SetScale(0.8)
		plot.followerIcon:SetPoint("CENTER",20,15)
	end
	local frame=plot.followerIcon
	if (addon:GetToggle("HF")) then
		return frame:Hide()
	end
	if plot.followerTooltip then
		local followerName, level, quality, followerID, garrFollowerID, status, portraitIconID = G.GetFollowerInfoForBuilding(plot.plotID)
		if followerName then
			if (level == GARRISON_FOLLOWER_MAX_LEVEL) then
				level=G.GetFollowerItemLevelAverage(followerID)
				frame.PortraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_iLvlBorder");
				frame.PortraitFrame.LevelBorder:SetWidth(70);
			else
				frame.PortraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
				frame.PortraitFrame.LevelBorder:SetWidth(58);
			end
			local info=new()
			info.quality=quality
			info.level=level
			info.portraitIconID=portraitIconID
			info.displayID=portraitIconID
			info.followerTypeID=_G.LE_FOLLOWER_TYPE_GARRISON_6_0
			GMF:SetFollowerPortrait(frame.PortraitFrame, info, false)
			frame.PortraitFrame.Empty:Hide()
			del(info)
		else
			frame.PortraitFrame.Empty:Show()
		end
		frame:Show()
	else
		frame:Hide()
	end
end
function module:AddFollowersToMap()
	for i=1,#GBFMap.Plots do
		self:AddFollowerToPlot(GBFMap.Plots[i])
	end
end
