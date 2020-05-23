--[[
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
--]]

--Settings storaged in NarcissusDB
Narci.EnableAutoUpdate = true;

local Irrelevant_Attribute_Alpha = 0.5;
local slotTable = {};
local statTable = {};
local statTable_Short = {};
local L = Narci.L;
local VignetteAlpha = 0.5;
--local FrameGap = 1/60;									-- 1 / FrameRate
local OpenViaClick = false;									--Addon was opened by clicking
local TransmogMode = false;
local Format_Digit = "%.2f";
local xmogMode = 0;											-- 0 off	1 "Texts Only" 	2 "Texts & Model"

local GetItemEnchant = NarciAPI_GetItemEnchant;				--Bridge/ItemAPIs.lua
local EnchantInfo = Narci_EnchantInfo;						--Bridge/GearBonus.lua
local FormatLargeNumbers = NarciAPI_FormatLargeNumbers;
local BreakUpLargeNumbers = BreakUpLargeNumbers;
local IsSpecialItem = NarciAPI_IsSpecialItem;
local Narci_GetPrimaryStatsName = NarciAPI_GetPrimaryStatsName;
local Narci_LetterboxAnimation = NarciAPI_LetterboxAnimation;
local SmartFontType = NarciAPI_SmartFontType;
local LanguageDetector = Narci_LanguageDetector;
local IsItemSocketable = NarciAPI_IsItemSocketable;
local GetItemExtraEffect = NarciAPI_GetItemExtraEffect;
local GetCorruptedItemAffix = NarciAPI_GetCorruptedItemAffix;
local Narci_AlertFrame_Autohide = Narci_AlertFrame_Autohide;
local C_Item = C_Item;
local C_TransmogCollection = C_TransmogCollection;
local After = C_Timer.After;

local sin = math.sin;
local cos = math.cos;
local pi = math.pi;
local max = math.max;

local UIFrameFadeIn = UIFrameFadeIn;
local UIFrameFadeOut = UIFrameFadeOut;
local FadeFrame = NarciAPI_FadeFrame;
local UIParent = _G.UIParent;

function PlaceHolderFeature_OnLoad(self)
	self.tooltipHeadline = "Button-PH";
	self.tooltipLineOpen = "Placeholder: RP addon support, player statistics";
	self.tooltipSpecial = "In development"
end

hooksecurefunc("StaticPopup_Show", function(name)
	if name == "EXPERIMENTAL_CVAR_WARNING" then
		StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING");
	end
end)

function Narci_Pref_SetVignetteStrength()
	local alpha = tonumber(NarcissusDB.VignetteStrength) or 0.5;
	VignetteAlpha = alpha;
	Narci_Vignette.VignetteLeft:SetAlpha(VignetteAlpha);
	Narci_Vignette.VignetteRight:SetAlpha(VignetteAlpha);
	Narci_Vignette.VignetteRightSmall:SetAlpha(VignetteAlpha);
	ModelVignetteRightSmall:SetAlpha(VignetteAlpha);
end

local ACL = CreateFrame("Frame", "Narci_CharacterListener");
ACL:Hide();
--[[
local TakenOutFrames = {
	[2] = AzeriteEmpoweredItemUI, 		--
	[3] = ItemSocketingFrame,			--
	[4] = ArtifactFrame,				--
}
--]]

local DefaultTooltip = GameTooltip;

local function TakeOutFromUIParent(frame, FrameStrata, bool) --take out frames from UIParent, so they will still be visible when UI is hidden
	local effectiveScale = UIParent:GetEffectiveScale();
	FrameStrata = FrameStrata or "MEDIUM";

	if frame then
		if bool == true then
			frame:SetParent(nil);
			frame:SetFrameStrata(FrameStrata);
			frame:SetScale(effectiveScale);
		elseif bool == false or bool == nil then
			frame:SetScale(1);
			frame:SetParent(UIParent);
			frame:SetFrameStrata(FrameStrata);
		end
	end
end

function Narci_ShowButtonTooltip(self)
	DefaultTooltip:Hide();
	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	if not self.tooltipHeadline then
		return
	end

	DefaultTooltip:SetText(self.tooltipHeadline);
	if self.IsOn then
		DefaultTooltip:AddLine(self.tooltipLineClose, 1, 1, 1, true);
	else
		DefaultTooltip:AddLine(self.tooltipLineOpen, 1 ,1 ,1 ,true);
	end

	if self.tooltipSpecial then
		DefaultTooltip:AddLine(" ");
		DefaultTooltip:AddLine(self.tooltipSpecial, 0.25, 0.78, 0.92, true);
	end

	DefaultTooltip:SetAlpha(0);
	NarciAPI_ShowDelayedTooltip("BOTTOM", self, "TOP", 0, 2);	
end

function Narci:HideButtonTooltip()
	DefaultTooltip:Hide();	
	--DefaultTooltip:SetFrameStrata("TOOLTIP");
end

--[[
Workflow: (RP Addon) TotalRP

	MainMenuBar
	PlayerFrame
	TargetFrame

local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(self.visualInfo.visualID);

/console test_cameraOverShoulder 

--]]
-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

--[[ LibEasing
--
-- Original Lua implementations
-- from 'EmmanuelOga'
-- https://github.com/EmmanuelOga/easing/
--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
local function linear(t, b, c, d)
	return c * t / d + b
end

local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

--------------------------------
local UIPA = CreateFrame("Frame");	--UIParentAlphaAnimation
UIPA:Hide()
UIPA.TimeSinceLastUpdate = 0;
UIPA.TotalTime = 0;
local function UIParent_AnimIn(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	self.TotalTime = self.TotalTime + elapsed;
	if self.TimeSinceLastUpdate < 0.06 then
		return;
	else
		self.TimeSinceLastUpdate = 0;
	end
	
	local alpha = linear(self.TotalTime, self.StartAlpha, self.EndAlpha - self.StartAlpha, 0.5);

	if self.TotalTime >= 0.5 then
		alpha = self.EndAlpha;
		self:Hide();
	end

	UIParent:SetAlpha(alpha);
end


UIPA:SetScript("OnShow", function(self)
	self.StartAlpha = UIParent:GetAlpha();
end);
UIPA:SetScript("OnUpdate", UIParent_AnimIn);
UIPA:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0;
	self.TotalTime = 0;
end);


--------------------------------
-----------CVar Backup----------
--------------------------------
ConsoleExec( "pitchlimit 88");
local CVar_Temp = {};
--CVar_Temp.YawSpeed = GetCVar("cameraYawMoveSpeed");							--Discarded due to new method
CVar_Temp.OverShoulder = GetCVar("test_cameraOverShoulder");
CVar_Temp.ActioncamState = tonumber(GetCVar("test_cameraDynamicPitch"));		--No CVar directly shows the current state of ActionCam. Check this CVar for the moment. 1~On  2~Off
CVar_Temp.MusicVolume = GetCVar("Sound_MusicVolume");
CVar_Temp.ZoomLevel = 2;

local ZoomFactor = {};
ZoomFactor.Time = 1.5;			--1.5 outSine
--ZoomFactor.Amplifier = 0.65; 	--0.65
ZoomFactor.EndSpeedBasic = 0.004;	--yawmovespeed 180
ZoomFactor.StartSpeedBasic = 1.0;	--yawmovespeed 180
ZoomFactor.EndSpeed = 0.005;	--yawmovespeed 180
ZoomFactor.StartSpeed = 1.0;	--yawmovespeed 180 outSine 1.4 
ZoomFactor.SpeedFactor = 180/GetCVar("cameraYawMoveSpeed");
ZoomFactor.Goal = 2.5; --2.5 with dynamic pitch

local MogMode_Offset = 0;
local ZoomValuebyRaceID = {
	--[raceID] = {ZoomValue Bust, factor1, factor2, ZoomValue for XmogMode},
	[0] = {[2] = {2.1, 0.361, -0.1654, 4},},		--Default Value

	[1] = {[2] = {2.1, 0.3283, -0.02, 4},		--1 Human √
		   [3] = {2.0, 0.38, 0.0311, 3.6}},

	[2] = {[2] = {2.4, 0.2667, -0.1233, 5.2},	--2 Orc √
		   [3] = {2.1, 0.3045, -0.0483, 5}},

	[3] = {[2] = {2.0, 0.2667, -0.0267, 3.6},	--3 Dwarf √
		   [3] = {1.8, 0.3533, -0.02, 3.6}},

	[4] = {[2] = {2.1, 0.30, -0.0404, 5},		--4 NE √
		   [3] = {2.1, 0.329, 0.025, 4.6}},

	[5] = {[2] = {2.1, 0.3537, -0.15, 4.2},		--5 UD √
		   [3] = {2.0, 0.3447, 0.03, 3.6}},

	[6] = {[2] = {4.5, 0.2027, -0.18, 5.5},		--6 Tauren Male √
		   [3] = {3.0, 0.2427, -0.1867, 5.5}},

	[7] = {[2] = {2.1, 0.329, 0.0517, 3.2},		--7 Gnome √
		   [3] = {2.1, 0.329, -0.012, 3.1}},

	[8] = {[2] = {2.1, 0.2787, 0.04, 5.2},		--8 Troll √
		   [3] = {2.1, 0.355, -0.1317, 5}},

	[9] = {[2] = {2.1, 0.2787, 0.04, 4.2},		--9 Goblin √
		   [3] = {2.1, 0.3144, -0.054, 4}},

	[10] = {[2] = {2.1, 0.361, -0.1654, 4},		--10 BloodElf Male √
		    [3] = {2.1, 0.3177, 0.0683, 3.8}},

	[11] = {[2] = {2.4, 0.248, -0.02, 5.5},		--11 Goat Male √
			[3] = {2.1, 0.3177, 0, 5}},
			
	[24] = {[2] = {2.5, 0.2233, -0.04, 5.2},		--24 Pandaren Male √
		    [3] = {2.5, 0.2433, 0.04, 5.2}},

	[27] = {[2] = {2.1, 0.3067, -0.02, 5.2},		--27 Nightborne √
		   [3] = {2.1, 0.3347, -0.0563, 4.7}},

	[28] = {[2] = {3.5, 0.2027, -0.18, 5.5},		--28 Tauren Male √
		   [3] = {2.3, 0.2293, 0.0067, 5.5}},

	[29] = {[2] = {2.1, 0.3556, -0.1038, 4.5},		--24 VE √
			[3] = {2.1, 0.3353, -0.02, 3.8}},

	[31] = {[2] = {2.3, 0.2387, -0.04, 5.5},		--32 Zandalari √
		   [3] = {2.1, 0.2733, -0.1243, 5.5}},

	[32] = {[2] = {2.3, 0.2387, 0.04, 5.2},			--32 Kul'Tiran √
		   [3] = {2.1, 0.312, -0.02, 4.7}},

	[35] = {[2] = {2.1, 0.31, -0.03, 3.1},			--35 Vulpera √
		   [3] = {2.1, 0.31, -0.03, 3.1}},	

	["Wolf"] = {[2] = {2.6, 0.2266, -0.02, 5},	--22 Worgen Wolf form √
		   	[3] = {2.1, 0.2613, -0.0133, 4.7}},
	
	["Druid"] = {[1] = {3.71, 0.2027, -0.02, 5},		--Cat
				 [5] = {4.8, 0.1707, -0.04, 5},			--Bear
				 [31] = {4.61, 0.1947, -0.02, 5},		--Moonkin
				 [4] = {4.61, 0.1307, -0.04, 5},		--Swim
				 [27] = {3.61, 0.1067, -0.02, 5},		--Fly Swift
				 [29] = {3.61, 0.1067, -0.02, 5},		--Fly
				 [3] = {4.91, 0.184, -0.02, 5},			--Travel Form
				 [36] = {4.2, 0.1707, -0.04, 5},		--Treant
				 [2] = {5.4, 0.1707, -0.04, 5},			--Tree of Life
				},

	["Mounted"] = {[1] = {8, 1.2495, -4, 5.5}},
	
	--1 	Human 32 Kultiran
	--2 	Orc
	--3 	Dwarf
	--4 	Night Elf
	--5 	Undead
	--6 	Tauren
	--7 	Gnome
	--8 	Troll
	--9 	Goblin
	--10 	Blood Elf
	--11 	Draenei
};

local _, _, playerRaceID = UnitRace("player")
local playerGenderID = UnitSex("player")
local _, _, playerClassID = UnitClass("player");
local distanceIndex = 1;
local ZoomInValue = ZoomValuebyRaceID[0][1];
local Shoulder_Factor1 = ZoomValuebyRaceID[0][2];
local Shoulder_Factor2 = ZoomValuebyRaceID[0][3];

local function ReIndexRaceID(raceID)
	if raceID == 25 or raceID == 26 then	--Pandaren A|H
		raceID = 24;
	elseif raceID == 30 then				--Lightforged
		raceID = 11;
	elseif raceID == 36 then				--Mag'har Orc
		raceID = 2;
	elseif raceID == 34 then				--DarkIron
		raceID = 3;
	elseif raceID == 37 then				--Mechagnome
		raceID = 7;
	end
	return raceID
end

playerRaceID = ReIndexRaceID(playerRaceID)

function Narci:InitializeCameraFactors()
	if NarcissusDB and not NarcissusDB.UseBustShot then
		distanceIndex = 4;
	else
		distanceIndex = 1;
	end
end

local function ModifyCameraForMounts()
	if IsMounted() then
		local index = "Mounted";
		ZoomInValue = ZoomValuebyRaceID[index][1][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[index][1][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[index][1][3];
	else
		local zoom = ZoomValuebyRaceID[playerRaceID] or ZoomValuebyRaceID[1];
		ZoomInValue = defaultZoomInValue;
		Shoulder_Factor1 = zoom[playerGenderID][2];
		Shoulder_Factor2 = zoom[playerGenderID][3];
		ZoomInValue_XmogMode = zoom[playerGenderID][4];		
	end
end

local function ModifyCameraForShapeshifter()
	if IsMounted() then
		local index = "Mounted";
		ZoomInValue = ZoomValuebyRaceID[index][1][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[index][1][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[index][1][3];
		return;
	end

	if playerRaceID ~= 22 and playerClassID ~= 11 then	--22 Worgen 11 druid
		local zoom = ZoomValuebyRaceID[playerRaceID] or ZoomValuebyRaceID[1];
		ZoomInValue = zoom[playerGenderID][distanceIndex];
		Shoulder_Factor1 = zoom[playerGenderID][2];
		Shoulder_Factor2 = zoom[playerGenderID][3];
		ZoomInValue_XmogMode = zoom[playerGenderID][4];
		return;
	end

	local raceID_shouldUse = 1;
	
	if playerClassID ~= 11 then
		--Not Druid
		local _, inAlternateForm = HasAlternateForm();
		if not inAlternateForm then						--Is curren in wolf form
			raceID_shouldUse = "Wolf";
		else
			raceID_shouldUse = 1;
		end
		ZoomInValue = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][distanceIndex];
		Shoulder_Factor1 = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][3];
		ZoomInValue_XmogMode = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][4];
		return;
	else
		--Druid
		raceID_shouldUse = "Druid";
		ACL:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		local formID = GetShapeshiftFormID();
		
		if ( not formID ) or ( not ZoomValuebyRaceID[raceID_shouldUse][formID] ) then
			if playerRaceID == 22 then
				local _, inAlternateForm = HasAlternateForm();
				if not inAlternateForm then						--Is curren in wolf form
					raceID_shouldUse = "Wolf";
				else
					raceID_shouldUse = 1;
				end
			else
				raceID_shouldUse = playerRaceID;
			end
			formID = playerGenderID;
		elseif formID == 31 then
			local _, GlyphID = GetCurrentGlyphNameForSpell(24858);		--Moonkin form with Glyph of Stars use regular configuration
			if GlyphID and GlyphID == 114301 then
				local zoom = ZoomValuebyRaceID[playerRaceID] or ZoomValuebyRaceID[1];
				ZoomInValue = zoom[playerGenderID][distanceIndex];
				Shoulder_Factor1 = zoom[playerGenderID][2];
				Shoulder_Factor2 = zoom[playerGenderID][3];
				ZoomInValue_XmogMode = zoom[playerGenderID][4];
				return;
			end
		end
		ZoomInValue = ZoomValuebyRaceID[raceID_shouldUse][formID][distanceIndex];
		Shoulder_Factor1 = ZoomValuebyRaceID[raceID_shouldUse][formID][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[raceID_shouldUse][formID][3];
		ZoomInValue_XmogMode = ZoomValuebyRaceID[raceID_shouldUse][formID][4];
	end
end


local Smooth_Shoulder = CreateFrame("Frame");
Smooth_Shoulder.t = 0;
Smooth_Shoulder.duration = 1;
Smooth_Shoulder:Hide();

local function Smooth_Shoulder_Update(self, elapsed)
	self.t = self.t + elapsed
	local Value = outSine(self.t, self.StartPoint, self.EndPoint - self.StartPoint, self.duration) --0.11 NE

	if self.t >= self.duration then
		Value = self.EndPoint;
		self:Hide();
	end

	SetCVar("test_cameraOverShoulder", Value);
end


Smooth_Shoulder:SetScript("OnShow", function(self)
	self.StartPoint = GetCVar("test_cameraOverShoulder");
end);
Smooth_Shoulder:SetScript("OnUpdate", Smooth_Shoulder_Update);
Smooth_Shoulder:SetScript("OnHide", function(self)
	self.t = 0
end);

local function Smooth_ShoulderCVar(EndPoint)
	Smooth_Shoulder:Hide();
	Smooth_Shoulder.EndPoint = EndPoint;
	Smooth_Shoulder:Show();
end

local UpdateShoulderCVar = {};
function UpdateShoulderCVar:Start(increment)
	if ( not self.pauseUpdate ) then
		self.zoom = GetCameraZoom();
		self.pauseUpdate = true;
		After(0.1, function()    -- Execute after 0.1s
			self.pauseUpdate = nil;
			Smooth_ShoulderCVar(self.zoom * Shoulder_Factor1 + Shoulder_Factor2 + MogMode_Offset);
		end)
	end
	self.zoom = self.zoom + increment;
end

hooksecurefunc("CameraZoomIn", function(increment)
	if OpenViaClick and (xmogMode ~= 1) then
		UpdateShoulderCVar:Start(-increment);
	end
end)

hooksecurefunc("CameraZoomOut", function(increment)
	if OpenViaClick  and (xmogMode ~= 1)then
		UpdateShoulderCVar:Start(increment);
	end
end)


function Narci:CameraZoomIn(EndPoint)
	local goal = EndPoint or ZoomFactor.Goal;
	ZoomFactor.Current = GetCameraZoom();
	if ZoomFactor.Current >= goal then
		CameraZoomIn(ZoomFactor.Current - goal);
	else
		CameraZoomOut(-ZoomFactor.Current + goal);
	end
end

local function SmoothYaw(self, elapsed)
	self.t = self.t + elapsed;
	local factor = ZoomFactor;
	local speed = inOutSine(self.t, factor.StartSpeed, factor.EndSpeed - factor.StartSpeed, 1.5);
	MoveViewRightStart(speed);
	
	if self.t >= 1.5 then
		if not IsPlayerMoving() then
			MoveViewRightStart(factor.EndSpeed);
		else
			MoveViewRightStop();
		end
		self.t = 0;
		self:Hide();
	end
end

local SY = CreateFrame("Frame");
SY.t = 0;
SY:Hide();
SY:SetScript("OnUpdate", SmoothYaw); --SmoothYaw
SY:SetScript("OnHide", function(self)
	self.t = 0
end);

--[[
local function SmoothZoom_Update(self, elapsed)
	self.TimeSinceLastUpdate_Zoom = self.TimeSinceLastUpdate_Zoom + elapsed
	local x = self.TimeSinceLastUpdate_Zoom;
	local t = 3;
	local EndDistance = ZoomFactor.Goal;
	local goal = 5.5;
	ZoomFactor.Current = GetCameraZoom();
	local speed = (ZoomFactor.Current- goal-1)*inOutSine(self.TimeSinceLastUpdate_Zoom, 1,  -1, t) --0.11 NE
	if speed > 0 then
		MoveViewInStart(speed);
	else
		MoveViewOutStart(-speed);
	end
	
	if self.TimeSinceLastUpdate_Zoom >= t then
		MoveViewInStop()
		self.TimeSinceLastUpdate_Zoom = 0;
		self:Hide();
	end
end

local SZ = CreateFrame("Frame","SmoothZoomContainer");
SZ.TimeSinceLastUpdate_Zoom = 0
SZ:Hide();
SZ:SetScript("OnUpdate", SmoothZoom_Update);
SZ:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate_Zoom = 0
end);
--]]

local function SmoothPitch_Update(self, elapsed)
	self.TimeSinceLastUpdate_Pitch = self.TimeSinceLastUpdate_Pitch + elapsed
	local x = self.TimeSinceLastUpdate_Pitch;
	local t = 1.65;
	local EndDistance = ZoomFactor.Goal;
	local PL = tostring(outSine(self.TimeSinceLastUpdate_Pitch, 88,  -88, t));
	ConsoleExec( "pitchlimit "..PL)
	if self.TimeSinceLastUpdate_Pitch >= t then
		--ConsoleExec( "pitchlimit 0");
		ConsoleExec( "pitchlimit 88");
		self.TimeSinceLastUpdate_Pitch = 0;
		self:Hide();
	end
end

local SP = CreateFrame("Frame","SmoothPitchContainer");
SP.TimeSinceLastUpdate_Pitch = 0;
SP:Hide();
SP:SetScript("OnShow", function(self)
	self.TimeSinceLastUpdate_Pitch = 0
end);
SP:SetScript("OnUpdate", SmoothPitch_Update);
SP:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate_Pitch = 0
end);
------------------------------

local function ExitFunc()
	OpenViaClick = false;
	xmogMode = 0;
	MogMode_Offset = 0;
	NarciPlayerModelFrame1.xmogMode = 0;
	ACL:Hide();
	MoveViewRightStop();
	if CVar_Temp.ActioncamState ~= 1 or not Narci.keepActionCam then		--Restore the acioncam state
		SetCVar("test_cameraDynamicPitch", 0);								--Note: "test_cameraDynamicPitch" may cause camera to jitter while reseting the player's view
		Smooth_ShoulderCVar(0);
		After(1, function()
			ConsoleExec( "actioncam off" );
			MoveViewRightStop();
		end)
	else
		Smooth_ShoulderCVar(CVar_Temp.OverShoulder);
		After(1, function()
			MoveViewRightStop();
		end)
	end
		
	ConsoleExec( "pitchlimit 88")
	
	FadeFrame(Narci_Vignette, 0.5, "OUT");
	Narci_Attribute.animOut:Play();
	UIParent:SetAlpha(0);
	After(0.1, function()
		UIPA.StartAlpha = 0;
		UIPA.EndAlpha = 1;
		UIPA:Show();
		SetUIVisibility(true);
		--UIFrameFadeIn(UIParent, 0.5, 0, 1);	--cause frame rate drop
		Minimap:Show();
		local CameraFollowStyle = GetCVar("cameraSmoothStyle");
		if CameraFollowStyle == "0" then		--workaround for auto-following
			SetView(5);
		else
			ResetView(2);
			ResetView(5);
			Narci:CameraZoomIn(CVar_Temp.ZoomLevel);
		end
	end)	
	Narci_Attribute:Show();

	Narci.isActive = false;
	Narci.isAFK = false;

	DefaultTooltip:Hide();
end

--[[
local function SetDate()
	local CalendarTime = C_Calendar.GetDate();
	local hour = CalendarTime.hour;
	local minute = CalendarTime.minute;
	if minute < 10 then
		minute = "0"..tostring(minute)
	end
	Narci_Vignette.Time:SetText(hour..":"..minute)
	local zoneText = GetMinimapZoneText()
	Narci_Vignette.Location:SetText(zoneText)
end
--]]

local function BeginZoomingIn()
	CVar_Temp.ZoomLevel = GetCameraZoom();
	SetCVar("test_cameraDynamicPitch", 1)
	if NarcissusDB.CameraOrbit and not IsPlayerMoving() and not IsMounted() then
		SY:Show();
		SetView(2);	
	end

	if not IsFlying("player") then
		SP:Show();
	end
	
	After(0.1, function()
		Narci:CameraZoomIn(ZoomInValue)
	end)
end

function Narci:EmergencyStop()
	print("Camera has been reset.");
	UIParent:SetAlpha(1);
	MoveViewRightStop();
	MoveViewLeftStop();
	ResetView(5);
	ConsoleExec( "pitchlimit 88");
	CVar_Temp.OverShoulder = 0;
	SetCVar("test_cameraOverShoulder", 0);
	ConsoleExec( "actioncam off" );
	Narci_ModelContainer:Hide();
	Narci_ModelSettings:Hide();
	Narci_Character:Hide();
	Narci_Attribute:Hide();
	Narci_Vignette:Hide();
	OpenViaClick = false;
	xmogMode = 0;
	MogMode_Offset = 0;
	NarciPlayerModelFrame1.xmogMode = 0;
	ACL:Hide();
end

function Narci_MinimapButton_OnPostClick(self, button, down)
	if button == "MiddleButton" then
		Narci:EmergencyStop();
	end
end

function Narci_MinimapButton_OnClick(self, button, down)
	if button == "MiddleButton" then
		return;
	elseif button == "RightButton" then
		if IsShiftKeyDown() then
			NarcissusDB.ShowMinimapButton = false;
			print("Minimap button has been hidden. You may type /Narci minimap to re-enable it.");
			self:Hide();
			Narci_MinimapButtonSwitch.Tick:Hide();
		else
			Narci_OpenGroupPhoto();
			GameTooltip:Hide();
			self:Disable();
			After(1.5, function()
				self:Enable()
			end)
		end
		return;
	end
	
	if IsShiftKeyDown() then
		DressUpFrame_Show(DressUpFrame);
		Narci_UpdateDressingRoom();
		--FadeFrame(Narci_ItemParser, 0.25, "Forced_IN");
		return;
	end

	GameTooltip:Hide();
	self:Disable();	
	Narci_Open();

	After(1.5, function()
		self:Enable();
	end)
end

function Narci_MinimapButton_OnEnter(self)
	if not NarcissusDB.ShowMinimapButton then return; end

	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOM", 0, 0);
	GameTooltip:SetText(NARCI_GRADIENT);
	
	--Normal Tooltip
	local HotKey1, HotKey2 = GetBindingKey("TOGGLECHARACTER0");
	local KeyText;
	local LeftClickText = L["Minimap Tooltip Left Click"];
	if HotKey1 and NarcissusDB.EnableDoubleTap then
		KeyText = "("..HotKey1..")";
		if HotKey2 then
			KeyText = KeyText .. "|cffffffff or |r("..HotKey2..")";
		end
		LeftClickText = LeftClickText.." |cffffffff".."/".." |r"..L["Minimap Tooltip Double Click"].." "..KeyText.."|r";
	end

	local bindAction = "CLICK Narci_MinimapButton:LeftButton";
	local keyBind = GetBindingKey(bindAction);
	if keyBind and keyBind ~= "" then
		LeftClickText = LeftClickText.." |cffffffff".."/|r "..keyBind;
	end


	GameTooltip:AddLine(LeftClickText.." "..L["Minimap Tooltip To Open"], nil, nil, nil, false);
	GameTooltip:AddLine(L["Minimap Tooltip Right Click"].." "..L["Minimap Tooltip Enter Photo Mode"], nil, nil, nil, false);
	GameTooltip:AddLine(L["Minimap Tooltip Shift Left Click"].." "..L["Toggle Dressing Room"], nil, nil, nil, true);
	GameTooltip:AddLine(L["Minimap Tooltip Shift Right Click"].." "..L["Minimap Tooltip Hide Button"], nil, nil, nil, true);
	GameTooltip:AddLine(L["Minimap Tooltip Middle Button"], nil, nil, nil, true);
	GameTooltip:AddLine(" ", nil, nil, nil, true);
	GameTooltip:AddDoubleLine(NARCI_VERSION_INFO, NARCI_DEVELOPER_INFO, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8);
	GameTooltip:AddLine("https://wow.curseforge.com/projects/narcissus", 0.5, 0.5, 0.5, false);

	self.Color:Show();
	UIFrameFadeIn(self.Color, 0.2, self.Color:GetAlpha(), 1);
	UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1);
	SetCursor("Interface/CURSOR/Item.blp");

	GameTooltip:Show();
end

-- Derivative from [[LibDBIcon-1.0]]

local minimapShapes = {
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {false, false, false, true},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
	["SIDE-LEFT"] = {false, true, false, true},
	["SIDE-RIGHT"] = {true, false, true, false},
	["SIDE-TOP"] = {false, false, true, true},
	["SIDE-BOTTOM"] = {true, true, false, false},
	["TRICORNER-TOPLEFT"] = {false, true, true, true},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local RadialOffset = 10;	--minimapbutton offset
local function Narci_MinimapButton_UpdateAngle(radian)
	local x, y, q = cos(radian), sin(radian), 1;
	if x < 0 then q = q + 1 end
	if y > 0 then q = q + 2 end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND";
	local quadTable = minimapShapes[minimapShape];
	local w = (Minimap:GetWidth() / 2) + RadialOffset	--10
	local h = (Minimap:GetHeight() / 2) + RadialOffset
	if quadTable[q] then
		x, y = x*w, y*h
	else
		local diagRadiusW = sqrt(2*(w)^2) - RadialOffset	--  -10
		local diagRadiusH = sqrt(2*(h)^2) - RadialOffset
		x = max(-w, min(x*diagRadiusW, w));
		y = max(-h, min(y*diagRadiusH, h));
	end
	Narci_MinimapButton:SetPoint("CENTER", "Minimap", "CENTER", x, y);
end

function Narci_MinimapButton_OnLoad(self)
	local radian = NarcissusDB.MinimapButton.Position;
	Narci_MinimapButton_UpdateAngle(radian);
end

function Narci_MinimapButton_DraggingFrame_OnUpdate()
	local button = Narci_MinimapButton;
	local radian;

	local mx, my = Minimap:GetCenter();
	local px, py = GetCursorPosition();
	local scale = Minimap:GetEffectiveScale();
	px, py = px / scale, py / scale;
	radian = math.atan2(py - my, px - mx);

	Narci_MinimapButton_UpdateAngle(radian);
	NarcissusDB.MinimapButton.Position = radian;
end

---------------End of derivation---------------

function Narci_ItemSlotButton_OnEnter(self, direction)
	UIFrameFadeIn(self.Highlight, 0.15, self.Highlight:GetAlpha(), 1);
	if IsAltKeyDown() and not TransmogMode then
		Narci_EquipmentFlyout_Show(self, self:GetID());
		Narci_EquipmentFlyoutFrame.Arrow:Show();
	end

	if Narci_EquipmentFlyoutFrame:IsShown() then
		Narci_Comparison_SetComparison(Narci_EquipmentFlyoutFrame.BaseItem, self);
		return;
	end

	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	if direction == "left" then
		DefaultTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 10, -20);
	else
		DefaultTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", -10, -20);
	end
	if (self.hyperlink) then
		DefaultTooltip:SetHyperlink(self.hyperlink);
		DefaultTooltip:Show();
		return;
	end
	local hasItem, hasCooldown, repairCost = DefaultTooltip:SetInventoryItem("player", self:GetID(), nil, true);
	DefaultTooltip:Show()
end

local BorderTexture = NarciAPI_GetBorderTexture();

local RunePlateTexture = {
	[0] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Black",		--Enchantable but unenchanted
	[1] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Black",
	[2] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Uncommon",
	[3] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Rare",
	[4] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Epic",
	[5] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Legendary",
	[6] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Artifact",
	[7] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Heirloom",

	["NZoth"] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-NZoth",
}

---Get Transmog Appearance---
--[[
	==sourceInfo==
	sourceType					TRANSMOG_SOURCE_1 = "Boss Drop";
	invType						TRANSMOG_SOURCE_2 = "Quest";
	visualID					TRANSMOG_SOURCE_3 = "Vendor";
	isCollected					TRANSMOG_SOURCE_4 = "World Drop";
	sourceID					TRANSMOG_SOURCE_5 = "Achievement";
	isHideVisual				TRANSMOG_SOURCE_6 = "Profession";
	itemID
	itemModID					Normal 0, Heroic 1, Mythic 3, LFG 4
	categoryID
	name
	quality	
--]]

local xmogTable = {
	{1, INVTYPE_HEAD}, {3, INVTYPE_SHOULDER}, {15, INVTYPE_CLOAK}, {5, INVTYPE_CHEST}, {4, INVTYPE_BODY}, {18, INVTYPE_TABARD}, {9, INVTYPE_WRIST},		--Left 	**slotID for TABARD is 19
	{10, INVTYPE_HAND}, {6, INVTYPE_WAIST}, {7, INVTYPE_LEGS}, {8, INVTYPE_FEET},																		--Right
	{16, INVTYPE_WEAPONMAINHAND}, {17, INVTYPE_WEAPONOFFHAND},																							--Weapon
};

local function ShareHyperLink()																	--Send transmog hyperlink to chat
	local delay = 0;																			--Keep message in order
	print(MYMOG_GRADIENT)
	for i=1, #xmogTable do
		local index =  xmogTable[i][1]
		if slotTable[index] and slotTable[index].hyperlink then			
			After(delay, function()
			SendChatMessage(xmogTable[i][2]..": "..slotTable[index].hyperlink, "GUILD")
			end)
			delay = delay + 0.1;
		end
	end
end

local function SetCoolDown(self)
	local frame = self.CooldownFrame.Cooldown;
	if frame then
		local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
		if enable and enable ~= 0 and start > 0 and duration > 0 then
			frame:SetCooldown(start, duration);
			frame:SetHideCountdownNumbers(false);
		else
			frame:Clear();
		end
	end
end

local function GetSlotVisualID(slotId)
	if slotId == 2 or (slotId > 10 and slotId < 15) then
		return -1, -1;
	end
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, _, _, _, hideVisual = C_Transmog.GetSlotVisualInfo(slotId, 0);
	if ( hideVisual ) then
		return 0, 0;
	elseif ( appliedSourceID == NO_TRANSMOG_SOURCE_ID ) then
		return baseSourceID, baseVisualID;
	else
		return appliedSourceID, appliedVisualID;
	end
end

local function SetItemSocketingFramePosition(self)		--Let ItemSocketingFrame appear on the side of the slot
	if ItemSocketingFrame then																		
		if self.GemSlot:IsShown() then
			ItemSocketingFrame:Show()
		else
			ItemSocketingFrame:Hide()
			return;
		end
		ItemSocketingFrame:ClearAllPoints();
		if self.IsRight then
			ItemSocketingFrame:SetPoint("TOPRIGHT", self, "TOPLEFT", 4, 0);
		else
			ItemSocketingFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", -4, 0);
		end
		DefaultTooltip:Hide();
	end
end

local function ShowOrHideEquiment(self)
	if not self.sourceID then return; end;
	self.IsHiddenSlot = not self.IsHiddenSlot;
	local slotID = self:GetID();
	if self.IsHiddenSlot then
		NarciPlayerModelFrame1:UndressSlot(slotID);	
	else
		NarciPlayerModelFrame1:TryOn(self.sourceID, Narci.SlotIDtoName[slotID][1]);	--weapon enchant
	end
end

function Narci_ItemSlotButton_OnClick(self, button)
	ClearCursor();
	Narci_AlertFrame_Autohide:SetAnchor(self, -24, true);
	if ( IsModifiedClick() ) then
		if IsAltKeyDown() and button == "LeftButton" then
			local action = EquipmentManager_UnequipItemInSlot(self:GetID())
			if action then
				EquipmentManager_RunAction(action)
			end
			return;
		elseif IsShiftKeyDown() and button == "LeftButton" then
			if self.hyperlink then
				SendChatMessage(self.hyperlink)
			end
			--ShareHyperLink()
		else
			PaperDollItemSlotButton_OnModifiedClick(self, button);
			
			TakeOutFromUIParent(AzeriteEmpoweredItemUI, "MEDIUM", true);
			TakeOutFromUIParent(AzeriteEssenceUI, "MEDIUM", true);
			TakeOutFromUIParent(ItemSocketingFrame, "MEDIUM", true);
			TakeOutFromUIParent(ArtifactFrame, "MEDIUM", true);
			SetItemSocketingFramePosition(self);
		end
	else
		if button == "LeftButton" then
			if TransmogMode then	--Undress an item from player model while in Xmog Mode
				ShowOrHideEquiment(self);
			else	
				Narci_EquipmentFlyout_Show(self, self:GetID());
			end
		elseif button == "RightButton" then
		--	UseInventoryItem(self:GetID());
		end
	end
end

local function IsItemEnchantable(self, slotID)
	if slotID == 11 or slotID == 12 or
		slotID == 16 or slotID == 17 then
		return true;
	elseif (slotID == 9 or slotID == 10) and false then
		return true;
	else
		return false;
	end
end

local RuneLetterTable = {
	["crit"] = "ᚲ\nᚱ\nᛁ",	  --CRI
	["haste"] = "ᚼ\nᛆ\nᛋ",	 --HAS
	["mastery"] = "ᛘ\nᛋ\nᛐ", --MST
	["versatility"] = "ᚡ\nᚽ\nᚱ",	 --VER
	["STR"] = "ᛊ\nᛏ\nᚱ",	 --STR
	["AGI"] = "ᛆ\nᚵ\nᛁ",	 --AGI
	["INT"] = "ᛁ\nᚾ\nᛐ",	 --INT
	["speed"] = "ᛋ\nᛕ\nᛑ",	 --SPF
	["armor"] = "ᛆ\nᚱ\nᛘ",	 --ARM
	["heal"] = "ᚺ\nᛁ\nᛚ", 	 --HIL
	["leech"] = "ᛒ\nᛚ\nᛑ",	 --BLD
	["spell"] = "ᛗ\nᚷ\nᚲ",	 --MGC
}

local function DisplayRuneSlot(self, slotID, itemQuality, itemLink)
	if not self.RuneSlot then
		return;
	elseif (itemQuality == 0) or (not itemLink) then
		self.RuneSlot:Hide();
		return;
	end

	if IsItemEnchantable(self, slotID) then
		self.RuneSlot:Show();
		self.RuneSlot.Background:SetTexture(RunePlateTexture[itemQuality])
	else
		self.RuneSlot:Hide();
	end

	local EnchantID = GetItemEnchant(itemLink)
	if EnchantID ~= 0 then
		self.RuneSlot.RuneLetter:Show();
		if EnchantInfo[EnchantID] then
			self.RuneSlot.RuneLetter:SetText(RuneLetterTable[ EnchantInfo[EnchantID][1] ])
			self.RuneSlot.spellID = EnchantInfo[EnchantID][3]
		end
	else
		self.RuneSlot.Background:SetTexture(RunePlateTexture[0])	--if the item is enchantable but unenchanted, set its texture to black
		self.RuneSlot.spellID = nil;
		self.RuneSlot.RuneLetter:Hide();
	end
end

function Narci_RuneButton_OnEnter(self)
	local spellID = self.spellID;
	if (not spellID) then
		return;
	end
	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	DefaultTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
	DefaultTooltip:SetSpellByID(spellID);
	DefaultTooltip:Show()
end

---------------------------------------------------
local UseDelay = true;
local function AssignDelay(id, forced)
	if UseDelay or forced then
		local time = 0;
		if id == 1 then
			time = 1;
		elseif id == 2 then
			time = 2;
		elseif id == 3 then
			time = 3;
		elseif id == 15 then	--back
			time = 4;
		elseif id == 5 then
			time = 5;
		elseif id == 9 then
			time = 6;
		elseif id == 16 then
			time = 7;
		elseif id == 17 then
			time = 8;
		elseif id == 4 then		--shirt
			time = 9;
		elseif id == 10 then
			time = 10;
		elseif id == 6 then
			time = 11;
		elseif id == 7 then
			time = 12;
		elseif id == 8 then
			time = 13;
		elseif id == 11 then
			time = 14;
		elseif id == 12 then
			time = 15;
		elseif id == 13 then
			time = 16;	
		elseif id == 14 then
			time = 17;	
		elseif id == 19 then
			time = 18;
		end
		
		time = time/20;
		return time;
	else
		return 0;
	end;
end

function Narci_ItemSlotButton_SetUseItem(self)
	local slotName = strsub(self:GetName(), 7);
	local slotId, textureName = GetInventorySlotInfo(slotName)
	self:SetID(slotId);
	self:SetAttribute("type2", "item")
	self:SetAttribute("item", slotId)
end

local function GetTraitsIcon(itemLocation)
    if not itemLocation then return; end
    local TierInfos = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation);
	if not TierInfos then return; end
	local PowerIDs, icon, _;
	local isRightSpec = true;
	local TraitIcons = {};
	local specIndex = GetSpecialization() or 1;
	local SpecID = GetSpecializationInfo(specIndex);
	local MaximumTier = 5;

    for i = 1, MaximumTier do
        if (not TierInfos[i]) or (not TierInfos[i].azeritePowerIDs) then         
            return TraitIcons;
        end
		PowerIDs = TierInfos[i].azeritePowerIDs;
        for k, PowerID in pairs(PowerIDs) do
			if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, PowerID) then
				local PowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(PowerID)
				isRightSpec = isRightSpec and C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(PowerID, SpecID);
				_, _, icon = GetSpellInfo(PowerInfo and PowerInfo.spellID);
                TraitIcons[i] = icon;
                break;
            else
                TraitIcons[i] = "";
            end
        end
	end

    return TraitIcons, isRightSpec;
end

local GetGemBorderTexture = Narci.GetGemBorderTexture;

function Narci_ItemSlotButton_OnLoad(self)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	SetCoolDown(self);
	local slotId = self:GetID();
	local slotName = strsub(self:GetName(), 7);
	local _, textureName = GetInventorySlotInfo(slotName);

	local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotId)
	--print(slotName..slotId)
	--local texture = CharacterHeadSlot.popoutButton.icon:GetTexture()
	local itemLink = "";
	local itemIcon, itemName, itemQuality, itemLevel, effectiveLvl, GemName, GemLink;
	local isAzeriteEmpoweredItem = false;		--3 Pieces	**likely to be changed in patch 8.2
	local isAzeriteItem = false;				--Heart of Azeroth
	local isCorruptedItem = false;
	local sourceitemIcon, sourceitemName, sourceitemQuality;

	if C_Item.DoesItemExist(itemLocation) and not TransmogMode then
		self.Icon:SetDesaturated(false)
		self.Name:Show();
		self.ItemLevel:Show();

		local current, maximum = GetInventoryItemDurability(slotId);
		if current and maximum then
			self.Durability = (current / maximum);
		end
		itemLink = C_Item.GetItemLink(itemLocation);
		self.hyperlink = nil;
		itemIcon = GetInventoryItemTexture("player", slotId);
		itemName = C_Item.GetItemName(itemLocation);
		self.GradientBackground:Show()
		itemQuality = C_Item.GetItemQuality(itemLocation);
		_, _, _, itemLevel = GetItemInfo(itemLink);
		effectiveLvl = C_Item.GetCurrentItemLevel(itemLocation);
		
		if slotId == 13 or slotId == 14 then
			local itemID = GetItemInfoInstant(itemLink);
			if itemID == 167555 then	--Pocket-Sized Computation Device
				GemName, GemLink = IsItemSocketable(itemLink, 2);
			else
				GemName, GemLink = IsItemSocketable(itemLink);
			end
		else
			GemName, GemLink = IsItemSocketable(itemLink);
		end

		self.GemSlot.ItemLevel = effectiveLvl;
		self.GemLink = GemLink;		--Later used in OnEnter func in NarciSocketing.lua

		if slotId == 2 then
			isAzeriteItem = C_AzeriteItem.IsAzeriteItem(itemLocation);
		elseif slotId == 1 or slotId == 3 or slotId == 5 then
			isAzeriteEmpoweredItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation);
		else
			isCorruptedItem = IsCorruptedItem(itemLink);
		end
		

	elseif C_Item.DoesItemExist(itemLocation) and TransmogMode then
		self.IsHiddenSlot = false;	--Undress an item from player model
		self.RuneSlot:Hide();		
		self.GradientBackground:Show();
		local appliedSourceID, appliedVisualID = GetSlotVisualID(slotId);
		if appliedVisualID > 0 then
			local sourceInfo = {};
			if appliedVisualID ~= self.appliedVisualID or (not (self.sourceInfo and self.sourceInfo.name)) then
				--print("Caching...#"..slotId)
				self.appliedVisualID = appliedVisualID;
				sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID);
				self.sourceInfo = sourceInfo;
				_, self.sourceID = C_TransmogCollection.GetItemInfo(sourceInfo.itemID, sourceInfo.itemModID);
				if sourceInfo.sourceType == 1 then
					self.drops = C_TransmogCollection.GetAppearanceSourceDrops(self.sourceID);
				end
			else
				sourceInfo = self.sourceInfo;
				--print("Slot #"..slotId.." is using cache.")
			end
			self.itemID = sourceInfo.itemID;																						--saved for export
			itemName = sourceInfo.name; 																							--sourceitemName
			--local _, sourceID = C_TransmogCollection.GetItemInfo(sourceInfo.itemID, sourceInfo.itemModID)							--appearanceID, sourceID
			itemQuality = sourceInfo.quality or 12;																					--sourceitemQuality
			--itemIcon = GetItemIcon(sourceInfo.itemID); 																				--sourceitemIcon
			itemIcon = C_TransmogCollection.GetSourceIcon(appliedSourceID);
			local _, _, _, hex = GetItemQualityColor(itemQuality);
			_, self.hyperlink = GetItemInfo(sourceInfo.itemID);
			self.itemModID = sourceInfo.itemModID;

			local sourceType = sourceInfo.sourceType;
			local difficulty;
			local bonusID;

			if sourceType == 1 then	--TRANSMOG_SOURCE_BOSS_DROP = 1
				local drops = self.drops	--C_TransmogCollection.GetAppearanceSourceDrops(self.sourceID)
				if drops and drops[1] then
					effectiveLvl = drops[1].encounter.." ".."|cFFFFD100"..drops[1].instance.."|r|CFFf8e694";
					self.sourcePlainText = drops[1].encounter.." "..drops[1].instance;
					
					if sourceInfo.itemModID == 0 then 
						difficulty = PLAYER_DIFFICULTY1;
						bonusID = 3561;
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."1"..":1476:|h|r";
					elseif sourceInfo.itemModID == 1 then 
						difficulty = PLAYER_DIFFICULTY2;
						bonusID = 3562;
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."2"..":1476:|h|r";
					elseif sourceInfo.itemModID == 3 then 
						difficulty = PLAYER_DIFFICULTY6;
						bonusID = 3563;
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."3"..":1476:|h|r";
					elseif sourceInfo.itemModID == 4 then
						difficulty = PLAYER_DIFFICULTY3;
						bonusID = 3564;
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."4"..":1476:|h|r";
					end

					if difficulty then
						effectiveLvl = effectiveLvl.." "..difficulty;
						self.sourcePlainText = self.sourcePlainText.." "..difficulty;
					end
				end
			else
				if sourceType == 2 then --quest
					effectiveLvl = TRANSMOG_SOURCE_2
					if sourceInfo.itemModID == 3 then 
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."6"..":1562:|h|r";
						bonusID = 5126;
					elseif sourceInfo.itemModID == 2 then 
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."5"..":1562:|h|r";
						bonusID = 5125;
					elseif sourceInfo.itemModID == 1 then 
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."4"..":1562:|h|r";
						bonusID = 5124;
					end
				elseif sourceType == 3 then --vendor
					effectiveLvl = TRANSMOG_SOURCE_3;
				elseif sourceType == 4 then --world drop
					effectiveLvl = TRANSMOG_SOURCE_4;
				elseif sourceType == 5 then --achievement
					effectiveLvl = TRANSMOG_SOURCE_5;
				elseif sourceType == 6 then	--profession
					effectiveLvl = TRANSMOG_SOURCE_6;
				else
					if itemQuality == 6 then
						effectiveLvl = ITEM_QUALITY6_DESC;
					elseif itemQuality == 5 then
						effectiveLvl = ITEM_QUALITY5_DESC;
					end
				end
				self.sourcePlainText = effectiveLvl;
			end
			if self.hyperlink then
				_, self.hyperlink = GetItemInfo(self.hyperlink);																		--original hyperlink cannot be printed (workaround)
			end

			if itemQuality == 6 then
				if slotId == 16 then
					bonusID = (sourceInfo.itemModID or 0);	--Artifact use itemModID "7V0" + modID - 1
				else
					bonusID = 0;
				end
			end
			self.bonusID = bonusID;
		else	--irrelevant slot
			self.Icon:SetDesaturated(true);
			itemQuality = 0;
			self.Name:Hide();
			self.ItemLevel:Hide();
			self.GradientBackground:Hide();
			self.bonusID = nil;
		end
	else
		self.Icon:SetDesaturated(false);
		self.itemID = nil;
		self.bonusID = nil;
		itemQuality = 0;
		itemIcon = textureName;
		itemName = "" ;
		self.GradientBackground:Hide();
		itemLevel = "";
		effectiveLvl = "";
	end

	self.itemQuality = itemQuality;
	self.IlvlCenter.ItemLevelCenter:SetText(effectiveLvl);
	local borderTex;
	local Br, Bg, Bb = 1, 1, 1;
	if itemQuality then --itemQuality sometimes return nil. This is a temporary solution
		Br, Bg, Bb = GetItemQualityColor(itemQuality);
		borderTex = BorderTexture[itemQuality];
	end

	if isAzeriteEmpoweredItem then
		borderTex = BorderTexture[8];
		if not TransmogMode then
			local icons, isRightSpec = GetTraitsIcon(itemLocation);
			local texID;
			for i = 1, #icons do
				effectiveLvl = effectiveLvl.." |T"..icons[i]..":12:12:0:0:64:64:4:60:4:60|t";
			end
		end
	end

	if isAzeriteItem then
		local HeartLevel = C_AzeriteItem.GetPowerLevel(itemLocation);
		local xp_Current, xp_Needed =  C_AzeriteItem.GetAzeriteItemXPInfo(itemLocation);
		local GetEssenceInfo = C_AzeriteEssence.GetEssenceInfo;
		local GetMilestoneEssence = C_AzeriteEssence.GetMilestoneEssence; 
		if not C_AzeriteItem.IsAzeriteItemAtMaxLevel() then
			HeartLevel = HeartLevel .. "  |CFFf8e694" .. math.floor((xp_Current/xp_Needed)*100 + 0.5) .. "%";
		end
		effectiveLvl = effectiveLvl.."  |cFFFFD100"..HeartLevel;
		
		local EssenceID = GetMilestoneEssence(115);
		if EssenceID then
			borderTex = BorderTexture.Heart;
			local EssenceInfo = GetEssenceInfo(EssenceID);
			local Colors = ITEM_QUALITY_COLORS[EssenceInfo.rank + 1];
			if Colors then	Br, Bg, Bb = Colors.r, Colors.g, Colors.b; end;
			itemName = EssenceInfo.name;
			itemIcon = EssenceInfo.icon;

			--Gem glow
			self.VFX:Show();
		end

		for i = 116, 119 do
			--116, 117, 119  3 minor slots
			if i ~= 118 then
				EssenceID = GetMilestoneEssence(i);
				if EssenceID then
					local icon = GetEssenceInfo(EssenceID).icon;
					effectiveLvl = effectiveLvl.." |T"..icon..":12:12:0:0:64:64:4:60:4:60|t";
				end
			end
		end
	else
		if slotId == 2 then
			self.VFX:Hide();
		end
	end

	if isCorruptedItem then
		borderTex = BorderTexture.NZoth;
		if not TransmogMode then
			local corruption = GetItemStats(itemLink)["ITEM_MOD_CORRUPTION"];
			if corruption then
				local Affix = GetCorruptedItemAffix(itemLink);
				if Affix then
					if self.IsRight then
						effectiveLvl = Affix.."  |cff946dd1"..corruption.."|r  "..effectiveLvl;
					else
						effectiveLvl = effectiveLvl.."  "..Affix.."  |cff946dd1"..corruption.."|r";
					end
				else
					if self.IsRight then
						effectiveLvl = "|cff946dd1"..corruption.."|r  "..effectiveLvl;
					else
						effectiveLvl = effectiveLvl.."  |cff946dd1"..corruption.."|r";
					end				
				end
			end
			itemQuality = "NZoth";
		end
	end

	if slotId == 15 then
		--Backslot
		if TransmogMode then
			self.VFX:Hide();
		else
			local itemID = GetItemInfoInstant(itemLink);
			if itemID == 169223 then 	--Ashjra'kamas, Shroud of Resolve Legendary Cloak
				local rank, corruptionResistance = NarciAPI_GetItemRank(itemLink, "ITEM_MOD_CORRUPTION_RESISTANCE");
				effectiveLvl = effectiveLvl.."  "..rank.."  |cFFFFD100"..corruptionResistance.."|r";
				borderTex = BorderTexture.BlackDragon;
				self.VFX:Show();
			else
				self.VFX:Hide();
			end
		end
	end

	if effectiveLvl == nil then
		local _, sourceName = IsSpecialItem(self.itemID);
		effectiveLvl = sourceName or " ";
	end
	
	--Enchant Frame--
	if itemQuality and not TransmogMode then
		DisplayRuneSlot(self, slotId, itemQuality, itemLink);
	end

	--Gem Slot--
	self:StopAnimating();
	if GemName ~= nil then
		--self.GemSlot:Show()
		if GemLink then
			--local _, _, _, _, _, _, _, _, _, GemIcon, _, _, itemSubClassID = GetItemInfo(GemLink);
			local id, _, _, _, GemIcon, _, itemSubClassID = GetItemInfoInstant(GemLink);
			local _, GemTexture = GetGemBorderTexture(id, itemSubClassID);
			self.GemSlot.GemBorder:SetTexture(GemTexture);
			self.GemSlot.GemIcon:SetTexture(GemIcon);
			self.GemSlot.GemIcon:Show();
			self.GemSlot.ItemID = id;
		else
			self.GemSlot.GemBorder:SetTexture("Interface/AddOns/Narcissus/Art/GemBorder/GemSlot");	--empty socket
			self.GemSlot.GemIcon:SetTexture(nil);
			self.GemSlot.GemIcon:Hide();
		end
		if self:IsVisible() then
			self.GemSlot.animIn:Play();
		else
			self.GemSlot:Show();
		end
	else
		--self.GemSlot:Hide();
		if self:IsVisible() then
			self.GemSlot.animOut:Play();
		else
			self.GemSlot:Hide();
		end
	end
	--------------------------------------------------
	--Display Texts: Transition Animation --solve frame rate drop
	if self:IsVisible() then
		self.BorderOverlay:SetTexture(borderTex);
		self.Border.anim:Play();
		if itemIcon then
			self.IconOverlay:SetTexture(itemIcon);
			self.Icon.anim:Play();
		end
		self.ItemLevel.anim1:SetScript("OnFinished", function()
			self.ItemLevel:SetText(effectiveLvl);
			self.ItemLevel.anim2:Play();
		end)
		self.Name.anim1:SetScript("OnFinished", function()
			self.Name:SetText(itemName);
			self.Name:SetTextColor(Br, Bg, Bb);
			self.Name.anim2:Play();
			After(0, function()
				self.GradientBackground:SetHeight(self.Name:GetHeight() + self.ItemLevel:GetHeight() + 18);
			end)
		end)
		self.ItemLevel.anim1:Play();
		self.Name.anim1:Play();
	else
		self.ItemLevel:SetText(effectiveLvl);
		self.Name:SetText(itemName);
		self.Name:SetTextColor(Br, Bg, Bb);
		self.Border:SetTexture(borderTex);
		if itemIcon then
			self.Icon:SetTexture(itemIcon);
		end
		self.GradientBackground:SetHeight(self.Name:GetHeight() + self.ItemLevel:GetHeight() + 18);
	end
	--self.GradientBackground:SetHeight(self.Name:GetHeight() + self.ItemLevel:GetHeight() + 18);
end

function Narci_ItemSlotButton_OnEvent(self, event, ...)
	if event == "BAG_UPDATE_COOLDOWN" then
		SetCoolDown(self);
	elseif event == "MODIFIER_STATE_CHANGED" then
		local key, state = ...;
		if ( key == "LALT" and self:IsMouseOver() ) then
			local flyout = Narci_EquipmentFlyoutFrame
			if state == 1 then
				if flyout:IsShown() and flyout.slotID == self:GetID() then
					flyout:Hide();
				else
					Narci_EquipmentFlyout_Show(self, self:GetID())
					flyout.Arrow:Show();
				end
			else
				--Narci_EquipmentFlyout_Show(self, -1)
			end
			
		end
	elseif event == "UI_ERROR_MESSAGE" then
		local _, msg = ...
		Narci_AlertFrame_Autohide:AddMessage(msg, true);
	end
end

function Narci_ItemSlotButton_OnShow(self)
	SetCoolDown(self)
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
end

function Narci_ItemSlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	UIFrameFadeOut(self.Highlight, 0.25, 1, 0);
	Narci:HideButtonTooltip();
end

function Narci_ItemSlotButton_OnHide(self)
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self.Highlight:Hide();
	self.Highlight:SetAlpha(0);
end

------------------------------------------------------------------
----The following codes are derivated from PapaerDollFrame.lua----
------------------------------------------------------------------

local function SetRegen(self)
	local powerType, powerToken = UnitPowerType("player");
	local regenRate = GetPowerRegen()
	local regenRateText = BreakUpLargeNumbers(regenRate);
	local regenRatePerSec = string.format("%.2f", regenRate).."/s";
	if powerToken == "ENERGY" then
		self.Label:SetText(STAT_ENERGY_REGEN);
		self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ENERGY_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		self.tooltip2 = STAT_ENERGY_REGEN_TOOLTIP;
	elseif powerToken == "RUNES" then
		self.Label:SetText(STAT_RUNE_REGEN);
		self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		self.tooltip2 = STAT_RUNE_REGEN_TOOLTIP;
	elseif powerToken == "FOCUS" then
		self.Label:SetText(STAT_FOCUS_REGEN);
		self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_FOCUS_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		self.tooltip2 = STAT_FOCUS_REGEN_TOOLTIP;
	elseif UnitHasMana("player") then
		regenRate = GetManaRegen();
		regenRatePerSec = tostring(math.floor(regenRate)).."/s";
		self.Label:SetText(MANA_REGEN);
	else
		local _, class = UnitClass("player");
		if (class ~= "DEATHKNIGHT") then
			self.Label:SetText(MANA_REGEN_COMBAT);		--MANA_REGEN_ABBR
			self.Value:SetText("N/A");
			self.Label:SetAlpha(Irrelevant_Attribute_Alpha);
			self.Value:SetAlpha(Irrelevant_Attribute_Alpha);
			return;
		end
		local _, regenRate = GetRuneCooldown(1);
		local regenRateText = (format(STAT_RUNE_REGEN_FORMAT, regenRate));
		self.Label:SetText(STAT_RUNE_REGEN);
		self.Value:SetText(regenRateText);
		self.Label:SetAlpha(1);
		self.Value:SetAlpha(1);
		return;
	end
	
	self.Value:SetText(regenRatePerSec)
end

local function GetEffectiveCrit()
	local rating;
	local spellCrit, rangedCrit, meleeCrit;
	local critChance;
	
	-- Start at 2 to skip physical damage
	local holySchool = 2;
	local minCrit = GetSpellCritChance(holySchool);
	local spellCritTable = {};
	spellCritTable[holySchool] = minCrit;
	local spellCrit;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
		spellCritTable[i] = spellCrit;
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance();
	meleeCrit = GetCritChance();

	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit;
		rating = CR_CRIT_SPELL;
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit;
		rating = CR_CRIT_RANGED;
	else
		critChance = meleeCrit;
		rating = CR_CRIT_MELEE;
	end

	return critChance, rating
end

Narci.GetEffectiveCrit = GetEffectiveCrit;

local function SetCrit(self)
	if not Narci.EnableAutoUpdate then return end;
	local critChance, rating = GetEffectiveCrit();

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.2F%%", critChance)..FONT_COLOR_CODE_CLOSE;
	local extraCritChance = GetCombatRatingBonus(rating);
	local extraCritRating = GetCombatRating(rating);
	self.tooltip4 = nil;
	if (GetCritChanceProvidesParryEffect()) then
		self.tooltip2 = format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating));
	else
		if extraCritChance == 0 then
			self.tooltip2 = format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance);
		else
			self.tooltip2 = NARCI_CRIT_TOOLTIP;
			self.tooltip4 = {format(NARCI_CRIT_TOOLTIP_FORMAT, BreakUpLargeNumbers(extraCritRating), extraCritChance), math.floor( (extraCritRating / extraCritChance) * 100 + 0.5) / 100 .. " [+1%]"}
		end
	end

	local PercentageText = string.format(Format_Digit, critChance).."%"
	self.Label:SetText(NARCI_CRITICAL_STRIKE);		--COMBAT_RATING_NAME10
	self.Value:SetText(PercentageText);
	self.ValueRating:SetText(extraCritRating);
end

local function SetHaste(self)
	if not Narci.EnableAutoUpdate then return end;
	local unit = "player";
	local haste = GetHaste();
	local rating = CR_HASTE_MELEE;
	local hasteFormatString;

	if (haste < 0 and not GetPVPGearStatRules()) then
		hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
	else
		hasteFormatString = "%s";
	end

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE) .. " " .. format(hasteFormatString, format("%.2F%%", haste)) .. FONT_COLOR_CODE_CLOSE;

	local _, class = UnitClass(unit);
	self.tooltip2 = _G["STAT_HASTE_"..class.."_TOOLTIP"];
	if (not self.tooltip2) then
		self.tooltip2 = STAT_HASTE_TOOLTIP;
	end

	local Rating = GetCombatRating(rating);
	local RatingBonus = GetCombatRatingBonus(rating);
	if RatingBonus == 0 then
		self.tooltip2 = self.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(Rating), RatingBonus);
		self.tooltip4 = nil;
	else
		self.tooltip4 = {format(NARCI_HASTE_TOOLTIP_FORMAT, BreakUpLargeNumbers(Rating), RatingBonus), math.floor( (Rating / RatingBonus) * 100 + 0.5) / 100 .. " [+1%]"};
	end

	local PercentageText = string.format(Format_Digit, haste).."%"
	self.Label:SetText(STAT_HASTE);
	self.Value:SetText(PercentageText);
	self.ValueRating:SetText(GetCombatRating(rating));
end

local function MasteryFrame_OnEnter(self)
	SetRadarVertexSize(self, 15);

	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");

	local _, class = UnitClass("player");
	local mastery, bonusCoeff = GetMasteryEffect();
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff;

	local title = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MASTERY).." "..format("%.2F%%", mastery)..FONT_COLOR_CODE_CLOSE;
	if (masteryBonus > 0) then
		title = title..HIGHLIGHT_FONT_COLOR_CODE.." ("..format("%.2F%%", mastery-masteryBonus)..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..format("%.2F%%", masteryBonus)..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
	end
	DefaultTooltip:SetText(title);

	local masteryRating = GetCombatRating(CR_MASTERY);
	local primaryTalentTree = GetSpecialization();
	if (primaryTalentTree) then
		local masterySpell, masterySpell2 = GetSpecializationMasterySpells(primaryTalentTree);
		if (masterySpell) then
			DefaultTooltip:AddSpellByID(masterySpell);
		end
		if (masterySpell2) then
			DefaultTooltip:AddLine(" ");
			DefaultTooltip:AddSpellByID(masterySpell2);
		end
		DefaultTooltip:AddLine(" ");
		local tooltip = format(STAT_MASTERY_TOOLTIP, BreakUpLargeNumbers(masteryRating), masteryBonus);
		if masteryBonus ~= 0 then
			DefaultTooltip:AddDoubleLine(tooltip ,math.floor( (masteryRating / masteryBonus) * 100 + 0.5) / 100 .. " [+1%]", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		else
			DefaultTooltip:AddLine(tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end
	else
		DefaultTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, BreakUpLargeNumbers(masteryRating), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		DefaultTooltip:AddLine(" ");
		DefaultTooltip:AddLine(STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
	end
	DefaultTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0)
	DefaultTooltip:Show();
end

local function SetMastery(self)
	if not Narci.EnableAutoUpdate then return end;
	self:SetScript("OnEnter", MasteryFrame_OnEnter);

	local mastery = GetMasteryEffect();
	local PercentageText = string.format(Format_Digit, mastery).."%"
	self.Label:SetText(STAT_MASTERY);

	--[[
	if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
		self.numericValue = 0;
		self.Value:SetText("N/A");
		self.ValueRating:SetText("0");
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha)
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha)
		self.ValueRating:SetAlpha(Irrelevant_Attribute_Alpha)
		return;
	end
	--]]

	self.Value:SetText(PercentageText);
	self.ValueRating:SetText(GetCombatRating(CR_MASTERY));

	self.Label:SetAlpha(1)
	self.Value:SetAlpha(1)
	self.ValueRating:SetAlpha(1)
end

local function SetVersatility(self)
	if not Narci.EnableAutoUpdate then return end;
	local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(VERSATILITY_TOOLTIP_FORMAT, STAT_VERSATILITY, versatilityDamageBonus, versatilityDamageTakenReduction) .. FONT_COLOR_CODE_CLOSE;

	if versatilityDamageBonus == 0 then
		self.tooltip2 = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);
		self.tooltip4 = nil;
	else
		self.tooltip2 = format(NARCI_VERSATILITY_TOOLTIP_FORMAT_1, versatilityDamageBonus, versatilityDamageTakenReduction);
		self.tooltip4 = {format(NARCI_VERSATILITY_TOOLTIP_FORMAT_2, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction) , math.floor( (versatility / versatilityDamageBonus) * 100 + 0.5) / 100 .. " [+1%/0.5%]"};
	end
	
	local PercentageText = string.format(Format_Digit, versatilityDamageBonus).."%"
	self.Label:SetText(STAT_VERSATILITY);
	self.Value:SetText(PercentageText);
	self.ValueRating:SetText(GetCombatRating(CR_VERSATILITY_DAMAGE_DONE));
end

local function SetLeech(self)
	local lifesteal = GetLifesteal();

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. format("%.2F%%", lifesteal) .. FONT_COLOR_CODE_CLOSE;

	self.tooltip2 = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL));

	--self:Show();

	local PercentageText = string.format(Format_Digit, lifesteal).."%"
	self.Label:SetText(STAT_LIFESTEAL);
	self.Value:SetText(PercentageText);
	if lifesteal == 0 then
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha)
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha)
		self.animIn.A2:SetToAlpha(1);
	else
		self.Label:SetAlpha(1)
		self.Value:SetAlpha(1)
		self.animIn.A2:SetToAlpha(1);
	end
end

local function SetAvoidance(self)
	local avoidance = GetAvoidance();

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. format("%.2F%%", avoidance) .. FONT_COLOR_CODE_CLOSE;

	self.tooltip2 = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)), GetCombatRatingBonus(CR_AVOIDANCE));

	--self:Show();

	local PercentageText = string.format(Format_Digit, avoidance).."%"
	self.Label:SetText(STAT_AVOIDANCE);
	self.Value:SetText(PercentageText);
	
	if avoidance == 0 then
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha)
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha)
		self.animIn.A2:SetToAlpha(1);
	else
		self.Label:SetAlpha(1)
		self.Value:SetAlpha(1)
		self:SetAlpha(1)
		self.animIn.A2:SetToAlpha(1);
	end
end

local function SetSpeed(self)
	local speed = GetSpeed();

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED) .. " " .. format("%.2F%%", speed) .. FONT_COLOR_CODE_CLOSE;

	self.tooltip2 = format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED));

	--self:Show();

	local PercentageText = string.format(Format_Digit, speed).."%"
	self.Label:SetText(STAT_SPEED);
	self.Value:SetText(PercentageText);

	if speed == 0 then
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha)
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha)
		self.animIn.A2:SetToAlpha(1);
	else
		self.Label:SetAlpha(1)
		self.Value:SetAlpha(1)
		self.animIn.A2:SetToAlpha(1);
	end
end

local function AAAMovementSpeed_OnUpdate(self, elapsedTime)
	local unit = self.unit;
	local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(unit);
	runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100;
	flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100;
	swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100;

	-- Determine whether to display running, flying, or swimming speed
	local speed = runSpeed;
	local swimming = IsSwimming(unit);
	if (swimming) then
		speed = swimSpeed;
	elseif (IsFlying(unit)) then
		speed = flightSpeed;
	end

	-- Hack so that your speed doesn't appear to change when jumping out of the water
	if (IsFalling(unit)) then
		if (self.wasSwimming) then
			speed = swimSpeed;
		end
	else
		self.wasSwimming = swimming;
	end

	local valueText = format("%d%%", speed+0.5);

	self.Label:SetText(L["Movement Speed"]);		--STAT_MOVEMENT_SPEED
	self.Value:SetText(valueText);

	self.speed = speed;
	self.runSpeed = runSpeed;
	self.flightSpeed = flightSpeed;
	self.swimSpeed = swimSpeed;
end

local function MovementSpeed_OnEnter(self)
	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	DefaultTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MOVEMENT_SPEED).." "..format("%d%%", self.speed+0.5)..FONT_COLOR_CODE_CLOSE);

	DefaultTooltip:AddLine(format(STAT_MOVEMENT_GROUND_TOOLTIP, self.runSpeed+0.5));
	if (self.unit ~= "pet") then
		DefaultTooltip:AddLine(format(STAT_MOVEMENT_FLIGHT_TOOLTIP, self.flightSpeed+0.5));
	end
	DefaultTooltip:AddLine(format(STAT_MOVEMENT_SWIM_TOOLTIP, self.swimSpeed+0.5));
	DefaultTooltip:AddLine(" ");
	DefaultTooltip:AddLine(format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED)));

	DefaultTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0)
	DefaultTooltip:Show();

	self.UpdateTooltip = MovementSpeed_OnEnter;
end

local function SetMovementSpeed(self)
	local unit = "player"

	self.wasSwimming = nil;
	self.unit = unit;
	--self:Show();
	AAAMovementSpeed_OnUpdate(self);
	self:SetScript("OnEnter", MovementSpeed_OnEnter);
	--self.onEnterFunc = MovementSpeed_OnEnter;

	self:SetScript("OnUpdate", AAAMovementSpeed_OnUpdate);
end

local function SetStatTooltipText(self)
	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	DefaultTooltip:SetText(self.tooltip);
	if ( self.tooltip2 ) then
		DefaultTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	if ( self.tooltip3 ) then
		DefaultTooltip:AddLine(" ");
		DefaultTooltip:AddLine(self.tooltip3, RAID_CLASS_COLORS["MAGE"].r, RAID_CLASS_COLORS["MAGE"].g, RAID_CLASS_COLORS["MAGE"].b, true);
	end
	if ( self.tooltip4 ) then
		DefaultTooltip:AddLine(" ");
		DefaultTooltip:AddDoubleLine(self.tooltip4[1], self.tooltip4[2], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);		
	end
end

function Narci_ShowStatTooltip(self, direction)
	if ( not self.tooltip ) then
		return;
	end
	SetStatTooltipText(self)
	if (not direction) then
		DefaultTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0)
	elseif direction=="RIGHT" then
		DefaultTooltip:SetPoint("LEFT",self,"RIGHT", 0, 0)
	elseif direction=="TOP" then
		DefaultTooltip:SetPoint("BOTTOM",self,"TOP", 0, -4)
	elseif direction=="CURSOR" then
		DefaultTooltip:SetOwner(self, "ANCHOR_CURSOR");
	end

	DefaultTooltip:Show();
end

function Narci_ShowStatTooltipDelayed(self)
	if ( not self.tooltip ) then
		return;
	end
	SetStatTooltipText(self);
	DefaultTooltip:SetAlpha(0);
	NarciAPI_ShowDelayedTooltip("BOTTOM",self,"TOP", 0, -4);
end



local powerTypeList = {
	--localized Name
	[0] 	= MANA,						--mana
	[1] 	= RAGE,						--rage
	[2] 	= FOCUS,					--focus
	[3] 	= ENERGY,					--energy
	[4] 	= TUTORIAL_TITLE61_ROGUE,	--combo points
	[5] 	= RUNES,					--runes
	[6] 	= RUNIC_POWER,				--runic power
	[7] 	= SOUL_SHARDS_POWER,		--soul shards
	[8] 	= ECLIPSE,					--eclipse
	[9] 	= HOLY_POWER,				--holy power
	[11]	= MAELSTROM,				--Maelstrom
	[12]	= CHI,						--Chi
	[13]	= INSANITY,					--Shadow Priests
	[16]	= ARCANE_CHARGES,			--
	[17]	= FURY,						--Havoc 
	[18]	= PAIN,						--Vengeance 		

};

--[[local RegenList = {
	[2] = STAT_FOCUS_REGEN,
	[3] = STAT_ENERGY_REGEN,
	[5] = STAT_RUNE_REGEN,
}--]]

local function trim(s)
	if s ~= nil then
		return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

local function PlayIlvlInfoAnimation()
	local frame = Narci_IlvlInfoFrame;
	local frame1 = frame.IlvlButtonLeft;
	local frame2 = frame.IlvlButtonRight;

	if NarcissusDB.DetailedIlvlInfo and not frame1:IsVisible() and not TransmogMode then
		frame1.AnimFrame:Show();
		frame2.AnimFrame:Show();
		frame1:Show();
		frame2:Show();
	end
end

local function ShowDetailedIlvlInfo(self)
	if NarcissusDB.DetailedIlvlInfo then
		FadeFrame(Narci_DetailedStatFrame, 0, "IN");
		FadeFrame(Narci_RadarChartFrame, 0, "IN");
		FadeFrame(Narci_ConciseStatFrame, 0, "OUT");
	else
		FadeFrame(Narci_DetailedStatFrame, 0, "OUT");
		FadeFrame(Narci_RadarChartFrame, 0, "OUT");
		FadeFrame(Narci_ConciseStatFrame, 0, "IN");
	end
end

local InventorySlotIdTable = {
	1, 		--Head
	2, 		--Neck
	3, 		--Shoulder
	--,4 	--Shirt
	5,		--Chest
	6, 		--Waist
	7, 		--Legs
	8, 		--Feet
	9, 		--Wrist
	10, 	--Hand
	11, 	--Finger1
	12,		--Finger2
	13,		--Trinket1
	14,		--Trinket2
	15,		--Back
	16,		--MainHand
	17, 	--OffHand
	--18，	--INVSLOT_RANGED
}
--/dump GetItemStats(GetInventoryItemLink("player", 8))
--/script DEFAULT_CHAT_FRAME:AddMessage("\124cff0070dd\124Hitem:152783::::::::120::::1:1672:\124h[Mac'Aree Focusing Amethyst]\124h\124r");
--/script DEFAULT_CHAT_FRAME:AddMessage("\124cff0070dd\124Hitem:152783::::::::120::::1:1657:\124h[Mac'Aree Focusing Amethyst]\124h\124r");
--/script DEFAULT_CHAT_FRAME:AddMessage("\124cff0070dd\124Hitem:158362::::::::120::::2:1557:4778:\124h[Lord Waycrest's Signet]\124h\124r");
--[[				 Stats sum						ilvl							ilvl+ from Gem
	Ring		1.7626*ilvl - 246.88		(sum + 246.88) / 1.7626				40  / 1.7626 = 22.6937
--]]

function CalculateWA()
	local k1, k2, k3, k4, k5 = 1, 1, 1 ,1 ,1 ;
	local Num_Equip = 0;
	local Gears = {};
	local Sum_weight = 0;
	local Sum_WI = 0;

	for i=1, #InventorySlotIdTable do
		local slotID = InventorySlotIdTable[i]
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotId)
		local itemLink = GetInventoryItemLink("player", slotID)
		--local itemLink = C_Item.GetItemLink(itemLocation)
		Gears[i] = {};

		if itemLink then
			Num_Equip = Num_Equip + 1;
			local ilvl = GetDetailedItemLevelInfo(itemLink)
			local stats = GetItemStats(itemLink)
			local prim = stats["ITEM_MOD_AGILITY_SHORT"] or stats["ITEM_MOD_STRENGTH_SHORT"] or stats["ITEM_MOD_INTELLECT_SHORT"] or 0;
			local crit = stats["ITEM_MOD_CRIT_RATING_SHORT"] or 0;
			local haste = stats["ITEM_MOD_HASTE_RATING_SHORT"] or 0;
			local mastery = stats["ITEM_MOD_MASTERY_RATING_SHORT"] or 0;
			local versa = stats["ITEM_MOD_VERSATILITY"] or 0;
			--print(ilvl.." "..prim.." "..crit.." "..haste.." "..mastery.." "..versa)

			Gears[i].ilvl = ilvl;
			local weight = k1 * prim + k2 * crit + k3 * haste + k4 * mastery + k5 * versa;
			--Gears[i].weight =
			Gears[i].WI = ilvl * weight

			Sum_WI = Sum_WI + Gears[i].WI
			Sum_weight = Sum_weight + weight
			--Gears[i].prim = prim;
			--Gears[i].crit = crit;
			--Gears[i].haste = haste;
			--Gears[i].mastery = mastery;
			--Gears[i].versa = versa;
		end
	end

	local WAvg = Sum_WI/Sum_weight
	--print("Num_Equip = "..WAvg)
	for i=1, #InventorySlotIdTable do
		if Gears[i] and Gears[i].ilvl then
		--print("Item "..i.." WA: "..(Gears[i].WI/Sum_weight*Num_Equip))
		end
	end

	return WAvg;
end

local SmoothFluid = NarciAPI_SmoothFluid;
local GetEyeballColor = NarciAPI_GetEyeballColor;

local function SetIlvlBackground(level)
	level = level or UnitLevel("player");
	local frame = Narci_IlvlInfoFrame.IlvlButtonCenter;
	local frame2 = Narci_IlvlInfoFrame.IlvlButtonLeft;
	local frame3 = Narci_IlvlInfoFrame.IlvlButtonRight;
	local avgItemLevel, avgItemLevelEquipped, _ = GetAverageItemLevel();
	local floor = math.floor;
	local avgIvl = floor(avgItemLevel);
	local maxIlvl = floor(avgItemLevel*100 + 0.5) / 100
	local EAvg = floor(avgItemLevelEquipped*100 + 0.5) / 100;
	frame2.PlayerItemLvlEquipped:SetText(EAvg);
	local percentage	--Set the bar(Fluid) height in the Tube
	local height;
	local centerText, centerHeader;
	local rightText, rightHeader;
	--Corruption System
	local corruption = GetCorruption();
	local corruptionResistance = GetCorruptionResistance();
	local totalCorruption = max(corruption - corruptionResistance, 0);

	if corruption > 0 then
		frame3.Number:SetText(maxIlvl);
		frame3.Header:SetText("MAX");
		frame3.tooltipHeadline = format(ITEM_LEVEL, avgItemLevel);
		frame3.tooltipLineOpen = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP;
		return;
	else
		frame.isCorrupted = false;
		frame.Eyelid:Hide();
		if level <= 60 then
			frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Grey")
			frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[0].r, ITEM_QUALITY_COLORS[0].g, ITEM_QUALITY_COLORS[0].b);
		elseif level <= 80 then
			frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Green")
			frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[2].r, ITEM_QUALITY_COLORS[2].g, ITEM_QUALITY_COLORS[2].b);
		elseif level <= 100 then
			frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Blue")
			frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[3].r, ITEM_QUALITY_COLORS[3].g, ITEM_QUALITY_COLORS[3].b);
		elseif level > 100 then
			if avgItemLevel < 385 then
				frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Blue")
				frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[3].r, ITEM_QUALITY_COLORS[3].g, ITEM_QUALITY_COLORS[3].b);
			else
				frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Purple")
				frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[4].r, ITEM_QUALITY_COLORS[4].g, ITEM_QUALITY_COLORS[4].b);
			end
		end
		frame.IvlBackground:SetTexCoord(0, 1, 0, 1);
		percentage = math.ceil( (avgItemLevel - avgIvl)*100 );
		centerText = avgIvl;
		centerHeader = "MAX";
	end
	
	if percentage < 10 then
		height = 0;
	elseif percentage > 90 then
		height = 84;
	else
		height = 84*percentage/100;
	end
	
	frame.Fluid:SetHeight(height);

	if Narci.EnableAutoUpdate then
		frame.PlayerItemLvl:SetText(centerText);
		frame.Header:SetText(centerHeader);
	end
	frame.tooltip = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..maxIlvl;
	frame.tooltip2 = HIGHLIGHT_FONT_COLOR_CODE .. STAT_AVERAGE_ITEM_LEVEL_TOOLTIP .. FONT_COLOR_CODE_CLOSE;
	frame.tooltip3 = L["Toggle Equipment Set Manager"];
end

Narci.Corruption = -1;
Narci.corruptionResistance = -1;
local function SetCorruptionBackground()
	local frame = Narci_IlvlInfoFrame.IlvlButtonCenter;
	local frame3 = Narci_IlvlInfoFrame.IlvlButtonRight;
	local percentage	--Set the bar(Fluid) height in the Tube
	local height;
	local centerText, centerHeader;
	--Corruption System
	local corruption = GetCorruption();
	local corruptionResistance = GetCorruptionResistance();
	if corruption ~= Narci.corruption or corruptionResistance ~= Narci.corruptionResistance then
		Narci.corruption = corruption;
		Narci.corruptionResistance = corruptionResistance;
	else
		return;
	end
	--print("Update Corruption")
	local totalCorruption = max(corruption - corruptionResistance, 0);

	local newLevel, texID;
	if corruption > 0 then
		local cap, bottom, corruptionLevel;
		if totalCorruption < 1 then
			cap = 1;
			corruptionLevel = 0;
			texID = 6;
		elseif totalCorruption < 20 then
			cap = 20;
			bottom = 1;
			corruptionLevel = 1;
			texID = 1;
		elseif totalCorruption < 40 then
			cap = 40;
			bottom = 20;
			corruptionLevel = 2;
			texID = 2;
		elseif totalCorruption < 60 then
			cap = 60;
			bottom = 40;
			corruptionLevel = 3;
			texID = 3;
		elseif totalCorruption < 80 then
			cap = 80;
			bottom = 60;
			corruptionLevel = 4;
			texID = 4;
		else
			cap = 80;
			bottom = 80;
			corruptionLevel = 5;	
			texID = 5;	
		end

		if corruptionLevel == 0 then
			percentage = math.ceil(100 * (corruption / corruptionResistance));
		elseif corruptionLevel < 5 then
			percentage = math.ceil(100 * (20 - cap + totalCorruption) / 20);
		else
			percentage = 100;
		end

		local eyeballTex, hexTextColor, fR, fG, fB = GetEyeballColor();
		frame.Eyelid.Blink.texID = texID;

		if not frame.isCorrupted then
			frame.IvlBackground:SetTexCoord(0.125*(texID - 1), 0.125*texID, 0, 1);
			frame.IvlBackground:SetTexture(eyeballTex);
			frame.isCorrupted = true;
		end
		
		if corruptionLevel == 0 then
			centerHeader = corruption.." ".. "|cffa59bb5" ..corruptionResistance;
			fR, fG, fB = 0.73, 0.68, 0.8;
		elseif corruptionLevel < 5 then
			if totalCorruption < 20 then
				bottom = "  1 ";
			end
			centerHeader = "|cffa59bb5".. bottom.." ".. hexTextColor .. totalCorruption .. " |cffa59bb5" .. cap;
		else
			centerHeader = "|cffa59bb5".. bottom.." ".. hexTextColor .. totalCorruption .. "    ";
		end
		
		centerText = " ";
		newLevel = corruptionLevel;

		
		frame.Eyelid:Show();
		--Fluid Animation
		if percentage < 10 then
			height = 0;
		elseif percentage > 90 then
			height = 84;
		else
			height = 84*percentage/100;
		end

		local delay = SmoothFluid(frame.Fluid, height, newLevel, fR, fG, fB);
		
		if delay then
			delay = min(delay, 0.85)
			After(delay, function()
				frame.Eyelid.Blink:Play();
				--[[
				if corruptionLevel ~= 0 then
					frame.CorruptionEffect.Bling:Play();
				end
				--]]
			end)
		end
	else
		SetIlvlBackground();
		frame3.Number:SetText(0);
		frame3.Header:SetText("TC");
		frame3.tooltipHeadline = TOTAL_CORRUPTION_TOOLTIP_LINE.." "..0;
		frame3.tooltipLineOpen = L["No Corrupted Item"];
		return;
	end


	if Narci.EnableAutoUpdate then
		frame.PlayerItemLvl:SetText(centerText);
		frame.Header:SetText(centerHeader);
	else
		frame3.Header:SetText("TC");
		frame3.Number:SetText(totalCorruption);
		frame3.tooltipHeadline = TOTAL_CORRUPTION_TOOLTIP_LINE.." "..totalCorruption;
		frame3.tooltipLineOpen = format(L["Total Corruption Format"], totalCorruption);
	end
end

function Narci_SolidHexagonButton_OnEnter(self)
	UIFrameFadeIn(self.Highlight, 0.2, self.Highlight:GetAlpha(), 1);

	--EquipmentSetManager
	if self.isSetManagerOpen then return end

	--corruption or not
	if self.isCorrupted then
		NarciAPI_RunDelayedFunction(self, 0.2, function()
			local frame = Narci_CorruptionTooltip;
			if not frame:IsVisible() and not self.isSetManagerOpen and not IsMouseButtonDown() then
				frame:ClearAllPoints();
				frame.ModelScene.Background:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 1, 1, 1, 1);
				frame:SetScale(self:GetScale());
				frame:SetParent(self);
				frame:SetPoint("TOP", self, "BOTTOM", 0, -12);
				frame:SetHitRectInsets(-32, -32, -32, -32);
				FadeFrame(frame, 0.25, "IN");
			end
		end);
	else
		Narci_ShowStatTooltipDelayed(self);
	end
end
function Narci:SetItemLevel()
	--forced fresh
	Narci_IlvlInfoFrame.IlvlButtonCenter.isCorrupted = false;
	Narci.corruption = -1;
	SetCorruptionBackground();
end

local function CharacterInfoFrame_OnLoad(NewLevel)
	local TitleID = GetCurrentTitle();
	local TitleName = GetTitleName(TitleID);
	if TitleName ~= nil then
		TitleName = strtrim(TitleName); --delete the space in Title
	end
	local level = NewLevel or UnitLevel("player");

	local _, currentSpecName;
	local currentSpec = GetSpecialization();
	if currentSpec then
	   _, currentSpecName = GetSpecializationInfo(currentSpec);
	else
		currentSpecName = " ";
	end

	local className, englishClass, _ = UnitClass("player");
	local _, _, _, rgbHex = GetClassColor(englishClass);
	local frame = PlayerInfoFrame;
	if currentSpecName ~= nil then
		if TitleName ~= nil then
			frame.Miscellaneous:SetText(TitleName.."  |  ".."|cFFFFD100"..level.."|r  ".." ".."|c"..rgbHex..currentSpecName.." "..className.."|r");
		else
			frame.Miscellaneous:SetText("Level".." |cFFFFD100"..level.."|r  ".."|c"..rgbHex..currentSpecName.." "..className.."|r");
		end
	end

	SetIlvlBackground(level);
end

local function RefreshSlot(SlotId)
	if slotTable[SlotId] then
		After(AssignDelay(SlotId), function()
			Narci_ItemSlotButton_OnLoad(slotTable[SlotId]);
		end)
	end
end

local function RefreshAllSlot()
	for i=1, #slotTable do
		RefreshSlot(i);
	end
end

local function PlaySlotAnimOut()
	if not InCombatLockdown() then
		for i=1, #slotTable do
			if slotTable[i] then
				slotTable[i].animOut:Play()
			end
		end
	end
	Narci_Character.animOut:Play();
end

local function CacheSourceInfo(slotId)
	local appliedSourceID, appliedVisualID 
	if slotId then
		After(AssignDelay(slotId, true), function()
			appliedSourceID, appliedVisualID = GetSlotVisualID(slotId);
			if appliedVisualID > 0 then
				local sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID);
				local sources = C_TransmogCollection.GetAppearanceSources(appliedVisualID);
			
				if slotTable[slotId] then
					local slot = slotTable[slotId];
					slot.sourceInfo = sourceInfo;
					slot.appliedVisualID = appliedVisualID;
					local _, sourceID = C_TransmogCollection.GetItemInfo(sourceInfo.itemID, sourceInfo.itemModID);
					if sourceInfo and sourceInfo.sourceType == 1 then
						slot.drops = C_TransmogCollection.GetAppearanceSourceDrops(sourceID);
					end
				end
				--print("Caching Slot... #"..slotId)
			end
		end)
	else
		for i=1, #slotTable do
			if slotTable[i] then
				local ID = slotTable[i]:GetID();
				appliedSourceID, appliedVisualID = GetSlotVisualID(ID);
				if appliedVisualID > 0 then
					local sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID);
					local sources = C_TransmogCollection.GetAppearanceSources(appliedVisualID);
				end
			end
		end
	end
end

--[[
local SlotLabelStyle = true;

function SetSlotLabelStyle(self)

	if SlotLabelStyle then
		for i=1, #slotTable do
			if slotTable[i] then
				slotTable[i].GradientBackground:Hide();
				slotTable[i].GradientBackground:SetAlpha(0);
				slotTable[i].Name:Hide();
				local text = slotTable[i].ItemLevel:GetText();
				slotTable[i].ItemLevel:Hide();
				slotTable[i].IlvlCenter.ItemLevelCenter:SetText(text);
				slotTable[i].IlvlCenter:Show();
			end
		end
	else
		for i=1, #slotTable do
			if slotTable[i] then
				slotTable[i].GradientBackground:Show();
				slotTable[i].GradientBackground:SetAlpha(1);
				slotTable[i].Name:Show();
				slotTable[i].ItemLevel:Show();
				slotTable[i].IlvlCenter:Hide();
			end
		end
	end
	if SlotLabelStyle then
		self.icon:SetTexCoord(0, 0.5, 0, 1)
	else
		self.icon:SetTexCoord(0.5, 1, 0, 1)
	end
	SlotLabelStyle = not SlotLabelStyle;
end
--]]

local function GetPrimaryStatsNum()
	local _, Strength, _, _ = UnitStat("player", 1);
	local _, Agility, _, _ = UnitStat("player", 2);
	local _, Intellect, _, _ = UnitStat("player", 4);
	if Strength > Agility and Strength > Intellect then
		return Strength;
	elseif	Agility > Strength and Agility > Intellect then
		return Agility;
	elseif	Intellect > Agility and	Intellect >	Strength then
		return Intellect;
	end
end

local function SetPrimary(self)
	local unit = "player"
	local PrimaryStatsName, PrimaryStatsNum = NarciAPI_GetPrimaryStats();
	self.Label:SetText(PrimaryStatsName)
	self.Value:SetText(PrimaryStatsNum)
	local spec = GetSpecialization();
	if not spec then return; end
	local role = GetSpecializationRole(spec);
	local _, _, _, _, _, primaryStat = GetSpecializationInfo(spec);
	if type(tonumber(primaryStat)) ~= "number" then return; end		--sometimes changing zones cause Lua error
	local stat, effectiveStat, posBuff, negBuff = UnitStat(unit, primaryStat);
	local effectiveStatDisplay = FormatLargeNumbers(effectiveStat);

	-- Set the tooltip text
	local statName = _G["SPELL_STAT"..primaryStat.."_NAME"];
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		self.tooltip = tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	else
		tooltipText = tooltipText..effectiveStatDisplay;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		self.tooltip = tooltipText;

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 and not GetPVPGearStatRules() ) then
			effectiveStatDisplay = RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
		end
	end

	self.tooltip2 = _G["DEFAULT_STAT"..primaryStat.."_TOOLTIP"];

	if ( primaryStat == LE_UNIT_STAT_AGILITY ) then
		local attackPower = GetAttackPowerForStat(primaryStat, effectiveStat);
		local tooltip = STAT_TOOLTIP_BONUS_AP;
		if (HasAPEffectsSpellPower()) then
			tooltip = STAT_TOOLTIP_BONUS_AP_SP;
		end
		if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
			self.tooltip2 = format(tooltip, BreakUpLargeNumbers(attackPower));
			if ( role == "TANK" ) then
				local increasedDodgeChance = GetDodgeChanceFromAttribute();
				if ( increasedDodgeChance > 0 ) then
					self.tooltip2 = self.tooltip2.."|n|n"..format(CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance);
				end
			end
		else
			self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
		end

	elseif ( primaryStat == LE_UNIT_STAT_STRENGTH ) then
		local attackPower = GetAttackPowerForStat(primaryStat,effectiveStat);
		if (HasAPEffectsSpellPower()) then
			self.tooltip2 = STAT_TOOLTIP_BONUS_AP_SP;
		end
		if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
			self.tooltip2 = format(self.tooltip2, BreakUpLargeNumbers(attackPower));
			if ( role == "TANK" ) then
				local increasedParryChance = GetParryChanceFromAttribute();
				if ( increasedParryChance > 0 ) then
					self.tooltip2 = self.tooltip2.."|n|n"..format(CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
				end
			end
		else
			self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
		end

	elseif ( primaryStat == LE_UNIT_STAT_INTELLECT ) then
		if ( UnitHasMana("player") ) then
			if (HasAPEffectsSpellPower()) then
				self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			else
				local result, druid = HasSPEffectsAttackPower();
				if (result and druid) then
					self.tooltip2 = format(STAT_TOOLTIP_SP_AP_DRUID, max(0, effectiveStat), max(0, effectiveStat));
				elseif (result) then
					self.tooltip2 = format(STAT_TOOLTIP_BONUS_AP_SP, max(0, effectiveStat));
				elseif (not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT) then
					self.tooltip2 = format(self.tooltip2, max(0, effectiveStat));
				else
					self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
				end
			end
		else
			self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
		end
	end

end

local function SetStamina(self)
	local statIndex = LE_UNIT_STAT_STAMINA;
	local stat, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex);

	local effectiveStatDisplay = FormatLargeNumbers(effectiveStat);
	-- Set the tooltip text
	local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		self.tooltip = tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	else
		tooltipText = tooltipText..effectiveStatDisplay;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		self.tooltip = tooltipText;

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 and not GetPVPGearStatRules() ) then
			effectiveStatDisplay = RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
		end
	end

	self.Label:SetText(statName)
	self.Value:SetText(effectiveStat)
	self.tooltip2 = _G["DEFAULT_STAT"..statIndex.."_TOOLTIP"];
	self.tooltip2 = format(self.tooltip2, BreakUpLargeNumbers(((effectiveStat*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player")));

	--self:Show();
end

local function GetAppropriateDamage(unit)
	if IsRangedWeapon() then
		local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
		return minDamage, maxDamage, nil, nil, 0, 0, percent;
	else
		return UnitDamage(unit);
	end
end

local function CharacterDamageFrame_OnEnter(self)
	-- Main hand weapon
	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	if ( self.unit == "pet" ) then
		DefaultTooltip:SetText(INVTYPE_WEAPONMAINHAND_PET, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		DefaultTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	DefaultTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	DefaultTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	-- Check for offhand weapon
	if ( self.offhandAttackSpeed ) then
		DefaultTooltip:AddLine("\n");
		DefaultTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		DefaultTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		DefaultTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	DefaultTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0);
	DefaultTooltip:Show();
end

local function SetDamage(self)
	local unit = "player";

	local speed, offhandSpeed = UnitAttackSpeed(unit);
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = GetAppropriateDamage(unit);

	-- remove decimal points for display values
	local displayMin = max(floor(minDamage),1);
	local displayMinLarge = displayMin	--BreakUpLargeNumbers(displayMin);
	local displayMax = max(ceil(maxDamage),1);
	local displayMaxLarge = displayMax	--BreakUpLargeNumbers(displayMax);

	-- calculate base damage
	if percent == 0 then return; end;
	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local totalBonus = (fullDamage - baseDamage);
	-- set tooltip text with base damage
	local damageTooltip = BreakUpLargeNumbers(max(floor(minDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxDamage),1));

	local colorPos = "|cffffffff";
	local colorNeg = "|cffffffff";

	-- epsilon check
	if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
		totalBonus = 0.0;
	end

	local value;
	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
			value = displayMinLarge.." - "..displayMaxLarge;
		else
			value = displayMinLarge.." - "..displayMaxLarge;
		end
	else
		-- set bonus color and display
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
			value = color..displayMinLarge.." - "..displayMaxLarge.."|r";
		else
			value = color..displayMinLarge.." - "..displayMaxLarge.."|r";
		end
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end

	end

	self.Label:SetText(DAMAGE)
	self.Value:SetText(value)
	self.damage = damageTooltip;
	self.attackSpeed = speed;
	self.unit = unit;

	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed and minOffHandDamage and maxOffHandDamage ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local offhandDamageTooltip = BreakUpLargeNumbers(max(floor(minOffHandDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxOffHandDamage),1));
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		self.offhandDamage = offhandDamageTooltip;
		self.offhandAttackSpeed = offhandSpeed;
	else
		self.offhandAttackSpeed = nil;
	end

	self:SetScript("OnEnter", CharacterDamageFrame_OnEnter);
	--self:Show();
end

local function SetAttackSpeed(self, unit)
	local unit = "player"

	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed(unit);

	local displaySpeed = math.floor(100*speed + 0.5)/100;
	if ( offhandSpeed ) then
		offhandSpeed = math.floor(100*offhandSpeed + 0.5)/100;
	end
	if ( offhandSpeed ) then
		if displaySpeed ~= offhandSpeed then
			displaySpeed =  displaySpeed.." / ".. offhandSpeed;
		else
			displaySpeed =  displaySpeed;
		end
	else
		displaySpeed =  displaySpeed;
	end

	local speedText = string.format(Format_Digit, meleeHaste).."%"
	self.Label:SetText(ATTACK_SPEED)
	self.Value:SetText(displaySpeed)

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, string.format(Format_Digit, meleeHaste));

	--self:Show();
end

local function SetArmor(self, unit)
	local unit = "player"

	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor(unit);
	self.Label:SetText(STAT_ARMOR);
	self.Value:SetText(effectiveArmor);

    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));
	local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ARMOR).." "..BreakUpLargeNumbers(effectiveArmor)..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(STAT_ARMOR_TOOLTIP, armorReduction);
	if (armorReductionAgainstTarget) then
		self.tooltip3 = format(STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget);
	else
		self.tooltip3 = nil;
	end
	--self:Show();
end

local function SetPower(self)
	local unit = "player"
	local powerType, powerToken = UnitPowerType(unit);
	local power = UnitPowerMax(unit) or 0;
	local powerText = FormatLargeNumbers(power);
	local powerName = _G[powerToken];
	if (powerToken and powerName) then
		self.Label:SetText(powerName)
		self.Value:SetText(powerText)
		self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, powerName).." "..powerText..FONT_COLOR_CODE_CLOSE;
		self.tooltip2 = _G["STAT_"..powerToken.."_TOOLTIP"];
		self:Show();
	else
		self.Label:SetText("Resource")
		self.Value:SetText("N/A")
	end
end

local function SetReduction(self)
	local unit = "player"
	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor(unit);

    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));
	local armorReductionAgainstTarget = C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(effectiveArmor);
	local armorReductionText = string.format(Format_Digit, armorReduction).."%"
	
	self.Label:SetText(L["Damage Reduction Percentage"]);

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_TEXT_SHOW_RESISTANCES_TEXT.." "..armorReductionText..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(STAT_ARMOR_TOOLTIP, armorReduction);
	if (armorReductionAgainstTarget) then
		self.tooltip3 = format(STAT_ARMOR_TARGET_TOOLTIP, 100*armorReductionAgainstTarget);
		armorReduction = 100 * armorReductionAgainstTarget
	else
		self.tooltip3 = nil;
	end

	self.Value:SetText(armorReductionText);
	--self:Show();
end

local function SetDodge(self)
	local chance = GetDodgeChance();
	local chanceText = string.format("%.2F", chance).."%"
	self.Label:SetText(STAT_DODGE);
	self.Value:SetText(chanceText);

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
	--self:Show();
end

local function SetParry(self)
	local chance = GetParryChance();
	local chanceText = string.format("%.2F", chance).."%"
	self.Label:SetText(STAT_PARRY);
	self.Value:SetText(chanceText);		

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
	--self:Show();
end

local function SetBlock(self, unit)
	local unit = "player"

	local chance = GetBlockChance();
	local chanceText = string.format("%.2F", chance).."%"
	self.Label:SetText(STAT_BLOCK);

	local spec = GetSpecialization();
	if not spec then return; end
	local role = GetSpecializationRole(spec);

	if role == "TANK" and chance ~= 0 then
		self.Value:SetText(chanceText);
		self.Label:SetAlpha(1);
		self.Value:SetAlpha(1);	
	else
		self.Value:SetText("N/A");
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha);
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha);		
	end

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;

	local shieldBlockArmor = GetShieldBlock();
	local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel(unit));
	local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor);

	self.tooltip2 = CR_BLOCK_TOOLTIP:format(blockArmorReduction);
	if (blockArmorReductionAgainstTarget) then
		self.tooltip3 = format(STAT_BLOCK_TARGET_TOOLTIP, blockArmorReductionAgainstTarget);
	else
		self.tooltip3 = nil;
	end
	--self:Show();
end

local function SetHealth(self, unit)
	if (not unit) then
		unit = "player";
	end
	local health = UnitHealthMax(unit);
	local healthText = FormatLargeNumbers(health);
	self.Label:SetText(HEALTH)
	self.Value:SetText(healthText)
	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, HEALTH).." "..healthText..FONT_COLOR_CODE_CLOSE;
	if (unit == "player") then
		self.tooltip2 = STAT_HEALTH_TOOLTIP;
	elseif (unit == "pet") then
		self.tooltip2 = STAT_HEALTH_PET_TOOLTIP;
	end
	self:Show();
end

------------------------------------------------------------------
-----Some of the codes are derivated from EquipmentFlyout.lua-----
------------------------------------------------------------------
local itemTable = {}; 					-- Used for items and locations
local itemDisplayTable = {} 			-- Used for ordering items by location
local itemDisplayTable_ilvl = {}		-- *Sorted by item level
local MaxItemLevelinSlot = 0;

local function SortedbyIlvl(a,b)
	return tonumber(a.Level)> tonumber(b.Level)
end

function Narci_ItemFlyoutButton_OnClick(self)
	local action = EquipmentManager_EquipItemByLocation(self.location, self.id)
	if action then
		Narci_AlertFrame_Autohide:SetAnchor(self, -24, true);
		EquipmentManager_RunAction(action)
	end
	self:Disable();
	After(0.8, function()
		self:Enable();
	end)
end

function Narci_FlyoutBlack_OnUpdate(self, elapsed)
	local alpha;
	local t = self.TimeSinceLastUpdate;
	local blackFrame = self:GetParent();
	local AnimDuration = 0.25;

	if self.OppoDirection then
		alpha = outSine(t, self.startAlpha, 0 - self.startAlpha, AnimDuration);
	else
		alpha = outSine(t, self.startAlpha, 1 - self.startAlpha, AnimDuration);
	end

	blackFrame:SetAlpha(alpha);

	if t >= AnimDuration then
		if self.OppoDirection then
			blackFrame:SetAlpha(0);
		else
			blackFrame:SetAlpha(1);
		end

		self:Hide();
		return;
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

local function Narci_EquipmentFlyout_CreateButton()
	local frame = Narci_EquipmentFlyoutFrame
	local perRow = EQUIPMENTFLYOUT_ITEMS_PER_ROW;
	local buttons = frame.buttons;
	local buttonAnchor = frame.buttonFrame;
	local numButtons = #buttons;

	local button = CreateFrame("Button", "Narci_EquipmentFlyoutFrameButton" .. numButtons + 1, buttonAnchor, "AAAEquipmentFlyoutButtonTemplate");
	button:SetFrameStrata("DIALOG")
	local pos = numButtons/perRow;
	if pos == 0 then
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	elseif ( math.floor(pos) == pos ) then
		-- This is the first button in a row (from 2nd)
		button:SetPoint("TOP", buttons[numButtons + 1 - perRow], "BOTTOM", 0, -2);
	else
		button:SetPoint("TOPLEFT", buttons[numButtons], "TOPRIGHT", 0, 0);
	end

	tinsert(buttons, button);
	return button
end

local function ShowLessInformation(self, bool)
	if bool then
		self.Name:Hide();
		self.ItemLevel:Hide();
		self.IlvlCenter:Show();
	else
		self.Name:Show();
		self.ItemLevel:Show();
		self.IlvlCenter:Hide();
	end
end

function Narci_ShowAllInformation()
	if xmogMode ~=0 then
		return;
	end

	local level = Narci_FlyoutBlack:GetFrameLevel() - 1;

	for i=1, #slotTable do
		if slotTable[i] then
			ShowLessInformation(slotTable[i], false);
			slotTable[i]:SetFrameLevel(level -1)
			slotTable[i].RuneSlot:SetFrameLevel(level)
		end
	end
end

function Narci_EquipmentFlyoutFrame_OnHide(self)
	Narci_ShowAllInformation();
	self.slotID = -1;
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	self.Arrow:Hide();
	self:StopAnimating();

	if Narci_Character.animOut:IsPlaying() then return; end
	Narci_FlyoutBlack.AnimFrame:Hide();
	Narci_FlyoutBlack.AnimFrame:Show();
end

function Narci_EquipmentFlyoutFrame_OnEvent(self, event, ...)	--Hide Flyout if Left-Alt is released
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		local key, state = ...;
		if ( key == "LALT" ) then
			local flyout = Narci_EquipmentFlyoutFrame
			if state == 0 and flyout:IsShown() then
				flyout:Hide()
			end
		end
	end
end

function Narci_EquipmentFlyout_Show(self, slotID)
	--self: Item slot
	if TransmogMode then
		return;
	end
	
	local flyout = Narci_EquipmentFlyoutFrame;
	if (flyout.slotID == slotID or slotID == -1) and (not IsAltKeyDown()) then
		flyout:Hide();
		return;
	end
	if slotTable[flyout.slotID] then
		local level = Narci_FlyoutBlack:GetFrameLevel() -1
		slotTable[flyout.slotID]:SetFrameLevel(level - 1);
		slotTable[flyout.slotID].RuneSlot:SetFrameLevel(level)
		ShowLessInformation(slotTable[flyout.slotID], false);
	end
	flyout.slotID = slotID
	Narci_BuildFlyout();
	flyout:SetParent(self);
	flyout:ClearAllPoints();
	if self.IsRight then
		flyout:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0);			--EquipmentFlyout's Position
	else
		flyout:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
	end

	flyout.Arrow:ClearAllPoints();
	flyout.Arrow:SetPoint("TOP", self, "TOP", 0, 0);

	Narci_FlyoutBlack.AnimFrame:Hide();
	Narci_FlyoutBlack.AnimFrame.OppoDirection = false;
	Narci_FlyoutBlack.AnimFrame:Show();
	self:SetFrameLevel(Narci_FlyoutBlack:GetFrameLevel() + 1)
	flyout:SetFrameLevel(20);
	Narci:HideButtonTooltip();
	ShowLessInformation(self, true)
	
	--Reposition Comparison Tooltip if it reaches the top of the screen--
	local Tooltip = Narci_Comparison;
	Tooltip:ClearAllPoints();
	Tooltip:SetPoint("BOTTOMLEFT", "Narci_EquipmentFlyoutFrame", "TOPLEFT", 8, 12);
	if self:GetTop() > Tooltip:GetBottom() then
    	Tooltip:ClearAllPoints();
    	Tooltip:SetPoint("TOPLEFT", "Narci_EquipmentFlyoutFrame", "BOTTOMLEFT", 8, -12);
	end
	Narci_Comparison_SetComparison(Narci_EquipmentFlyoutFrame.BaseItem, self);
	Tooltip:Show();
end

function Narci_BuildFlyout(slotID)
	local flyout = Narci_EquipmentFlyoutFrame;
	local LoadItemData = C_Item.RequestLoadItemData;	--Cache Item Info

	flyout:Show();
	local id = slotID or flyout.slotID;
	
	--print(id)
	flyout.BaseItem = ItemLocation:CreateFromEquipmentSlot(id)
	local buttons = flyout.buttons;
	MaxItemLevelinSlot = 0;
	
	wipe(itemDisplayTable);
	wipe(itemTable);
	wipe(itemDisplayTable_ilvl);
	GetInventoryItemsForSlot(id, itemTable);
	local itemLocation, itemLevel, tableOutput
	for location, itemID in next, itemTable do
		if ( location - id == ITEM_INVENTORY_LOCATION_PLAYER ) then -- Remove the currently equipped item from the list
			itemTable[location] = nil;
		else
			local _, _, bags, _, slot, bag = EquipmentManager_UnpackLocation(location);
			if bags then
				itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
				itemLevel = C_Item.GetCurrentItemLevel(itemLocation)
				NarciCacheTooltip:SetHyperlink(C_Item.GetItemLink(itemLocation))
				MaxItemLevelinSlot = math.max(MaxItemLevelinSlot, itemLevel)
				LoadItemData(itemLocation)
				tableOutput = {["Level"] = itemLevel, ["itemLocation"] = itemLocation, ["location"] = location}
				tinsert(itemDisplayTable_ilvl, tableOutput);
			end 
		end
	end

	table.sort(itemDisplayTable); -- Sort by location. This ends up as: inventory, backpack, bags, bank, and bank bags.
	table.sort(itemDisplayTable_ilvl, SortedbyIlvl);
	local numTotalItems = #itemDisplayTable_ilvl;
	local buttonWidth, buttonHeight = Narci_HeadSlot:GetWidth(), Narci_HeadSlot:GetHeight();
	buttonWidth, buttonHeight = math.floor(buttonWidth + 0.5), math.floor(buttonHeight + 0.5);
	flyout:SetWidth(math.max(buttonWidth, math.min(numTotalItems, EQUIPMENTFLYOUT_ITEMS_PER_ROW)*buttonWidth))
	--print(numTotalItems)
	local numPageItems = min(numTotalItems, EQUIPMENTFLYOUT_ITEMS_PER_PAGE);
	flyout:SetHeight(math.max(math.floor((numPageItems-1)/EQUIPMENTFLYOUT_ITEMS_PER_ROW + 1)*buttonHeight, buttonHeight))
	local index = 1;
	while #buttons < numPageItems do -- Create any buttons we need.
		local button = Narci_EquipmentFlyout_CreateButton();
	end
	
	for i=1, #buttons do
		button = buttons[i]
		if i <= numPageItems then
			button.itemLocation = itemDisplayTable_ilvl[i].itemLocation;
			button.location = itemDisplayTable_ilvl[i].location;
			button.id = id;
			Narci_EquipmentFlyout_DisplayButton(button)
			button:Show();
			button:SetSize(buttonWidth, buttonHeight)
		else
			button:Hide();
		end
	end
end

function Narci_EquipmentFlyout_DisplayButton(button)
	local location = button.itemLocation;
	button.hyperlink = C_Item.GetItemLink(location)
	if ( not location ) then
		return;
	end

	local itemQuality = C_Item.GetItemQuality(location);
	local itemLevel = C_Item.GetCurrentItemLevel(location);
	local itemIcon = C_Item.GetItemIcon(location);
	local itemLink = C_Item.GetItemLink(location)

	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(location) then
		itemQuality = 8;	--AzeriteEmpoweredItem
	elseif IsCorruptedItem(itemLink) then
		itemQuality = "NZoth";
	end

	if itemLevel < MaxItemLevelinSlot - 44 then
		itemQuality = 0;
		button.Icon:SetDesaturated(true);
	else
		button.Icon:SetDesaturated(false);
	end
	
	button.Icon:SetTexture(itemIcon)
	button.Border:SetTexture(BorderTexture[itemQuality])
	button.IlvlCenter.ItemLevelCenter:SetText(itemLevel)
	button.IlvlCenter:Show()

	if itemLink then
		DisplayRuneSlot(button, button.id, itemQuality, itemLink);
	end
end
-----------------------------------------------------------
------------------------Color Theme------------------------
-----------------------------------------------------------
local ColorTable = Narci_ColorTable;
local ColorIndex = Narci_GlobalColorIndex; --#ColorTable;		--Pick up color according to MapID

local function SetColorThemeBasedOnMapID()
	local mapID = C_Map.GetBestMapForUnit("player");
	if mapID and NarcissusDB.AutoColorTheme then
		if ColorTable[mapID] then
			ColorIndex = mapID;
			Narci_GlobalColorIndex = mapID;
		else
			ColorIndex = 0;
			Narci_GlobalColorIndex = 0;
		end
	end
	Narci:SetRadarColor();
	--print("mapID: "..mapID.." ColorIndex: "..ColorIndex)
end

function Narci_Pref_ColorTheme(index)
	ColorIndex = index or 0;
	if not ColorTable[ColorIndex] then return; end;
	Narci_GlobalColorIndex = ColorIndex;
	Narci_Attribute:Hide();
	Narci_Attribute:Show();
	Narci:SetRadarColor();
end

local function SetWidgetColor(frame)
	local R, G, B = ColorTable[ColorIndex][1], ColorTable[ColorIndex][2], ColorTable[ColorIndex][3];
	local r, g, b = R/255, G/255 ,B/255;
	local type = frame:GetObjectType();

	if type == "FontString" then
		local sqrt = math.sqrt;
		r, g, b = sqrt(r), sqrt(g), sqrt(b)
		frame:SetTextColor(r, g, b);
		return;
	end

	frame:SetColorTexture(r, g, b);
end

function SetRadarVertexSize(self, size)
	local name = self:GetName()
	local Frame = Narci_RadarChartFrame;
	if name == "ADCrit" then
		Frame.P1:SetSize(size, size);
	elseif name == "ADHaste" then
		Frame.P2:SetSize(size, size);
	elseif name == "ADMastery" then
		Frame.P3:SetSize(size, size);
	elseif name == "ADVersatility" then
		Frame.P4:SetSize(size, size);
	end
end

function Narci:SetRadarColor()
	local Frame = Narci_RadarChartFrame
	SetWidgetColor(Frame.MaskedBackground)
	SetWidgetColor(Frame.MaskedBackground2)
	SetWidgetColor(Frame.MaskedLine1)
	SetWidgetColor(Frame.MaskedLine2)
	SetWidgetColor(Frame.MaskedLine3)
	SetWidgetColor(Frame.MaskedLine4)
end

function Narci:SetRadarChart(c, h, m, v, ManuallyInPutSum)
	--c, h, m, v: Input manually or use combat ratings
	local deg = math.deg;
	local rad = math.rad;
	local atan2 = math.atan2;
	local sqrt = math.sqrt;
	local Radar = Narci_RadarChartFrame;

	local chartWidth = 96 / 2;	--In half
	local _, rating = GetEffectiveCrit();										--		|	p1(x1,y1)	  Line4		p3(x3,y3)
																				--		|			*				*
	local Crit = c or GetCombatRating(rating) or 0;								--		|			 	*		*
	local Haste = h or GetCombatRating(CR_HASTE_MELEE) or 0;					--		|	Line1		 	*		   Line3
	local Mastery = m or GetCombatRating(CR_MASTERY) or 0;						--		|			 	*		*
	local Versatility = v or GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0;	--		|			*				*
																				--		|	p2(x2,y2)	  Line2		p4(x4,y4)

	local v1, v2, v3, v4, v5, v6 = true, true, true, true, true, true;
	if Crit == 0 and Haste == 0 and Mastery == 0 and Versatility == 0 then
		v1, v2, v3, v4, v5, v6 = false, false, false, false, false, false;
	else
		if Crit == 0 and Haste == 0 then v1 = false; end;
		if Haste == 0 and Versatility == 0 then v2 = false; end;
		if Mastery == 0 and Versatility == 0 then v3 = false; end;
		if Crit == 0 and Mastery == 0 then v4 = false; end;
		Crit, Haste, Mastery = Crit + 0.03, Haste + 0.02, Mastery + 0.01;				--Avoid some mathematical issues
	end
	Radar.MaskedLine1:SetShown(v1);
	Radar.MaskedLine2:SetShown(v2);
	Radar.MaskedLine3:SetShown(v3);
	Radar.MaskedLine4:SetShown(v4);
	Radar.MaskedBackground:SetShown(v5);
	Radar.MaskedBackground2:SetShown(v6);

	--[[
		--4500 8.3 Stat Sum
		Enchancements on ilvl 445 (Mythic Eternal Palace) Player Lvl 120
		Weapon 152 Back 171 Wrist 171 Hands 229 Waist 229 Legs 306 Feet 229 Ring 538 Trinket 218	Max:3151 + 12*50Gem ~= 3750
		ilvl 240 (Mythic Antorus) Player Lvl 110
		Head 87 Shoulder 64 Chest 88 Weapon 152 Back 49 Wrist 49 Hands 64 Waist 64 Legs 87 Feet 63 Ring 165 Trinket 62	Max ~= 1100
		ilvl 149 (Mythic HFC) Player Lvl 100
		Head 48 Shoulder 36 Chest 48 Weapon 24 Back 28 Wrist 27 Hands 36 Waist 36 Legs 48 Feet 35 Ring 27 Trinket 32	Max ~= 510
		Heirlooms Player Lvl 20
		Weapon 4 Back 4 Wrist 4 Hands 6 Waist 6 Legs 8 Feet 6 Ring 5 Trinket 6	 ~= 60
	--]]

	local Sum = ManuallyInPutSum or 0;
	local maxNum = max(Crit + Haste + Mastery + Versatility, 1);
	if maxNum > 0.95 * Sum then
		Sum = maxNum;
	end

	local d1, d2, d3, d4 = (Crit / Sum), (Haste / Sum) , (Mastery / Sum) , (Versatility / Sum);
	local a;
	if (d1 + d4) ~= 0 and (d2 + d3) ~= 0 then
		--a = chartWidth * math.sqrt(0.618/(d1 + d4)/(d2 + d3)/2)* 96;
		a = 1.414*chartWidth
	else
		a = 0;
	end
	
	
	--[[
	local dmax = chartWidth * math.max(d1, d2, d3, d4);
	local Amplifier = 0;
	local playerLevel = tonumber(UnitLevel("player"));
	if playerLevel >= 1 then
		Amplifier = 0.1671 * math.log(playerLevel);
	end

	if dmax >= Amplifier * chartWidth then
		a = a * Amplifier * chartWidth / dmax;
		print("b")
	end
	--]]

	local x1, x2, x3, x4 = -d1*a, -d2*a, d3*a, d4*a;
	local y1, y2, y3, y4 = d1*a, -d2*a, d3*a, -d4*a;
	local mx1, mx2, mx3, mx4 = (x1 + x2)/2, (x2 + x4)/2, (x3 + x4)/2, (x1 + x3)/2;
	local my1, my2, my3, my4 = (y1 + y2)/2, (y2 + y4)/2, (y3 + y4)/2, (y1 + y3)/2;

	local ma1 = atan2((y1 - y2), (x1 - x2));
	local ma2 = atan2((y2 - y4), (x2 - x4));
	local ma3 = atan2((y4 - y3), (x4 - x3));
	local ma4 = atan2((y3 - y1), (x3 - x1));

	if my1 == 0 then
		my1 = 0.01;
	end
	if my3 == 0 then
		my1 = -0.01;
	end
	if deg(ma1) == 90 then
		ma1 = rad(89);
	end
	if deg(ma3) == -90 then
		ma1 = rad(-89);
	end

	Radar.P1:SetPoint("CENTER", x1, y1);
	Radar.P2:SetPoint("CENTER", x2, y2);
	Radar.P3:SetPoint("CENTER", x3, y3);
	Radar.P4:SetPoint("CENTER", x4, y4);

	Radar.Mask1:SetRotation(ma1);
	Radar.Mask2:SetRotation(ma2);
	Radar.Mask3:SetRotation(ma3);
	Radar.Mask4:SetRotation(ma4);
		
	local hypo1 = sqrt(2*x1^2 + 2*x2^2);
	local hypo2 = sqrt(2*x2^2 + 2*x4^2);
	local hypo3 = sqrt(2*x4^2 + 2*x3^2);
	local hypo4 = sqrt(2*x3^2 + 2*x1^2);

	if (hypo1 - 4) > 0 then
		Radar.MaskLine1:SetWidth(hypo1 - 4);	--Line length
	else
		Radar.MaskLine1:SetWidth(0.1);
	end

	if (hypo2 - 4) > 0 then
		Radar.MaskLine2:SetWidth(hypo2 - 4);
	else
		Radar.MaskLine2:SetWidth(0.1);
	end

	if (hypo3 - 4) > 0 then
		Radar.MaskLine3:SetWidth(hypo3 - 4);
	else
		Radar.MaskLine3:SetWidth(0.1);
	end

	if (hypo4 - 4) > 0 then
		Radar.MaskLine4:SetWidth(hypo4 - 4);
	else
		Radar.MaskLine4:SetWidth(0.1);
	end

	Radar.MaskLine1:ClearAllPoints();
	Radar.MaskLine1:SetRotation(0);
	Radar.MaskLine1:SetRotation(ma1);
	Radar.MaskLine1:SetPoint("CENTER", Radar, "CENTER", mx1, my1);
	Radar.MaskLine2:ClearAllPoints();
	Radar.MaskLine2:SetRotation(0);
	Radar.MaskLine2:SetRotation(ma2);
	Radar.MaskLine2:SetPoint("CENTER", Radar, "CENTER", mx2, my2);
	Radar.MaskLine3:ClearAllPoints();
	Radar.MaskLine3:SetRotation(0);
	Radar.MaskLine3:SetRotation(ma3);
	Radar.MaskLine3:SetPoint("CENTER", Radar, "CENTER", mx3, my3);
	Radar.MaskLine4:ClearAllPoints();
	Radar.MaskLine4:SetRotation(0);
	Radar.MaskLine4:SetRotation(ma4);
	Radar.MaskLine4:SetPoint("CENTER", Radar, "CENTER", mx4, my4);
	Radar.Mask1:SetPoint("CENTER", mx1, my1);
	Radar.Mask2:SetPoint("CENTER", mx2, my2);
	Radar.Mask3:SetPoint("CENTER", mx3, my3);
	Radar.Mask4:SetPoint("CENTER", mx4, my4);

	Radar.MaskedBackground:SetAlpha(0.4);
	Radar.MaskedBackground2:SetAlpha(0.4);

	Radar.n1, Radar.n2, Radar.n3, Radar.n4 = Crit, Haste, Mastery, Versatility;
end

function Narci:AnimateRadarChart(c, h, m, v)
	--Update the radar chart using animation
	local Radar = Narci_RadarChartFrame;
	local UpdateFrame = Radar.UpdateFrame;
	if not UpdateFrame then
		UpdateFrame = CreateFrame("Frame", nil, Radar, "NarciUpdateFrameTemplate");
		Radar.UpdateFrame = UpdateFrame;
		Radar.n1, Radar.n2, Radar.n3, Radar.n4 = 0, 0, 0, 0;
	end

	local s1, s2, s3, s4 = Radar.n1, Radar.n2, Radar.n3, Radar.n4;	--start/end point
	local critChance, critRating = GetEffectiveCrit();
	local e1 = c or GetCombatRating(critRating) or 0;
	local e2 = h or GetCombatRating(CR_HASTE_MELEE) or 0;
	local e3 = m or GetCombatRating(CR_MASTERY) or 0;
	local e4 = v or GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0;

	local duration = 0.2;

	local playerLevel = UnitLevel("player");
	local sum;
	if playerLevel ~= 120 then
		--sum = 31 * math.exp( 0.04 * UnitLevel("player")) + 40;
		sum = (e1 + e2 + e3 + e4) * 1.5;
	else
		sum = math.max(e1 + e2 + e3 + e4 , 5500);	--Status Sum for 8.3 Raid
	end

	local function UpdateFunc(self, elapsed)
		local t = self.TimeSinceLastUpdate;
		local v1 = outSine(t, s1, e1 - s1 , duration);
		local v2 = outSine(t, s2, e2 - s2 , duration);
		local v3 = outSine(t, s3, e3 - s3 , duration);
		local v4 = outSine(t, s4, e4 - s4 , duration);
		Narci:SetRadarChart(v1, v2, v3, v4, sum);
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
		if t >= duration then
			Narci:SetRadarChart(e1, e2, e3, e4, sum);
			self:Hide();
		end
	end

	UpdateFrame:Hide();
	UpdateFrame:SetScript("OnUpdate", UpdateFunc);
	UpdateFrame:Show();
end

local SetRadarChart = Narci.AnimateRadarChart;

function Pref_SetBackgroundColor(self)
	local FrameID = self:GetID() or 0;
	local R, G, B = ColorTable[ColorIndex][1], ColorTable[ColorIndex][2], ColorTable[ColorIndex][3];
	local r, g, b = R/255, G/255 ,B/255;
	if FrameID % 2 == 0 then
		if self.Color then
			self.Color:SetColorTexture(r, g, b, 0.75);
			return;
		elseif self.Color1 and self.Color2 then
			self.Color1:SetColorTexture(r, g, b, 0.75);
			self.Color2:SetColorTexture(r, g, b, 0.75);
		end
	else
		if self.Color then
			self.Color:SetColorTexture(0.1, 0.1, 0.1, 0.75);
			return;
		elseif self.Color1 and self.Color2 then
			self.Color1:SetColorTexture(0.1, 0.1, 0.1, 0.75);
			self.Color2:SetColorTexture(0.1, 0.1, 0.1, 0.75);
		end
	end
end

function AttributeTemplate_OnLoad(self)
	local numericValue;
	tinsert(self, numericValue)
	Pref_SetBackgroundColor(self);
end

function XmogList_OnLoad(self)
	Pref_SetBackgroundColor(self);
end

local function Stats_OnLoad(self)
	if not self then
		return;
	end
	local FrameName = strsub(self:GetName(), 3);

	if FrameName == "Primary" then
		SetPrimary(self);
	elseif FrameName == "Stamina" then
		SetStamina(self);
	elseif FrameName == "Health" then
		SetHealth(self)
	elseif FrameName == "Energy" then
		SetPower(self);
	elseif FrameName == "Regen" then
		SetRegen(self)
	elseif FrameName == "Crit" then
		SetCrit(self)
	elseif FrameName == "Haste" then
		SetHaste(self)
	elseif FrameName == "Mastery" then
		SetMastery(self)
	elseif FrameName == "Versatility" then
		SetVersatility(self)
	elseif FrameName == "Leech" then
		SetLeech(self)
	elseif FrameName == "Avoidance" then
		SetAvoidance(self)
	elseif FrameName == "Speed" then
		SetSpeed(self)
	elseif FrameName == "MovementSpeed" then
		SetMovementSpeed(self)
	elseif FrameName == "Damage" then
		SetDamage(self);
	elseif FrameName == "AttackSpeed" then
		SetAttackSpeed(self);
	elseif FrameName == "Armor" then
		SetArmor(self);
	elseif FrameName == "Reduction" then
		SetReduction(self);
	elseif FrameName == "Dodge" then
		SetDodge(self);	
	elseif FrameName == "Parry" then
		SetParry(self);	
	elseif FrameName == "Block" then
		SetBlock(self);				
	end
end

local function RefreshStats(id, frame)
	local frame = frame or "Detailed";

	if frame == "Detailed" then
		if statTable[id] then
			Stats_OnLoad(statTable[id]);
		end
	elseif frame == "Concise" then
		if statTable[id] then
			Stats_OnLoad(statTable_Short[id]);
		end
	end
end

local isRefreshing;
local function RefreshAllStats()
	if not isRefreshing then
		isRefreshing = true;
		After(0, function()
			for i=1, #statTable do
				RefreshStats(i);
			end
	
			for i=1, #statTable_Short do
				RefreshStats(i, "Concise");
			end
			isRefreshing = nil;
		end);
	end
end

Narci.RefreshAllStats = RefreshAllStats;

local function PlayAttributeAnimation()
	if not NarcissusDB.DetailedIlvlInfo then
		Narci.AnimateRadarChart();
		return
	end
	local anim;
	for i=1, #statTable do
		anim = statTable[i].animIn;
		if anim then
			anim.A2:SetToAlpha(statTable[i]:GetAlpha());
			anim:Play();
		end
	end
	Narci_RadarChartFrame.animIn:Play();
end

local function ShowAttributeButton(bool)
	local state = bool or true;
	if state then
		if NarcissusDB.DetailedIlvlInfo then
			Narci_DetailedStatFrame:SetShown(true);
			Narci_RadarChartFrame:SetShown(true);
			Narci_ConciseStatFrame:SetShown(false);
		else
			Narci_DetailedStatFrame:SetShown(false);
			Narci_RadarChartFrame:SetShown(false);
			Narci_ConciseStatFrame:SetShown(true);
		end
		Narci_IlvlInfoFrame:SetShown(true);
	else
		Narci_DetailedStatFrame:SetShown(false);
		Narci_RadarChartFrame:SetShown(false);
		Narci_ConciseStatFrame:SetShown(false);
		Narci_IlvlInfoFrame:SetShown(false);
	end

end

local function AssignFrame()
	local slotFrame = Narci_Character;

	slotTable[1] = slotFrame.HeadSlot;
	slotTable[2] = slotFrame.NeckSlot;
	slotTable[3] = slotFrame.ShoulderSlot;
	slotTable[4] = slotFrame.ShirtSlot;
	slotTable[5] = slotFrame.ChestSlot;
	slotTable[6] = slotFrame.WaistSlot;
	slotTable[7] = slotFrame.LegsSlot;
	slotTable[8] = slotFrame.FeetSlot;
	slotTable[9] = slotFrame.WristSlot;
	slotTable[10] = slotFrame.HandsSlot;
	slotTable[11] = slotFrame.Finger0Slot;
	slotTable[12] = slotFrame.Finger1Slot;
	slotTable[13] = slotFrame.Trinket0Slot;
	slotTable[14] = slotFrame.Trinket1Slot;
	slotTable[15] = slotFrame.BackSlot;
	slotTable[16] = slotFrame.MainHandSlot;
	slotTable[17] = slotFrame.SecondaryHandSlot;
	slotTable[18] = slotFrame.NeckSlot;		--=RangedSlot; --abandoned
	slotTable[19] = slotFrame.TabardSlot;

	Narci.slotTable = slotTable;

	local statFrame = Narci_DetailedStatFrame;
	statTable[1] = statFrame.Primary;
	statTable[2] = statFrame.Stamina;
	statTable[3] = statFrame.Damage;
	statTable[4] = statFrame.AttackSpeed;
	statTable[5] = statFrame.Energy;
	statTable[6] = statFrame.Regen;
	statTable[7] = statFrame.Health;
	statTable[8] = statFrame.Armor;
	statTable[9] = statFrame.Reduction;
	statTable[10]= statFrame.Dodge;
	statTable[11]= statFrame.Parry;
	statTable[12]= statFrame.Block;
	statTable[13]= ADCrit			--statFrame.Crit;
	statTable[14]= ADHaste			--statFrame.Haste;
	statTable[15]= ADMastery		--statFrame.Mastery;
	statTable[16]= ADVersatility	--statFrame.Versatility;
	statTable[17]= statFrame.Leech;
	statTable[18]= statFrame.Avoidance;
	statTable[19]= statFrame.MovementSpeed;
	statTable[20]= statFrame.Speed;

	local statFrame_Short = Narci_ConciseStatFrame;
	statTable_Short[1]  = statFrame_Short.Primary;
	statTable_Short[2]  = statFrame_Short.Stamina;
	statTable_Short[3]  = statFrame_Short.Health;
	statTable_Short[4]  = statFrame_Short.Energy;
	statTable_Short[5]  = statFrame_Short.Regen;
	statTable_Short[6]  = statFrame_Short.Crit;
	statTable_Short[7]  = statFrame_Short.Haste;
	statTable_Short[8]  = statFrame_Short.Mastery;
	statTable_Short[9]  = statFrame_Short.Versatility;
	statTable_Short[10] = statFrame_Short.Leech;
	statTable_Short[11] = statFrame_Short.Avoidance;
	statTable_Short[12] = statFrame_Short.Speed;
end

function Narci_AliasButton_OnClick(self)
	local editBox = PlayerInfoFrame.PlayerName;
	NarcissusDB_PC.UseAlias = not NarcissusDB_PC.UseAlias;

	if NarcissusDB_PC.UseAlias then
		self.Label:SetText(NARCI_ALIAS_USE_PLAYER_NAME)
		editBox:Enable()
		editBox:SetFocus();
		editBox:SetText(NarcissusDB_PC.PlayerAlias or UnitName("player"))
		editBox:HighlightText();
	else
		self.Label:SetText(NARCI_ALIAS_USE_ALIAS)

		local text = strtrim(editBox:GetText());
		editBox:SetText(text);
		NarcissusDB_PC.PlayerAlias = text;
		editBox:Disable();
		editBox:HighlightText(0,0)
		editBox:SetText(UnitName("player"));
	end
	self:SetWidth(self.Label:GetWidth() + 12)
	local LetterNum = editBox:GetNumLetters()
	local w = math.max(LetterNum*16, 160)
	editBox:SetWidth(w);
end


--local defaultVolume
local MusicIO = CreateFrame("Frame", "Narci_MusicInOut");
MusicIO.TimeSinceLastUpdate = 0;
MusicIO:Hide()

local function MusicIO_Update(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local volume;
	if self.State then
		volume = math.max((self.TimeSinceLastUpdate/2), CVar_Temp.MusicVolume)
	else
		volume = math.max((self.StartVolume - self.TimeSinceLastUpdate/2), CVar_Temp.MusicVolume)
	end
	SetCVar("Sound_MusicVolume",volume)

	if (self.State and volume >= 1) or ((not self.State) and volume <= tonumber(CVar_Temp.MusicVolume)) then
		self:Hide()
		self.TimeSinceLastUpdate = 0;
	end
end

MusicIO:SetScript("OnShow", function(self)
	self.StartVolume = GetCVar("Sound_MusicVolume") or 1;
end)
MusicIO:SetScript("OnUpdate", MusicIO_Update)
MusicIO:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0;
end)

local function SmoothMusicVolume(state)
	if state then
		if not NarcissusDB.FadeMusic then
			return;
		end
	end

	MusicIO:Hide()
	MusicIO.State = state
	MusicIO:Show()
end

function Narci_Open()
	if not OpenViaClick then
		if InCombatLockdown() then
			return;
		end
		OpenViaClick = true;
		CVar_Temp.ActioncamState = tonumber(GetCVar("test_cameraDynamicPitch"));
		CVar_Temp.OverShoulder = GetCVar("test_cameraOverShoulder");
		CVar_Temp.MusicVolume = GetCVar("Sound_MusicVolume");
		SaveView(5)
		ModifyCameraForShapeshifter();
		xmogMode = 0;
		MogMode_Offset = 0;
		NarciPlayerModelFrame1.xmogMode = 0;
		local speedFactor = 180/(GetCVar("cameraYawMoveSpeed") or 180);
		ZoomFactor.EndSpeed = speedFactor*ZoomFactor.EndSpeedBasic;
		ZoomFactor.StartSpeed = speedFactor*ZoomFactor.StartSpeedBasic;
		Narci_FlyoutBlack:SetAlpha(0);
		SmoothMusicVolume(true);
		ACL:Show();

		Narci_PhotoModeController:Show();
		Narci_XmogButton:Enable();
		BeginZoomingIn();

		DefaultTooltip:SetScale(UIParent:GetEffectiveScale() or 1);

		After(0, function()
			RefreshAllSlot();
			Narci:SetRadarChart(0,0,0,0,1);
			Narci_LetterboxAnimation();
			local Vignette = Narci_Vignette;
			Vignette.VignetteLeft:SetAlpha(VignetteAlpha);
			Vignette.VignetteRight:SetAlpha(VignetteAlpha);
			Vignette.VignetteRightSmall:SetAlpha(0);
			UIFrameFadeIn(Vignette, 1, Vignette:GetAlpha(), 1);
			Vignette.VignetteRight.animIn:Play();
			Vignette.VignetteLeft.animIn:Play();

			if UIParent:IsShown() then
				UIPA.EndAlpha = 0;
				UIPA:Show();
			end
			SetCVar("test_cameraDynamicPitchSmartPivotCutoffDist", 10);

			After(0.5, function()
				SetUIVisibility(false); 		--Same as pressing Alt + Z
				SetCorruptionBackground();
			end)

			After(0.8, function()
				UIParent:SetAlpha(1);
			end)
		end)
		
		Narci.EnableAutoUpdate = true;
		Narci.isActive = true;
	else
		if Narci.showExitConfirm and not InCombatLockdown() then
			local ExitConfirm = Narci_ExitConfirmationDialog;
			if not ExitConfirm:IsShown() then
				FadeFrame(ExitConfirm, 0.25, "IN");

				--"Nullify" ShowUI
				UIParent:SetAlpha(0);
				Minimap:Hide();
				After(0, function()
					SetUIVisibility(false);
					Narci_MinimapButton:Enable();
					UIParent:SetAlpha(1);
					Minimap:Show()
				end);

				return;
			else
				FadeFrame(ExitConfirm, 0.15, "OUT");
			end
		end
		PlaySlotAnimOut();
		ExitFunc();
		SmoothMusicVolume(false);
		Narci_LetterboxAnimation("OUT");
		if Narci_TitleManager_Switch.IsOn then
			Narci_TitleManager_Switch:Click();
		end
		Narci_EquipmentFlyoutFrame:Hide();
		Narci_TitleManager_TitleTooltip:Hide();		--TitleManager
		Narci_ModelSettings:Hide();

		local frame = Narci_PhotoModeController;
		frame.PhotoModeController_AnimFrame.OppoDirection = true;
		frame.PhotoModeController_AnimFrame:Hide();
		frame.PhotoModeController_AnimFrame.EndPointY = "-80"
		frame.PhotoModeController_AnimFrame.toAlpha = 0;
		frame.PhotoModeController_AnimFrame:Show();
		TakeOutFromUIParent(AzeriteEmpoweredItemUI, "MEDIUM", false);
		TakeOutFromUIParent(AzeriteEssenceUI, "MEDIUM", false);
		TakeOutFromUIParent(ArtifactFrame, "MEDIUM", false);
		TakeOutFromUIParent(ItemSocketingFrame, "MEDIUM", false);

		Narci.showExitConfirm = false;
	end
end

function Narci_OpenGroupPhoto()
	if not OpenViaClick then
		if InCombatLockdown() then
			return;
		end
		ModifyCameraForShapeshifter();
		CVar_Temp.ZoomLevel = GetCameraZoom();
		SetCVar("test_cameraDynamicPitch", 1)
		OpenViaClick = true;
		local xmogMode_Temp = NarcissusDB.DefaultLayout;
		NarcissusDB.DefaultLayout = 2;

		if not Narci_PhotoModeButton.IsOn then
			Narci_PhotoModeButton:Click();
		end

		Narci_XmogButton:Enable();
		Narci_XmogButton:Click();

		--Narci_ActorPanelExpandButton_OnClick(Narci_ExpandButton)
		After(0.4, function()
			NarcissusDB.DefaultLayout = xmogMode_Temp;
		end)
		
		CVar_Temp.ActioncamState = tonumber(GetCVar("test_cameraDynamicPitch"));
		CVar_Temp.OverShoulder = GetCVar("test_cameraOverShoulder");
		CVar_Temp.MusicVolume = GetCVar("Sound_MusicVolume");
		SaveView(5)
		
		local speedFactor = 180/(GetCVar("cameraYawMoveSpeed") or 180);
		ZoomFactor.EndSpeed = speedFactor*ZoomFactor.EndSpeedBasic;
		ZoomFactor.StartSpeed = speedFactor*ZoomFactor.StartSpeedBasic;
		Narci_FlyoutBlack:SetAlpha(0);
		ACL:Show();

		Narci_PhotoModeController:Show();
		
		SP:Show();	

		DefaultTooltip:SetScale(UIParent:GetEffectiveScale() or 1);

		After(0, function()
			RefreshAllSlot();
			local Vignette = Narci_Vignette;
			Vignette.VignetteLeft:SetAlpha(VignetteAlpha);
			Vignette.VignetteRight:SetAlpha(VignetteAlpha);
			Vignette.VignetteRightSmall:SetAlpha(0);
			UIFrameFadeIn(Vignette, 1, Vignette:GetAlpha(), 1);
			Vignette.VignetteRight.animIn:Play();
			Vignette.VignetteLeft.animIn:Play();

			if UIParent:IsShown() then
				UIPA.EndAlpha = 0;
				UIPA:Show();
			end

			SetCVar("test_cameraDynamicPitchSmartPivotCutoffDist", 10);

			After(0.5, function()
				SetUIVisibility(false); 		--Same as pressing Alt + Z
			end)

			After(0.8, function()
				UIParent:SetAlpha(1);
			end)
		end)
		Narci.isActive = true;
	end
end

function Narci_AliasButton_SetState()
	local editBox = PlayerInfoFrame.PlayerName;
	local button = Narci_AliasButton;

	if NarcissusDB_PC.UseAlias then
		editBox:Enable();
		editBox:SetText((NarcissusDB_PC.PlayerAlias or UnitName("player")));
		button.Label:SetText(NARCI_ALIAS_USE_PLAYER_NAME);
	else
		editBox:Disable();
		button.Label:SetText(NARCI_ALIAS_USE_ALIAS);
	end

	local LetterNum = editBox:GetNumLetters()
	local w = math.max(LetterNum*16, 160)
	editBox:SetWidth(w);

	button:SetWidth(button.Label:GetWidth() + 12)
end

function Narci_SetPlayerName(self)
	local playerName = UnitName("player");
	self.PlayerName:SetShadowColor(0, 0, 0);
	self.PlayerName:SetShadowOffset(2, -2);
	self.PlayerName:SetText(playerName);
	SmartFontType(self.PlayerName);
end

---Widgets---

function CameraControllerThumb_OnLoad(self)
	self:RegisterForClicks("RightButtonUp");
	self:RegisterForDrag("LeftButton");
	self.Reading:SetText(string.format(Format_Digit, 0));
end

local function CameraControlBarThumb_Reposition(self, ofsx)
	self:GetParent().Thumb:SetPoint("CENTER", ofsx, 0);
	CameraOffsetControlBar.PosX = ofsx;
	SetCVar("test_cameraOverShoulder", 0 - ofsx/20)	--Ajust the Zoom - Shoulder factor
	local currentShoulder = GetCVar("test_cameraOverShoulder");
	local Zoom = GetCameraZoom();
end

function CameraControlBar_DraggingFrame_OnUpdate(self)
	local scale = self:GetParent():GetEffectiveScale();
	local xpos, _ = GetCursorPosition() / scale;
	local xmin, xmax = self:GetParent():GetLeft() + 18 , self:GetParent():GetRight() - 18;

	CameraOffsetControlBar.Range = xmax - xmin;

	local xcenter, _ = self:GetParent():GetCenter();
	local ofsx;
	if xpos < xmin then
		ofsx = xmin - xcenter;
	elseif xpos > xmax then
		ofsx = xmax - xcenter;
	else
		ofsx = xpos - xcenter;
	end

	CameraControlBarThumb_Reposition(self, ofsx);
end

function CameraControlBarThumb_OnClick(self, button, down)
	--self:GetParent().Thumb:SetPoint("CENTER", 0, 0);
	self:Disable()
	CameraControlBar_ResetPosition_AnimFrame.OppoDirection = true
	CameraControlBar_ResetPosition_AnimFrame:Show();
	After(0.6, function()
		self:Enable();
		CameraOffsetControlBar.PosX = 0;
		CameraOffsetControlBar.PosRadian = 0;
	end)
	local Zoom = GetCameraZoom()
	Smooth_ShoulderCVar(Shoulder_Factor1*Zoom + Shoulder_Factor2)
	self:GetParent().Thumb.Reading:SetText(string.format(0))
end

local function rotateFrame(frame, Degree)
    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Rotation")
	a1:SetDegrees(Degree)
	a1:SetOrigin("LEFT",0 ,0) 
	a1:SetOrder(1)
	a1:SetDuration(0)
	local a2 = ag:CreateAnimation("Rotation")
	a2:SetDegrees(0)
	a2:SetOrigin("LEFT",0 ,0) 
	a2:SetOrder(2)
    a2:SetDuration(1)       
	ag:Play()
	ag:Pause()  
end

local shaftDiameter = 53;
local lastDegree = 0;
local tinyIncre = 1000;

local function TinyZoom(degree, lastDegree)
	if (degree >= 0 and lastDegree >= 0) or (degree <= 0 and lastDegree <= 0) then
		if degree < lastDegree then
			CameraZoomIn((lastDegree - degree)/tinyIncre);
		elseif degree > lastDegree then
			CameraZoomOut((degree - lastDegree)/tinyIncre);
		end
	elseif degree >= 0 and lastDegree < 0 then
		if degree >= 90 then
			CameraZoomIn((180 - degree)/tinyIncre);
		else
			CameraZoomOut((0 + degree)/tinyIncre);
		end
	elseif degree <= 0 and lastDegree > 0 then
		if degree <= -90 then
			CameraZoomOut((180 + degree)/tinyIncre);
		else
			CameraZoomIn((0 - degree)/tinyIncre);
		end
	end
end

local function RotateShaftNode(radian)
	local ofsx = shaftDiameter*math.cos(radian)
	local ofsy = shaftDiameter*math.sin(radian)
	CameraControllerNode:SetPoint("CENTER", "CameraControllerThumb", "CENTER", ofsx, ofsy);
	CameraControllerThumb.Shaft:SetRotation(radian)
end

function CameraZoomController_DraggingFrame_OnUpdate(self)
	local scale = self:GetParent():GetEffectiveScale()
	local xpos, ypos = GetCursorPosition()
	xpos, ypos = xpos/scale, ypos/scale
	local radian = math.atan2( (ypos - self.cy),(xpos - self.cx))
	RotateShaftNode(radian);
	CameraOffsetControlBar.PosRadian = radian;
	local degree = math.deg(radian)

	--rotateFrame(self:GetParent().Shaft, degree - lastDegree)
	if not self.isPressed then
		TinyZoom(degree, lastDegree)
	else
		if degree < 0 then
			CameraZoomIn( (-degree)/tinyIncre)
		elseif degree > 0 then
			CameraZoomOut( (degree)/tinyIncre)
		end
	end

	lastDegree = degree;
end



------------------------------------------------------
------------------Photo Mode Controller---------------
------------------------------------------------------
function Narci_KeyListener_OnEscapePressed()
	if OpenViaClick then
		Narci_MinimapButton:Click();
	end
end

function Narci_ExitButton_OnClick(self)
	if OpenViaClick then
		Narci_Open();
		SetUIVisibility(true);
	end
end

local function TokenButton_ClearMarker(self)
	local parent = self:GetParent();
	if parent.buttons then
		for i=1, #parent.buttons do
			parent.buttons[i].HighlightColor:Hide();
		end
	end
end

---Set Graphics Settings to Ultra---
local PhotoMode_Cvar_GraphicsBackup = {};
local PhotoMode_Cvar_GraphicsList = {
	["ffxAntiAliasingMode"] = 2,

	["graphicsTextureResolution"] = 3,
	["graphicsTextureFiltering"] = 6,
	["graphicsProjectedTextures"] = 2,

	["graphicsViewDistance"] = 10,
	["graphicsEnvironmentDetail"] = 10,
	["graphicsGroundClutter"] = 10,

	["graphicsShadowQuality"] = 6,
	["graphicsLiquidDetail"] = 4,
	["graphicsSunshafts"] = 3,
	["graphicsParticleDensity"] = 5,
	["graphicsSSAO"] = 5,
	["graphicsDepthEffects"] = 4,
	--["graphicsLightingQuality"] = 3,
	["lightMode"] = 2,
	["MSAAQuality"] = 4,	--4 is invalid. But used for backup
}

---Hide Names and Bubbles---
--local PhotoMode_Cvar_TrackingList = 1		--Track Battle Pet
local PhotoMode_Cvar_TrackingBAK = true;
local PhotoMode_Cvar_NamesBackup = {};
local PhotoMode_Cvar_NamesList = {			--Unit Name CVars
	["UnitNameOwn"] = 0,
	["UnitNameNonCombatCreatureName"] = 0,
	["UnitNameFriendlyPlayerName"] = 0,
	["UnitNameFriendlyPetName"] = 0,
	["UnitNameFriendlyMinionName"] = 0,
	["UnitNameFriendlyGuardianName"] = 0,
	["UnitNameFriendlySpecialNPCName"] = 0,
	["UnitNameInteractiveNPC"] = 0,
	["UnitNameEnemyPlayerName"] = 0,
	["UnitNameEnemyPetName"] = 0,
	["UnitNameEnemyGuardianName"] = 0,
	["UnitNameNPC"] = 0,
	["UnitNameInteractiveNPC"] = 0,
	["UnitNameHostleNPC"] = 0,
	["chatBubbles"] = 0,
	["floatingCombatTextCombatDamage"] = 0,
	["floatingCombatTextCombatHealing"] = 0,
};

local function PhotoMode_BackupCvar(BackupTable, OriginalTable)
	if OriginalTable then
		for k, v in pairs(OriginalTable) do
			BackupTable[k] = GetCVar(k) or 0;
		end
	end
end

local function PhotoMode_RestoreCvar(BackupTable) --it can also be used to set CVars to pre-defined values
	if BackupTable then
		for k, v in pairs(BackupTable) do
			SetCVar(k, v)
			--print(k.." "..v)
		end
	end
end

local function PhotoMode_ZeroCvar(BackupTable)
	if BackupTable then
		for k, v in pairs(BackupTable) do
			SetCVar(k, 0)
		end
	end	
end

local function PhotoMode_GetTrackingInfo(id)
	local id = 1;
	local _, _, active = GetTrackingInfo(id)
	PhotoMode_Cvar_TrackingBAK = active;
end

local ControllerButtonTooltip = {
    -- [ Name ] = { HeadLine, Line, Special, Guide Pic Index } 
	["Narci_PhotoModeButton"] = {
		L["Photo Mode"],
		L["Photo Mode Tooltip Open"],
		L["Photo Mode Tooltip Special"],
	},

	["Narci_XmogButton"] = {
		L["Xmog Button"],
		L["Xmog Button Tooltip Open"],
		L["Xmog Button Tooltip Special"],
	},

	["Narci_EmoteButton"] = {
		L["Emote Button"],
		L["Emote Button Tooltip Open"],
		L["Emote Button Tooltip Special"],
	},

	["Narci_HideTextsButton"] = {
		L["HideTexts Button"],
		L["HideTexts Button Tooltip Open"],
		L["HideTexts Button Tooltip Special"],
		1,
	},

	["Narci_TopQualityButton"] = {
		L["TopQuality Button"],
		L["TopQuality Button Tooltip Open"],
		L["HideTexts Button Tooltip Special"],
		2,
	},
}

function ControllerButtonTemplate_OnLoad(self)
	self.IsOn = false;
	local name = self:GetName();

	if ControllerButtonTooltip[name] then
		if ControllerButtonTooltip[name][3] then	--special notes
			self.tooltip = {ControllerButtonTooltip[name][1], ControllerButtonTooltip[name][2] .. "\n|cff6b6b6b".. ControllerButtonTooltip[name][3]};	--42% Grey
		else
			self.tooltip = {ControllerButtonTooltip[name][1], ControllerButtonTooltip[name][2]};
		end

		if ControllerButtonTooltip[name][4] then
			self.GuideIndex = ControllerButtonTooltip[name][4];
		end
	end

	if self.Pushed and self.Icon then
		self.Pushed:SetTexture(self.Icon:GetTexture())
	end
end

local function TemporarilyHidePopUp(frame)
	if frame:IsShown() then
		frame.AnimFrame:Hide();
		frame.AnimFrame.OppoDirection = true		
		frame.AnimFrame:Show();
		frame.AnimFrame.EndPointY = -20;
	end
end

--[[
function Narci_ShowXmogSlot()
	local scale = Narci_Finger0Slot:GetEffectiveScale()
	--Narci_GuideLineFrame.VirtualLineRight:SetPoint("RIGHT", -10, 0);
	local VirtualLineRight = Narci_VirtualLineRight;
	local _, _, _, offsetX= VirtualLineRight:GetPoint();
	VirtualLineRight.AnimFrame.StartPoint = offsetX -- -10;
	VirtualLineRight.AnimFrame.EndPoint = -80 - scale*Narci_Finger0Slot:GetWidth()/2;

	FadeFrame(Narci_Character, 0.6, "Forced_IN")
	VirtualLineRight.AnimFrame:Show();
	VirtualLineRight.AnimFrame:Show();
end
--]]

function XmogButtonPopUp_OnShow(self)
	SetWidgetColor(self.Color);
	SetWidgetColor(self.Option);
end

function XmogButtonPopUp_OnLoad(self)
	self.CopyButton.Label:SetText(NARCI_COPY_TEXTS)
	self.ModeButton.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
	self.ModeButton.Label:SetText(NARCI_LAYOUT)
	self.ModeButton.Option:SetText(NARCI_LAYOUT_SYMMETRY)
	self.ModelToggle.Label:SetText(NARCI_3DMODEL)
	SetWidgetColor(self.ModeButton.Option)

	local SyntaxButton = self.CopyButton.GearTexts
	SyntaxButton.PlainText.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
	SyntaxButton.BBSCode.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
	SyntaxButton.Markdown.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
	SyntaxButton.PlainText.Label:SetText(NARCI_SYNTAX_PLAIN_TEXT)
	SyntaxButton.BBSCode.Label:SetText(NARCI_SYNTAX_BBCODE)
	SyntaxButton.Markdown.Label:SetText(NARCI_SYNTAX_MARKDOWN)

end

local function HidePlayerModel()
	if (not Narci_ModelContainer:IsVisible()) or (NarcissusDB.AlwaysShowModel) then	return; end
	PlayerModelAnimOut:Show()
	After(0.4, function()
		FadeFrame(NarciPlayerModelFrame1, 0.5 , "OUT")
	end)
end

local function UseXmogLayout(index)
	if index == 1 then
		xmogMode = 1;
		NarciPlayerModelFrame1.xmogMode = 1;
		Narci_XmogButtonPopUp_ModeButton.Option:SetText(NARCI_LAYOUT_SYMMETRY)
		SP:Show()
		HidePlayerModel()
		Smooth_Shoulder.EndPoint = 0.01;
		Smooth_Shoulder:Show()
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = -80;
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
		Smooth_ShoulderCVar(0.01)
		Narci_XmogButtonPopUp_ModeButton.ShowModel = false;

		if NarcissusDB.AlwaysShowModel then
			NarciModel_RightGradient:Hide();
			ModelVignetteRightSmall:Hide();
			if not NarciPlayerModelFrame1:IsVisible() then
				Narci_PlayerModelAnimIn:Show()
			end
		end
	elseif index == 2 then
		xmogMode = 2;
		MogMode_Offset = 0.2;
		NarciPlayerModelFrame1.xmogMode = 2;
		FadeFrame(NarciModel_RightGradient, 0.5, "IN")
		Narci_XmogButtonPopUp_ModeButton.Option:SetText(NARCI_LAYOUT_ASYMMETRY)
		if not NarciPlayerModelFrame1:IsVisible() then
			Narci_PlayerModelAnimIn:Show()
		end
		ModelVignetteRightSmall:Show();
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = -600
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
		Narci_XmogButtonPopUp_ModeButton.ShowModel = true;
		After(0, function()
			if not IsMounted() then
				SmoothPitchContainer:Show()
				Narci:CameraZoomIn(ZoomInValue_XmogMode)	--ajust by raceID
			else
				Narci:CameraZoomIn(8)	--ajust by raceID
			end
		end)
	end
end

local function PlayCheckSound(self, state)
	if not self.EnableSFX then return;
	elseif state then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

local function ActiveXmogMode()
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Hide();

	if TransmogMode then
		FadeFrame(Narci_Attribute, 0.5, "OUT")
		FadeFrame(Narci_XmogNameFrame, 0.2, "IN")
		local DefaultLayout = NarcissusDB.DefaultLayout;
		if DefaultLayout == 1 then
			xmogMode = 1;
		elseif DefaultLayout == 2 then
			xmogMode = 2;
			MogMode_Offset = 0.2;
		elseif DefaultLayout == 3 then
			xmogMode = 2;
			MogMode_Offset = 0.2;
		end

		UseXmogLayout(xmogMode);
		--print(xmogMode)
		NarciPlayerModelFrame1.xmogMode = xmogMode;
	else
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPointBAK
		if Narci_PhotoModeController:IsShown() then
			Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
			FadeFrame(Narci_Attribute, 0.5, "IN")
			local Zoom = GetCameraZoom()
			Smooth_ShoulderCVar(Shoulder_Factor1*Zoom + Shoulder_Factor2)
		end
		FadeFrame(Narci_XmogNameFrame, 0.2, "OUT")
		ShowAttributeButton(true);
		xmogMode = 0;
		MogMode_Offset = 0;
		NarciPlayerModelFrame1.xmogMode = 0;
	end
end

function XmogButton_OnClick(self)
	self.IsOn = not self.IsOn
	MoveViewRightStop();
	Narci_EquipmentFlyoutFrame:Hide();
	TransmogMode = not TransmogMode;
	local PopUp = Narci_XmogButtonPopUp;
	if not self.IsOn then
		--Exit Xmog mode
		FadeFrame(VignetteRightSmall, 0.5, "OUT");
		UIFrameFadeIn(VignetteRightLarge, 0.5, VignetteRightLarge:GetAlpha(), NarcissusDB.VignetteStrength);
		Narci_SnowEffect(true);
		Narci_LetterboxAnimation();
		PlayCheckSound(self, false)
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		if NarcissusDB.EnableGrainEffect then
			FadeFrame(FullScreenFilterGrain, 0.5, "IN");
			FadeFrame(FullScreenFilterGrain2, 0.5, "IN");
		end
		PopUp.AnimFrame:Hide();
		PopUp.AnimFrame.OppoDirection = true
		PopUp.AnimFrame:Show();
		PopUp.AnimFrame.EndPointY = -20;
		if Narci_ModelContainer:IsVisible() then
			if OpenViaClick then
				SmoothPitchContainer:Show()
			else
				Smooth_ShoulderCVar(0)
			end
			PlayerModelAnimOut:Show()
			After(0.4, function()
				FadeFrame(NarciPlayerModelFrame1, 0.5 , "OUT")
			end)
		end
		Narci_ModelSettings:Hide();
		self.tooltip = {L["Xmog Button"], L["Xmog Button Tooltip Open"] .. "\n|cff6b6b6b"..L["Xmog Button Tooltip Special"]};

		if not Narci_ExitConfirmationDialog:IsShown() then
			Narci.showExitConfirm = false;
		end
	else
		UIFrameFadeIn(VignetteRightSmall, 0.5, VignetteRightSmall:GetAlpha(), NarcissusDB.VignetteStrength);
		FadeFrame(VignetteRightLarge, 0.5, "OUT");
		FadeFrame(FullScreenFilterGrain, 0.5, "OUT");
		FadeFrame(FullScreenFilterGrain2, 0.5, "OUT");
		Narci_SnowEffect(false);
		Narci_LetterboxAnimation("OUT");
		PlayCheckSound(self, true)
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		PopUp:Show();
		PopUp.AnimFrame:Hide();
		PopUp.AnimFrame.OppoDirection = false		
		PopUp.AnimFrame:Show();
		PopUp.AnimFrame.EndPointY = 8;
		Narci_XmogNameFrame.PlayerName:SetText(PlayerInfoFrame.PlayerName:GetText())
		self.tooltip = {L["Xmog Button"], L["Xmog Button Tooltip Close"]};
	end
	
	RefreshAllSlot();
	After(0.1, function()
		ActiveXmogMode();
	end)

	NarciTooltip:FadeOut();

	TemporarilyHidePopUp(EmoteButtonPopUp)
end

function XmogName_OnLoad()
	local Frame = Narci_XmogNameFrame;
	Narci_SetPlayerName(Frame)
	local currentSpec = GetSpecialization()
	if not currentSpec then
	   return;
	end
	
	local _, currentSpecName = GetSpecializationInfo(currentSpec);
	currentSpecName = currentSpecName or " ";

	local className, englishClass, _ = UnitClass("player");
	local _, _, _, rgbHex = GetClassColor(englishClass);

	local ArmorType;
	local Token = 159243;

	if IsSpellKnown(76273) or IsSpellKnown(106904) or IsSpellKnown(202782) or IsSpellKnown(76275) then
		--ArmorType = "Leather"
		Token = 159300
	elseif IsSpellKnown(76250) or IsSpellKnown(76272) then
		--ArmorType = "Mail"
		Token = 159371
	elseif IsSpellKnown(76276) or IsSpellKnown(76277) or IsSpellKnown(76279) then
		--ArmorType = "Cloth"
		Token = 159243
	elseif IsSpellKnown(76271) or IsSpellKnown(76282) or IsSpellKnown(76268) then
		--ArmorType = "Plate"
		Token = 159418
	end

	local _, _, ArmorType = GetItemInfoInstant(Token)
	--Leather 76273		Mail 76250		Cloth 76276	76279	Plate 76271 76282
	ArmorType = ArmorType or "ArmorType"
	Frame.Miscellaneous:SetText("|cFFFFD100"..ArmorType.."|r".."  |  ".."|c"..rgbHex..currentSpecName.." "..className.."|r");
end

function GetWowHeadDressingRoomURL()
	local slot;
	local ItemList = {};
	for i=1, #xmogTable do
		slot = xmogTable[i][1];
		if slotTable[slot] and slotTable[slot].itemID then
			ItemList[slot] = {slotTable[slot].itemID, slotTable[slot].bonusID};
		end
	end
	return NarciBridge_EncodeItemlist(ItemList);
end

local function CopyTexts(type, subType)
	local texts = Narci_XmogNameFrame.PlayerName:GetText() or "My Transmog";
	local type = type or "TEXT"
	local subType = subType or "Wowhead"
	local showItemID = Narci_XmogButtonPopUp.CopyButton.showItemID or false;
	local source;
	if type == "TEXT" then
		texts = texts.."\n"
		for i=1, #xmogTable do
			local index =  xmogTable[i][1]
			if slotTable[index] and slotTable[index].Name:GetText() then
				local text = "|cFFFFD100"..xmogTable[i][2]..":|r "..(slotTable[index].Name:GetText() or " ")

				if showItemID and slotTable[index].itemID then
					text = text.." |cFFacacac"..slotTable[index].itemID.."|r";
				end
				
				source = slotTable[index].ItemLevel:GetText()
				if source ~= " " then
				text = text.." |cFF40C7EB("..source..")|r"
				end
				if text then
					texts = texts.."\n"..text;
				end
			end
		end

	elseif type == "BBS" then
		if subType == "Wowhead" then
			texts = "|cFF959595[table border=2 cellpadding=4]\n[tr][td colspan=3 align=center][b]|r"..texts.."|r|cFF959595[/b][/td][/tr]\n[tr][td align=center]Slot[/td][td align=center]Name[/td][td align=center]Source[/td][/tr]|r"
		elseif subType == "NGA" then
			texts = "|cFF959595[table]\n[tr][td colspan=3][align=center][b]|r"..texts.."|r|cFF959595[/b][/align][/td][/tr]\n[tr][td][align=center]部位[/align][/td][td][align=center]装备名称[/align][/td][td][align=center]来源[/align][/td][/tr]|r"
		elseif subType == "mmo-champion" then
			texts =	"|cFF959595[table=\"width: 640, class: grid\"]\n[tr][td=\"colspan: 3\"][center][b]|r"..texts.."|r|cFF959595[/b][/center][/td][/tr]\n[tr][td][center]Slot[/center][/td][td][center]Name[/center][/td][td][center]Source[/center][/td][/tr]|r"
		end

		
		for i=1, #xmogTable do
			local index =  xmogTable[i][1]
			if slotTable[index] and slotTable[index].Name:GetText() then
				local text = "|cFF959595[tr][td]|r".."|cFFFFD100"..xmogTable[i][2].."|r|cFF959595[/td][td]|r"
				if showItemID and slotTable[index].itemID then
					if subType == "Wowhead" then
						text = text.."[item="..slotTable[index].itemID.."|r|cFF959595][/td]|r"
					elseif subType == "NGA" then
						text = text.."|cFF959595[url=https://www.wowhead.com/item="..slotTable[index].itemID.."]|r"..(slotTable[index].Name:GetText() or " ").."|cFF959595[/url][/td]|r"
					elseif subType == "mmo-champion" then
						text = text.."|cFF959595[url=https://www.wowdb.com/items/"..slotTable[index].itemID.."]|r"..(slotTable[index].Name:GetText() or " ").."|cFF959595[/url][/td]|r"
					end
				else
					text = text..(slotTable[index].Name:GetText() or " ").."|r|cFF959595[/td]|r"
				end
				source = slotTable[index].ItemLevel:GetText()
				if source then
					text = text.."|cFF959595[td]|r|cFF40C7EB"..source.."|r|cFF959595[/td]|r"
				else
					text = text.."|cFF959595[td] [/td]|r"
				end
				if text then
					texts = texts.."\n"..text.."|cFF959595[/tr]|r";
				end
			end
		end
		texts = texts.."\n|cFF959595[/table]|r"


		-----
		if subType == "Wowhead" then
			texts = GetWowHeadDressingRoomURL()
		end
	elseif type == "MARKDOWN" then	
		texts = "|cFF959595**|r"..texts.."|cFF959595**\n\n| Slot | Name | Source |".."\n".."|:--|:--|:--|"
		for i=1, #xmogTable do
			local index =  xmogTable[i][1]
			if slotTable[index] and slotTable[index].Name:GetText() then
				local text = "|cFF959595| |r|cFFFFD100"..xmogTable[i][2].."|r |cFF959595| |r"
				if	showItemID and slotTable[index].itemID then
					text = text.."|cFF959595[|r"..(slotTable[index].Name:GetText() or " ").."|cFF959595](https://www.wowhead.com/item=|r"..slotTable[index].itemID..")|r"
				else
					text = text..(slotTable[index].Name:GetText() or " ")
				end
				source = slotTable[index].ItemLevel:GetText()
				if source then
				text = text.." |cFF959595| |r|cFF40C7EB"..source.."|r |cFF959595| |r"
				else
					text = text.." |cFF959595| |r"
				end
				if text then
					texts = texts.."\n"..text;
				end
			end
		end
		texts = texts.."\n"
	end
	return texts;
end

local WebsiteTable = {
	[0] = {"reddit", "Interface/AddOns/Narcissus/Art/Logos/reddit"},
	[1] = {"Wowhead", "Interface/AddOns/Narcissus/Art/Logos/Wowhead"},
	[2] = {"NGA", "Interface/AddOns/Narcissus/Art/Logos/NGA"},
	[3] = {"mmo-champion", "Interface/AddOns/Narcissus/Art/Logos/mmo-champion"},
	--[4] = {"Vanion", "Interface/AddOns/Narcissus/Art/Logos/Vanion"},
}

function WebsiteButton_OnLoad(self)
	local index = self:GetID() or 2;
	if WebsiteTable[index] then
		self.NormalTex:SetTexture(WebsiteTable[index][2]);
		self.PushedTex:SetTexture(WebsiteTable[index][2]);
		if not self:GetParent().buttons then
			self:GetParent().buttons = {};
		end
		tinsert(self:GetParent().buttons, self);
	else
		self:Hide()
	end
end

local function WebsiteButton_DesatureLogo(self)
	local parent = self:GetParent();
	if parent.buttons then
		for i=1, #parent.buttons do
			parent.buttons[i].NormalTex:SetTexCoord(0, 0.5, 0, 1);
			parent.buttons[i].PushedTex:SetTexCoord(0, 0.5, 0, 1);
			parent.buttons[i].IsOn = false;
		end
	end
end

function WebsiteButton_OnClick(self)
	WebsiteButton_DesatureLogo(self)
	self.NormalTex:SetTexCoord(0.5, 1, 0, 1);
	self.PushedTex:SetTexCoord(0.5, 1, 0, 1);
	self.IsOn = true;
	self:GetParent().subType = WebsiteTable[self:GetID()][1];
	self:GetParent():Click();
end

local function SetClipboard(self, type, subType)
	local frame = self or Narci_XmogButtonPopUp.CopyButton;
	local type = type or frame.CodeType or "TEXT";
	local subType = subType or frame.GearTexts.BBSCode.subType or "Wowhead";
	local texts = CopyTexts(type, subType);
	frame.GearTexts:SetText(texts);

	if frame.GearTexts then
		frame.GearTexts:SetFocus();
		frame.GearTexts:HighlightText();
	end
end

local CodeTokenList = {
	[1] = "TEXT",	[2] = "BBS", [3] = "MARKDOWN",
}

function Narci_CodeTokenButton_OnClick(self)
	self:GetParent():GetParent().CodeType = CodeTokenList[self:GetID()];
	SetClipboard();
	TokenButton_ClearMarker(self);
	self.HighlightColor:Show();
	self.AnimFrame.Anim:SetScale(1.8);
	self.AnimFrame.Anim.Bling:Play();
end

function IncludeIDButton_OnClick(self)
	self.IsOn = not self.IsOn
	if self.IsOn then
		self.Tick:Show();
		Narci_XmogButtonPopUp.CopyButton.showItemID = true;
	else
		self.Tick:Hide();
		Narci_XmogButtonPopUp.CopyButton.showItemID = false;
	end
	SetClipboard()
end

function CopyButton_OnClick(self)
	self.IsOn = not self.IsOn;
	if self.IsOn then
		SetClipboard(self);
		FadeFrame(self.GearTexts, 0.25, "IN");
	else
		FadeFrame(self.GearTexts, 0.25, "OUT");
	end

	self.AnimFrame.Anim:SetScale(1.5);
	self.AnimFrame.Anim.Bling:Play();
end

--Narci_EmoteButton
local EmoteTokenList = {
	[1] = {{"Talk", EMOTE94_CMD1},	{"TALKEX", EMOTE95_CMD1} , {"TALKQ", EMOTE96_CMD2} , {"Flee", YELL} },
	[2] = {{"Kiss", EMOTE59_CMD1}, {"Salute", EMOTE79_CMD1}	, {"Bye", EMOTE102_CMD1}, {"Bow", EMOTE17_CMD1} },
	[3] = {{"Dance", EMOTE35_CMD1}, {"Read", EMOTE453_CMD2}, {"Train", EMOTE155_CMD1}, {"Chicken", EMOTE22_CMD1} },
	[4] = {{"Clap", EMOTE24_CMD1}, {"Cheer", EMOTE21_CMD1}, {"Cackle", EMOTE61_CMD1} },
	[5] = {{"Nod", EMOTE68_CMD1}, {"Doubt", EMOTE67_CMD1}, {"Point", EMOTE73_CMD1} },
	[6] = {{"Rude", EMOTE78_CMD1}, {"Flex", EMOTE42_CMD1}, {"ROAR", EMOTE76_CMD1}},
	[7] = {{"Cower", EMOTE29_CMD1}, {"Beg", EMOTE8_CMD1}, {"Cry", EMOTE32_CMD1}},
	[8] = {{"Laydown", EMOTE62_CMD1}, {"Stand", EMOTE143_CMD1}, {"Sit", EMOTE87_CMD1}, {"Kneel", EMOTE60_CMD1}},
}

local function EmoteButton_CreateList(self, buttonTemplate, List)
	local ltrim = string.trim;
	local PopUp = self;
	local button, buttonWidth, buttonHeight, buttons, numButtons;

	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;

	local initialPoint = "TOPLEFT";
	local initialRelative = "TOPLEFT";
	local point = "TOPLEFT";
	local relativePoint = "TOPRIGHT";
	local offsetX = 0;

	buttons = {}

	local subListNum, subListNum_Max = 1, 1

	if List and List[1] then
		for i = 1, #List do
			subListNum = #List[i]
			subListNum_Max = math.max(subListNum, subListNum_Max);
		end
	end
	--print("subListNum_Max: "..subListNum_Max)
	for i=1, #List do
		--print(i.." Total: "..#List[i])
		for j=1, subListNum_Max do
			
			button = CreateFrame("Button", buttonName and (buttonName ..(i+j-1) ) or nil, PopUp, buttonTemplate);

			if List[i][j] then
				local text = ltrim(List[i][j][2],"/"); 									--remove the slash
				if LanguageDetector(text) == "RM" then
					text = strupper(string.sub(text, 1, 1)) .. string.sub(text, 2)		--upper initial
				end
				button.Label:SetText(text)
				button.Token = List[i][j][1]
			else
				button.Label:SetText(" ")
				button.Token = nil
				button:Disable();
			end

			if i % 2 == 0 then
				button.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
			end
			buttonWidth = button:GetWidth();
			buttonHeight = button:GetHeight();

			local offsetY = (1-i)*buttonHeight
			if not buttons then
				button:SetPoint(initialPoint, PopUp, initialRelative, 0, offsetY);
			elseif j == 1 then
				button:SetPoint(initialPoint, PopUp, initialRelative, 0, offsetY);
			else
				local index = #buttons
				button:SetPoint(point, buttons[index], relativePoint, 0, 0);
			end
			tinsert(buttons, button);
		end
	end

	self.buttons = buttons;

	local PopUpHeight = #List * buttonHeight
	local PopUpWidth = 4 * buttonWidth
	PopUp:SetHeight(PopUpHeight)
	PopUp:SetWidth(PopUpWidth)
end

function EmoteButtonPopUp_OnLoad(self) 
	EmoteButton_CreateList(self, "NarciEmoteTokenButtonTemplate", EmoteTokenList)
	self.autoCapture = false;
end

function Narci_EmoteButton_OnClick(self)
	self.IsOn = not self.IsOn
	if not self.IsOn then
		PlayCheckSound(self, false)
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		self.UpdateFrame:Hide();

		EmoteButtonPopUp.AnimFrame:Hide();
		EmoteButtonPopUp.AnimFrame:Show();
		EmoteButtonPopUp.AnimFrame.EndPointY = -40;
	else
		PlayCheckSound(self, true)
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		--self.UpdateFrame.Emote = "cry";
		--self.UpdateFrame.duration = 3.5;
		--self.UpdateFrame:Show();
		EmoteButtonPopUp:Show();

		EmoteButtonPopUp.AnimFrame:Hide();
		EmoteButtonPopUp.AnimFrame:Show();
		EmoteButtonPopUp.AnimFrame.EndPointY = 8;
	end

	NarciTooltip:FadeOut();

	if Narci_XmogButton.IsOn then
		Narci_XmogButtonPopUp.AnimFrame:Hide();
		Narci_XmogButtonPopUp.AnimFrame:Show();
		Narci_XmogButtonPopUp.AnimFrame.EndPointY = -20;
	end
end

function EmoteButtonPopUp_AnimFrame_OnUpdate(self, elapsed)
	local duration = 0.35;
	local EndPoint = self.EndPointY
	local StartPoint = self.StartPointY
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, StartPoint, EndPoint - StartPoint , duration)
	frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, offSet);
	if not self.OppoDirection then
		frame:SetAlpha(2*t/duration);
	else
		frame:SetAlpha(1 - 1.5*t/duration);
	end

	if t >= duration then
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, EndPoint);
		if not self.OppoDirection then
			frame:SetAlpha(1)
			frame:Show()
		else
			frame:SetAlpha(0)
			frame:Hide()
		end

		self:Hide()
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function EmoteButton_UpdateFrame_OnShow(self)
	self.TimeSinceLastUpdate = 0;
	self.duration = self.duration or 0;
	
	DoEmote(self.Emote, "none");

	if self.duration == 0 then
		self:Hide();
	end

	if EmoteButtonPopUp.autoCapture then
		After(0.8, function()
			Screenshot()
		end)
	end
end

function EmoteButton_UpdateFrame_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if self.TimeSinceLastUpdate >=	self.duration then
		DoEmote(self.Emote, "none");
		self.TimeSinceLastUpdate = 0;
		--print("end")
	end
end

function AutoCaptureButton_OnClick(self)
	self.IsOn = not self.IsOn
	if self.IsOn then
		self.Tick:Show();
		self:GetParent().autoCapture = true;
	else
		self.Tick:Hide();
		self:GetParent().autoCapture = false;
	end
end

function Narci_SetButtonColor(self)
	SetWidgetColor(self.Color);
	SetWidgetColor(self.HighlightColor);
end

function Narci_EmoteTokenButton_OnClick(self)
	TokenButton_ClearMarker(self)
	self.HighlightColor:Show()
	Narci_EmoteButton.UpdateFrame.Emote = self.Token;
	if Narci_EmoteButton.IsOn then
		Narci_EmoteButton.UpdateFrame:Hide();
		Narci_EmoteButton.UpdateFrame:Show();
	end

	self.AnimFrame.Anim.Bling:Play();
end

function Narci_HideTextsButton_OnClick(self)
	self.IsOn = not self.IsOn
	NarcissusDB.PhotoModeButton.HideTexts = self.IsOn

	if not self.IsOn then
		PlayCheckSound(self, false)
		PhotoMode_RestoreCvar(PhotoMode_Cvar_NamesBackup);
		SetTracking(1, PhotoMode_Cvar_TrackingBAK);		--Track Battle Pet
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		self.tooltip = {L["HideTexts Button"], L["HideTexts Button Tooltip Open"] .. "\n|cff6b6b6b"..L["HideTexts Button Tooltip Special"]};
	else
		PlayCheckSound(self, true)

		PhotoMode_BackupCvar(PhotoMode_Cvar_NamesBackup, PhotoMode_Cvar_NamesList);
		PhotoMode_ZeroCvar(PhotoMode_Cvar_NamesBackup);
		PhotoMode_GetTrackingInfo();
		SetTracking(1, false);
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		self.tooltip = {L["HideTexts Button"], L["HideTexts Button Tooltip Close"] .. "\n|cff6b6b6b"..L["HideTexts Button Tooltip Special"]};
	end

	NarciTooltip:FadeOut();
end

function TopQualityButton_OnClick(self)
	self.IsOn = not self.IsOn
	if not self.IsOn then
		PlayCheckSound(self, false)
		PhotoMode_RestoreCvar(PhotoMode_Cvar_GraphicsBackup);
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		FadeFrame(TopQualityButton_MSAASlider, 0.25, "OUT");
		self.tooltip = {L["TopQuality Button"], L["TopQuality Button Tooltip Open"] .. "\n|cff6b6b6b"..L["HideTexts Button Tooltip Special"]};
	else
		PlayCheckSound(self, true)
		PhotoMode_BackupCvar(PhotoMode_Cvar_GraphicsBackup, PhotoMode_Cvar_GraphicsList);
		PhotoMode_RestoreCvar(PhotoMode_Cvar_GraphicsList);
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		FadeFrame(TopQualityButton_MSAASlider, 0.25, "IN");
		self.tooltip = {L["TopQuality Button"], L["TopQuality Button Tooltip Close"] .. "\n|cff6b6b6b"..L["HideTexts Button Tooltip Special"]};
	end

	NarciTooltip:FadeOut();
end

function TopQualityButton_MSAASlider_OnValueChanged(self, value, userInput)
	if not self:IsShown() then
		return;
	end
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		local value, valueText = tonumber(value), "";
		if value ~= 0 then
			if value == 1 then
				valueText = "2x";
			elseif value == 2 then
				valueText = "4x";
			elseif value == 3 then
				valueText = "8x";
			end
			valueText = "|cfffced00"..valueText;
		else
			valueText = "|cffee3224"..OFF;
		end
		self.KeyLabel2:SetText(MULTISAMPLE_ANTI_ALIASING.." "..valueText)
		if value ~=0 then
			ConsoleExec("MSAAQuality "..value..",0" )
		else
			ConsoleExec("MSAAQuality 0")
		end
	end
end

function Narci_Vignette_OnFinished()
	local GuideLineFrame = Narci_GuideLineFrame;
	local VirtualLineRight = GuideLineFrame.VirtualLineRight;
	GuideLineFrame.VirtualLineLeft:SetPoint("LEFT", 0, 0);
	local _, _, _, offsetX = VirtualLineRight:GetPoint();
	if TransmogMode then
		--VirtualLineRight:SetPoint("RIGHT", -15, 0);
		--VirtualLineRight.AnimFrame.StartPoint = -15
		VirtualLineRight.AnimFrame.StartPoint = offsetX;
		FadeFrame(Narci_Attribute, 0.4, "OUT")
	else
		
		--VirtualLineRight.AnimFrame.StartPoint = offsetX -- -10;
		VirtualLineRight.AnimFrame.StartPoint = offsetX
		VirtualLineRight.AnimFrame.EndPoint = GuideLineFrame.VirtualLineRight.AnimFrame.EndPointBAK
		FadeFrame(Narci_Attribute, 0.4, "Forced_IN")
	end
	RefreshAllStats();
	PlayAttributeAnimation();
	FadeFrame(Narci_Character, 0.6, "Forced_IN")
	VirtualLineRight.AnimFrame:Show()
	GuideLineFrame.VirtualLineLeft.AnimFrame:Show()
	After(0.3, function()
		PlayIlvlInfoAnimation()	
	end)
	Narci_SnowEffect(true);
end

----------------------------
local EndWidth = 220;
function PhotoModeController_UpdateFrame_OnUpdate(self, elapsed)
	local radian, offSet;
	local t = self.TimeSinceLastUpdate;
	local IsOn = self:GetParent().Switch.IsOn;

	if IsOn then
		radian = outSine(t, self.StartDegree, 1.25*pi - self.StartDegree, 0.6)
		offSet = outSine(t, self.StartOffSet, EndWidth - self.StartOffSet, 0.6)
	else
		radian = outSine(t, self.StartDegree, 2*pi - self.StartDegree, 0.6)
		offSet = outSine(t, self.StartOffSet, 40 - self.StartOffSet, 0.6)
	end
	self:GetParent().Switch.Ring:SetRotation(radian)
	self:GetParent().Bar:SetWidth(offSet)
	if t >= 0.6 then	--duration_Controller
		if IsOn then
			self:GetParent().Switch.Ring:SetRotation(1.25*pi)
			self:GetParent().Bar:SetWidth(EndWidth)
			PhotoModeControllerBar:SetClipsChildren(false)
		else
			self:GetParent().Switch.Ring:SetRotation(2*pi)
			self:GetParent().Bar:SetWidth(40)
			PhotoModeControllerBar:SetClipsChildren(true)
		end
		self:Hide()
		self.TimeSinceLastUpdate = 0;
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

local duration_FlyIn = 0.4;
function PhotoModeController_AnimFrame_OnUpdate(self, elapsed)
	local duration = duration_FlyIn;
	local EndPoint = self.EndPointY;
	local StartPoint = self.StartPointY;
	local offSet, alpha;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, StartPoint, EndPoint - StartPoint , duration);
	alpha = outSine(t, self.fromAlpha, self.toAlpha - self.fromAlpha , duration);
	frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, offSet);
	frame:SetAlpha(alpha)

	if t >= duration then
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, self.EndPointY);
		if not self.OppoDirection then
			frame:SetAlpha(self.toAlpha);
			frame:Show();
			PhotoModeControllerBar:SetAlpha(1)
		else
			frame:SetAlpha(0);
			frame:Hide();
		end

		self:Hide();
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function PhotoModeController_AnimFrame_OnHide(self)
	self.TimeSinceLastUpdate = 0;
end


local duration_Translation = 0.8;

function LeftLineAnimFrame_OnUpdate(self, elapsed)
	local EndPoint = self.EndPoint;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, EndPoint - 120, 120 , duration_Translation);

	if t >= duration_Translation then
		offSet = EndPoint;
		After(0, function()
			self:Hide();
		end);
	end
	frame:SetPoint(self.AnchorPoint, offSet, 0);
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function RightLineAnimFrame_OnUpdate(self, elapsed)
	local StartPoint = self.StartPoint;
	local EndPoint = self.EndPoint;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, StartPoint, EndPoint - StartPoint, duration_Translation);
	
	if t >= duration_Translation then
		offSet = EndPoint;
		self:Hide();
		After(0, function()
			self:Hide();
		end);
	end
	frame:SetPoint(self.AnchorPoint, offSet, 0);
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function IlvlButtonLeftAnimFrame_OnUpdate(self, elapsed)
	local StartPoint = self.StartPoint;
	local EndPoint = 24;
	local Distance = self.Width + 10;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();

	if not self.OppoDirection then
		offSet = outSine(t, StartPoint, EndPoint - StartPoint , duration_FlyIn);
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= duration_FlyIn then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, EndPoint, 0);
			self:Hide()
			return;
		end
	else
		offSet = outSine(t, StartPoint, Distance - StartPoint, duration_FlyIn);
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= duration_FlyIn then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, Distance, 0);
			self:Hide();
			frame:Hide();
			return;
		end
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function IlvlButtonRightAnimFrame_OnUpdate(self, elapsed)
	local StartPoint = self.StartPoint;
	local EndPoint = -24;
	local Distance = self.Width + 10;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();

	if not self.OppoDirection then	
		offSet = outSine(t, StartPoint , EndPoint - StartPoint, duration_FlyIn)
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= duration_FlyIn then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, EndPoint, 0);
			self:Hide()
			return;
		end
	else
		offSet = outSine(t, StartPoint, -Distance - StartPoint , duration_FlyIn)
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= duration_FlyIn then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, -Distance, 0);
			self:Hide();
			frame:Hide();
			return;
		end
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end
--[[
Set Graphics Settings to Ultra


ffxAntiAliasingMode 2-3
MSAAQuality = not advanced

graphicsTextureResolution 3
graphicsTextureFiltering 6
graphicsProjectedTextures 2

graphicsViewDistance 10
graphicsEnvironmentDetail 10
graphicsGroundClutter 10

graphicsShadowQuality 6
graphicsLiquidDetail 6
graphicsSunshafts 3
graphicsParticleDensity 5
graphicsSSAO 5
graphicsDepthEffects 4
graphicsLightingQuality 3
--]]

------Photo Mode Switch------

function SwitchMode_OnClick(self, key)
	self.IsOn = not self.IsOn;
	self:GetParent().PhotoModeController_UpdateFrame.TimeSinceLastUpdate = 0;
	self:GetParent().PhotoModeController_UpdateFrame:Hide();
	self:GetParent().PhotoModeController_UpdateFrame:Show();
	if self.IsOn then
		self.Icon:SetTexCoord(0.25, 0.5, 0.75, 1);
		PhotoModeControllerBar:SetAlpha(1)
	else
		self.Icon:SetTexCoord(0, 0.25, 0.75, 1);
		PhotoModeControllerBar:SetClipsChildren(true);
	end

	NarciTooltip:FadeOut();
	TemporarilyHidePopUp(Narci_XmogButtonPopUp);
	TemporarilyHidePopUp(EmoteButtonPopUp);
end

function PhotoModeController_Disable()
	if Narci_EmoteButton.IsOn then
		Narci_EmoteButton:Click();
	end

	if Narci_HideTextsButton.IsOn then
		Narci_HideTextsButton:Click();
		NarcissusDB.PhotoModeButton.HideTexts = true
	end

	if Narci_XmogButton.IsOn then
		Narci_XmogButton:Click()		--Quit Xmog Mode
	end
	
	if Narci_TopQualityButton.IsOn then
		Narci_TopQualityButton:Click();
	end
end

function PhotoModeController_OnHide(self)
	PhotoModeController_Disable()
	self:UnregisterEvent("PLAYER_LOGOUT");
end

function PhotoModeController_OnShow(self)
	self:RegisterEvent("PLAYER_LOGOUT");
	self:SetScript("OnEvent",function()
		PhotoModeController_Disable();
		SetCVar("Sound_MusicVolume", CVar_Temp.MusicVolume);
		if CVar_Temp.ActioncamState ~= 1 then		--Restore the acioncam state
			SetCVar("test_cameraDynamicPitch", 0);
			ConsoleExec( "actioncam off");
		end
		ResetView(5);
	end)

	self.PhotoModeController_AnimFrame:Hide()
	self.PhotoModeController_AnimFrame.EndPointY = "10"
	self.PhotoModeController_AnimFrame.OppoDirection = false
	self.PhotoModeController_AnimFrame:Show()

	SetColorThemeBasedOnMapID();
end


hooksecurefunc("SetUIVisibility", function(bool)
	if OpenViaClick then		--when Narcissus hide the UI
		if not bool then
			if NarcissusDB.PhotoModeButton.HideTexts and (not Narci_HideTextsButton.IsOn) then
				Narci_HideTextsButton:Click();
			end
			local frame = Narci_PhotoModeController;
			if not frame:IsShown() then
				frame:Show();
				frame.PhotoModeController_AnimFrame.OppoDirection = false;
			end
		end
	else						--when user hide the UI manually
		if not bool then
			local frame = Narci_PhotoModeController;
			if not frame:IsShown() then
				CVar_Temp.OverShoulder = GetCVar("test_cameraOverShoulder");
			end
			frame.PhotoModeController_AnimFrame.toAlpha = 0;
			frame:Show();
			frame.PhotoModeController_AnimFrame.OppoDirection = false;

			if NarcissusDB.PhotoModeButton.HideTexts and (not Narci_HideTextsButton.IsOn) then
				Narci_HideTextsButton:Click();
			end
			
			Narci_XmogButton:Disable();
		else
			--When player closes the full-screen world map, SetUIVisibility(true) fires twice, and WorldMapFrame:IsShown() returns true and false.
			--Thus, use this VisibilityTracker instead to check if WorldMapFrame has been closed recently.
			--WorldMapFrame.VisibilityTracker.state
			if Narci_Character:IsShown() then return; end
			Smooth_ShoulderCVar(CVar_Temp.OverShoulder);
			if not Narci.keepActionCam then
				After(0.6, function()
					ConsoleExec( "actioncam off" );
				end)
			end
			local frame = Narci_PhotoModeController;
			frame.PhotoModeController_AnimFrame:Hide();
			frame.PhotoModeController_AnimFrame.OppoDirection = true;
			frame.PhotoModeController_AnimFrame.EndPointY = "-80";
			frame.PhotoModeController_AnimFrame:Show();
			CameraOffsetControlBar.Thumb:SetPoint("CENTER", 0, 0);
		end
	end

end)

SLASH_NARCI1 = "/narci"
SLASH_NARCI2 = "/narcissus"
SlashCmdList["NARCI"] = function(Msg)
	local msg = strlower(Msg);
	if msg == "" then
		Narci_MinimapButton:Click();
	elseif msg == "minimap" then
		Narci_MinimapButton:Show();
		NarcissusDB.ShowMinimapButton = true;
		print("Minimap button has been re-enabled.");
	elseif msg == "itemlist" then
		DressUpFrame_Show(DressUpFrame);
	elseif msg == "parser" then
		FadeFrame(Narci_ItemParser, 0.25, "Forced_IN");
	else
		local color = "|cff40C7EB";
		print(color.."Show Minimap Button:|r /narci minimap");
		print(color.."Copy Item List:|r /narci itemlist");
		print(color.."Corruption Item Parser:|r /narci parser");
	end
end

--[[
Global Strings:

SoundKit
54133		UI_70_Artifact_Forge_Toast_TraitAvailable


powerType, powerTypeString = UnitPowerType(UnitId);
local id, name, description, icon, _, primaryStat = GetSpecializationInfo(shownSpec, nil, self.isPet, nil, sex)
SPEC_FRAME_PRIMARY_STAT_AGILITY 
SPEC_FRAME_PRIMARY_STAT_INTELLEC
SPEC_FRAME_PRIMARY_STAT_STRENGTH

STAT_ARMOR
STAT_BLOCK
STAT_PARRY
DODGE_CHANCE

STAT_DODGE
STAT_ENERGY_REGEN
STAT_RUNE_REGEN
STAT_MANA_TOOLTIP
STAT_CRITICAL_STRIKE
STAT_HASTE
STAT_MASTERY
STAT_VERSATILITY

STAT_LIFESTEAL
STAT_AVOIDANCE

ITEM_MOD_MANA_REGENERATION_SHORT
MANA_REGEN_COMBAT

STAT_ENERGY_REGEN = "Energy Regen";
STAT_ENERGY_REGEN_TOOLTIP = "Energy regenerated every second.";
STAT_ENERGY_TOOLTIP = "Maximum energy.  Energy is consumed when using abilities and is restored automatically over time.";

STAT_CHI_TOOLTIP
STAT_DPS_SHORT

STAT_FOCUS_REGEN = "Focus Regen";
STAT_FOCUS_REGEN_TOOLTIP = "Focus regenerated every second.";
STAT_FOCUS_TOOLTIP = "Maximum focus.  Focus is consumed when using abilities and is restored automatically over time.";

PlayerModel

/run NarciPlayerModelFrame1:SetLight(true, false, 1, 1, 1.732, 1, 0.8, 0.8, 0.8, 1, 0.8, 0.8, 0.8)
/run NarciPlayerModelFrame1:SetLight(true, false, -0.2, 1, -1, 1, 0.8, 0.8, 0.8, 1, 1, 0.6, 0.6)
/run NarciPlayerModelFrame1:SetLight(true, false, -0.5, 0.5, -0.5, 0.8, 0.5, 0.5, 0.8, 1, 0.8, 0.8, 0.8)  

/run NarciPlayerModelFrame1:SetLight(true, false, -0.5, 0.5, -0.5, 0.8, 0.7, 0.5, 0.8, 1, 0.8, 0.8, 0.8)
/run NarciPlayerModelFrame1:FreezeAnimation(1)
SetPortraitZoom(0.3)
SetPosition(0,0,-0.06)
NarciPlayerModelFrame1:SetFacing(-.4)
NarciPlayerModelFrame1:SetSequenceTime(68)
/run Narci_PlayerModelAnimIn:Show()
--]]


function Narci_ModelToggle_OnClick(self)
	self:Disable()
	After(1, function()
		self:Enable()
	end)
	self.AnimFrame.Anim:SetScale(1.5)
	self.AnimFrame.Anim.Bling:Play();
	NarcissusDB.AlwaysShowModel = not NarcissusDB.AlwaysShowModel;
	self.IsOn = NarcissusDB.AlwaysShowModel;
	self.Tick:SetShown(self.IsOn);
	Narci_AlwaysShowModelSwitch.Tick:SetShown(self.IsOn);
	if self.IsOn and xmogMode == 1 then
		if not NarciPlayerModelFrame1:IsVisible() then
			if xmogMode == 1 then
				NarciModel_RightGradient:Hide();
			end
			Narci_PlayerModelAnimIn:Show()
		end
	elseif xmogMode ~= 2 then
		HidePlayerModel()
	end

end

function Narci_XmogLayoutButton_OnClick(self)
	self:Disable()
	After(0.8, function()
		self:Enable()
	end)
	
	self.ShowModel = not self.ShowModel;
	if self.ShowModel then
		UseXmogLayout(2)
	else
		UseXmogLayout(1)
	end

	self.AnimFrame.Anim:SetScale(1.5)
	self.AnimFrame.Anim.Bling:Play()
end

local function HideContollerButton(state)
	if state then
		Narci_XmogButton:Hide()
		Narci_EmoteButton:Hide()
		Narci_HideTextsButton:Hide()
		Narci_TopQualityButton:Hide()
	else
		Narci_XmogButton:Show()
		Narci_EmoteButton:Show()
		Narci_HideTextsButton:Show()
		Narci_TopQualityButton:Show()
	end
end

function PhotoMode_WheelEventContrainer_OnMouseWheel(self, delta)
	if Narci_PhotoModeButton.IsOn then
		if CameraOffsetControlBar:IsShown() then
			CameraControlBar_ResetPosition(true)
		end
		TemporarilyHidePopUp(Narci_XmogButtonPopUp);
		TemporarilyHidePopUp(EmoteButtonPopUp);
		AnimationSequenceContainer_Controller:Hide()
		AnimationSequenceContainer_Controller:Show()
	end
end

local function TemporarilyDisableWheel(frame)
	frame:SetScript("OnMouseWheel", function(self, delta)
	end)

	After(0.2, function()
		frame:SetScript("OnMouseWheel", PhotoMode_WheelEventContrainer_OnMouseWheel)
	end)
end

----------------
--3D Animation--
local ASC = CreateFrame("Frame","AnimationSequenceContainer_Controller");
ASC:Hide()
local function InitializeAnimationContainer(frame, SequenceInfo, TargetFrame)
	frame.OppoDirection = false;
	frame.TimeSinceLastUpdate = 0
	frame.TotalTime = 0;
	frame.Index = 1;
	frame.Pending = false;
	frame.IsPlaying = false;	
	frame.SequenceInfo = SequenceInfo;
	frame.Target = TargetFrame
end

local function AnimationContainer_OnHide(self)
	self.TotalTime = 0;
	self.TimeSinceLastUpdate = 0;
	self.OppoDirection = not self.OppoDirection
	if self.Index <= 0 then
		self.Index = 0;
	end
end

local PlayAnimationSequence = NarciAPI_PlayAnimationSequence;

local function Controller_AnimationSequence_OnUpdate(self, elapsed)
	if self.Pending then
		return;
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	self.TotalTime = self.TotalTime + elapsed;
	
	if self.TimeSinceLastUpdate >= 0.01666 then
		self.TimeSinceLastUpdate = 0;
		if self.OppoDirection then
			self.Index = self.Index - 1;
		else
			self.Index = self.Index + 1;
		end

		if not PlayAnimationSequence(self.Index, self.SequenceInfo, self.Target) then
			Narci_PhotoModeButton:SetAlpha(1);
			PhotoModeControllerBar:SetAlpha(1);
			if self.OppoDirection then
				UIFrameFadeOut(PhotoModeControllerTransition.Sequence, 0.2, 1 , 0)
				HideContollerButton(false)
				Narci_PhotoModeButton:SetAlpha(1);
				PhotoModeControllerBar:SetAlpha(1);
				CameraOffsetControlBar:Hide()
				--print("Hide")
			else
				HideContollerButton(true)
				CameraOffsetControlBar:Show()
				CameraOffsetControlBar:SetAlpha(1);
				UIFrameFadeOut(PhotoModeControllerTransition.Sequence, 0.2, 1 , 0)
				After(0.25, function()
					CameraControlBar_ResetPosition(false)
				end)
			end
			TemporarilyDisableWheel(PhotoMode_WheelEventContrainer);
			self:Hide()
			self.IsPlaying = false;
			return;
		end
		--CameraOffsetControlBar:SetAlpha(0);
		Narci_PhotoModeButton:SetAlpha(0);
		PhotoModeControllerBar:SetAlpha(0);
	end
end

ASC:SetScript("OnUpdate", Controller_AnimationSequence_OnUpdate)
ASC:SetScript("OnHide", AnimationContainer_OnHide)
ASC:SetScript("OnShow", function(self)
	self.IsPlaying = true;
end)

local ASC2 = CreateFrame("Frame","AnimationSequenceContainer_Heart");
ASC2.Delay = 5;
ASC2.IsPlaying = false;
ASC2:Hide();

local function Generic_AnimationSequence_OnUpdate(self, elapsed)
	if self.Pending then
		return;
	end

	self.TotalTime = self.TotalTime + elapsed;
	if (not self.OppoDirection and self.TotalTime < self.Delay) and (not self.IsPlaying) then
		return;
	elseif not self.IsPlaying then
		if not self.OppoDirection then		--box closing
			FadeFrame(HeartofAzeroth_AnimFrame, 0.25, "IN")
			After(0.3, function()
				HeartofAzeroth_AnimFrame.Background:SetAlpha(1);
				HeartofAzeroth_AnimFrame.Quote:SetAlpha(1);
				HeartofAzeroth_AnimFrame.SN:SetAlpha(1);
			end)
		end
		self.IsPlaying = true;
	end
	
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if self.TimeSinceLastUpdate >= 0.01666 then
		self.TimeSinceLastUpdate = 0;
		if self.OppoDirection then
			self.Index = self.Index - 1;
		else
			self.Index = self.Index + 1;
		end

		if not PlayAnimationSequence(self.Index, self.SequenceInfo, self.Target) then
			self:Hide()
			self.IsPlaying = false;
			if not self.OppoDirection then
				HeartofAzeroth_AnimFrame.Background:SetAlpha(0);
				HeartofAzeroth_AnimFrame.Quote:SetAlpha(0);
				HeartofAzeroth_AnimFrame.SN:SetAlpha(0);
				FadeFrame(HeartofAzeroth_AnimFrame, 0.25, "OUT")
			end
			return;
		end
	end
end

ASC2:SetScript("OnUpdate", Generic_AnimationSequence_OnUpdate);
ASC2:SetScript("OnHide", AnimationContainer_OnHide);


function CameraControlBar_ResetPosition_AnimFrame_OnShow(self)
	local StartX = CameraOffsetControlBar.PosX or 0;
	local StartAngle = CameraOffsetControlBar.PosRadian or 0;
	self.tOut = math.max(math.abs(StartX) / CameraOffsetControlBar.Range, math.abs(StartAngle)/(2*pi), 0.2)
end

function CameraControlBar_ResetPosition_AnimFrame_OnUpdate(self, elapsed)

	AnimationSequenceContainer_Controller.Pending = true;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local StartX, EndX, StartAngle, EndAngle, t;
	if self.OppoDirection then
		StartX = CameraOffsetControlBar.PosX or 0;
		EndX = 0;
		StartAngle = CameraOffsetControlBar.PosRadian or 0;
		EndAngle = 0;
		t = self.tOut
	else
		StartX = 0;
		EndX = CameraOffsetControlBar.PosX or 0;
		StartAngle = 0;
		EndAngle = CameraOffsetControlBar.PosRadian or 0; --CameraOffsetControlBar.PosRadian or
		t = 0.5
	end

	local Value_Angle = outSine(self.TimeSinceLastUpdate, StartAngle, EndAngle - StartAngle, t)
	local Value_X = outSine(self.TimeSinceLastUpdate, StartX, EndX - StartX, t)
	RotateShaftNode(Value_Angle)
	CameraControllerThumb:SetPoint("CENTER", Value_X, 0);

	if self.TimeSinceLastUpdate >= t then
		RotateShaftNode(EndAngle)
		CameraControllerThumb:SetPoint("CENTER", EndX, 0);
		self:Hide();
		AnimationSequenceContainer_Controller.Pending = false;
		CameraOffsetControlBar.PosRadian = 0;
	end	
end

function CameraControlBar_ResetPosition(bool)
	--print("Last: "..CameraOffsetControlBar.PosRadian)
	if CameraOffsetControlBar:IsShown() and (not AnimationSequenceContainer_Controller.IsPlaying) then
		CameraControlBar_ResetPosition_AnimFrame.OppoDirection = bool
		AnimationSequenceContainer_Controller.Pending = true;
		CameraControlBar_ResetPosition_AnimFrame:Show();
	end
end

local raceList = {	--For 3D Portait on the top-left
  --[RaceID] = {[GenderID] = {offsetX, offsetY, distance, angle, CameraIndex, {animation} }}
	[1]  = {[2] = {10, -10, 0.75, false, 0},	--Human Male √
		    [3] = {12, -10, 0.71, false, 1, 2},	-- 	    Female	 √
		},

	[2]  = {[2] = {12, -16, 1.3, 1.1, 0},	--Orcs Male  √
		    [3] = {18, -16, 0.72, 1.1, 0, 1},	-- 	    Female	 √
		},

	[3]  = {[2] = {14, -20, 0.88, 0.9, 1},	--Dwarf Male
		    [3] = {2, -12, 0.75, false, 0},	-- 	    Female	 √
		},	

	[4]  = {[2] = {16, -5, 1, 1.5, 0},		--NE	Male
		    [3] = {8, -10, 0.75, false, 0},	-- 	    Female
		},	

	[5]  = {[2] = {16, -6, 0.6, 0.8, 1},	--UD 	Male
		    [3] = {10, -6, 0.68, 1.0, 1, 3},	-- 	    Female
		},

	[6]  = {[2] = {24, -15, 3, 0.6, 1},		--Tauren Male	√
		    [3] = {24, -8, 1.8, false, 1},	-- 	     Female
		},	

	[7]  = {[2] = {10, -14, 1, 0.5, 1},			--Gnome Male
		    [3] = {14, -14, 0.8, 0.55, 0},	-- 	    Female
		},

	[8]  = {[2] = {16, -4, 1.15, 1.3, 0},	--Troll Male √
		    [3] = {18, -10, 0.75, 1.3, 0},	-- 	    Female	 √
		},

	[9] = {[2] = {8, 0, 0.8, 0.6, 0},		--Goblin Male 	 √
			[3] = {20, -14, 0.85, 0.8, 0},	-- 	    Female 	 √
		},	

	[10] = {[2] = {8, -5, 0.75, 1.2, 0},		--	BE Male
			[3] = {0, -4, 0.53, 1.1, 0},	-- 	    Female
		},	

	[11] = {[2] = {15, -12, 1, 1.4, 0},		--	Goat Male
			[3] = {10, -10, 0.66, 1.4, 0},	-- 	    Female
		},	

	[22]  = {[2] = {10, -10, 0.75, false, 0},	--Worgen Male Human Form
		    [3] = {12, -12, 0.72, 1.1, 1},		--Female	 √
		},

	[24]  = {[2] = {14, 0, 1.1, 1.15, 0},		--Pandaren Male		√
		    [3] = {12, 4, 1.0, 1.1, 0},			--Female	 
		},

	[27]  = {[2] = {24, -10, 0.72, false, 0},	--Highborne Male		√
		    [3] = {16, -4, 0.70, false, 0},			--Female	 
		},

	[28]  = {[2] = {24, -15, 2.4, 0.6, 0},		--Tauren Male	√
		    [3] = {4, -10, 0.62, false, 0},	-- 	     Female
		},	

	[128]  = {[2] = {18, -18, 1.4, 0.85, 0},	--Worgen Male Wolf Form
		    [3] = {18, -15, 1.1, 1.25, 0},		--Female	 √
		},

	[31]  = {[2] = {4, 0, 1.2, 1.6, 0},		--Zandalari Male √
		    [3] = {18, -12, 0.95, 1.6, 0},		-- 	    Female	 √
		},

	[32]  = {[2] = {10, -16, 1.25, 1.15, 1},	--Kul'tiran Male	√
		    [3] = {12, -10, 0.9, 1.5, 0},			--Female	 
		},

	[36]  = {[2] = {14, -10, 1.2, 1.2, 0, 2},		--Mag'har Male
		    [3] = {20, -20, 0.75, false, 0, 1},		-- 	    Female	 √
		},

	[35]  = {[2] = {18, -8, 0.7, false, 1, 2},		--Vulpera Male
		    [3] = {18, -8, 0.7, false, 1, 2},	-- 	    Female 	 √
		},
}

function PortraitPieces_OnLoad(self)
	local unit = "player";
	local a1, a2, a3;
	local ModelPieces = self.Pieces;
	local _, _, raceID = UnitRace(unit);
	local GenderID = UnitSex(unit);

	--print("raceID: "..raceID)

	if raceID == 34 then	 --DarkIron
		raceID = 3;
	elseif raceID == 29 then --VE
		raceID = 10
	elseif raceID == 28 then --Highmountain
		raceID = 6
	elseif raceID == 30 then --LightForged
		raceID = 11
	elseif raceID == 25 or raceID == 26 then --Pandaren A|H
		raceID = 24
	elseif raceID == 37 then				--Mechagnome
		raceID = 7;
	elseif raceID == 22 then --Worgen
		local _, inAlternateForm = HasAlternateForm();
		if not inAlternateForm	then
			raceID = 128;
		end
	end

	local model;
	if raceList[raceID] and raceList[raceID][GenderID] then
		if FigureModelReference then
			FigureModelReference:SetPoint("CENTER", raceList[raceID][GenderID][1], raceList[raceID][GenderID][2])
		end

		for i = 1, #ModelPieces do
			model = ModelPieces[i];
			model:SetUnit(unit);
			model:SetCamera(raceList[raceID][GenderID][5]);
			model:MakeCurrentCameraCustom();
			if raceList[raceID][GenderID][3] then
				model:SetCameraDistance(raceList[raceID][GenderID][3])
			end
			if raceList[raceID][GenderID][4] then
				a1, a2, a3 = model:GetCameraPosition();
				model:SetCameraPosition(a1, a2, raceList[raceID][GenderID][4])
			end
			if raceList[raceID][GenderID][6] then
				model:SetAnimation(2, raceList[raceID][GenderID][6])
			end
		end
	else
		for i = 1, #ModelPieces do
			model = ModelPieces[i];
			model:SetCamera(0);
			model:MakeCurrentCameraCustom();
			a1, a2, a3 = model:GetCameraPosition();
			model:SetCameraPosition(a1, a2, 1.1);
		end
	end

	for i = 1, #ModelPieces do
		model = ModelPieces[i];
		model:SetFacing(-math.pi/24)	--Front pi/6
		model:SetAnimation(804, 1);	--804
		model:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 0.7, 0.5, 0.8, 1, 0.8, 0.8, 0.8)
		model:UndressSlot(1);
		model:UndressSlot(3);
		model:UndressSlot(16);
		model:UndressSlot(17);
		--model:ApplySpellVisualKit(58897, false);	--Xmas Candy Mouth
		--model:TryOn(80593);	--Xmas Hat 80593 Red 80594 Green
	end
end


ACL:RegisterEvent("ADDON_LOADED");
ACL:RegisterEvent("PLAYER_ENTERING_WORLD");
ACL:RegisterEvent("UNIT_NAME_UPDATE");
ACL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
ACL:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
ACL:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
ACL:RegisterEvent("PLAYER_LEVEL_UP");
ACL:RegisterEvent("LOADING_SCREEN_DISABLED");

--These events might become deprecated in future expansions
ACL:RegisterEvent("AZERITE_ESSENCE_ACTIVATED");
ACL:SetScript("OnEvent",function(self,event,...)
	--print(event)
		
	if event == "ADDON_LOADED" then
		local name = ...;
		if name ~= "Narcissus" then
			return;
		end
		self:UnregisterEvent("ADDON_LOADED");
		AssignFrame();
		Narci_AliasButton_SetState();
		Narci_SetActiveBorderTexture();
		ShowDetailedIlvlInfo();
		Narci:InitializeCameraFactors();
		After(2, function()
			Narci_MinimapButton_OnLoad();
			RefreshAllStats();
			Narci:SetRadarChart(0,0,0,0,1);
			XmogName_OnLoad();
		end)

		local AnimSequenceInfo = Narci.AnimSequenceInfo;
		InitializeAnimationContainer(ASC2, AnimSequenceInfo["Heart"], HeartofAzeroth_AnimFrame.Sequence)
		InitializeAnimationContainer(ASC, AnimSequenceInfo["Controller"], PhotoModeControllerTransition.Sequence)
		local HeartSerialNumber = strsub(UnitGUID("player"), 8, 15);
		HeartofAzeroth_AnimFrame.SN:SetText("No."..HeartSerialNumber)
		
	elseif event == "LOADING_SCREEN_DISABLED" then
		Narci_MinimapButton:Disable();			--Disable minimap button while caching
		After(2, function()
			CacheSourceInfo();
		end)
		After(4, function()
			TransmogMode = true;
			UseDelay = true;
			RefreshAllSlot();					--Cache transmog appearance sources
		end)
		After(7, function()
			TransmogMode = false
			RefreshAllSlot();
			Narci_MinimapButton:Enable();
			Narci_MinimapButton:SetMotionScriptsWhileDisabled(false)
		end)
		self:UnregisterEvent("LOADING_SCREEN_DISABLED");
	elseif event == "PLAYER_ENTERING_WORLD" then
		DefaultTooltip = CreateFrame("GameTooltip", "NarciGameTooltip", nil, "GameTooltipTemplate");
		DefaultTooltip:SetIgnoreParentScale(true);
		DefaultTooltip:SetIgnoreParentAlpha(true);
		CharacterInfoFrame_OnLoad();
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local InventorySlotId, isItem = ...;
		CacheSourceInfo(InventorySlotId)
		UseDelay = false;
		RefreshSlot(InventorySlotId);
		if Narci_EquipmentFlyoutFrame:IsShown() and Narci_EquipmentFlyoutFrame.slotID == InventorySlotId then
			Narci_BuildFlyout(InventorySlotId)
		end
		UseDelay = true;
	elseif event == "AZERITE_ESSENCE_ACTIVATED" then
		RefreshSlot(2);		--Heart of Azeroth
	elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" then
        if not self.isRefreshing then
            self.isRefreshing = true;
            After(0, function()    -- only want 1 update per 0.4s
				SetIlvlBackground();
				After(0.4, function()
					self.isRefreshing = nil;
				end)
            end)
        end
	elseif event == "UNIT_NAME_UPDATE" then
		local UnitID = ...;
		if UnitID == "player" then
			CharacterInfoFrame_OnLoad()
		end

	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		CharacterInfoFrame_OnLoad()

	elseif event == "PLAYER_LEVEL_UP" then
		local NewLevel = ...;
		CharacterInfoFrame_OnLoad(NewLevel)

	elseif ( event == "COMBAT_RATING_UPDATE" or
			 event == "UNIT_MAXPOWER" or
			 event == "UNIT_AURA") and Narci.EnableAutoUpdate then
		-- don't refresh stats when equipment set manager is activated
		RefreshAllStats();
		if event == "COMBAT_RATING_UPDATE" then
			if not self.pauseCorruption then
				self.pauseCorruption = true;
				After(0, function()    -- only want 1 update per 0.4s
					SetCorruptionBackground();
					After(0.4, function()
						self.pauseCorruption = nil;
					end)
				end)
			end

			if Narci_Character:IsShown() then
				SetRadarChart();
			end
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		RefreshStats(9) 		--Damage Reduction
	elseif event == "UNIT_MODEL_CHANGED" then
		local unit = ...;
		if unit == "player" then
			NarciPlayerModelFrame1:Dress()
		end
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
		ModifyCameraForShapeshifter();
		Narci:CameraZoomIn(ZoomInValue);
		--print("Shape shift")
	elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
		ModifyCameraForMounts();
		Narci:CameraZoomIn(ZoomInValue);
	elseif event == "PLAYER_REGEN_DISABLED" then
		Narci_Character:Hide();
		if Narci.isAFK and Narci.isActive then
			--exit when entering combat during AFK mode
			Narci_MinimapButton:Click();
			Narci:PlayVoice("DANGER");
		end
	elseif event == "PLAYER_STARTED_MOVING" then
		self:UnregisterEvent("PLAYER_STARTED_MOVING");
		MoveViewRightStop();
		if Narci.isAFK and Narci.isActive then
			--exit when entering combat during AFK mode
			Narci_MinimapButton:Click();
		end
	elseif event == "PLAYER_STARTED_TURNING" and not TransmogMode then
		NarciAR.Turning.radian = GetPlayerFacing();
		NarciAR.Turning:Show();
	elseif event == "PLAYER_STOPPED_TURNING" and not TransmogMode then
		NarciAR.Turning:Hide();
	end
end)
ACL:SetScript("OnShow",function(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("COMBAT_RATING_UPDATE");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
	self:RegisterEvent("PLAYER_STARTED_MOVING");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterEvent("PLAYER_STARTED_TURNING");
	self:RegisterEvent("PLAYER_STOPPED_TURNING");
	if NarciAR then
		NarciAR:Show();
	end
end)
ACL:SetScript("OnHide",function(self)
	self:UnregisterEvent("COMBAT_RATING_UPDATE");
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("UNIT_AURA");
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:UnregisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
	self:UnregisterEvent("PLAYER_STARTED_MOVING");
	self:UnregisterEvent("PLAYER_REGEN_DISABLED");
	self:UnregisterEvent("UNIT_MAXPOWER");
	self:UnregisterEvent("PLAYER_STARTED_TURNING");
	self:UnregisterEvent("PLAYER_STOPPED_TURNING");
	if NarciAR then
		NarciAR:Hide();
	end
end)

--[[
function Te(a,b,r)
	local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min

	local rX = sin(a)*sin(b)*r
	local rY = -sin(a)*cos(b)*r
	local rZ = -cos(a)*rX

	Test1:SetCameraPosition(rX, rY, rZ)
end
--Te(math.pi/2, math.pi/2, 2)
--Test1:SetCameraDistance() 0.4589388
--/run Test1:SetUnit("player")
/run Test1:SetCamera(1)


function Ce(a)
	local a1, a2, a3 = Test1:GetCameraPosition()
	--print(a1.." "..a2.." "..a3)
	Test1:SetCameraPosition(a1, a2, a)
end

--]]

local function Narci_DoubleClickTrigger_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if self.TimeSinceLastUpdate > 0.25 then
		self:SetScript("OnUpdate", function()
		end);
	end
end

function Narci_DoubleClickTrigger_OnShow(self)
	self.TimeSinceLastUpdate = 0;
	self:SetScript("OnUpdate", Narci_DoubleClickTrigger_OnUpdate);
end

function Narci_DouleClickTrigger_OnHide(self)
	if (self.TimeSinceLastUpdate < 0.25) and NarcissusDB.EnableDoubleTap then
		Narci_MinimapButton:Click();
	end
	self.TimeSinceLastUpdate = 0;
end

function Narci_Bridge_DragStratEvent()
	if Bridge_AzeriteUI_ShowActionBars then
		UIFrameFadeOut(Narci_PhotoModeController, 0.2, Narci_PhotoModeController:GetAlpha(), 0);
		--Bridge_AzeriteUI_ShowActionBars(true);
		--Narci_SharedAnimatedParent.animIn:Play();
		--Narci_SharedAnimatedParent_Anim:Show()
	else
		return;
	end
end

function Narci_Bridge_DragEndEvent()
	if Bridge_AzeriteUI_ShowActionBars then
		--Bridge_AzeriteUI_ShowActionBars(false);
		--Narci_SharedAnimatedParent.animOut:Play();
	else
		return;
	end
end


function Narci_SetActiveBorderTexture()
	local minimapTexture, themeName;
	BorderTexture, minimapTexture, themeName = NarciAPI_GetBorderTexture();
	local MinimapButton = Narci_MinimapButton;
	local minimapBackgroundSize = 42;
	local slot;
	if themeName == "Dark" then
		for i=1, #slotTable do
			slot = slotTable[i];
			if slot then
				RefreshSlot(i);
				slot.RuneSlot.Background:SetAlpha(0);
				slot.Shadow:Show();
				slot.Icon:SetSize(44, 44);
				slot:SetWidth(70);
				slot:SetHeight(72);
			end
		end
	else
		for i=1, #slotTable do
			slot = slotTable[i];
			if slot then
				RefreshSlot(i);
				slot.RuneSlot.Background:SetAlpha(1);
				slot.Shadow:Hide();
				slot.Icon:SetSize(48, 48);
				slot:SetWidth(64);
				slot:SetHeight(64);
			end
		end
	end

	--Optimize this minimap button's radial offset
	if IsAddOnLoaded("AzeriteUI") then
		RadialOffset = 18;
		if MinimapButton:GetParent() == UIParent then
			minimapBackgroundSize = 80;
		end
		minimapTexture = "Interface/AddOns/Narcissus/Art/Minimap/LOGO-Thick";
	elseif IsAddOnLoaded("DiabolicUI") then
		RadialOffset = 12;
	elseif IsAddOnLoaded("GoldieSix") then
		--GoldpawUI
		RadialOffset = 18;
	elseif IsAddOnLoaded("GW2_UI") then
		RadialOffset = 44;
	elseif IsAddOnLoaded("SpartanUI") then
		RadialOffset = 8;
	else
		RadialOffset = 10;
	end

	MinimapButton.Background:SetSize(minimapBackgroundSize, minimapBackgroundSize);	
	MinimapButton.Background:SetTexture(minimapTexture);
	MinimapButton.Color:SetTexture(minimapTexture);
end

function Narci_GuideLineFrame_OnSizing(self, offset)
	local W0, H = WorldFrame:GetSize();
	if not (W0 and H) or H == 0 then return; end;
	local offset = offset or 0;
	local W = math.min(H / 9 * 16, W0);
	W = math.floor(W + 0.5);
	--print("Original: "..W0.." Calculated: "..W);
	self:SetWidth(W - offset);

	local C = W*0.618;

	self.VirtualLineRight:SetPoint("RIGHT", C - W +32, 0);
	self.VirtualLineRight.EndPointBAK = C - W +32;

	local AnimFrame = self.VirtualLineRight.AnimFrame
	AnimFrame.OppoDirection = false;
	AnimFrame.TimeSinceLastUpdate = 0;

	AnimFrame.AnchorPoint, AnimFrame.relativeTo, AnimFrame.relativePoint, AnimFrame.EndPoint, AnimFrame.EndPointY = AnimFrame:GetParent():GetPoint();
	AnimFrame.EndPointBAK = AnimFrame.EndPoint;
end

function Narci:SetReferenceFrameOffset(offset)
	--A positive offset expands the reference frame.
	Narci_GuideLineFrame_OnSizing(Narci_GuideLineFrame, -offset);
end