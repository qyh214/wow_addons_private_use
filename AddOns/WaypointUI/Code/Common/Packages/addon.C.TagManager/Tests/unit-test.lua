local addon = select(2, ...)

--------------------------------
-- UNIT TEST
--------------------------------

do
	C_Timer.After(1, function()
		TAG_MANAGER_TEST_ID = addon.C.DevTools.Script.UnitTest:New({
			{
				name = "Initalize Environment",
				run = function(env, name)
					env.Frame = addon.C.FrameTemplates:CreateFrame("Frame", "Frame", nil)
					env.Frame:SetId("TEST_ID_001")
				end
			},
			{
				name = "Check if the frame is returned by querying by id",
				test = function(env, name)
					local criteria = addon.C.TagManager.Script:GetElementById("TEST_ID_001") == env.Frame
					return addon.C.DevTools.Script.UnitTest:Check("Get Frame by ID", criteria)
				end
			},
			{
				name = "Check if the frame id can be changed cleanly",
				run = function(env)
					env.Frame:SetId("TEST_ID_002")
				end,
				test = function(env, name)
					local prev = addon.C.TagManager.Script:GetElementById("TEST_ID_001")
					local new = addon.C.TagManager.Script:GetElementById("TEST_ID_002")
					local criteria = prev == nil and new == env.Frame
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Check if the new frame id can be returned by querying the new id",
				test = function(env, name)
					local criteria = addon.C.TagManager.Script:GetElementById("TEST_ID_002") == env.Frame
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			}
		})

		TAG_MANAGER_TEST_CLASS = addon.C.DevTools.Script.UnitTest:New({
			{
				name = "Setup test environment with solo and group frames",
				run = function(env, name)
					env.SoloFrame = addon.C.FrameTemplates:CreateFrame("Frame", "SoloFrame", nil)
					env.SoloFrame:SetClass("TEST_CLASS_SOLO")

					env.numGroupFrames = 10
					for i = 1, env.numGroupFrames do
						env["GroupFrame" .. i] = addon.C.FrameTemplates:CreateFrame("Frame", "GroupFrame" .. i, nil)
						env["GroupFrame" .. i]:SetClass("TEST_CLASS_GROUP")
					end
				end
			},
			{
				name = "Frame class change removes from old class and adds to new class",
				run = function(env)
					env.SoloFrame:SetClass("TEST_CLASS_SOLO_NEW")
				end,
				test = function(env, name)
					local prev = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_SOLO")[1]
					local new = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_SOLO_NEW")[1]
					local criteria = prev == nil and new == env.SoloFrame
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end,
			},
			{
				name = "Frame can be retrieved by its new class after class change",
				test = function(env, name)
					local criteria = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_SOLO_NEW")[1] == env.SoloFrame
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Frame can be retrieved by querying its assigned class",
				test = function(env, name)
					-- Note: SoloFrame was moved to class "TEST_CLASS_SOLO_NEW" in previous test, so "TEST_CLASS_SOLO" should be empty
					local oldClassFrames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_SOLO")
					local newClassFrames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_SOLO_NEW")
					local criteria = #oldClassFrames == 0 and #newClassFrames == 1 and newClassFrames[1] == env.SoloFrame
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "All frames in same class are returned by class query",
				test = function(env, name)
					local criteria = #addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_GROUP") == env.numGroupFrames
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Frame removal from class updates class member count",
				run = function(env)
					-- Move one of the GroupFrames to a different class
					env.GroupFrame1:SetClass("TEST_CLASS_MOVED")
				end,
				test = function(env, name)
					local criteria = #addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_GROUP") == env.numGroupFrames - 1
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Setting nil class removes frame from all classes",
				run = function(env)
					env.SoloFrame:SetClass(nil)
				end,
				test = function(env, name)
					-- SoloFrame was in class "TEST_CLASS_SOLO_NEW" from previous tests, should now be removed
					local criteria = #addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_SOLO_NEW") == 0
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Setting empty string class removes frame from all classes",
				run = function(env)
					env.GroupFrame2:SetClass("")
				end,
				test = function(env, name)
					-- GroupFrame1 was moved to "TEST_CLASS_MOVED", GroupFrame2 is now removed, so TEST_CLASS_GROUP should have numGroupFrames - 2
					local criteria = #addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_GROUP") == env.numGroupFrames - 2
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Multiple frames can have the same class",
				run = function(env)
					env.TestFrame1 = addon.C.FrameTemplates:CreateFrame("Frame", "TestFrame1", nil)
					env.TestFrame2 = addon.C.FrameTemplates:CreateFrame("Frame", "TestFrame2", nil)
					env.TestFrame1:SetClass("TEST_CLASS_SHARED")
					env.TestFrame2:SetClass("TEST_CLASS_SHARED")
				end,
				test = function(env, name)
					local frames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_SHARED")
					local criteria = #frames == 2 and
						(frames[1] == env.TestFrame1 or frames[1] == env.TestFrame2) and
						(frames[2] == env.TestFrame1 or frames[2] == env.TestFrame2) and
						frames[1] ~= frames[2]
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Querying non-existent class returns empty table",
				test = function(env, name)
					local frames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_NONEXISTENT")
					local criteria = type(frames) == "table" and #frames == 0
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Class names are case sensitive",
				run = function(env)
					env.CaseFrame = addon.C.FrameTemplates:CreateFrame("Frame", "CaseFrame", nil)
					env.CaseFrame:SetClass("TEST_CLASS_CaseSensitive")
				end,
				test = function(env, name)
					local upperFrames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_CASESENSITIVE")
					local lowerFrames = addon.C.TagManager.Script:GetElementsByClass("test_class_casesensitive")
					local correctFrames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_CaseSensitive")
					local criteria = #upperFrames == 0 and #lowerFrames == 0 and #correctFrames == 1
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			},
			{
				name = "Rapid class changes maintain consistency",
				run = function(env)
					env.RapidFrame = addon.C.FrameTemplates:CreateFrame("Frame", "RapidFrame", nil)
					env.RapidFrame:SetClass("TEST_CLASS_RAPID_1")
					env.RapidFrame:SetClass("TEST_CLASS_RAPID_2")
					env.RapidFrame:SetClass("TEST_CLASS_RAPID_3")
					env.RapidFrame:SetClass("TEST_CLASS_RAPID_1")
				end,
				test = function(env, name)
					local class1Frames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_RAPID_1")
					local class2Frames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_RAPID_2")
					local class3Frames = addon.C.TagManager.Script:GetElementsByClass("TEST_CLASS_RAPID_3")
					local criteria = #class1Frames == 1 and #class2Frames == 0 and #class3Frames == 0 and
						class1Frames[1] == env.RapidFrame
					return addon.C.DevTools.Script.UnitTest:Check(criteria)
				end
			}
		})

		TAG_MANAGER_TEST_RUN = function()
			-- addon.C.TagManager.Script.Id
			TAG_MANAGER_TEST_ID:Run()

			-- addon.C.TagManager.Script.Class
			TAG_MANAGER_TEST_CLASS:Run()
		end
	end)
end
