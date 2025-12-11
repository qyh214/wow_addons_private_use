local env               = select(2, ...)

local assert            = assert
local type              = type
local GetCursorPosition = GetCursorPosition

local Utils_General     = env.WPM:New("wpm_modules/utils/general")


-- API
--------------------------------

function Utils_General.GetMouseDelta(originX, originY)
    assert(originX, "`GetMouseDelta`: expected originX, got " .. type(originX))
    assert(originY, "`GetMouseDelta`: expected originY, got " .. type(originY))

    local mouseX, mouseY = GetCursorPosition()
    local deltaX = mouseX - originX
    local deltaY = originY - mouseY

    return deltaX, deltaY
end
