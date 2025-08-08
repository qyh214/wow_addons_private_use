---@class addon
local addon = select(2, ...)
local NS = addon.C.Animation; addon.C.Animation = NS

--------------------------------
-- FUNCTIONS (LOGIC)
--------------------------------

do
	NS.AnimationEngine = {}
	NS.AnimationEngine.AnimationIdentifier = {
		ALPHA = "Alpha",
		SCALE = "Scale",
		WIDTH = "Width",
		HEIGHT = "Height",
		TRANSLATE = "Translate",
		TRANSLATE_TO = "TranslateTo",
		TEXT_GRADIENT = "Text_Gradient",
		TEXTURE_ROTATE = "Texture_Rotate",
		TEXTURE_CONTINOUS_ROTATE = "Texture_ContinousRotate",
		RANGE_SET_PROGRESS = "Range_SetProgress",
		SCROLL_FRAME_SCROLL_TO = "ScrollFrame_ScrollTo",
	}

	--------------------------------

	do -- PROCESS
		do -- GENERAL
			local function GeneralProcess(animationIdentifier, func, frame, startTime, duration, startValue, endValue, easeName, stopEvent)
				if stopEvent and stopEvent() then
					func(frame, endValue)
					NS.AnimationEngine:ClearUpdater(frame, animationIdentifier)

					--------------------------------

					return
				end

				--------------------------------

				local currentTime = GetTime()
				local endTime = startTime + duration
				local progress = (currentTime - startTime) / duration
				local easedProgress = NS[easeName](progress)
				local currentValue = startValue + (endValue - startValue) * easedProgress

				if currentTime >= endTime then
					func(frame, endValue)
					NS.AnimationEngine:ClearUpdater(frame, animationIdentifier)
				else
					func(frame, currentValue)
				end
			end

			function NS.AnimationEngine:Process_Alpha(frame, startTime, duration, startValue, endValue, easeName, stopEvent)
				GeneralProcess(NS.AnimationEngine.AnimationIdentifier.ALPHA, frame.SetAlpha, frame, startTime, duration, startValue, endValue, easeName, stopEvent)
			end

			function NS.AnimationEngine:Process_Scale(frame, startTime, duration, startValue, endValue, easeName, stopEvent)
				GeneralProcess(NS.AnimationEngine.AnimationIdentifier.SCALE, frame.SetScale, frame, startTime, duration, startValue, endValue, easeName, stopEvent)
			end

			function NS.AnimationEngine:Process_Width(frame, startTime, duration, startValue, endValue, easeName, stopEvent)
				GeneralProcess(NS.AnimationEngine.AnimationIdentifier.WIDTH, frame.SetWidth, frame, startTime, duration, startValue, endValue, easeName, stopEvent)
			end

			function NS.AnimationEngine:Process_Height(frame, startTime, duration, startValue, endValue, easeName, stopEvent)
				GeneralProcess(NS.AnimationEngine.AnimationIdentifier.HEIGHT, frame.SetHeight, frame, startTime, duration, startValue, endValue, easeName, stopEvent)
			end

			function NS.AnimationEngine:Process_Translate(frame, startTime, duration, startValue, endValue, axis, easeName, stopEvent)
				if stopEvent and stopEvent() then
					local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
					local newOffsetX = axis == "x" and endValue or offsetX
					local newOffsetY = axis == "y" and endValue or offsetY

					frame:SetPoint(point, relativeTo, relativePoint, newOffsetX, newOffsetY)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TRANSLATE)

					--------------------------------

					return
				end

				--------------------------------

				local currentTime = GetTime()
				local endTime = startTime + duration
				local progress = (currentTime - startTime) / duration
				local easedProgress = NS[easeName](progress)
				local currentValue = startValue + (endValue - startValue) * easedProgress

				local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
				local newOffsetX = axis == "x" and currentValue or offsetX
				local newOffsetY = axis == "y" and currentValue or offsetY

				frame:SetPoint(point, relativeTo, relativePoint, newOffsetX, newOffsetY)

				if currentTime >= endTime then
					local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
					local newOffsetX = axis == "x" and endValue or offsetX
					local newOffsetY = axis == "y" and endValue or offsetY

					frame:SetPoint(point, relativeTo, relativePoint, newOffsetX, newOffsetY)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TRANSLATE)
				end
			end

			function NS.AnimationEngine:Process_TranslateTo(frame, startTime, duration, startX, startY, toX, toY, easeName, stopEvent)
				if stopEvent and stopEvent() then
					local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
					frame:SetPoint(point, relativeTo, relativePoint, toX, toY)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TRANSLATE_TO)

					--------------------------------

					return
				end

				--------------------------------

				local currentTime = GetTime()
				local endTime = startTime + duration
				local progress = (currentTime - startTime) / duration
				local easedProgress = NS[easeName](progress)
				local newX = startX + (toX - startX) * easedProgress
				local newY = startY + (toY - startY) * easedProgress

				local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
				frame:SetPoint(point, relativeTo, relativePoint, newX, newY)

				if currentTime >= endTime then
					local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
					frame:SetPoint(point, relativeTo, relativePoint, toX, toY)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TRANSLATE_TO)
				end
			end
		end

		do -- TEXT
			function NS.AnimationEngine:Process_Text_Gradient(frame, startTime, duration, elapsed, width, easeName, stopEvent)
				if stopEvent and stopEvent() then
					frame:SetAlpha(1)
					frame:SetIgnoreParentAlpha(false)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXT_GRADIENT)

					--------------------------------

					return
				end

				--------------------------------

				local updater = NS.AnimationEngine:GetUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXT_GRADIENT)
				local length = strlenutf8(frame:GetText() or "")
				local speed = ceil(length / duration) * 10
				local currentTime = GetTime() - startTime
				updater.progress = updater.progress + (elapsed * speed)

				local easedProgress = NS[easeName](currentTime)
				local new = updater.progress * easedProgress

				if not frame:SetAlphaGradient(new, width) then
					frame:SetAlpha(1)
					frame:SetIgnoreParentAlpha(false)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXT_GRADIENT)
				end
			end
		end

		do -- TEXTURE
			function NS.AnimationEngine:Process_Texture_Rotate(frame, startTime, duration, startRotation, endRotation, easeName, stopEvent)
				if stopEvent and stopEvent() then
					frame:SetRotation(endRotation % 360)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXTURE_ROTATE)

					--------------------------------

					return
				end

				--------------------------------

				local currentTime = GetTime()
				local progress = (currentTime - startTime) / duration
				local endTime = startTime + duration
				local easedProgress = NS[easeName](progress)
				local currentRotation = startRotation + (endRotation - startRotation) * easedProgress

				currentRotation = currentRotation % 360
				frame:SetRotation(currentRotation)

				if currentTime >= endTime then
					frame:SetRotation(endRotation % 360)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXTURE_ROTATE)
				end
			end

			function NS.AnimationEngine:Process_Texture_ContinousRotate(frame, startTime)
				local updater = NS.AnimationEngine:GetUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXTURE_CONTINOUS_ROTATE)
				local speed = updater.rotationSpeed
				local currentTime = GetTime()

				local duration = .1
				local transition = (currentTime - startTime) / duration
				if transition >= 1 then transition = 1 end

				--------------------------------

				frame:SetRotation(updater.savedRotation + (speed * currentTime * transition))
				updater.savedRotation = updater.savedRotation + (speed * currentTime * transition)
			end
		end

		do -- RANGE
			function NS.AnimationEngine:Process_Range_SetProgress(frame, startTime, duration, value, easeName, stopEvent)
				if stopEvent and stopEvent() then
					frame:SetValue(value)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.RANGE_SET_PROGRESS)

					--------------------------------

					return
				end

				--------------------------------

				local updater = NS.AnimationEngine:GetUpdater(frame, NS.AnimationEngine.AnimationIdentifier.RANGE_SET_PROGRESS)
				local currentTime = GetTime()
				local endTime = startTime + duration
				local progress = (currentTime - startTime) / duration
				local easedProgress = NS[easeName](progress)
				local newValue = updater.initialValue + updater.delta * easedProgress

				frame:SetValue(newValue)

				if currentTime >= endTime then
					frame:SetValue(value)

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.RANGE_SET_PROGRESS)
				end
			end
		end

		do -- SCROLL FRAME
			function NS.AnimationEngine:Process_ScrollFrame_ScrollTo(frame, startTime, duration, direction, value, easeName, stopEvent)
				if stopEvent and stopEvent() then
					if direction == "VERTICAL" then frame:SetVerticalScroll(value) else frame:SetHorizontalScroll(value) end

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.SCROLL_FRAME_SCROLL_TO)

					--------------------------------

					return
				end

				--------------------------------

				local updater = NS.AnimationEngine:GetUpdater(frame, NS.AnimationEngine.AnimationIdentifier.SCROLL_FRAME_SCROLL_TO)
				local currentTime = GetTime()
				local endTime = startTime + duration
				local progress = (currentTime - startTime) / duration
				local easedProgress = NS[easeName](progress)
				local newPos = updater.initialPosition + (value - updater.initialPosition) * easedProgress

				if direction == "VERTICAL" then frame:SetVerticalScroll(newPos) else frame:SetHorizontalScroll(newPos) end

				if currentTime >= endTime then
					if direction == "VERTICAL" then frame:SetVerticalScroll(value) else frame:SetHorizontalScroll(value) end

					NS.AnimationEngine:ClearUpdater(frame, NS.AnimationEngine.AnimationIdentifier.SCROLL_FRAME_SCROLL_TO)
				end
			end
		end
	end

	do -- UPDATER
		function NS.AnimationEngine:CreateUpdater(frame, animationIdentifier)
			local updater = nil

			--------------------------------

			if not frame["AnimationEngine_" .. animationIdentifier .. "_Updater"] then
				if type(frame) ~= "FontString" then
					frame["AnimationEngine_" .. animationIdentifier .. "_Updater"] = CreateFrame("Frame", "$parent.AnimationEngine_" .. animationIdentifier .. "_Updater", frame:GetParent())
				else
					frame["AnimationEngine_" .. animationIdentifier .. "_Updater"] = CreateFrame("Frame", "$parent.AnimationEngine_" .. animationIdentifier .. "_Updater", frame)
				end
			end

			updater = frame["AnimationEngine_" .. animationIdentifier .. "_Updater"]

			--------------------------------

			return updater
		end

		function NS.AnimationEngine:ClearUpdater(frame, animationIdentifier)
			local updater = NS.AnimationEngine:GetUpdater(frame, animationIdentifier)

			if updater then
				updater:SetScript("OnUpdate", nil)
			end
		end

		function NS.AnimationEngine:GetUpdater(frame, animationIdentifier)
			return frame["AnimationEngine_" .. animationIdentifier .. "_Updater"]
		end
	end
end

--------------------------------
-- FUNCTIONS (SEQUENCER)
--------------------------------

do
	NS.Sequencer = {}

	--------------------------------

	do -- CREATE
		function NS.Sequencer:CreateLoop()
			local loop = {}
			loop.interval = 1
			loop.animation = nil
			loop.onStart = nil
			loop.onStop = nil
			loop.timer = nil

			--------------------------------

			do -- LOGIC
				do -- FUNCTIONS
					do -- SET
						function loop:SetInterval(interval)
							loop.interval = interval
						end

						function loop:SetAnimation(animation)
							loop.animation = animation
						end

						function loop:SetOnStart(onStart)
							loop.onStart = onStart
						end

						function loop:SetOnStop(onStop)
							loop.onStop = onStop
						end
					end

					do -- LOGIC
						function loop:Start()
							if loop.timer then
								loop.timer:Cancel()
							end

							if loop.onStart then
								loop.onStart()
							end

							loop.animation()
							loop.timer = C_Timer.NewTicker(loop.interval, loop.animation)
						end

						function loop:Stop()
							if loop.timer then
								loop.timer:Cancel()
							end

							if loop.onStop then
								loop.onStop()
							end
						end
					end
				end
			end

			--------------------------------

			return loop
		end

		function NS.Sequencer:CreateAnimation(data)
			local loop = {}
			loop.timers = {}

			--------------------------------

			do -- LOGIC
				do -- FUNCTIONS
					do -- LOGIC
						-- ["stopEvent"] = ...
						-- ["sequences"]
						--      -> ["Animation 1"]
						--           -> [1]
						--                -> ["wait"] = ...
						--                -> ["animation"] = function() ... end

						function loop:Play(id)
							local stopEvent = data.stopEvent
							local sequence = data.sequences[id]

							--------------------------------

							for i = 1, #sequence do
								local entry = sequence[i]
								local animation, wait = entry.animation, entry.wait

								--------------------------------

								if not wait then
									animation()
								else
									local timer = C_Timer.After(wait, function()
										if stopEvent and stopEvent() then
											return
										end

										--------------------------------

										animation()
									end)

									table.insert(loop.timers, timer)
								end
							end
						end

						function loop:Stop()
							if #loop.timers >= 1 then
								for i = 1, #loop.timers do
									loop.timers[i]:Cancel()
								end
							end
						end
					end
				end
			end

			--------------------------------

			return loop
		end
	end
end

--------------------------------
-- FUNCTIONS (MAIN)
--------------------------------

do
	do -- UTILITIES
		function NS:CancelAnimation(frame, animationIdentifier)
			NS.AnimationEngine:ClearUpdater(frame, animationIdentifier)
		end

		function NS:CancelAll(frame)
			for k, v in pairs(NS.AnimationEngine.AnimationIdentifier) do
				NS.AnimationEngine:ClearUpdater(frame, v)
			end
		end
	end

	do -- GENERAL
		function NS:Alpha(data)
			local frame, duration, from, to, ease, stopEvent = data.frame, data.duration, data.from, data.to, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not from and "AnimationEngine Missing field (from)" or not to and "AnimationEngine Missing field (to)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.ALPHA)

			--------------------------------

			NS.AnimationEngine:Process_Alpha(frame, startTime, duration, from, to, ease, stopEvent)
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_Alpha(frame, startTime, duration, from, to, ease, stopEvent)
			end)
		end

		function NS:Scale(data)
			local frame, duration, from, to, ease, stopEvent = data.frame, data.duration, data.from, data.to, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not from and "AnimationEngine Missing field (from)" or not to and "AnimationEngine Missing field (to)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.SCALE)

			--------------------------------

			NS.AnimationEngine:Process_Scale(frame, startTime, duration, from, to, ease, stopEvent)
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_Scale(frame, startTime, duration, from, to, ease, stopEvent)
			end)
		end

		function NS:Width(data)
			local frame, duration, from, to, ease, stopEvent = data.frame, data.duration, data.from, data.to, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not from and "AnimationEngine Missing field (from)" or not to and "AnimationEngine Missing field (to)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.WIDTH)

			--------------------------------

			NS.AnimationEngine:Process_Width(frame, startTime, duration, from, to, ease, stopEvent)
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_Width(frame, startTime, duration, from, to, ease, stopEvent)
			end)
		end

		function NS:Height(data)
			local frame, duration, from, to, ease, stopEvent = data.frame, data.duration, data.from, data.to, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not from and "AnimationEngine Missing field (from)" or not to and "AnimationEngine Missing field (to)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.HEIGHT)

			--------------------------------

			NS.AnimationEngine:Process_Height(frame, startTime, duration, from, to, ease, stopEvent)
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_Height(frame, startTime, duration, from, to, ease, stopEvent)
			end)
		end

		function NS:Translate(data)
			local frame, duration, from, to, axis, ease, stopEvent = data.frame, data.duration, data.from, data.to, data.axis, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not from and "AnimationEngine Missing field (from)" or not to and "AnimationEngine Missing field (to)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TRANSLATE)

			--------------------------------

			NS.AnimationEngine:Process_Translate(frame, startTime, duration, from, to, axis, ease, stopEvent)
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_Translate(frame, startTime, duration, from, to, axis, ease, stopEvent)
			end)
		end

		function NS:TranslateTo(data)
			local frame, duration, toX, toY, ease, stopEvent = data.frame, data.duration, data.toX, data.toY, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not toX and "AnimationEngine Missing field (toX)" or not toY and "AnimationEngine Missing field (toY)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TRANSLATE_TO)

			--------------------------------

			local _, _, _, startX, startY = frame:GetPoint()

			NS.AnimationEngine:Process_TranslateTo(frame, startTime, duration, startX, startY, toX, toY, ease, stopEvent)
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_TranslateTo(frame, startTime, duration, startX, startY, toX, toY, ease, stopEvent)
			end)
		end
	end

	do -- TEXT
		function NS:Text_Gradient(data)
			local frame, duration, width, ease, stopEvent = data.frame, data.duration, data.width, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not width and "AnimationEngine Missing field (width)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXT_GRADIENT)

			--------------------------------

			frame:SetAlphaGradient(0, width)
			frame:SetIgnoreParentAlpha(true)

			updater.progress = 0
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function(_, elapsed)
				NS.AnimationEngine:Process_Text_Gradient(frame, startTime, duration, elapsed, width, ease, stopEvent)
			end)
		end
	end

	do -- TEXTURE
		function NS:Texture_Rotate(data)
			local frame, duration, from, to, ease, stopEvent = data.frame, data.duration, data.from, data.to, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not from and "AnimationEngine Missing field (from)" or not to and "AnimationEngine Missing field (to)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXTURE_ROTATE)

			--------------------------------

			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_Texture_Rotate(frame, startTime, duration, from, to, ease, stopEvent)
			end)
		end

		function NS:Texture_ContinousRotate_Start(data)
			local frame, speed = data.frame, data.speed

			local err = not frame and "AnimationEngine Missing field (frame)" or not speed and "AnimationEngine Missing field (speed)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXTURE_ROTATE_CONTINOUS)

			--------------------------------

			updater.rotationSpeed = speed
			updater.savedRotation = frame:GetRotation()
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_Texture_ContinousRotate(frame, startTime)
			end)
		end

		function NS:Texture_ContinousRotate_Stop(data)
			local frame = data.frame

			local err = not frame and "AnimationEngine Missing field (frame)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local updater = NS.AnimationEngine:GetUpdater(frame, NS.AnimationEngine.AnimationIdentifier.TEXTURE_ROTATE_CONTINOUS)

			--------------------------------

			updater:SetScript("OnUpdate", nil)
		end
	end

	do -- RANGE
		function NS:Range_SetProgress(data)
			local frame, duration, value, ease, stopEvent = data.frame, data.duration, data.value, data.ease, data.stopEvent
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not value and "AnimationEngine Missing field (value)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.RANGE_SET_PROGRESS)

			--------------------------------

			updater.initialValue = frame:GetValue()
			updater.delta = value - updater.initialValue
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_Range_SetProgress(frame, startTime, duration, value, ease, stopEvent)
			end)
		end
	end

	do -- SCROLL FRAME
		function NS:ScrollFrame_ScrollTo(data)
			local frame, direction, value, ease, stopEvent = data.frame, data.direction, data.value, data.ease, data.stopEvent
			local duration = .25
			ease = ease or "EaseLinear"

			local err = not frame and "AnimationEngine Missing field (frame)" or not duration and "AnimationEngine Missing field (duration)" or not value and "AnimationEngine Missing field (value)"
			if err then
				print(err)
				return
			end

			--------------------------------

			local startTime = GetTime()
			local updater = NS.AnimationEngine:CreateUpdater(frame, NS.AnimationEngine.AnimationIdentifier.SCROLL_FRAME_SCROLL_TO)

			--------------------------------

			updater.initialPosition = direction == "VERTiCAL" and frame:GetVerticalScroll() or frame:GetHorizontalScroll()
			updater:SetScript("OnUpdate", nil)
			updater:SetScript("OnUpdate", function()
				NS.AnimationEngine:Process_ScrollFrame_ScrollTo(frame, startTime, duration, value, ease, stopEvent)
			end)
		end

		function NS:ScrollFrame_AddSmoothScrolling(frame, direction)
			frame:SetScript("OnMouseWheel", function(_, delta)
				if direction == "VERTICAL" then
					local current = frame:GetVerticalScroll()

					--------------------------------

					NS:ScrollFrame_ScrollTo({ ["frame"] = frame, ["direction"] = "VERTICAL", ["value"] = current + -delta * 100, ["ease"] = nil, ["stopEvent"] = nil })
				else
					local current = frame:GetHorizontalScroll()

					--------------------------------

					NS:ScrollFrame_ScrollTo({ ["frame"] = frame, ["direction"] = "HORIZONTAL", ["value"] = current + -delta * 100, ["ease"] = nil, ["stopEvent"] = nil })
				end
			end)
		end
	end

	do -- SPRITESHEET
		function NS:Spritesheet_Create(parent, path, rows, columns, playbackSpeed)
			local frame = CreateFrame("Frame")
			frame:SetParent(parent)

			--------------------------------

			local function Texture()
				frame.texture = frame:CreateTexture(nil, "BACKGROUND")
				frame.texture:SetTexture(path)
				frame.texture:SetAllPoints(frame)
			end

			--------------------------------

			Texture()

			--------------------------------

			local totalRows = rows
			local totalColumns = columns
			local totalFrames = totalRows * totalColumns
			local frameWidth = 1 / totalColumns
			local frameHeight = 1 / totalRows

			local currentFrame = 0

			--------------------------------

			frame.Play = function(reverse)
				local function Play(reverse)
					currentFrame = currentFrame + 1

					--------------------------------

					if currentFrame >= totalFrames then
						frame:SetAlpha(0)
						currentFrame = 0

						--------------------------------

						frame:SetScript("OnUpdate", nil)
					else
						if frame:GetAlpha() == 0 then
							frame:SetAlpha(1)
						end
					end

					--------------------------------

					local column = currentFrame % totalColumns
					local row = math.floor(currentFrame / totalColumns)

					local left = column * frameWidth
					local right = left + frameWidth
					local top = row * frameHeight
					local bottom = top + frameHeight

					--------------------------------

					if reverse then
						frame.texture:SetTexCoord(right, left, top, bottom)
					else
						frame.texture:SetTexCoord(left, right, top, bottom)
					end
				end

				--------------------------------

				frame:SetScript("OnUpdate", function(self, elapsed)
					self.elapsed = (self.elapsed or 0) + elapsed

					--------------------------------

					if self.elapsed >= playbackSpeed then
						self.elapsed = 0

						--------------------------------

						Play(reverse)
					end
				end)
			end

			--------------------------------

			return frame
		end

		function NS:Spritesheet_Play(frameTexture, path, totalFrames)
			local texture = frameTexture:GetTexture()
			frameTexture:SetTexture(path .. "_" .. "1" .. ".png")

			--------------------------------

			local currentFrame = 0

			--------------------------------

			frameTexture.Play = function()
				local function Play()
					currentFrame = currentFrame + 1

					--------------------------------

					if currentFrame >= totalFrames then
						frameTexture:SetTexture(texture)

						--------------------------------

						frameTexture:SetScript("OnUpdate", nil)
					end

					--------------------------------

					frameTexture:SetTexture(path .. "_" .. currentFrame .. ".png")
				end

				--------------------------------

				frameTexture:SetScript("OnUpdate", Play)
			end

			--------------------------------

			frameTexture.Play()
		end
	end

	do -- EFFECTS
		function NS:Effects_Parallax(frame, parent, startRequirement, isController)
			frame.EnterMouseX = nil
			frame.EnterMouseY = nil

			--------------------------------

			local function FollowCursor()
				if frame.EnterMouseX and frame.EnterMouseY then
					local MouseX, MouseY = addon.C.API.FrameUtil:GetMouseDelta(frame.EnterMouseX, frame.EnterMouseY)

					--------------------------------

					if not isController then
						if not startRequirement or (startRequirement and startRequirement()) then
							frame:SetPoint("CENTER", parent, MouseX / (25 * (frame.API_Animation_Parallax_Weight or 1)), -MouseY / (7.5 * (frame.API_Animation_Parallax_Weight or 1)))
						end
					end
				end
			end

			local function OnEnter()
				if not isController then
					if startRequirement() then
						frame.EnterMouseX, frame.EnterMouseY = GetCursorPosition()
						frame.API_Animation_Parallax_Update:Show()
					end
				end
			end

			local function OnLeave()
				frame.EnterMouseX, frame.EnterMouseY = nil, nil
				frame.API_Animation_Parallax_Update:Hide()

				--------------------------------

				NS.Animation:MoveTo(frame, (.5 / (frame.API_Animation_Parallax_Weight or 1)), "CENTER", parent, nil, nil, 0, 0, NS.Animation.EaseExpo_Out, function() return frame.EnterMouseX ~= nil or frame.EnterMouseY ~= nil end)
			end

			--------------------------------

			addon.C.FrameTemplates:CreateMouseResponder(parent, { enterCallback = OnEnter, leaveCallback = OnLeave })

			--------------------------------

			frame.API_Animation_Parallax_Update = CreateFrame("Frame", "$parent.API-Animation.lua -- Parallax", parent)
			frame.API_Animation_Parallax_Update:SetParent(parent)
			frame.API_Animation_Parallax_Update:SetScript("OnUpdate", function()
				FollowCursor()
			end)
		end
	end
end
