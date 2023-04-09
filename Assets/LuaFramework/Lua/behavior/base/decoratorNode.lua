--[[
----------------------------------------------------
	created: 2020-10-26 11:22
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class DecoratorNode : ParentNode
DecoratorNode = BaseClass(ParentNode)

---@param node TaskNode
function DecoratorNode:AddChild(node)
	if self.children == nil then
		self.children = {}
	end
	if #self.children > 0 then
		node.parent = nil
		table.remove(self.children, 1)
	end
	node.parent = self
	table.insert(self.children, node)
end

function DecoratorNode:IsDecorator()
	return true
end
