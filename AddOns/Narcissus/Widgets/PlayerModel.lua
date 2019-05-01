local pi = math.pi;
local sin = math.sin;
local FadeFrame = NarciAPI_FadeFrame;
local updateThreshold = 2;

-----------------------------------
local defaultZ = -0.275;
local defaultY = 0.4;
local startY = 2;
local endFacing = -pi/8;
--/dump Narci_CharacterModelFrame:GetPosition()
-----------------------------------

local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end
local function outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end


function Narci_CharacterModelFrame_OnShow(self)
	FadeFrame(Narci_CharacterModelSettings, 0.25, "IN")
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
	ModelFrame.panMaxLeft = -100
	ModelFrame.panMaxRight = 100
	ModelFrame:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 0.7, 0.5, 0.8, 1, 0.8, 0.8, 0.8)
	Narci_CharacterModelSettings.Color2:Click()
	local zoomLevel = 0.1						--x=700, zoomLevel=0.3
	ModelFrame:SetPortraitZoom(zoomLevel)
	ModelFrame.zoomLevel = zoomLevel
	ModelFrame:SetPosition(0, startY, defaultZ)		--was 0, 0.12, -0.06	/dump Narci_CharacterModelFrame:GetPosition()
	ModelFrame:SetFacing(-pi/2)
	ModelFrame:FreezeAnimation(4,1)
	ModelFrame:SetAnimation(4)
	FadeFrame(ModelFrame, 0.5, "Forced_IN")
	--ModelFrame:Show()
	SetView(2)
	AAACameraZoomIn(ZoomInValue_XmogMode)	--ajust by raceID
	SmoothPitchContainer:Show()
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = -600
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
	if OpenViaClick then
		UIFrameFadeOut(Narci_Attribute, 0.5, Narci_Attribute:GetAlpha(), 0)
	end
	--Smooth_ShoulderCvar(1.66)	--ajust by raceID

	Narci_CharacterListener:UnregisterEvent("UNIT_MODEL_CHANGED");
	ModelFrame:SetSheathed(true)
end);
PMAI:SetScript("OnUpdate", PlayerModelAnimIn_Update);
PMAI:SetScript("OnHide", function(self)
	Narci_CharacterListener:RegisterEvent("UNIT_MODEL_CHANGED");
	--Narci_CharacterModelFrame:SetAnimation(1242)
	--Narci_CharacterModelFrame:SetSheathed(true)
	self.TimeSinceLastUpdate = 0
	self.FaceTime = 0
	self.Trigger = true
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

function SetLightButton(self, button)
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



--------------------------------
--------------------------------
local ModelSettings = {
	["Generic"] = { panMaxLeft = -2, panMaxRight = 3, panMaxTop = 1.2, panMaxBottom = -1.2, panValue = 40 },
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

----------- Derivated from Blizzard ModelFrames.lua	Model_OnUpdate() -----------

function Narci_Model_OnUpdate(self, elapsedTime, rotationsPerSecond)
	if ( not rotationsPerSecond ) then
		rotationsPerSecond = ROTATIONS_PER_SECOND;
	end

	---Show split line and hide player--
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsedTime;
	if self.TimeSinceLastUpdate > updateThreshold then
		self.TimeSinceLastUpdate = 0;
		local _, offset = self:GetPosition();
		if offset < 0 then
			--self.GuideFrame:Show();
			FadeFrame(self.GuideFrame, 0.5, "IN");
		else
			--self.GuideFrame:Hide();
			FadeFrame(self.GuideFrame, 0.5, "OUT");
		end
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
		ModelPanningFrame:SetPoint("BOTTOMLEFT", cursorX / scale - 16, cursorY / scale - 16);	-- half the texture size to center it on the cursor
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