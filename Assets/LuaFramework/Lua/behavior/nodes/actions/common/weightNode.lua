--[[
----------------------------------------------------
	created: 2020-11-23 19:06
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class weightNode : actionNode
weightNode = BaseClass(actionNode)

function weightNode:tick()
	local weight = self.data.weight or 0
	local score = math.random(0, 1000)
	if score < weight then
		self:print("随机为真")
		self.state = eNodeState.success
	else
		self:print("随机为假")
		self.state = eNodeState.failure
	end
	return self.state
end

