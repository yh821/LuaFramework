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
	local state = eNodeState.Failure
	if self.children then
		for _, v in ipairs(self.children) do
			local will_abort = self:GetAbortType() ~= eAbortType.None and v:IsCondition()
			if v:GetState() == nil or will_abort or v:GetState() == eNodeState.Running then
				v:SetState(v:Tick(delta_time))
				if v:GetState() == eNodeState.Success then
					state = eNodeState.Success
				end
			end
		end
	end
	return state
end