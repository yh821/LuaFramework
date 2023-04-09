--[[
----------------------------------------------------
	created: 2020-10-26 11:22
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class failureNode : DecoratorNode
failureNode = BaseClass(DecoratorNode)

function failureNode:tick(delta_time)
    local state = self.children[1]:Tick(delta_time)
    if state == eNodeState.Success then
        return eNodeState.Failure
    end
    return state
end

