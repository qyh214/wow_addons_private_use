---@class addon
local addon = select(2, ...)
local NS = addon.C.TagManager; addon.C.TagManager = NS

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
		do -- ID
			Callback.Id = {}
			Callback.Id.Registry = {}

			--------------------------------

			-- Adds a frame to the reference registry under an id. The id must be unique.
			---@param frame any
			---@param id string
			function Callback.Id:Add(frame, id)
				local previousId = frame.ctm_id
				if previousId then Callback.Id:Remove(previousId) end
				frame.ctm_id = id

				if id then
					Callback.Id.Registry[id] = frame
				end
			end

			-- Removes the id from the reference registry.
			---@param id string
			function Callback.Id:Remove(id)
				if not id then return end

				--------------------------------

				local frame = Callback.Id.Registry[id]
				frame.ctm_id = nil
				Callback.Id.Registry[id] = nil
			end
		end

		do -- CLASS
			Callback.Class = {}
			Callback.Class.Registry = {}

			--------------------------------

			-- Adds a frame to a shared class.
			---@param frame any
			---@param class string
			function Callback.Class:Add(frame, class)
				local previousClass = frame.ctm_class
				if previousClass then Callback.Class:Remove(frame, previousClass) end
				frame.ctm_class = class

				if class then
					Callback.Class.Registry[class] = Callback.Class.Registry[class] or {}
					table.insert(Callback.Class.Registry[class], frame)
				end
			end

			-- Removes the frame from it's class.
			---@param frame any
			---@param class string
			function Callback.Class:Remove(frame, class)
				if not class then return end

				--------------------------------

				frame.ctm_class = nil

				local pos = addon.C.API.Util:FindValuePositionInTable(Callback.Class.Registry[class], frame)
				if pos and type(pos) == "number" then table.remove(Callback.Class.Registry[class], pos) end
			end
		end

		do -- GET
			-- Gets the frame from the reference registry under an id.
			---@param id string
			function Callback:GetElementById(id)
				return Callback.Id.Registry[id] or nil
			end

			-- Gets all the frames from the references registry under a class.
			---@param class string
			function Callback:GetElementsByClass(class)
				return Callback.Class.Registry[class] or {}
			end
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------
end
