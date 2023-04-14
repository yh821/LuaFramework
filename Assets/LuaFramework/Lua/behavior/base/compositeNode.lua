---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuanhuan.
--- DateTime: 2022/1/20 15:16
---

---@class CompositeNode : ParentNode
CompositeNode = BaseClass(ParentNode)

eAbortType = {
    None = 0,
    Self = 1,
    Lower = 2,
    Both = 3
}

---@param node TaskNode
function CompositeNode:AddChild(node)
    if self.children == nil then
        self.children = {}
    end
    node.parent = self
    table.insert(self.children, node)
end

function CompositeNode:GetAbortType()
    if self._abort_type == nil then
        local abort = self.data and self.data.abort
        self._abort_type = eAbortType[abort] or eAbortType.None
    end
    return self._abort_type
end

---@type fun(parent:TaskNode)
local __AbortNode
__AbortNode = function(node)
    local children = node:GetChildren()
    if children then
        for _, v in ipairs(children) do
            __AbortNode(v)
        end
    else
        if node:GetState() == eNodeState.Running then
            node:SetState(node:Abort())
        end
    end
end

function CompositeNode:AbortSelfNode(start_index)
    self:print("<color=red>打断Self节点</color>")
    for i = start_index, #self.children do
        __AbortNode(self.children[i])
    end
end

function CompositeNode:AbortLowerNode()
    self:print("<color=red>打断Lower节点</color>")
end

function CompositeNode:SetNeedReevaluate()
    self.need_revaluate = true
end

function CompositeNode:IsNeedReevaluate()
    return self.need_revaluate
end

function CompositeNode:IsComposite()
    return true
end