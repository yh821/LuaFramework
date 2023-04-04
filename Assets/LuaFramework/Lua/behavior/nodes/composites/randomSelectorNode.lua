--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class randomSelectorNode : compositeNode
randomSelectorNode = BaseClass(compositeNode)

local _random = math.random

function randomSelectorNode:tick(delta_time)
	if self.children then
		local index = nil
		for i, v in ipairs(self.children) do
			if index == nil and v.state == eNodeState.running then
				index = i
			end
		end
		if index == nil then
			index = _random(1, #self.children)
		end
		local n = self.children[index]
		if n then
			n.state = n:tick(delta_time)
			return n.state
		end
	end
	return eNodeState.failure
end