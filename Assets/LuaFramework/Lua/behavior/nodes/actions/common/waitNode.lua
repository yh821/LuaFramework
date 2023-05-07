---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuanhuan.
--- DateTime: 2020/10/26 10:12
---

---@class waitNode : ActionNode
waitNode = BaseClass(ActionNode)

local _random = math.random

function waitNode:Start()
    self.deltaTime = 0
    self.waitTime = _random(self.data.min_time, self.data.max_time)
end

function waitNode:Update(delta_time)
    if self.deltaTime >= self.waitTime then
        --self:print("等待完成")
        return eNodeState.Success
    end
    self.deltaTime = self.deltaTime + delta_time
    return eNodeState.Running
end

function waitNode:Abort()
    self:print("<color=red>打断等待</color>")
    return eNodeState.Failure
end