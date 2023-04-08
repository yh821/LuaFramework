--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class waitNode : ActionNode
waitNode = BaseClass(ActionNode)

local _random = math.random

function waitNode:Start()
	self.deltaTime = 0
	self.waitTime = _random(self.data.min_time, self.data.max_time)
end

function waitNode:Update(delta_time)
	if self.deltaTime >= self.waitTime then
		self:print("等待完成")
		return eNodeState.success
	end
	self.deltaTime = self.deltaTime + delta_time
	return eNodeState.running
end

function waitNode:Abort()
	self.state = eNodeState.failure
	return eNodeState.failure
end