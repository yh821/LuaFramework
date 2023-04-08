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
    table.insert(self.children, node)
end

function CompositeNode:GetAbortType()
    local abort = self.data and self.data.abort
    return eAbortType[abort] or eAbortType.None
end

function CompositeNode:IsComposite()
    return true
end