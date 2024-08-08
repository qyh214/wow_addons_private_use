-- Custom POIs for quest objectives, this isnt needed on more recent wow versions
if GetQuestPOIs then
    return
end

local LinePoolMixin, LinePool_Hide, LinePool_HideAndClearAnchors, CreateLinePool = LinePoolMixin, LinePool_Hide, LinePool_HideAndClearAnchors, CreateLinePool
if not LinePool then
	LinePoolMixin = CreateFromMixins(ObjectPoolMixin);

	local function LinePoolFactory(linePool)
		return linePool.parent:CreateLine(nil, linePool.layer, linePool.lineTemplate, linePool.subLayer);
	end

	function LinePoolMixin:OnLoad(parent, layer, subLayer, lineTemplate, resetterFunc)
		ObjectPoolMixin.OnLoad(self, LinePoolFactory, resetterFunc);
		self.parent = parent;
		self.layer = layer;
		self.subLayer = subLayer;
		self.lineTemplate = lineTemplate;
	end

	LinePool_Hide = function(_, frame)
        frame:Hide();
    end;
	LinePool_HideAndClearAnchors = function(_, frame)
        frame:Hide();
        frame:ClearAllPoints();
    end;

	function CreateLinePool(parent, layer, subLayer, lineTemplate, resetterFunc)
		local linePool = CreateFromMixins(LinePoolMixin);
		linePool:OnLoad(parent, layer, subLayer, lineTemplate, resetterFunc or LinePool_HideAndClearAnchors);
		return linePool;
	end
end

BtWQuestsQuestPOIDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);
function BtWQuestsQuestPOIDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	mapCanvas:SetPinTemplateType("BtWQuestsQuestPOITemplate", "BUTTON");
end
function BtWQuestsQuestPOIDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("BtWQuestsQuestPOITemplate");
end
local GetNumQuestWatches = C_QuestLog and C_QuestLog.GetNumQuestWatches or GetNumQuestWatches
local GetQuestIDForQuestWatchIndex = C_QuestLog and C_QuestLog.GetQuestIDForQuestWatchIndex or GetQuestWatchInfo
function BtWQuestsQuestPOIDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

    local uiMapID = self:GetMap():GetMapID()
	if BtWQuests.Settings.showMapPOIs then
        for i=1,GetNumQuestWatches() do
            local questID = GetQuestIDForQuestWatchIndex(i)
            local data = BtWQuests.Database:GetQuestByID(questID)
            if data and data.objectives then
                local objectives = C_QuestLog.GetQuestObjectives(questID)
                for index,objective in ipairs(objectives) do
                    local objectivesData = data.objectives[index]
                    if objectivesData then
                        if objectivesData.mapID then
                            objectivesData = {objectivesData}
                        end
                        for _, objectiveData in ipairs(objectivesData) do
                            if not objective.finished and objectiveData.mapID == uiMapID then
                                if objectiveData.type == "coords" then
                                    local points = {-0.01, 0, 0, -0.01, 0.01, 0, 0, 0.01}
                                    local pin = self:GetMap():AcquirePin("BtWQuestsQuestPOITemplate", questID, index, "area", points);
                                    pin:SetPosition(objectiveData.x, objectiveData.y);
                                    pin:Show();
                                else
                                    local source = objectiveData.points
                                    if #source ~= 1 then
                                        local points = {}
                                        local rect = {nil, nil, nil, nil}
                                        for _,point in ipairs(source) do
                                            rect[1] = math.min(rect[1] or point[1], point[1])
                                            rect[2] = math.max(rect[2] or point[1], point[1])
                                            rect[3] = math.min(rect[3] or point[2], point[2])
                                            rect[4] = math.max(rect[4] or point[2], point[2])
                                        end

                                        local x, y = (rect[2] - rect[1]) * 0.5 + rect[1], (rect[4] - rect[3]) * 0.5 + rect[3]

                                        for _,point in ipairs(source) do
                                            points[#points+1] = point[1] - x
                                            points[#points+1] = point[2] - y
                                        end
                                    
                                        local pin = self:GetMap():AcquirePin("BtWQuestsQuestPOITemplate", questID, index, "area", points);
                                        pin:SetPosition(x, y);
                                        pin:Show();
                                    else
                                        local points = {-0.01, 0, 0, -0.01, 0.01, 0, 0, 0.01}
                                        local pin = self:GetMap():AcquirePin("BtWQuestsQuestPOITemplate", questID, index, "area", points);
                                        -- local pin = self:GetMap():AcquirePin("BtWQuestsQuestPOITemplate", questID, index, "coords");
                                        pin:SetPosition(source[1][1], source[1][2]);
                                        pin:Show();
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
	if BtWQuests.Settings.showMapTurnIns then
        for i=1,GetNumQuestLogEntries() do
            local questID = select(8, GetQuestLogTitle(i))
            if questID and questID ~= 0 and IsQuestComplete(questID) then
                local data = BtWQuests.Database:GetQuestByID(questID)
                if data and data.targets then
                    if data.targets.type == "coords" and data.targets.mapID == uiMapID then
                        local pin = self:GetMap():AcquirePin("BtWQuestsQuestPOITemplate", questID, -1, "coords");
                        pin:SetPosition(data.targets.x, data.targets.y);
                        pin:Show();
                    elseif data.targets.points and data.targets.mapID == uiMapID then
                        local pin = self:GetMap():AcquirePin("BtWQuestsQuestPOITemplate", questID, -1, "coords");
                        pin:SetPosition(data.targets.points[1][1], data.targets.points[1][2]);
                        pin:Show();
                    end
                end
            end
        end
	end
end

BtWQuestsQuestPOIMixin = CreateFromMixins(MapCanvasPinMixin);
function BtWQuestsQuestPOIMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_STORY_LINE");
	self.linePool = CreateLinePool(self)
end
function BtWQuestsQuestPOIMixin:OnAcquired(questID, objectiveIndex, type, points)
	self.questID = questID;
    self.objectiveIndex = objectiveIndex
	self.mapID = self:GetMap():GetMapID();
    self.type = type
    self.normalizedPoints = points
    local adjustedPoints = {}

	self.linePool:ReleaseAll()
    if type == "coords" then
        self:SetScalingLimits(1, 1.0, 1.2)
        self.Circle:SetShown(objectiveIndex ~= -1)
        self.Turnin:SetShown(objectiveIndex == -1)
        if objectiveIndex == -1 and BtWQuests.Settings.smallMapPins then
            self:SetSize(16, 16)
        else
            self:SetSize(22, 22)
        end
    elseif type == "area" then
        self.Circle:SetShown(false)
        self.Turnin:SetShown(false)
        if #points <= 2 then
            error("To few points")
        else
            self:SetScalingLimits(nil, nil, nil)
            local w, h = self:GetMap():GetCanvas():GetWidth(), self:GetMap():GetCanvas():GetHeight()

            for i=1,#points,2 do
                local ax, ay = points[i  ], points[i+1]
                adjustedPoints[i], adjustedPoints[i+1] = ax * w, -ay * h
            end

            local rect = {nil, nil, nil, nil}
            for i=1,#points-2,2 do
                local ax, ay = points[i  ], points[i+1]
                local bx, by = points[i+2], points[i+3]

                rect[1] = math.min(rect[1] or ax, ax, bx)
                rect[2] = math.max(rect[2] or ax, ax, bx)
                rect[3] = math.min(rect[3] or ay, ay, by)
                rect[4] = math.max(rect[4] or ay, ay, by)

                local line = self.linePool:Acquire()
                line:SetThickness(3)
                line:SetColorTexture(0.409,0.678,1,1)
                line:SetStartPoint("CENTER", ax * w, -ay * h)
                line:SetEndPoint  ("CENTER", bx * w, -by * h)
                line:Show()
            end

            local ax, ay = points[1], points[2]
            local bx, by = points[#points-1], points[#points]

            rect[1] = math.min(rect[1] or ax, ax, bx)
            rect[2] = math.max(rect[2] or ax, ax, bx)
            rect[3] = math.min(rect[3] or ay, ay, by)
            rect[4] = math.max(rect[4] or ay, ay, by)

            local line = self.linePool:Acquire()
            line:SetThickness(3)
            line:SetColorTexture(0.409,0.678,1,1)
            line:SetStartPoint("CENTER", ax * w, -ay * h)
            line:SetEndPoint  ("CENTER", bx * w, -by * h)
            line:Show()

            self:SetSize((rect[2] - rect[1]) * w, (-rect[4] - -rect[3]) * h)
        end
    end

    self.adjustedPoints = adjustedPoints
end
function BtWQuestsQuestPOIMixin:GetQuestID()
    return self.questID
end
function BtWQuestsQuestPOIMixin:GetObjectiveIndex()
    return self.objectiveIndex, self.questID
end
function BtWQuestsQuestPOIMixin:IsMouseWithin()
    if not MouseIsOver(self) then
        return false
    end

    if self.type == "area" then
        local inside = false;

        local x, y = self:GetMap():GetCanvasContainer():GetNormalizedCursorPosition()
        local centerX, centerY = self:GetPosition()
        x = x - centerX
        y = y - centerY

        local points = self.normalizedPoints
        local length = #points * 0.5
        local oldX, oldY = points[length * 2 - 1], points[length * 2]

        for i=1,length do
            local newX, newY = points[(i-1) * 2 + 1], points[(i-1) * 2 + 2]

            local leftX, leftY;
            local rightX, rightY;
            if newX > oldX then
                leftX, leftY = oldX, oldY;
                rightX, rightY = newX, newY;
            else
                leftX, leftY = newX, newY;
                rightX, rightY = oldX, oldY;
            end

            if leftX < x and x <= rightX and (y - leftY) * (rightX - leftX) < (rightY - leftY) * (x - leftX) then
                inside = not inside;
            end

            oldX, oldY = newX, newY;
        end

        return inside;
    else
        return true
    end
end
local byQuestID = {}
function BtWQuestsQuestPOIMixin:OnUpdate()
    local x, y = GetCursorPosition()
    if x == self.lastMouseX and y == self.lastMouseY then
        return
    end
    self.lastMouseX, self.lastMouseY = x, y

    wipe(byQuestID)
    for pin in self:GetMap():EnumeratePinsByTemplate("BtWQuestsQuestPOITemplate") do
        if pin:IsMouseWithin() then
            local objective, questID = pin:GetObjectiveIndex()
            if objective ~= -1 then
                byQuestID[questID] = byQuestID[questID] or {}
                byQuestID[questID][#byQuestID[questID]+1] = objective
            end
        end
    end

    local tooltip = WorldMapTooltip or GameTooltip
	tooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
    for questID, visibleObjectives in pairs(byQuestID) do
        local objectives = C_QuestLog.GetQuestObjectives(questID)
        table.sort(visibleObjectives)

        tooltip:AddLine(QuestUtils_GetQuestName(questID));
        for _,objective in ipairs(visibleObjectives) do
	        tooltip:AddLine('- ' .. objectives[objective].text, 1, 1, 1, true);
        end
    end
	tooltip:Show();
end
function BtWQuestsQuestPOIMixin:OnMouseEnter()
    if self.objectiveIndex == -1 then
        local tooltip = WorldMapTooltip or GameTooltip
        tooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
        tooltip:SetText(QuestUtils_GetQuestName(self.questID));
        tooltip:Show();
    else
        self:SetScript("OnUpdate", self.OnUpdate)
    end
end
function BtWQuestsQuestPOIMixin:OnMouseLeave()
    self:SetScript("OnUpdate", nil)
    
    local tooltip = WorldMapTooltip or GameTooltip
	tooltip:Hide();
end
function BtWQuestsQuestPOIMixin:OnClick(button)
	if button == "RightButton" then
        self:GetMap():GetOwner():NavigateToParentMap()
    end
end