local env = select(2, ...)
local UIKit_Enum = env.modules:Import("packages\\ui-kit\\enum")
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_TagManager = env.modules:Import("packages\\ui-kit\\tag-manager")
local UIKit_UI = env.modules:Import("packages\\ui-kit\\ui")
local UIKit_Template = env.modules:Import("packages\\ui-kit\\template")
local UIKit_Renderer_Cleaner = env.modules:Import("packages\\ui-kit\\renderer\\cleaner")
local UIKit = env.modules:New("packages\\ui-kit")

UIKit.Enum = UIKit_Enum
UIKit.Define = UIKit_Define
UIKit.TagManager = UIKit_TagManager
UIKit.UI = UIKit_UI
UIKit.Template = UIKit_Template.New

UIKit.GetElementById = UIKit_TagManager.GetElementById
UIKit.AddElementToId = UIKit_TagManager.AddElementToId
UIKit.RemoveElementFromId = UIKit_TagManager.RemoveElementFromId
UIKit.NewGroupCaptureString = UIKit_TagManager.NewGroupCaptureString
UIKit.ReadGroupCaptureString = UIKit_TagManager.ReadGroupCaptureString
UIKit.IsGroupCaptureString = UIKit_TagManager.IsGroupCaptureString

UIKit.BeginBatch = UIKit_Renderer_Cleaner.BeginBatch
UIKit.EndBatch = UIKit_Renderer_Cleaner.EndBatch
