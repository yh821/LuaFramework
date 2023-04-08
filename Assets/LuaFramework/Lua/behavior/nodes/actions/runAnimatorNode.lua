--[[
----------------------------------------------------
	created: 2020-11-23 19:08
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class runAnimatorNode : ActionNode
runAnimatorNode = BaseClass(ActionNode)

local MapManager = CS.MapManagerInterface
local RunAnimator = MapManager.RunAnimator

function runAnimatorNode:Start()
	if self.data and self.data.stateId then
		self:refresh(self.data.stateId)
	end
end

function runAnimatorNode:Update()
	self:refresh(self:GetSharedVar('animState'))
	if self:GetSharedVar('playState') == playStateEnum.eEnd then
		return eNodeState.success
	end
	return eNodeState.running
end

function runAnimatorNode:Abort()
	---中断行为暂时设置为idle动画
	self:refresh(animatorStateEnum.eIdle)
end

---@param stateId number
function runAnimatorNode:refresh(stateId)
	if self.lastStateId ~= stateId then
		self.lastStateId = stateId
		RunAnimator(self.owner.guid, stateId)
	end
end