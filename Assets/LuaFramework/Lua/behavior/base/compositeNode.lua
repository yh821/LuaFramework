--[[
----------------------------------------------------
	created: 2022-1-20 15:16
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
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

function CompositeNode:IsComposite()
    return true
end