--[[
----------------------------------------------------
	created: 2020-11-23 19:06
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class weightNode : ActionNode
weightNode = BaseClass(ActionNode)

function weightNode:Tick()
	local weight = self.data.weight or 0
	local score = math.random(0, 1000)
	if score < weight then
		self:print("随机为真")
		self:SetState(eNodeState.Success)
	else
		self:print("随机为假")
		self:SetState(eNodeState.Failure)
	end
	return self.state
end

