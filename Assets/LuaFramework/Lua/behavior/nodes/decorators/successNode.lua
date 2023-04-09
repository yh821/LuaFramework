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
    local state = self.children[1]:Tick(delta_time)
    if state == eNodeState.Failure then
        return eNodeState.Success
    end
    return state
end