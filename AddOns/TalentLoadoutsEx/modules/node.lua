local addonName, Addon = ...;

-- [specID] = { nodeID, nodeID, ...}
local nodesList = {};
function Addon:GetNodes(specID, configID, treeID)
	if nodesList[specID] then
		return nodesList[specID];
	end

	local nodeOrder = {};
	for _, nodeID in pairs(C_Traits.GetTreeNodes(treeID)) do
		local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
		if nodeInfo.isVisible then
			table.insert(nodeOrder, {nodeInfo.posY, nodeInfo.posX, nodeID});
		end
	end

	table.sort(
		nodeOrder,
		function(a, b)
			if a[1] ~= b[1] then
				return a[1] < b[1];
			else
				return a[2] < b[2];
			end
		end
	);

	local nodeIDs = {};
	for _, node in ipairs(nodeOrder) do
		table.insert(nodeIDs, node[3]);
	end

	nodesList[specID] = nodeIDs;
	return nodeIDs;
end

-- [nodeID] = Order
local nodeOrderList = {};
function Addon:GetNodeOrder(specID, configID, treeID)
	if nodeOrderList[specID] then
		return nodeOrderList[specID];
	end

	local order = {};
	for index, nodeID in ipairs(Addon:GetNodes(specID, configID, treeID)) do
		order[nodeID] = index;
	end

	nodeOrderList[specID] = order;
	return order;
end
