local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")
local PA = B:GetModule("PrivateAuras")

function UF:CreatePrivateAuras(frame)
	frame.PrivateAuras = CreateFrame("Frame", frame:GetName().."PrivateAuras", frame)
	PA:RemoveAuras(frame.PrivateAuras)

	local db = C.db["UFs"]
	PA:SetupPrivateAuras(db, frame.PrivateAuras, frame.unit)
	frame.PrivateAuras:ClearAllPoints()
	frame.PrivateAuras:SetPoint("TOP", frame, "TOP", 0, 0)
	frame.PrivateAuras:SetSize(db.PrivateSize, db.PrivateSize)
	frame.PrivateAuras:SetFrameLevel(frame:GetFrameLevel() + 5)
end