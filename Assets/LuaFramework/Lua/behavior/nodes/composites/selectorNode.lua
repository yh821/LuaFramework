--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class selectorNode : CompositeNode
selectorNode = BaseClass(CompositeNode)

function selectorNode:Tick(delta_time)
	if self.children then
		for _, v in ipairs(self.children) do
			local will_abort = self:GetAbortType() ~= eAbortType.None and v:IsCondition()
			if v.state == nil or will_abort or v.state == eNodeState.running then
				v.state = v:Tick(delta_time)
				if v.state ~= eNodeState.failure then
					return v.state
				end
			end
		end
	end
	return eNodeState.failure
end