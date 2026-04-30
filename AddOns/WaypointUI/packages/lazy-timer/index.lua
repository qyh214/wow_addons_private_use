local env = select(2, ...)
local LazyTimer = env.modules:New("packages\\lazy-timer")

local Mixin = Mixin

local dummy = CreateFrame("Frame"); dummy:Hide()
local Method_SetScript = getmetatable(dummy).__index.SetScript

local TimerMixin = {}

function TimerMixin:OnLoad()
    self.elapsed = 0
    self.action = nil
    self.delay = 0
end

function TimerMixin:SetAction(action)
    self.action = action
end

local function OnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= self.delay then
        self.elapsed = 0

        Method_SetScript(self, "OnUpdate", nil)
        self.action(self)
    end
end

function TimerMixin:Start(delay)
    self.delay = delay
    Method_SetScript(self, "OnUpdate", OnUpdate)
end

function TimerMixin:Stop()
    Method_SetScript(self, "OnUpdate", nil)
end

function LazyTimer.New()
    local timer = CreateFrame("Frame")

    Mixin(timer, TimerMixin)
    timer:OnLoad()

    return timer
end
