--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class parallelNode : compositeNode
parallelNode = BaseClass(compositeNode)

function parallelNode:tick(delta_time)
	local state = eNodeState.success
	if self.children then
		for _, v in ipairs(self.children) do
			if v.state == nil or v.state == eNodeState.running then
				v.state = v:tick(delta_time)
				if v.state == eNodeState.failure then
					state = eNodeState.failure
				end
			end
		end
	end
	return state
end