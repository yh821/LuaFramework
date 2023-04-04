--[[
----------------------------------------------------
	created: 2020-10-26 11:22
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class decoratorNode : parentNode
decoratorNode = BaseClass(parentNode)

---@param node taskNode
function decoratorNode:addChild(node)
	if self.children == nil then
		self.children = {}
	end
	if #self.children > 0 then
		table.remove(self.children, 1)
	end
	table.insert(self.children, node)
end

function decoratorNode:isDecorator()
	return true
end
