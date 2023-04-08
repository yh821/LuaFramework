--[[
----------------------------------------------------
	created: 2020-12-07 16:52
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class setStateNode : ActionNode
setStateNode = BaseClass(ActionNode)

function setStateNode:Start()
	if self.data and self.data.stateId then
		self.owner:SetStateId(self.data.stateId)
		return eNodeState.success
	else
		return eNodeState.failure
	end
end

