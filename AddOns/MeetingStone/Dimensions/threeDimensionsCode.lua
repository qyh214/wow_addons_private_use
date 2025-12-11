
-- threeDimensionsCode.lua 客户端通讯
-- @Date   : 07/02/2024, 10:01:07 AM
--
BuildEnv(...)

if bit == nil and bit32 ~= nil then
    bit = bit32
end

local PAD_WIDTH = GetScreenWidth()
local PAD_HEIGHT = 10

local ThreeDimensionsCode = {}
ThreeDimensionsCode.__index = ThreeDimensionsCode

function ThreeDimensionsCode:new()
    local self = setmetatable({}, ThreeDimensionsCode)
    self.outputDataMaxlen = bit.bor(bit.lshift(255, 8), 255)
    self.padWriteIndex = 0
    self.commandID = math.random(0, 1000)
    self.createdFrames = false
    self.addonHasLoaded = false
    self.loadedAddOns = 0
    self.realScreenWidth = -1
    self.lastCheckTime = 0
    self.startTime = time()
    return self
end

function ThreeDimensionsCode:createFrames()
    --[[@debug@
    print("Creating frames...")
    --@end-debug@]]
    self.blackboard = CreateFrame("frame", "ThreeDimensionsCode", nil)
    self.blackboard:SetPoint("TOPLEFT", 0, 0)
    self.blackboard:SetWidth(PAD_WIDTH)
    self.blackboard:SetHeight(PAD_HEIGHT)
    self.blackboard:SetFrameStrata("TOOLTIP")
    self.blackboard:SetFrameLevel(128)
    self.blackboard:Show()

    self.blackboard.setReadScreenWidth = function(width)
        self.realScreenWidth = width
        self.blackboard:SetScale((GetScreenWidth() * UIParent:GetEffectiveScale()) / self.realScreenWidth)
        --[[@debug@
        print("new width:", (GetScreenWidth() * UIParent:GetEffectiveScale()), "/", self.realScreenWidth)
        --@end-debug@]]
    end

        -- 获取并设置初始屏幕宽度
    local physicalWidth, physicalHeight = GetPhysicalScreenSize()
    if physicalWidth and physicalWidth > 0 then
        self.blackboard.setReadScreenWidth(physicalWidth)
        --[[@debug@
        print("Initial screen width set:", physicalWidth)
        --@end-debug@]]
    end

    -- 监听屏幕尺寸变化
    self:setupScreenSizeMonitor()
end

function ThreeDimensionsCode:setupScreenSizeMonitor()
    -- 创建监听屏幕尺寸变化的frame
    if not self.screenSizeMonitorFrame then
        self.screenSizeMonitorFrame = CreateFrame("Frame")
        self.lastPhysicalWidth = nil
        self.lastPhysicalHeight = nil
    end

    -- 设置更新脚本来监听屏幕尺寸变化
    self.screenSizeMonitorFrame:SetScript("OnUpdate", function(_, elapsed)
        self.lastCheckTime = self.lastCheckTime + elapsed
        -- 每1秒检查一次
        if self.lastCheckTime >= 1.0 then
            self.lastCheckTime = 0
            local physicalWidth, physicalHeight = GetPhysicalScreenSize()

            -- 检查屏幕尺寸是否发生变化
            if physicalWidth and physicalHeight and
            (physicalWidth ~= self.lastPhysicalWidth or physicalHeight ~= self.lastPhysicalHeight) then

                -- 更新记录的尺寸
                self.lastPhysicalWidth = physicalWidth
                self.lastPhysicalHeight = physicalHeight

                -- 如果有有效的宽度且blackboard已创建，则更新屏幕宽度
                if physicalWidth > 0 and self.blackboard and self.blackboard.setReadScreenWidth then
                    self.blackboard.setReadScreenWidth(physicalWidth)
                    --[[@debug@
                    print("Screen size changed, updated width:", physicalWidth)
                    --@end-debug@]]
                end
            end
        end
    end)
end

function ThreeDimensionsCode:send(data)
    if not self.blackboard then
        --[[@debug@
        print("Error: Blackboard not created!")
        --@end-debug@]]
        return
    end

    self.padWriteIndex = 0
    data = string.sub(data, 1, self.outputDataMaxlen)
    local pixel = self:PixelPrototype()

    local len = #data
    local lowbit = bit.band(len, 255)
    local hightbit = bit.rshift(len, 8)

    pixel:pushbyte(bit.rshift(self.commandID, 8))
    pixel:pushchar("1")
    pixel:pushbyte(bit.band(self.commandID, 255))
    pixel:pushbyte(lowbit)
    pixel:pushchar("9")
    pixel:pushbyte(hightbit)

    for i = 1, #data do
        local char = string.sub(data, i, i)
        pixel:pushchar(char)
    end

    pixel:pushchar("8")
    pixel:pushchar("2")
    pixel:flush()

    self.commandID = self.commandID + 1
    if self.commandID > 65535 then
        self.commandID = 0
    end
end

function ThreeDimensionsCode:PixelPrototype()
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
        if not _G.ThreeDimensionsCode.blackboard then
            --[[@debug@
            print("Error: Blackboard not created in PixelPrototype!")
            --@end-debug@]]
            return
        end

        local p
        local ps = { _G.ThreeDimensionsCode.blackboard:GetChildren() }

        if #ps <= _G.ThreeDimensionsCode.padWriteIndex then
            p = CreateFrame("frame", "ThreeDimensionsCode_Pixel", _G.ThreeDimensionsCode.blackboard)
            p:SetWidth(1)
            p:SetHeight(1)
            local x = _G.ThreeDimensionsCode.padWriteIndex % PAD_WIDTH
            local y = math.floor(_G.ThreeDimensionsCode.padWriteIndex / PAD_WIDTH)

            p:SetPoint("TOPLEFT", x, y)
            p:Show()
            p.texture = p:CreateTexture(nil, "BACKGROUND")
        else
            p = ps[_G.ThreeDimensionsCode.padWriteIndex + 1]
        end

        p.texture:SetColorTexture(self:color(1), self:color(2), self:color(3), 1)
        p.texture:SetAllPoints(p)

        _G.ThreeDimensionsCode.padWriteIndex = _G.ThreeDimensionsCode.padWriteIndex + 1

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

function ThreeDimensionsCode:sendCommand(cmd, data)
    if data == nil then data = "" end
    self:send(cmd .. ":" .. data)
end

function ThreeDimensionsCode:onEvent(event, addonName)
    if event == "ADDON_LOADED" and addonName:sub(1, 9) ~= "Blizzard_" then
        self.loadedAddOns = self.loadedAddOns + 1
        if self.loadedAddOns >= self.enabledAddOns and not self.addonHasLoaded then
            self:allAddOnsLoaded()
        end
    end
end

function ThreeDimensionsCode:onUpdate(elapsed)
    if time() - self.startTime >= 3 and not self.addonHasLoaded then
        self:allAddOnsLoaded()
    end
end

function ThreeDimensionsCode:allAddOnsLoaded()
    self.addonHasLoaded = true
    if not self.createdFrames then
        self:createFrames()
        self.createdFrames = true
    end
end

function ThreeDimensionsCode:initialize()
    -- 查看一共多少插件
    self.enabledAddOns = 0
    for i = 1, C_AddOns.GetNumAddOns() do
        local name, title, notes, enabled, loadable, reason, security = C_AddOns.GetAddOnInfo(i)
        if enabled and not C_AddOns.IsAddOnLoadOnDemand(i) then
            self.enabledAddOns = self.enabledAddOns + 1
        end
    end

    -- 注册事件
    local frame = CreateFrame("frame","3DCodeCmdInit",UIParent)
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(_, event, addonName)
        self:onEvent(event, addonName)
    end)

    frame:SetScript("OnUpdate", function(_, elapsed)
        self:onUpdate(elapsed)
    end)

    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(128)
    frame:EnableKeyboard(true)
    frame:SetPropagateKeyboardInput(true);
    frame.PropagateKeyboardInput = true
    frame:SetScript("OnKeyDown", function(_, event, ...)
        if IsAltKeyDown() and (event == "PAGEUP" or event == "PAGEDOWN") then
            if event == "PAGEDOWN" then
                ThreeDimensionsCode_Savepipe_Yin()
            elseif event == "PAGEUP" then
                ThreeDimensionsCode_Savepipe_Yang()
            end
        end
    end)

    -- 检查是否已经加载了所有插件
    self:start()
end

function ThreeDimensionsCode:start()
    self.startTime = time()
end

-- 实例化并初始化ThreeDimensionsCode类
local threeDimensionsCode = ThreeDimensionsCode:new()
threeDimensionsCode:initialize()
_G.ThreeDimensionsCode = threeDimensionsCode
