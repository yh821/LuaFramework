--[[
----------------------------------------------------
	created: 2020-10-26 11:28
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class successNode : DecoratorNode
successNode = BaseClass(DecoratorNode)

function successNode:Tick(delta_time)
	if self.children then
		local v = self.children[1]
		if v.state == eNodeState.failure or v.state == eNodeState.success then
			return eNodeState.success
		else
			return v.state
		end
	end
	return eNodeState.success
end