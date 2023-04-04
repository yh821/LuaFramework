--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class parallelSelectorNode : compositeNode
parallelSelectorNode = BaseClass(compositeNode)

function parallelSelectorNode:tick(delta_time)
	local state = eNodeState.failure
	if self.children then
		for _, v in ipairs(self.children) do
			if v.state == nil or v.state == eNodeState.running then
				v.state = v:tick(delta_time)
				if v.state == eNodeState.success then
					state = eNodeState.success
				end
			end
		end
	end
	return state
end