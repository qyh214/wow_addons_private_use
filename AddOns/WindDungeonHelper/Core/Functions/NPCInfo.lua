local W, F, L = unpack(select(2, ...))
local NI = LibStub("LibNPCInfo")

function F.HandleNPCNameByID(id, callback)
	local cache = W.Database.locale

	if not cache.npcNames then
		cache.npcNames = {}
	end

	if cache.npcNames[id] then
		callback(cache.npcNames[id])
		return
	end

	NI.GetNPCInfoByID(id, function(data)
		callback(data.name)
		cache.npcNames[id] = data.name
	end, nil, nil)
end
