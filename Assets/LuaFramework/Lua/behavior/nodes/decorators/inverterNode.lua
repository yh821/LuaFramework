---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuanhuan.
--- DateTime: 2020/10/26 11:27
---

---@class inverterNode : DecoratorNode
inverterNode = BaseClass(DecoratorNode)

function inverterNode:Tick(delta_time)
    local state = self._children[1]:Tick(delta_time)
    if state == eNodeState.Failure then
        return eNodeState.Success
    elseif state == eNodeState.Success then
        return eNodeState.Failure
    end
    return state
end