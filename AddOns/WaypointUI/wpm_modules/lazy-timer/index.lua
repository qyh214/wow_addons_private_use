local env             = select(2, ...)
local MixinUtil       = env.WPM:Import("wpm_modules/mixin-util")

local Mixin           = MixinUtil.Mixin

local LazyTimer       = env.WPM:New("wpm_modules/lazy-timer")


-- Shared
--------------------------------

local dummy = CreateFrame("Frame"); dummy:Hide()
local Method_SetScript = getmetatable(dummy).__index.SetScript


-- Timer
--------------------------------

local TimerMixin = {}

function TimerMixin:OnLoad()
    self.elapsed = 0
    self.action = nil
    self.delay = 0
end

function TimerMixin.SetAction(self, action)
    self.action = action
end

local function handleOnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= self.delay then
        self.elapsed = 0

        Method_SetScript(self, "OnUpdate", nil)
        self.action(self)
    end
end

function TimerMixin.Start(self, delay)
    self.delay = delay
    Method_SetScript(self, "OnUpdate", handleOnUpdate)
end


function LazyTimer.New()
    local timer = CreateFrame("Frame")

    Mixin(timer, TimerMixin)
    timer:OnLoad()

    return timer
end
