local AS, L, S, R = unpack(AddOnSkins)

function R:ClassicQuestLog()
	S:HandleFrame(ClassicQuestLog, "Transparent")
	S:HandleScrollBar(ClassicQuestLog.log)
	S:StripTextures(ClassicQuestLogInset)
	S:StripTextures(ClassicQuestLogScrollFrame.expandAll)
	S:StripTextures(ClassicQuestLog.chrome.countFrame)
	S:StripTextures(ClassicQuestLogScrollFrame)
	S:StripTextures(ClassicQuestLogDetailScrollFrame)

	for i = 1, ClassicQuestLog.chrome:GetNumChildren() do
		local object = select(i, ClassicQuestLog.chrome:GetChildren())
		if object:IsObjectType('Button') then
			if object:GetText() ~= nil then
				S:HandleButton(object, true)
			else
				S:HandleCloseButton(object, true)
			end
		end
	end

	--Reposition Expand/Collapse Button
	ClassicQuestLogScrollFrame.expandAll:ClearAllPoints()
	ClassicQuestLogScrollFrame.expandAll:SetPoint('BOTTOMLEFT', ClassicQuestLog, 'TOPLEFT', 10, -53)

	if ClassicQuestLog.chrome then
		ClassicQuestLog.chrome.countFrame:SetSize(100, 20)
		ClassicQuestLog.chrome.countFrame:ClearAllPoints()
		ClassicQuestLog.chrome.countFrame:SetPoint('LEFT', ClassicQuestLogScrollFrame.expandAll, 'RIGHT', -4, -4)

		--Reposition Show Map Button
		ClassicQuestLog.chrome.mapButton:ClearAllPoints()
		ClassicQuestLog.chrome.mapButton:SetPoint('BOTTOMRIGHT', ClassicQuestLog, 'TOPRIGHT', 0, -59)
		ClassicQuestLog.chrome.mapButton.text:SetFormattedText("Click") -- Install addon and fix this button.
	end

	--Resize Expand/Collapse Button
	ClassicQuestLogScrollFrame.expandAll:SetSize(120, 30)
	ClassicQuestLogScrollFrame.expandAll:SetFormattedText("Expand/Collapse")

	--Resize Show Map Button
	ClassicQuestLog.chrome.mapButton:SetSize(56, 40)
end

AS:RegisterSkin('Classic Quest Log', R.ClassicQuestLog)
