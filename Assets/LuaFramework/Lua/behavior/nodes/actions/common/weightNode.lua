--[[
----------------------------------------------------
	created: 2020-11-23 19:06
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class weightNode : ActionNode
weightNode = BaseClass(ActionNode)

function weightNode:Update(delta_time)
	local weight = self.data.weight or 0
	local score = math.random(0, 1000)
	if score < weight then
		self:print("随机为真")
		return eNodeState.Success
	else
		self:print("随机为假")
		return eNodeState.Failure
	end
end

