---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuanhuan.
--- DateTime: 2020/10/26 10:12
---

---@class sequenceNode : CompositeNode
sequenceNode = BaseClass(CompositeNode)

function sequenceNode:Tick(delta_time)
    if self.children then
        local abort_type = self:GetAbortType()
        for i, v in ipairs(self.children) do
            if abort_type == eAbortType.Both or abort_type == eAbortType.Lower then
                if v:IsCondition() and v:GetState() ~= nil
                        and self:GetState() ~= eNodeState.Running and self:GetState() ~= nil
                        and self.parent:IsComposite() and self.parent:GetState() == eNodeState.Running
                then
                    if v:SetState(v:Tick(delta_time)) then
                        v:print("状态改变", v:GetState())
                        self:AbortLowerNode()
                    end
                end
            end
            if abort_type == eAbortType.Both or abort_type == eAbortType.Self then
                if v:IsCondition() and v:GetState() ~= nil
                        and self:GetState() == eNodeState.Running
                then
                    if v:SetState(v:Tick(delta_time)) then
                        v:print("状态改变", v:GetState())
                        if v:GetState() == eNodeState.Failure then
                            self:AbortSelfNode(i + 1) --打断i后的子节点
                            return v:GetState()
                        end
                    end
                end
            end
            if v:GetState() == nil or v:GetState() == eNodeState.Running then
                v:SetState(v:Tick(delta_time))
                if v:GetState() ~= eNodeState.Success then
                    return v:GetState()
                end
            end
        end
    end
    return eNodeState.Success
end
