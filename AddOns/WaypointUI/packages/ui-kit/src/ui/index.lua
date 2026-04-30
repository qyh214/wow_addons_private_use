local env = select(2, ...)
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_UI_Parser = env.modules:Import("packages\\ui-kit\\ui\\parser")
local UIKit_UI = env.modules:New("packages\\ui-kit\\ui")

local function NewConstructorFor(type) return function(name, children) return UIKit_UI_Parser:CreateFrameFromType(type, name, children) end end

UIKit_UI.Frames = {
    NewConstructorFor("Frame"),
    NewConstructorFor("LayoutGrid"),
    NewConstructorFor("LayoutHorizontal"),
    NewConstructorFor("LayoutVertical"),
    NewConstructorFor("Text"),
    NewConstructorFor("ScrollContainer"),
    NewConstructorFor("LazyScrollContainer"),
    NewConstructorFor("ScrollBar"),
    NewConstructorFor("ScrollContainerEdge"),
    NewConstructorFor("Input"),
    NewConstructorFor("LinearSlider"),
    NewConstructorFor("HitRect"),
    NewConstructorFor("List")
}

--Pre defined
UIKit_UI.FIT = UIKit_Define.Fit{}
UIKit_UI.FILL = UIKit_Define.Fill{}
UIKit_UI.P_FILL = UIKit_Define.Percentage{ value = 100 }
UIKit_UI.TEXTURE_NIL = UIKit_Define.Texture{ path = nil }
UIKit_UI.NINESLICE_NIL = UIKit_Define.Texture_NineSlice{ path = nil, inset = 0, scale = 1 }
