local env                    = select(2, ...)
local UIKit_Enum             = env.WPM:Import("wpm_modules/ui-kit/enum")
local UIKit_Define           = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_TagManager       = env.WPM:Import("wpm_modules/ui-kit/tag-manager")
local UIKit_UI               = env.WPM:Import("wpm_modules/ui-kit/ui")
local UIKit_Prefab           = env.WPM:Import("wpm_modules/ui-kit/prefab")
local UIKit_Renderer_Cleaner = env.WPM:Import("wpm_modules/ui-kit/renderer/cleaner")
local UIKit                  = env.WPM:New("wpm_modules/ui-kit")

UIKit.Enum                   = UIKit_Enum
UIKit.Define                 = UIKit_Define
UIKit.TagManager             = UIKit_TagManager
UIKit.UI                     = UIKit_UI
UIKit.Prefab                 = UIKit_Prefab.New

UIKit.GetElementById         = UIKit_TagManager.GetElementById
UIKit.AddElementToId         = UIKit_TagManager.AddElementToId
UIKit.RemoveElementFromId    = UIKit_TagManager.RemoveElementFromId
UIKit.NewGroupCaptureString  = UIKit_TagManager.NewGroupCaptureString
UIKit.ReadGroupCaptureString = UIKit_TagManager.ReadGroupCaptureString
UIKit.IsGroupCaptureString   = UIKit_TagManager.IsGroupCaptureString

UIKit.BeginBatch             = UIKit_Renderer_Cleaner.BeginBatch
UIKit.EndBatch               = UIKit_Renderer_Cleaner.EndBatch
