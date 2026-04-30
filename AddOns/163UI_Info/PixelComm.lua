---@type ns
local ns = select(2, ...)

if bit == nil and bit32 ~= nil then
    bit = bit32
end

local PAD_HEIGHT = 10

local PixelComm = {}
PixelComm.__index = PixelComm

function PixelComm:new()
    local self = setmetatable({}, PixelComm)
    self.sendDataMaxLen = 3000
    self.padWriteIndex = 0
    self.commandID = math.random(0, 1000)
    self.createdFrames = false
    self.startTime = time()
    self.autoClearTimer = nil
    self.sendQueue = {}
    self.isSending = false
    return self
end

function PixelComm:createFrames()
    local physicalWidth, physicalHeight = GetPhysicalScreenSize()
    if physicalWidth and physicalWidth > 0 then
        self.physicalWidth = physicalWidth
    else
        self.physicalWidth = GetScreenWidth()
    end
    self.blackboard = CreateFrame("frame", "PixelComm", nil)
    self.blackboard:SetPoint("TOPLEFT", 0, 0)
    self.blackboard:SetWidth(self.physicalWidth)
    self.blackboard:SetHeight(PAD_HEIGHT)
    self.blackboard:SetFrameStrata("TOOLTIP")
    self.blackboard:SetFrameLevel(128)
    self.blackboard:Show()

    self.blackboard.setReadScreenWidth = function(width)
        self.blackboard:SetWidth(width)
        self.blackboard:SetPoint("TOPLEFT", 0, 0)
        local newScale = (GetScreenWidth() * UIParent:GetEffectiveScale()) / width
        self.blackboard:SetScale(newScale)
    end

    local physicalWidth, physicalHeight = GetPhysicalScreenSize()
    if physicalWidth and physicalWidth > 0 then
        self.blackboard.setReadScreenWidth(physicalWidth)
    end

    self:setupScreenSizeMonitor()
end

function PixelComm:clearDisplay()
    if not self.blackboard then
        return
    end

    local children = { self.blackboard:GetChildren() }

    for i = 1, #children do
        local child = children[i]
        if child then
            child:Hide()
        end
    end

end

function PixelComm:setupScreenSizeMonitor()
    if not self.screenSizeMonitorFrame then
        self.screenSizeMonitorFrame = CreateFrame("Frame")
        self.lastPhysicalWidth = nil
        self.lastUIScale = nil
        self.lastCheckTime = 0
    end

    self.screenSizeMonitorFrame:SetScript("OnUpdate", function(_, elapsed)
        self.lastCheckTime = self.lastCheckTime + elapsed

        if self.lastCheckTime >= 1.0 then
            self.lastCheckTime = 0
            self:checkScreenChanges()
        end
    end)
end

function PixelComm:checkScreenChanges()
    local physicalWidth, physicalHeight = GetPhysicalScreenSize()
    local currentUIScale = UIParent:GetEffectiveScale()

    local expectedScale = nil
    if physicalWidth and physicalWidth > 0 then
        expectedScale = (GetScreenWidth() * currentUIScale) / physicalWidth
    end

    local currentBlackboardScale = self.blackboard and self.blackboard:GetScale() or nil

    local needUpdate = false

    if physicalWidth ~= self.lastPhysicalWidth then
        needUpdate = true
    end

    if currentUIScale ~= self.lastUIScale then
        needUpdate = true
    end

    if expectedScale and currentBlackboardScale and math.abs(expectedScale - currentBlackboardScale) > 0.001 then
        needUpdate = true
    end

    if needUpdate and physicalWidth and physicalWidth > 0 and self.blackboard and self.blackboard.setReadScreenWidth then

        self.lastPhysicalWidth = physicalWidth
        self.lastUIScale = currentUIScale

        self.blackboard.setReadScreenWidth(physicalWidth)
    end
end

function PixelComm:processQueue()
    if #self.sendQueue == 0 then
        self.isSending = false
        return
    end

    self.isSending = true
    local item = table.remove(self.sendQueue, 1)
    
    self.padWriteIndex = 0
    local pixel = self:PixelPrototype()

    local len = #item.segmentData
    local lowbit = bit.band(len, 255)
    local hightbit = bit.rshift(len, 8)

    pixel:pushbyte(bit.rshift(self.commandID, 8))
    pixel:pushchar("1")
    pixel:pushbyte(bit.band(self.commandID, 255))

    pixel:pushbyte(lowbit)
    pixel:pushchar("9")
    pixel:pushbyte(hightbit)
    
    pixel:pushbyte(bit.band(bit.rshift(item.timestamp_t, 16), 255))
    pixel:pushbyte(bit.band(bit.rshift(item.timestamp_t, 8), 255))
    pixel:pushbyte(bit.band(item.timestamp_t, 255))
    
    pixel:pushbyte(bit.band(item.timestamp_h, 255))
    pixel:pushbyte(bit.band(item.segment, 255))
    pixel:pushbyte(bit.band(item.totalSegments, 255))

    for i = 1, #item.segmentData do
        local char = string.sub(item.segmentData, i, i)
        pixel:pushchar(char)
    end

    pixel:pushchar("8")
    pixel:pushchar("2")
    pixel:flush()

    self.commandID = self.commandID + 1
    if self.commandID > 65535 then
        self.commandID = 0
    end

    C_Timer.After(2, function()
        self:processQueue()
    end)
end

function PixelComm:send(data)
    if not self.blackboard then
        return
    end

    self:clearDisplay()

    local timestamp = time()
    local timestamp_t = (timestamp % 10000000)
    local timestamp_h = (timestamp / 10000000)
    
    local totalSegments = math.ceil(#data / self.sendDataMaxLen)

    for segment = 1, totalSegments do
        local startPos = (segment - 1) * self.sendDataMaxLen + 1
        local endPos = math.min(segment * self.sendDataMaxLen, #data)
        local segmentData = string.sub(data, startPos, endPos)
        
        table.insert(self.sendQueue, {
            segmentData = segmentData,
            timestamp_t = timestamp_t,
            timestamp_h = timestamp_h,
            segment = segment,
            totalSegments = totalSegments
        })
    end

    if not self.isSending then
        self:processQueue()
    end
end

function PixelComm:PixelPrototype()
    local pixel = {}
    pixel.__index = pixel

    function pixel:new()
        local self = setmetatable({}, pixel)
        return self
    end

    function pixel:pushchar(char)
        self:pushbyte(string.byte(char))
    end

    function pixel:pushbyte(byte)
        table.insert(self, byte)
        if #self >= 3 then
            self:flush()
        end
    end

    function pixel:flush()
        if not ns.PixelComm.blackboard then
            return
        end

        local p
        local ps = { ns.PixelComm.blackboard:GetChildren() }

        local physicalWidth, physicalHeight = GetPhysicalScreenSize()

        local rightMargin = 1
        local currentWidth = physicalWidth - rightMargin

        local x = ns.PixelComm.padWriteIndex % currentWidth
        local y = math.floor(ns.PixelComm.padWriteIndex / currentWidth)
        local rightX = currentWidth - 1 - x

        if #ps <= ns.PixelComm.padWriteIndex then
            p = CreateFrame("frame", "PixelComm_Pixel", ns.PixelComm.blackboard)
            p:SetWidth(1)
            p:SetHeight(1)
            p:SetPoint("TOPLEFT", rightX, -y)
            p:Show()
            p.texture = p:CreateTexture(nil, "BACKGROUND")
        else
            p = ps[ns.PixelComm.padWriteIndex + 1]
            p:ClearAllPoints()
            p:SetPoint("TOPLEFT", rightX, -y)
            p:Show()
        end

        p.texture:SetColorTexture(self:color(1), self:color(2), self:color(3), 1)
        p.texture:SetAllPoints(p)

        ns.PixelComm.padWriteIndex = ns.PixelComm.padWriteIndex + 1

        for k, v in pairs(self) do
            self[k] = nil
        end
    end

    function pixel:color(bit)
        if self[bit] == nil then
            return 0
        else
            return self[bit] / 255
        end
    end

    return pixel:new()
end

function PixelComm:compressData(data)
    if not data or data == "" then
        return nil
    end

    if not C_EncodingUtil then
        return nil
    end

    local dataSerialized = C_EncodingUtil.SerializeCBOR(data)
    if not dataSerialized then
        return nil
    end

    local dataCompressed = C_EncodingUtil.CompressString(dataSerialized, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
    if not dataCompressed then
        return nil
    end

    return dataCompressed
end

function PixelComm:sendCommand(cmd, data)
    if data == nil then data = "" end

    local originalLength = 0
    local dataStr = data
    
    if type(data) == "table" then
        if ns and ns.JsonUtils then
            dataStr = ns.JsonUtils.TableToJson(data)
            if not dataStr then
                return
            end
        else
            return
        end
    end
    
    originalLength = #dataStr
    
    local compressedData = self:compressData(dataStr)

    self:send(cmd .. ":" .. compressedData)

    if self.autoClearTimer then
        self.autoClearTimer:Cancel()
        self.autoClearTimer = nil
    end

    self.autoClearTimer = C_Timer.NewTimer(60, function()
        self:clearDisplay()
        self.autoClearTimer = nil
    end)
end

function PixelComm:onUpdate(elapsed)
    if time() - self.startTime >= 1 and not self.createdFrames then
        self:createFrames()
        self.createdFrames = true
    end
end

function PixelComm:initialize()
    local frame = CreateFrame("frame", "PixelCommInit", UIParent)

    frame:SetScript("OnUpdate", function(_, elapsed)
        self:onUpdate(elapsed)
    end)

    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(128)
    frame:EnableKeyboard(true)
    frame:SetPropagateKeyboardInput(true)
    frame.PropagateKeyboardInput = true

    self.startTime = time()
end

local pixelComm = PixelComm:new()
pixelComm:initialize()
ns.PixelComm = pixelComm