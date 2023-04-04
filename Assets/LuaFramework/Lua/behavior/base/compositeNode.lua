--[[
----------------------------------------------------
	created: 2022-1-20 15:16
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class compositeNode : parentNode
compositeNode = BaseClass(parentNode)

---@param node taskNode
function compositeNode:addChild(node)
	if self.children == nil then
		self.children = {}
	end
	table.insert(self.children, node)
end

function compositeNode:isComposite()
	return true
end