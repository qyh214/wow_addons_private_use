local env = select(2, ...)
local UIKit_Renderer_Cleaner = env.modules:Import("packages\\ui-kit\\renderer\\cleaner")
local UIKit_Renderer_Scanner = env.modules:Import("packages\\ui-kit\\renderer\\scanner")
local UIKit_Renderer = env.modules:New("packages\\ui-kit\\renderer")

UIKit_Renderer.Cleaner = UIKit_Renderer_Cleaner
UIKit_Renderer.Scanner = UIKit_Renderer_Scanner
