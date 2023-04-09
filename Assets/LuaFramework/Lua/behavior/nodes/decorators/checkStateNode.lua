--[[
----------------------------------------------------
	created: 2020-11-30 21:31
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class checkStateNode : DecoratorNode
checkStateNode = BaseClass(DecoratorNode)

function checkStateNode:Tick(delta_time)
	local stateId = self.owner:GetStateId()
	if stateId == self.stateId then
		if self.children then
			local v = self.children[1]
			if v.state == nil or v.state == eNodeState.Running then
				v.state = v:Tick(delta_time)
				return v.state
			end
		end
	end
	return eNodeState.Failure
end