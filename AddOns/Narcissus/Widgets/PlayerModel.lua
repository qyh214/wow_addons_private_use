local pi = math.pi;
local sin = math.sin;
local FadeFrame = NarciAPI_FadeFrame;
local Screenshot = Screenshot;
local updateThreshold = 2;

-----------------------------------
local defaultZ = -0.275;
local defaultY = 0.4;
local startY = 2;
local endFacing = -pi/8;
--/dump Narci_CharacterModelFrame:GetPosition()
--/run Narci_CharacterModelFrame:SetPortraitZoom()
local function SetTutorialFrame(self, msg)
	local frame = Narci_AlertFrame_Static;
	frame:SetScale(Narci_Character:GetScale())
	frame.Text:SetText(msg);

	frame:SetParent(self)

	frame:SetPoint("BOTTOM", self, "TOP", 0, -4)
	frame:SetHeight(frame.Background:GetHeight());
	frame:SetFrameStrata("TOOLTIP");
	FadeFrame(frame, 0.25, "IN");

	if NarcissusDB and NarcissusDB.Tutorials and NarcissusDB.Tutorials[self.keyValue] then
		NarcissusDB.Tutorials[self.keyValue] = false;
	end
end

local TranslateValue_Male = {
	--[raceID] = {ZoomValue, defaultY, defaultZ},
	[0] = {[1] = {0.05, 0.4, -0.275},		--Default Value
				[2] = {0.05, 0.4, -0.275}},

	[1] = {[1] = {0, 0.43, -0.32},
				[2] = {-0.3, 0.7, -0.26}},		--1 Human √

	[2] = {[1] = {-0.2, 0.6, -0.44},
				[2] = {-0.5, 0.88, -0.386}},		--2 Orc √

	[3] = {[1] = {0.05, 0.2, -0.12},
				[2] = {-0.3, 0.4, -0.03}},		--3 Dwarf √

	[4] = {[1] = {0.1, 0.52, -0.31},
				[2] = {-0.2, 0.8, -0.18}},		--4 NE √

	[5] = {[1] = {0.1, 0.19, -0.2},
				[2] = {-0.3, 0.55, -0.2}},		--5 UD √

	[6] = {[1] = {0, 0.54, -0.1},
				[2] = {-0.3, 0.8, 0}},		--6 Tauren Male √

	[7] = {[1] = {0.05, 0, -0.09},
				[2] = {-0.6, 0.19, -0.175}},		--7 Gnome √

	[8] = {[1] = {-0.2, 0.5, -0.4},
				[2] = {-0.6, 0.76, -0.48}},		--8 Troll √

	[9] = {[1] = {0, 0.13, -0.06},
				[2] = {-0.5, 0.4, -0.123}},		--9 Goblin √

	[10] = {[1] = {0.2, 0.27, -0.25},
				[2] = {-0.3, 0.65, -0.29}},		--10 BloodElf Male √

	[11] = {[1] = {-0.1, 0.84, -0.417},
				[2] = {-0.5, 1.2, -0.48}},		--11 Goat Male √
			
	[24] = {[1] = {0, 0.78, -0.16},
				[2] = {-0.2, 1, -0.15}},		--24 Pandaren Male √

	[27] = {[1] = {0.1, 0.46, -0.35},
				[2] = {-0.3, 0.85, -0.334}},		--27 Nightborne √

	[28] = {[1] = {0.05, 0, -0.09},
				[2] = {-0.6, 0.3, -0.175}},		--28 Tauren Male √

	[31] = {[1] = {0.1, 0.61, -0.4},
				[2] = {-0.3, 1.15, -0.32}},		--31 Zandalari √

	[32] = {[1] = {0.1, 0.55, -0.36},
				[2] = {-0.4, 0.98, -0.46}},	--32 Kul'Tiran √

	[36] = {[1] = {0, 0.87, -0.35},
				[2] = {-0.3, 1.1, -0.38}},		--36 Mag'har √
}

local TranslateValue_Female = {
	--[raceID] = {ZoomValue, defaultY, defaultZ},
	[0] = {[1] = {0.05, 0.4, -0.275},		--Default Value
				[2] = {0.05, 0.4, -0.275}},

	[1] = {[1] = {0.1, 0.27, -0.34},
				[2] = {-0.3, 0.7, -0.26}},		--1 Human √

	[2] = {[1] = {0.1, 0.42, -0.33},
				[2] = {-0.3, 0.7, -0.25}},		--2 Orc √

	[3] = {[1] = {0.0, 0.19, -0.2},
				[2] = {-0.3, 0.4, -0.13}},		--3 Dwarf √

	[4] = {[1] = {0.2, 0.28, -0.28},
				[2] = {-0.3, 0.7, -0.317}},		--4 NE √

	[5] = {[1] = {0.2, 0.3, -0.15},
				[2] = {-0.2, 0.55, -0.09}},		--5 UD √

	[6] = {[1] = {0.1, 0.53, -0.30},
				[2] = {-0.3, 0.85, -0.26}},		--6 Tauren Female √

	[7] = {[1] = {0.05, 0, -0.09},
				[2] = {-0.4, 0.2, -0.1}},		--7 Gnome √

	[8] = {[1] = {0.1, 0.43, -0.3},
				[2] = {-0.4, 0.8, -0.26}},		--8 Troll √

	[9] = {[1] = {0, 0.13, -0.06},
				[2] = {-0.5, 0.35, -0.1653}},		--9 Goblin √

	[10] = {[1] = {0.2, 0.20, -0.25},
				[2] = {-0.3, 0.75, -0.23}},		--10 BloodElf Female √

	[11] = {[1] = {0.2, 0.35, -0.28},
				[2] = {-0.3, 0.85, -0.33}},		--11 Goat Female √
			
	[24] = {[1] = {-0.1, 0.64, -0.34},
				[2] = {-0.4, 1, -0.27}},		--24 Pandaren Female √

	[27] = {[1] = {0.1, 0.45, -0.35},
				[2] = {-0.4, 0.9, -0.378}},		--27 Nightborne √

	[31] = {[1] = {0.2, 0.5, -0.454},
				[2] = {-0.3, 0.95, -0.46}},		--31 Zandalari √

	[32] = {[1] = {0.1, 0.45, -0.36},
				[2] = {-0.5, 0.85, -0.48}},	--32 Kul'Tiran √

	[36] = {[1] = {0.1, 0.42, -0.33},
				[2] = {-0.3, 0.7, -0.25}},		--36 Mag'har √
}

local _, _, raceID = UnitRace("player")
if raceID == 28 then		--Hightmountain
	raceID = 6;
elseif raceID == 30 then	--Lightforged
	raceID = 11;
elseif raceID == 36 then	--Mag'har Orc
	--raceID = 2;
elseif raceID == 34 then	--DarkIron
	raceID = 3;
elseif raceID == 22 then	--Worgen
	raceID = 1;
elseif raceID == 25 or raceID == 26 then --Pandaren A|H
	raceID = 24;
elseif raceID == 28 then
	raceID = 6;
elseif raceID == 29 then
	raceID = 10;
end

local genderID = UnitSex("player"); --2 Male	3 Female
local TranslateValue
if genderID == 2 then
	TranslateValue = TranslateValue_Male[raceID];
else
	TranslateValue = TranslateValue_Female[raceID];
end
-----------------------------------

local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end
local function outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end


function Narci_CharacterModelFrame_OnShow(self)
	if self.xmogMode == 2 then
		self.Color1:Show();
	else
		self.Color1:Hide();
	end
	FadeFrame(Narci_CharacterModelSettings, 0.5, "IN")
end


local function rotateTexture(frame, Degree)
    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Rotation")
	a1:SetDegrees(Degree)
	a1:SetOrigin("CENTER",0 ,0) 
	a1:SetOrder(1)
	a1:SetDuration(0)
	local a2 = ag:CreateAnimation("Rotation")
	a2:SetDegrees(0)
	a2:SetOrigin("CENTER",0 ,0) 
	a2:SetOrder(2)
    a2:SetDuration(1)       
	ag:Play()
	ag:Pause()  
end

function LightButton_UpdateFrame_OnLoad(self)
	self.r = self:GetParent():GetWidth()/2 - 4
	local button = self:GetParent().Thumb
	--button:SetPoint("CENTER", 0, -self.r)
	local radian = self.radian
	local x, y = self.r*math.cos(radian), self.r*math.sin(radian)
	button:SetPoint("CENTER", x, y)
	button.Tex:SetRotation(radian)
	button.Highlight:SetRotation(radian)
	self:GetParent().BeamMask:SetRotation(radian)

	self.lastDegree = math.deg(radian)
end

function LightButton_UpdateFrame_OnUpdate(self)
	local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
	local button = self:GetParent().Thumb
	local radian
	local r = self.r

	local mx, my = self:GetParent():GetCenter()
	local px, py = GetCursorPosition()
	local scale = self:GetParent():GetEffectiveScale()
	px, py = px / scale, py / scale
	radian = math.atan2(py - my, px - mx);
	
	if self.limit then
		if radian >= pi/2 then
			radian = pi/2;
		elseif radian <= -pi/2 then
			radian = -pi/2
		end
		LightInfoSharedFrame.AngleZ = radian;
	else
		LightInfoSharedFrame.AngleXY = radian;
		local FaceLeft = self:GetParent():GetParent().LeftView.FaceLeft;
		local FaceRight = self:GetParent():GetParent().LeftView.FaceRight;
		if FaceLeft and FaceRight then
			local degree2 = math.deg(radian)
			if degree2 > 0 then
				FaceLeft:SetAlpha(1)
				FaceRight:SetAlpha(0)
			elseif degree2 <= 0 and radian >= -180 then
				FaceLeft:SetAlpha(0)
				FaceRight:SetAlpha(1)
			end
		end
	end

	local degree = math.deg(radian)
	rotateTexture(self:GetParent().BeamMask, degree - self.lastDegree)
	self.lastDegree = degree
	local x, y = r*cos(radian), r*sin(radian)
	button:SetPoint("CENTER", x, y)
	button.Tex:SetRotation(radian)
	button.Highlight:SetRotation(radian)
	local phi = pi/2-(LightInfoSharedFrame.AngleZ)
	local rX = sin(phi)*sin(LightInfoSharedFrame.AngleXY)
	local rY = -sin(phi)*cos(LightInfoSharedFrame.AngleXY)
	local rZ = -cos(phi)

	local enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB = Narci_CharacterModelFrame:GetLight();
	Narci_CharacterModelFrame:SetLight(enabled, omni, rX, rY, rZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB)
	--print("dirX: "..string.format(Format_Digit, dirX).." dirY: "..string.format(Format_Digit, dirY).." dirZ: "..string.format(Format_Digit, dirZ))
	--/run Narci_CharacterModelFrame:SetLight(true, false, 2, 1, 2, 60000, 1, 1, 1, 0, 1, 1, 1)
end

local PMAI = CreateFrame("Frame","PlayerModelAnimIn");
PMAI.TimeSinceLastUpdate = 0
PMAI.FaceTime = 0;
PMAI.Trigger = true
local function PlayerModelAnimIn_Update(self, elapsed)
	local ModelFrame = Narci_CharacterModelFrame
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local turnTime = 0.36
	local t = 1;
	local offset = outQuad(self.TimeSinceLastUpdate, startY, defaultY - startY, t)

	if self.TimeSinceLastUpdate > turnTime then
		self.FaceTime= self.FaceTime + elapsed;
		local radian = outSine(self.FaceTime, -pi/2, endFacing + pi/2, 0.8) --0.11 NE
		ModelFrame:SetFacing(radian)
		ModelFrame.rotation = radian
	end

	ModelFrame:SetPosition(0, offset, defaultZ)
	ModelFrame.cameraY, ModelFrame.cameraZ = offset, defaultZ
	if self.TimeSinceLastUpdate >= t then
		self.TimeSinceLastUpdate = 0;
		self:Hide();
	end
	
	if self.TimeSinceLastUpdate <=0.8 then
		return;
	elseif self.Trigger then
		self.Trigger = false;
		ModelFrame:SetAnimation(804, 1)
	end
end

function Narci_Test(id)
	if id == false then
		Narci_CharacterModelFrame:SetSheathed(false)
	elseif id == true then
		Narci_CharacterModelFrame:SetSheathed(true)
	else
		Narci_CharacterModelFrame:SetAnimation(id)
	end
end

PMAI:Hide();									--PlayerModelAnimIn
PMAI:SetScript("OnShow", function()
	local ModelFrame = Narci_CharacterModelFrame;
	ModelFrame:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 0.7, 0.5, 0.8, 1, 0.8, 0.8, 0.8)
	Narci_CharacterModelSettings.Color2:Click()
	local ZoomMode;
	if NarcissusDB.ShowFullBody then
		ZoomMode = 2;
	else
		ZoomMode = 1;
	end
	local zoomLevel = TranslateValue[ZoomMode][1] or 0.05;
	defaultY = TranslateValue[ZoomMode][2] or 0.4;
	defaultZ = TranslateValue[ZoomMode][3] or -0.275;
	ModelFrame:SetPortraitZoom(zoomLevel)
	ModelFrame.zoomLevel = zoomLevel
	ModelFrame:SetPosition(0, startY, defaultZ)		--was 0, 0.12, -0.06	/dump Narci_CharacterModelFrame:GetPosition()
	ModelFrame:SetFacing(-pi/2)
	ModelFrame:FreezeAnimation(4,1)
	ModelFrame:SetAnimation(4)
	FadeFrame(ModelFrame, 0.5, "Forced_IN")
	AAACameraZoomIn(ZoomInValue_XmogMode)	--ajust by raceID
	SmoothPitchContainer:Show()

	if OpenViaClick then
		UIFrameFadeOut(Narci_Attribute, 0.5, Narci_Attribute:GetAlpha(), 0)
	end

	--Narci_CharacterListener:UnregisterEvent("UNIT_MODEL_CHANGED");
	ModelFrame:SetSheathed(true)
end);
PMAI:SetScript("OnUpdate", PlayerModelAnimIn_Update);
PMAI:SetScript("OnHide", function(self)
	--Narci_CharacterListener:RegisterEvent("UNIT_MODEL_CHANGED");
	self.TimeSinceLastUpdate = 0
	self.FaceTime = 0
	self.Trigger = true

	Narci_CharacterModelFrame:MakeCurrentCameraCustom();
	Narci_CharacterModelFrame.cameraDistance = Narci_CharacterModelFrame:GetCameraDistance()
end);

local PMAO = CreateFrame("Frame","PlayerModelAnimOut");
PMAO.TimeSinceLastUpdate = 0
PMAO.FaceTime = 0;
PMAO.Trigger = true;
PMAO.Facing = 0;
PMAO.PosX = 0;
PMAO.PosY = 0;

local function PlayerModelAnimOut_Update(self, elapsed)
	local ModelFrame = Narci_CharacterModelFrame
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local turnTime = 0.3
	local t = 1;

	local radian = outSine(self.TimeSinceLastUpdate, self.Facing, pi/2 - self.Facing, turnTime) --0.11 NE
	if self.TimeSinceLastUpdate < turnTime then
		ModelFrame:SetFacing(radian)
		ModelFrame.rotation = radian
	end

	if self.TimeSinceLastUpdate > 0.2 then
		self.FaceTime= self.FaceTime + elapsed;
		local offset = PMAO.PosX + 1.15*self.FaceTime/t
		ModelFrame:SetPosition(0, offset, self.PosY)
		ModelFrame.cameraY, ModelFrame.cameraZ = offset, PMAO.PosY
	end

	if self.TimeSinceLastUpdate >= t then
		self.TimeSinceLastUpdate = 0;
		self:Hide();
	end
	
	if self.TimeSinceLastUpdate <=0.1 then
		return;
	elseif self.Trigger then
		self.Trigger = false;
		ModelFrame:SetAnimation(4)
	end
end

PMAO:SetScript("OnShow", function(self)
	self.Facing = Narci_CharacterModelFrame:GetFacing();
	_, self.PosX, self.PosY = Narci_CharacterModelFrame:GetPosition();
	FadeFrame(Narci_CharacterModelSettings, 0.4, "OUT")
end)

PMAO:SetScript("OnUpdate", PlayerModelAnimOut_Update);
PMAO:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0
	self.FaceTime = 0
	self.Trigger = true
	
end);

function Narci_SetLightButton(self, button)
	Narci_CharacterModelFrame:FreezeAnimation(1)
	Narci_CharacterModelFrame:SetPortraitZoom(0.3)
	Narci_CharacterModelFrame:SetPosition(0,0.12, defaultZ)
	--/run Narci_CharacterModelFrame:SetAnimation(
	--local a,b,c,d = GetDisplayInfo()
	local enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB = Narci_CharacterModelFrame:GetLight();
	local offset = 0
	local change = 0;
	local id = self:GetID()
	if button ~= "MiddleButton" then
		if button == "LeftButton" then
			offset = 0.1
		elseif button == "RightButton" then
			offset = -0.1
		end

		if id == 1 then
			dirX = dirX + offset;
			change = dirX;
		elseif id == 2 then
			dirY = dirY + offset;
			change = dirY;
		elseif id == 3 then
			dirZ = dirZ + offset;
			change = dirZ;
		end

	elseif button == "MiddleButton" then
		if id == 1 then
			--dirX = self:GetParent().dirX;
			dirX = -0.5
			change = dirX;
		elseif id == 2 then
			--dirY = self:GetParent().dirY;
			dirY = 0.5
			change = dirY;
		elseif id == 3 then
			--dirZ = self:GetParent().dirY;
			dirZ = -0.5
			change = dirZ;
		end		
	end
	--if button == "MiddleButton" then
		
	self.Readings:SetText(string.format(Format_Digit, change))
	Narci_CharacterModelFrame:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB)
end

--/run DressUpModel:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 1, 1, 1, 0.6, 0.8, 0.8, 0.8)
--/run Narci_CharacterModelFrame:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 0.7, 0.5, 0.8, 0.6, 0.8, 0.8, 0.8)
--/run DressUpModel:SetLight(true, false, 0, 0.8, -1, 1, 1, 1, 1, 0.3, 1, 1, 1);
--------------------------------
--------------------------------
local ModelSettings = {
	["Generic"] = { panMaxLeft = -2, panMaxRight = 3, panMaxTop = 1.2, panMaxBottom = -1.6, panValue = 40 },
}
local playerRaceSex;
if ( not IsOnGlueScreen() ) then
	local _;
	_, playerRaceSex = UnitRace("player");
	if ( UnitSex("player") == 2 ) then
		playerRaceSex = playerRaceSex.."Male";
	else
		playerRaceSex = playerRaceSex.."Female";
	end
end

function Narci_Xmog_UseCompactMode(state)
	local frame = Narci_CharacterModelFrame;
	if state then
		FadeFrame(frame.GuideFrame, 0.5, "IN");
		ModelVignetteRightSmall:Show();
		UIFrameFadeOut(frame.Color1, 0.5, frame.Color1:GetAlpha(), 0)
	else
		FadeFrame(frame.GuideFrame, 0.5, "OUT");
		if Narci_CharacterModelFrame.xmogMode == 2 then
			UIFrameFadeIn(frame.Color1, 0.5, frame.Color1:GetAlpha(), 1)
		end
	end
end
--/run Narci_Xmog_UseCompactMode
----------- Derivated from Blizzard ModelFrames.lua	Model_OnUpdate() -----------
local Smooth_Zoom = CreateFrame("Frame");
local SetCameraDistance = SetCameraDistance;
Smooth_Zoom.TimeSinceLastUpdate = 0;
Smooth_Zoom.duration = 0.2;
Smooth_Zoom:Hide();

local function Smooth_Zoom_Update(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local EndPoint = self.EndPoint;
	local StartPoint = self.StartPoint;
	local Value = outSine(self.TimeSinceLastUpdate, StartPoint, EndPoint - StartPoint, self.duration) --0.11 NE
	self.ModelFrame:SetCameraDistance(Value)

	if self.TimeSinceLastUpdate >= self.duration then
		--SetCVar("test_cameraOverShoulder", EndPoint)
		self:Hide();
	end
end


Smooth_Zoom:SetScript("OnShow", function(self)
	self.StartPoint = self.ModelFrame:GetCameraDistance()
	--print(self.EndPoint);
end);
Smooth_Zoom:SetScript("OnUpdate", Smooth_Zoom_Update);
Smooth_Zoom:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0
end);

local function Smooth_ZoomCvar(EndPoint)
	Smooth_Zoom:Hide();
	Smooth_Zoom.EndPoint = EndPoint;
	Smooth_Zoom:Show();
end

function NarciModel_OnWheel(self, delta)
	--[[
	maxZoom = self.maxZoom;
	minZoom = self.minZoom;
	local zoomLevel = self.zoomLevel;
	zoomLevel = zoomLevel + delta * 0.1;
	zoomLevel = min(zoomLevel, maxZoom);
	zoomLevel = max(zoomLevel, minZoom);
	self:SetPortraitZoom(zoomLevel);
	self.zoomLevel = zoomLevel;
	--]]

	self.cameraDistance = Narci_CharacterModelFrame:GetCameraDistance() - delta * 0.25
	--self:SetCameraDistance(self.cameraDistance)
	Smooth_ZoomCvar(self.cameraDistance)
end
function NarciModel_StartPanning(self)
	self.panning = true;
	local cameraX, cameraY, cameraZ = self:GetPosition();
	self.cameraX = cameraX;
	self.cameraY = cameraY;
	self.cameraZ = cameraZ;
	local cursorX, cursorY = GetCursorPosition();
	self.cursorX = cursorX;
	self.cursorY = cursorY;
end

function NarciModel_OnMouseDown(model, button)
	if ( not button or button == "LeftButton" ) then
		model.mouseDown = true;
		model.rotationCursorStart = GetCursorPosition();
	end
end

function Narci_Model_OnUpdate(self, elapsedTime, rotationsPerSecond)
	if ( not rotationsPerSecond ) then
		rotationsPerSecond = ROTATIONS_PER_SECOND;
	end

	-- Mouse drag rotation
	if (self.mouseDown) then
		if ( self.rotationCursorStart ) then
			local x = GetCursorPosition();
			local diff = (x - self.rotationCursorStart) * MODELFRAME_DRAG_ROTATION_CONSTANT;
			self.rotationCursorStart = GetCursorPosition();
			self.rotation = self.rotation + diff;
			if ( self.rotation < 0 ) then
				self.rotation = self.rotation + (2 * PI);
			end
			if ( self.rotation > (2 * PI) ) then
				self.rotation = self.rotation - (2 * PI);
			end
			self:SetRotation(self.rotation, false);
		end
	elseif ( self.panning ) then
		local modelScale = self:GetModelScale();
		local cursorX, cursorY = GetCursorPosition();
		local scale = UIParent:GetEffectiveScale();
		-- settings
		local settings;
		settings = ModelSettings["Generic"]
		--[[
		local hasAlternateForm, inAlternateForm = HasAlternateForm();
		if ( hasAlternateForm and inAlternateForm ) then
			settings = ModelSettings[playerRaceSex.."Alt"];
		else
			settings = ModelSettings[playerRaceSex];
		end
		--]]
		local zoom = self.zoomLevel or self.minZoom;
		zoom = 1 + zoom - self.minZoom;	-- want 1 at minimum zoom

		-- Panning should require roughly the same mouse movement regardless of zoom level so the model moves at the same rate as the cursor
		-- This formula more or less works for all zoom levels, found via trial and error
		local transformationRatio = settings.panValue * 2 ^ (zoom * 2) * scale / modelScale;

		local dx = (cursorX - self.cursorX) / transformationRatio;
		local dy = (cursorY - self.cursorY) / transformationRatio;
		local cameraY = self.cameraY + dx;
		local cameraZ = self.cameraZ + dy;
		-- bounds
		scale = scale * modelScale;
		local maxCameraY = settings.panMaxRight * scale;
		cameraY = min(cameraY, maxCameraY);
		local minCameraY = settings.panMaxLeft * scale;
		cameraY = max(cameraY, minCameraY);
		local maxCameraZ = settings.panMaxTop * scale;
		cameraZ = min(cameraZ, maxCameraZ);
		local minCameraZ = settings.panMaxBottom * scale;
		cameraZ = max(cameraZ, minCameraZ);

		self:SetPosition(self.cameraX, cameraY, cameraZ);
		self:SetCameraDistance(self.cameraDistance)
	end
	
	-- Rotate buttons
	--[[
	local leftButton, rightButton;
	if ( self.controlFrame ) then
		leftButton = self.controlFrame.rotateLeftButton;
		rightButton = self.controlFrame.rotateRightButton;
	else
		leftButton = self.RotateLeftButton or (self:GetName() and _G[self:GetName().."RotateLeftButton"]);
		rightButton = self.RotateRightButton or (self:GetName() and _G[self:GetName().."RotateRightButton"]);
	end

	Model_UpdateRotation(self, leftButton, rightButton, elapsedTime, rotationsPerSecond);
	--]]
end

function Narci_Model_SetSheath(self)
	Narci_CharacterModelFrame:SetSheathed(self.IsOn);
	self.IsOn = not self.IsOn;
	if self.IsOn then
		self.Highlight:Show();
	else
		self.Highlight:Hide();
	end
end

function TestAnimButton_OnClick(self, button)
	if button == "LeftButton" and self.animID < 1448 then
		self.animID = self.animID + 1;
	elseif button == "RightButton" and self.animID > 0 then
		self.animID = self.animID - 1;
	end
	self.Value:SetText(self.animID)
	Narci_CharacterModelFrame:SetAnimation(self.animID, 1)
end

function Narci_ShowEquipmentSlots(alpha)
	Narci_Character:SetShown(not Narci_Character:IsShown());
end

function Narci_ShowPlayerModel(alpha)
	local frame = Narci_CharacterModelFrame;
	if state ~= nil then
		frame:SetAlpha(alpha);
	else
		if frame:GetAlpha() == 1 then
			frame:SetAlpha(0);
			Narci_VignetteLeft:Hide();
			VignetteRightLarge:Hide();
		else
			frame:SetAlpha(1);
			Narci_VignetteLeft:Show();
			VignetteRightLarge:Show();
		end
	end
end

function Narci_ShowChromaKey(state)
	local frame = Narci_CharacterModelFrame.ChromaKey;
	Narci_Character:SetShown(not state)
	if state then
		FadeFrame(frame, 0.25, "IN");
	else
		FadeFrame(frame, 0.5, "OUT");
	end
end

--[[
Chroma Key Blue :
0, 71, 187
#0047bb

Chroma Key Green :
0, 177, 64
#00b140
--]]

--- Show Alpha Channel ---

local function ShowTextAlphaChannel(state)
    local slotTable = Narci_Character.slotTable;
    if not (slotTable) then
        return;
    end
	
	local theme = NarcissusDB.BorderTheme;
	local borderMask;
	local shadowAlpha = false;
	local runeAlpha = 1;
	if theme == "Bright" then
		borderMask = "Interface/AddOns/Narcissus/Art/Masks/HexagonThin-Mask";
	elseif theme == "Dark" then
		borderMask = "Interface/AddOns/Narcissus/Art/Masks/HexagonThick-Mask";
		shadowAlpha = true;
		runeAlpha = 0;
	end
	if state then
		for i=1, #slotTable do
			if slotTable[i] then
				--slotTable[i].Name:SetFont(font, Height);
				if slotTable[i].RuneSlot then
					slotTable[i].RuneSlot.AlphaChannelRune:Show();
					slotTable[i].RuneSlot.Background:SetAlpha(runeAlpha);
				end
				slotTable[i].AlphaChannelBorder:SetTexture(borderMask);
				slotTable[i].AlphaChannelBorder:Show();
				slotTable[i].AlphaChannelShadow:SetShown(shadowAlpha);
				slotTable[i].GradientBackground:SetColorTexture(1, 1, 1);
				slotTable[i].Name:SetTextColor(1, 1, 1);
				slotTable[i].Name:SetShadowColor(1, 1, 1);
				local sourcePlainText = slotTable[i].sourcePlainText;
				if sourcePlainText then
					slotTable[i].ItemLevel:SetText(sourcePlainText);
				end
				slotTable[i].ItemLevel:SetTextColor(1, 1, 1);
				slotTable[i].ItemLevel:SetShadowColor(1, 1, 1);
			end
		end
		Narci_CharacterModelFrame:SetAlpha(0);
		Narci_XmogNameFrame:Hide();
		Narci_Character:Show();
	else
		for i=1, #slotTable do
			if slotTable[i] then
				--slotTable[i].Name:SetFont(font, Height);
				if slotTable[i].RuneSlot then
					slotTable[i].RuneSlot.AlphaChannelRune:Hide();
					slotTable[i].RuneSlot.Background:SetAlpha(runeAlpha);
				end
				slotTable[i].AlphaChannelBorder:Hide();
				slotTable[i].AlphaChannelShadow:Hide();
				slotTable[i].GradientBackground:SetColorTexture(0, 0, 0);
				slotTable[i].Name:SetShadowColor(0, 0, 0);
				slotTable[i].ItemLevel:SetShadowColor(0, 0, 0);	
				Narci_ItemSlotButton_OnLoad(slotTable[i]);
			end
		end
		Narci_CharacterModelFrame:SetAlpha(1);
		Narci_XmogNameFrame:Show();
	end
end

function ShowTextAlphaChannel_OnClick(state)
	ShowTextAlphaChannel(state)
	if state then
		FadeFrame(FullScreenAlphaChannel, 0.5, "IN")
	else
		FadeFrame(FullScreenAlphaChannel, 0.5, "OUT")
	end
end

local hasBackup = false;
local LayerButtonStates = {};
local function UnhighlightAllLayerButtons()
	local buttons = Narci_CharacterModelSettings.LayerButtons;
	if not hasBackup then
		wipe(LayerButtonStates);
	end

	for i=1, #buttons do
		if not hasBackup then
			tinsert(LayerButtonStates, buttons[i].IsOn);
		end
		buttons[i].IsOn = false;
		buttons[i]:UnlockHighlight();
		buttons[i].Label:SetTextColor(0.6, 0.6, 0.6)
		buttons[i].AlphaButton.IsOn = false;
		buttons[i].AlphaButton:UnlockHighlight();
	end
	hasBackup = true;
end

local function RestoreAllLayerButtons()
	local buttons = Narci_CharacterModelSettings.LayerButtons;
	for i=1, #buttons do
		local state = LayerButtonStates[i];
		buttons[i].IsOn = state
		buttons[i].AlphaButton.IsOn = false;
		buttons[i].AlphaButton:UnlockHighlight();
		--print(i..": "..tostring(state))
		if state then
			buttons[i]:LockHighlight();
			buttons[i].Label:SetTextColor(1, 1, 1)		
		else
			buttons[i]:UnlockHighlight();
			buttons[i].Label:SetTextColor(0.6, 0.6, 0.6)
		end
	end
	hasBackup = false;
end

local function ExitAlphaMode()
	local buttons = Narci_CharacterModelSettings.AlphaButtons;
	for i=1, #buttons do
		if buttons[i].IsOn then
			buttons[i]:Click()
			return true;
		end
	end
	return false;
end

local function LayerButton_OnClick(self)
	if ExitAlphaMode() then
		return;
	end

	self.IsOn = not self.IsOn;
	if self.IsOn then
		self:LockHighlight();
		self.Label:SetTextColor(1, 1, 1);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		self:UnlockHighlight();
		self.Label:SetTextColor(0.6, 0.6, 0.6);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

local function HideVignette()
	local state = Narci_VignetteLeft:IsShown()
	Narci_VignetteLeft:SetShown(not state);
	VignetteRightSmall:SetShown(not state);
	if Narci_CharacterModelFrame.xmogMode == 2 and not state then
		VignetteRightLarge:SetShown(true);
	end
end

local function SlotLayerButton_OnClick(self)
	LayerButton_OnClick(self);
	Narci_Character:SetShown(self.IsOn);
end

local function PlayerModelLayerButton_OnClick(self)
	LayerButton_OnClick(self);
	if self.IsOn then
		Narci_CharacterModelFrame:SetAlpha(1);
	else
		Narci_CharacterModelFrame:SetAlpha(0);
	end	
end

local function PlayerModelLayerButton_Newbee(self)
	SetTutorialFrame(self, NARCI_TUTORIAL_GREEN_SCREEN);
	self:SetScript("OnClick", PlayerModelLayerButton_OnClick);
end

function Narci_LayerButton_OnLoad(self)
	self.IsOn = true;
	self:LockHighlight();
	local ID = self:GetID();
	if ID == 1 then
		self.Label:SetText(NARCI_EQUIPMENTSLOTS);
		self.Icon:SetTexCoord(0.5, 0.703125, 0.703125, 0.890625);
		self:SetScript("OnClick", SlotLayerButton_OnClick);
	elseif ID == 2 then
		self.Label:SetText(NARCI_3DMODEL);
		self:SetScript("OnClick", PlayerModelLayerButton_OnClick);
	end
	
	if not self:GetParent().LayerButtons then
		self:GetParent().LayerButtons = {};
	end
	tinsert(self:GetParent().LayerButtons, self);
end

local function AlphaLayerButton_OnClick(self)
	self.IsOn = not self.IsOn;
	if self.IsOn then
		UnhighlightAllLayerButtons();
		self.IsOn = true;
		self:LockHighlight();
		self:GetParent().Label:SetTextColor(1, 1, 1)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		RestoreAllLayerButtons();
		self:UnlockHighlight();
		self.IsOn = false;
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end	
end

function Narci_AlphaLayerButton_OnLoad(self)
	self.IsOn = false;
	local ID = self:GetParent():GetID();
	if ID == 1 then
		self:SetScript("OnClick", function(self)
			if Narci_PlayerModelLayerButton.AlphaButton.IsOn then
				Narci_PlayerModelLayerButton.AlphaButton:Click();
			end
			AlphaLayerButton_OnClick(self);
			ShowTextAlphaChannel_OnClick(self.IsOn);
		end)
		self:SetScript("OnHide", function()
			if self.IsOn then
				self.IsOn = false;
				self:UnlockHighlight();
				self:GetParent().Label:SetTextColor(0.6, 0.6, 0.6);
				ShowTextAlphaChannel_OnClick(false);
			end
		end)
	elseif ID == 2 then
		self:SetScript("OnClick", function(self)
			if Narci_SlotLayerButton.AlphaButton.IsOn then
				Narci_SlotLayerButton.AlphaButton:Click();
			end
			AlphaLayerButton_OnClick(self);
			Narci_ShowChromaKey(self.IsOn);
			if self.IsOn then
				self:GetParent().ColorButtons:Show();
			else
				self:GetParent().ColorButtons:Hide();
			end
		end)
		self:SetScript("OnHide", function()
			if self.IsOn then
				self.IsOn = false;
				self:UnlockHighlight();
				self:GetParent().Label:SetTextColor(0.6, 0.6, 0.6);
			end
		end)
	end

	if not self:GetParent():GetParent().AlphaButtons then
		self:GetParent():GetParent().AlphaButtons = {};
	end
	tinsert(self:GetParent():GetParent().AlphaButtons, self);
end


local AutoCloseTimer = C_Timer.NewTimer(0, function()	end)

function Narci_AnimationOption_MainTabButton_OnClick(self)
	AutoCloseTimer:Cancel()
	self.IsOn = not self.IsOn;
	if self.IsOn then
		self.Background:SetTexCoord(0, 0.376953125, 0.52734375, 0.6328125);
		self.Arrow:SetTexCoord(0, 1, 1, 0);
		self:GetParent().OtherTab:Show();
	else
		self.Background:SetTexCoord(0, 0.376953125, 0.2109375, 0.31640625);
		self.Arrow:SetTexCoord(0, 1, 0, 1);
		self:GetParent().OtherTab:Hide();
	end
	AutoCloseTimer = C_Timer.NewTimer(6, function()
		if Narci_AnimationOptionFrame_Tab1.IsOn then
			Narci_AnimationOptionFrame_Tab1:Click();
		end
	end)
end

local maxTab = 3;
local animationID = {
	[1] = {110, 48, 109, 29, ["name"] = NARCI_RANGED_WEAPON,},
	[2] = {968, 1242, 1240, 1076, ["name"] = NARCI_MELEE_WEAPON,},
	[3] = {124, 51, 874, 940, ["name"] = NARCI_SPELLCASTING,},
}

function Narci_AnimationOptionFrame_OnLoad(self)
	local _, _, classID = UnitClass("player");
	local ID;
	if classID == 5 or classID == 8 or classID == 9 or classID == 11 then	--spellcasting
		ID = 3;
	elseif classID == 3 then												--hunter
		ID = 1;
	else
		ID = 2;
	end
	self.tab1:SetID(ID);
	self.tab1.Label:SetText(animationID[ID]["name"]);

	local otherIDs = {}
	for i=1, maxTab do
		if i ~= ID then
			tinsert(otherIDs, i)
		end
	end

	self.OtherTab.tab2:SetID(otherIDs[1]);
	self.OtherTab.tab2.Label:SetText(animationID[otherIDs[1]]["name"]);	
	self.OtherTab.tab3:SetID(otherIDs[2]);
	self.OtherTab.tab3.Label:SetText(animationID[otherIDs[2]]["name"]);

	local buttons = self.buttons;
	for i=1, #buttons do
		buttons[i]:SetID(animationID[ID][i]);
	end
end

function Narci_AnimationOption_OtherTabButton_OnClick(self)
	local ID = self:GetID();
	local tab1 = self:GetParent():GetParent().tab1;
	local activeID = tab1:GetID();
	local buttons = self:GetParent():GetParent().buttons;

	for i=1, #buttons do
		buttons[i]:SetID(animationID[ID][i]);
		buttons[i].animOut:Play();
	end

	self:SetID(activeID);
	self.Label:SetText(animationID[activeID]["name"]);
	tab1:SetID(ID);
	tab1.Label:SetText(animationID[ID]["name"]);
	tab1:Click();
end

function Narci_Model_Idle(self)
	Narci_CharacterModelFrame:SetAnimation(804, 1);

	self.IsOn = true;
	if not self.IsOn then
		self.Highlight:Hide();
	end

	local buttons = Narci_AnimationOptionFrame.buttons;
	for i=1, #buttons do
		buttons[i].IsOn = false;
		buttons[i].Highlight:Hide();
	end
end


function Narci_Model_BrightnessSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		Narci_BackgroundBrightnessTexture:SetAlpha(value);
    end
end

function Narci_Model_VignetteSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		Narci_VignetteLeft:SetAlpha(value);
		VignetteRightLarge:SetAlpha(value);
		VignetteRightSmall:SetAlpha(value);
		ModelVignetteRightSmall:SetAlpha(value);
    end
end

function Narci_Model_UseCompactMode_OnClick(self)
	self.IsOn = not self.IsOn;
	if self.IsOn then
		self:LockHighlight();
		self.Label:SetTextColor(1, 1, 1)
		if not Narci_HidePlayerButton.IsOn then
			Narci_HidePlayerButton:Click();
		end
	else
		self:UnlockHighlight();
		self.Label:SetTextColor(0.6, 0.6, 0.6)
		if Narci_HidePlayerButton.IsOn then
			Narci_HidePlayerButton:Click();
		end
	end
	Narci_Xmog_UseCompactMode(self.IsOn);
end

function Narci_Model_HidePlayer_OnClick(self)
	self.IsOn = not self.IsOn;
	ConsoleExec( "showPlayer");
	if self.IsOn then
		self:LockHighlight();
		self.Label:SetTextColor(1, 1, 1)		
	else
		self:UnlockHighlight();
		self.Label:SetTextColor(0.6, 0.6, 0.6)
	end
end

function Narci_Model_AnimationFrameSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		local id = Narci_AnimationIDFrame_EditBox:GetNumber();
		Narci_CharacterModelFrame:FreezeAnimation(id, 0, value)
    end
end

function Narci_Model_NextAnimationButton_OnClick(self, button)
	Narci_AnimationIDFrame_EditBox:ClearFocus();
	local id = Narci_AnimationIDFrame_EditBox:GetNumber();
	
	if button == "LeftButton" and id < 1447000 then
		id = id + 1;
		while (not Narci_CharacterModelFrame:HasAnimation(id) and id <1447) do
			id = id + 1
		end
	elseif button == "RightButton" and id > 0 then
		id = id - 1;
		while (not Narci_CharacterModelFrame:HasAnimation(id) and id > 0) do
			id = id - 1
		end
	end

	
	if self:GetParent().Pause.IsOn then
		Narci_Model_AnimationFrameSlider:SetValue(1);
		Narci_CharacterModelFrame:FreezeAnimation(id, 0, 1)
	else
		Narci_CharacterModelFrame:SetAnimation(id, 1)
	end
	--]]

	Narci_Model_IdleButton.IsOn = false;
	Narci_Model_IdleButton.Highlight:Hide();
	
	Narci_AlertFrame_Static:Hide();
	Narci_AnimationIDFrame_EditBox:SetNumber(id)
	--Narci_CharacterModelFrame:ApplySpellVisualKit(id, true)
end

function NextAnimationButton_Newbee(self, button)
	SetTutorialFrame(self, NARCI_TUTORIAL_ANIMATION_ID);
	Narci_Model_NextAnimationButton_OnClick(self, button);
	self:SetScript("OnClick", Narci_Model_NextAnimationButton_OnClick);
end

function Narci_ModelShadow_SizeSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		Narci_GroundShadowFrame.Shadow:SetScale(value)
    end
end

function Narci_ModelShadow_AlphaSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		Narci_GroundShadowFrame.Shadow:SetAlpha(value)
    end
end







---------------------------
---------------------------
---------------------------
local LayersToBeCaptured = -1;
local Alpha_Temp1 = 1;
local Alpha_Temp2 = 1;
local Vignette_Temp = 0;
local Brightness_Temp = 0;
local HidePlayer_Temp = false;
local FullSceenChromaKey;
local r1, g1, b1 = 0, 177/255, 64/255;
local r2, g2, b2 = 0, 71/255, 187/255;

local function NarciModel_OnMouseUp(model, button)
	if ( not button or button == "LeftButton" ) then
		model.mouseDown = false;
	end
end

function NarciModel_OnLoad(self, maxZoom, minZoom, defaultRotation, onMouseUp)
	self:SetUnit("player");

	self.maxZoom = maxZoom or MODELFRAME_MAX_ZOOM;
	self.minZoom = minZoom or MODELFRAME_MIN_ZOOM;
	self.defaultRotation = defaultRotation or MODELFRAME_DEFAULT_ROTATION;
	self.onMouseUpFunc = onMouseUp or NarciModel_OnMouseUp;
	self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self.TimeSinceLastUpdate = 0;
	local r, g, b = 0, 177/255, 64/255;
	--local r, g, b =	0, 71/255, 187/255;
	self.ChromaKey:SetColorTexture(r, g, b);
	local W = self:GetWidth()
	self:SetHitRectInsets(2*W/3, 0, 0, 0);
	FullSceenChromaKey = self.ChromaKey;

	Smooth_Zoom.ModelFrame = self;
end

local function BeginLayerCapture()
	if LayersToBeCaptured == 5 then
		Narci_CharacterModelFrame:SetPaused(true);
		HidePlayer_Temp = Narci_HidePlayerButton.IsOn;
		if not HidePlayer_Temp then
			Narci_HidePlayerButton:Click();
		end
		Vignette_Temp = Narci_Model_VignetteSlider:GetValue();
		Brightness_Temp = Narci_Model_BrightnessSlider:GetValue();
		Narci_Model_VignetteSlider:SetValue(0);
		Narci_Model_BrightnessSlider:SetValue(0);
		Narci_Character:Hide();
		Narci_CharacterModelFrame:SetAlpha(0);
	elseif LayersToBeCaptured == 4 then
		Narci_CharacterModelFrame:SetAlpha(1);
		FullSceenChromaKey:SetColorTexture(r1, g1, b1);
		FullSceenChromaKey:Show();
		FullSceenChromaKey:SetAlpha(1);
	elseif LayersToBeCaptured == 3 then
		Narci_CharacterModelFrame:SetAlpha(1);
		FullSceenChromaKey:SetColorTexture(r2, g2, b2);
		FullSceenChromaKey:Show();
		FullSceenChromaKey:SetAlpha(1);
	elseif LayersToBeCaptured == 2 then
		Narci_CharacterModelFrame:SetAlpha(0);
		FullSceenChromaKey:Hide();
		FullSceenChromaKey:SetAlpha(0);
		ShowTextAlphaChannel(true);
		FullScreenAlphaChannel:SetAlpha(1);
		FullScreenAlphaChannel:Show();
	elseif LayersToBeCaptured == 1 then
		ShowTextAlphaChannel(false);
		FullScreenAlphaChannel:SetAlpha(1);
		FullScreenAlphaChannel:Show();
		Narci_CharacterModelFrame:SetAlpha(0);
	elseif LayersToBeCaptured == 0 then
		Narci_Model_VignetteSlider:SetValue(Vignette_Temp);
		Narci_Model_BrightnessSlider:SetValue(Brightness_Temp);
		Narci_CharacterModelFrame:SetAlpha(1);
		FullScreenAlphaChannel:SetAlpha(0);
		FullScreenAlphaChannel:Hide();
		if not HidePlayer_Temp then
			Narci_HidePlayerButton:Click();
		end
		LayersToBeCaptured = -1;
		Narci_Model_CaptureButton.Value:SetText(0);
		Narci_Model_CaptureButton:Enable();
		local button = Narci_SlotLayerButton;
		button:LockHighlight();
		button.Label:SetTextColor(1, 1, 1);
		button.IsOn = true;
		Narci_CharacterModelFrame:SetPaused(false);
		return;
	else
		LayersToBeCaptured = -1;
		Narci_Model_CaptureButton.Value:SetText(0);
		Narci_Model_CaptureButton:Enable();
		Narci_CharacterModelFrame:SetPaused(false);
		return;
	end
	C_Timer.After(1, function()
	Screenshot();
	end)
	Narci_Model_CaptureButton.Value:SetText(LayersToBeCaptured);
	LayersToBeCaptured = LayersToBeCaptured - 1;
	Narci_CharacterModelFrame:SetPaused(false);
end



local function CaptureButton_Seasoned(self)
	Narci_AlertFrame_Static:Hide();
	self:Disable()
	Narci_VignetteLeft:SetAlpha(0);
	VignetteRightSmall:SetAlpha(0);
	LayersToBeCaptured = 5;
	Screenshot();
end

local function CaptureButton_Newbee(self)
	SetTutorialFrame(self, NARCI_TUTORIAL_CAPTUREBUTTON)
	self:Disable()
	C_Timer.After(2, function()
		Narci_Model_CaptureButton:Enable();
		Narci_Model_CaptureButton:SetScript("OnClick", CaptureButton_Seasoned)
	end)
end

function Narci_Model_CaptureButton_OnClick(self)
	CaptureButton_Seasoned(self)
end

function Narci_Model_CaptureButton_OnEnter(self)
	if LayersToBeCaptured == -1 then
		Narci_Model_CaptureButton.Value:SetText(5);
	end
end

function Narci_Model_CaptureButton_OnLeave(self)
	if LayersToBeCaptured == -1 then
		Narci_Model_CaptureButton.Value:SetText(0);
	end
end

local function EnableButtonTutorial(button, key, func)
	if NarcissusDB and NarcissusDB.Tutorials and NarcissusDB.Tutorials[key] then
		button:SetScript("OnClick", func);
		button.keyValue = key;
	end
end

local ScreenshotListener = CreateFrame("Frame");
ScreenshotListener:RegisterEvent("SCREENSHOT_STARTED")
ScreenshotListener:RegisterEvent("SCREENSHOT_SUCCEEDED")
ScreenshotListener:RegisterEvent("VARIABLES_LOADED");
ScreenshotListener:SetScript("OnEvent",function(self,event,...)
	if event == "SCREENSHOT_STARTED" then
		Alpha_Temp1 = PhotoModeController:GetAlpha();
		Alpha_Temp2 = Narci_CharacterModelSettings:GetAlpha();
		PhotoModeController:SetAlpha(0);
		Narci_CharacterModelSettings:SetAlpha(0);
	elseif event == "SCREENSHOT_SUCCEEDED" then
		PhotoModeController:SetAlpha(Alpha_Temp1);
		Narci_CharacterModelSettings:SetAlpha(Alpha_Temp2);
		if LayersToBeCaptured >= 0  then
			C_Timer.After(1.5, function()
				BeginLayerCapture();
			end)
		end
	elseif event == "VARIABLES_LOADED" then
		EnableButtonTutorial(Narci_Model_CaptureButton, "CaptureButton", CaptureButton_Newbee);
		EnableButtonTutorial(Narci_Model_NextAnimationButton, "NextAnimationButton", NextAnimationButton_Newbee);
		EnableButtonTutorial(Narci_PlayerModelLayerButton, "PlayerModelLayerButton", PlayerModelLayerButton_Newbee);
		self:UnregisterEvent("VARIABLES_LOADED")
	end
end)
----------------------------
--[[
/run Narci_CharacterModelFrame:SetUseTransmogSkin(false)
/run Narci_CharacterModelFrame:PlayAnimKit(false)
/run Narci_CharacterModelFrame:ApplySpellVisualKit(92719, true)82193 73393 61975 82148 Ghost
82192	Fire in Hand
82148	Ghost
73396	Light Orb in hand
/run Narci_CharacterModelFrame:MakeCurrentCameraCustom()
/dump Narci_CharacterModelFrame:GetCameraPosition()
/dump Narci_CharacterModelFrame:GetModelFileID()
/run Narci_CharacterModelFrame:SetCameraPosition(3.62,0,0)
/dump Narci_CharacterModelFrame:GetCameraTarget()
/run Narci_CharacterModelFrame:SetPortraitZoom(4)
/run Narci_CharacterModelFrame:SetBarberShopAlternateForm()
/run Narci_CharacterModelFrame:SetCustomRace(1, 1);Narci_CharacterModelFrame:MakeCurrentCameraCustom()
/run Narci_CharacterModelFrame:SetDisplayInfo(89631)
/run Narci_CharacterModelFrame:SetParticlesEnabled(bool)
/run Narci_CharacterModelFrame:Undress()
/run Narci_CharacterModelFrame:SetItem(155880)
/run Narci_CharacterModelFrame:SetItemAppearance()
/run Narci_CharacterModelFrame:SetModel("spells\\errorcube.mdx")
/run Narci_CharacterModelFrame:SetRoll(math.pi/2)
/run Narci_CharacterModelFrame:SetPitch(math.pi/4)
/dump Narci_CharacterModelFrame:GetCameraPosition()
My wow programming in a nut shell: Spending 90% of time on finding the right API
/run Narci_CharacterModelFrame:EquipItem(159653)
/run xxid=Narci_CharacterModelFrame:GetSlotTransmogSources(5);dump C_TransmogCollection.GetSourceInfo(xxid)
C_TransmogCollection.GetSourceInfo(Narci_CharacterModelFrame:GetSlotTransmogSources(5))
/run Narci_CharacterModelFrame:SetUnit("target");
104197 lighting
104488 Red Ghost
104534  Heart of Azeroth!!! 1330
/run Narci_CharacterModelFrame:SetAnimation(1330);Narci_CharacterModelFrame:ApplySpellVisualKit(104534, false)

-----------------
-------API-------
-----------------

SetShadowEffect(0~1)	--Transparent



function SM(path)
	path = tostring(path)
	path = gsub(path, "%/", "\\".."\\")
	print(path)
	Narci_CharacterModelFrame:SetModel(path)
end--]]

function EQ(id)
	local _, itemLink = GetItemInfo(id)
	Narci_CharacterModelFrame:TryOn(itemLink)
end

function SV(id)
	Narci_CharacterModelFrame:ApplySpellVisualKit(id, true)
end

-------------------

--[[
hooksecurefunc("ShowUIPanel", function(name)
	if name == "DressUpFrame" then
		StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING");
	end
end)

--]]