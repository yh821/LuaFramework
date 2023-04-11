--[[
----------------------------------------------------
	created: 2020-11-30 21:31
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class checkStateNode : DecoratorNode
checkStateNode = BaseClass(DecoratorNode)

function checkStateNode:Update(delta_time)
	local stateId = self.owner:GetStateId()
	if stateId == self.stateId then
		if self.children then
			local v = self.children[1]
			if v:GetState() == nil or v:GetState() == eNodeState.Running then
				v:SetState(v:Tick(delta_time))
				return v:GetState()
			end
		end
	end
	return eNodeState.Failure
end