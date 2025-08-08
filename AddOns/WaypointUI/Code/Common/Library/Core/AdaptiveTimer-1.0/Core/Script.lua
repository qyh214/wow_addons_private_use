---@class addon
local addon = select(2, ...)
local NS = LibStub and LibStub("AdaptiveTimer-1.0", true)

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		function Callback:Schedule(callback, delay)
			local id = math.random(1, 9999999)
			local start = GetTime()

			--------------------------------

			local entry = {
				id = id,
				callback = callback,
				start = start,
				delay = delay,
			}

			table.insert(NS.Variables.Timers, entry)

			--------------------------------

			NS.UpdateFrame:Show()

			--------------------------------

			return id
		end

		function Callback:Cancel(id)
			local entries = NS.Variables.Timers

			--------------------------------

			local currentIndex = 0
			for k, v in pairs(entries) do
				currentIndex = currentIndex + 1

				--------------------------------

				if v.id == id then
					table.remove(NS.Variables.Timers, currentIndex)
					break
				end
			end
		end
	end

	--------------------------------
	-- FUNCTIONS (FRAME)
	--------------------------------


	--------------------------------
	-- EVENTS
	--------------------------------

	do
		NS.UpdateFrame = CreateFrame("Frame")
		NS.UpdateFrame:SetScript("OnUpdate", function(self, elapsed)
			local entries = NS.Variables.Timers
			local currentTime = GetTime()

			--------------------------------

			for k, v in pairs(entries) do
				if currentTime >= v.start + v.delay then
					v.callback()

					--------------------------------

					Callback:Cancel(v.id)
				end
			end

			--------------------------------

			if #entries <= 0 then
				self:Hide()
			end
		end)
	end

	--------------------------------
	-- SETUP
	--------------------------------
end

NS.Script:Load()
