local env = select(2, ...)
local UIFont_Enum = env.modules:New("packages\\ui-font\\enum")

UIFont_Enum.FontFlags = {
    [1] = "",
    [2] = "OUTLINE",
    [3] = "THICKOUTLINE",
    [4] = "MONOCHROME"
}
