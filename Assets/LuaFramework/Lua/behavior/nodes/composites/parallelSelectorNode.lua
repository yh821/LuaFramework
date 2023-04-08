--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class parallelSelectorNode : CompositeNode
parallelSelectorNode = BaseClass(CompositeNode)

function parallelSelectorNode:Tick(delta_time)
	local state = eNodeState.failure
	if self.children then
		for _, v in ipairs(self.children) do
			local will_abort = self:GetAbortType() ~= eAbortType.None and v:IsCondition()
			if v.state == nil or will_abort or v.state == eNodeState.running then
				v.state = v:Tick(delta_time)
				if v.state == eNodeState.success then
					state = eNodeState.success
				end
			end
		end
	end
	return state
end