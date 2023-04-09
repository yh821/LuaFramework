--[[
----------------------------------------------------
	created: 2020-11-23 19:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class moveToPositionNode : ActionNode
moveToPositionNode = BaseClass(ActionNode)

local MapManager = CS.MapManagerInterface
local IsPositionEqual = MapManager.IsPositionEqual
local GetEntityPos = MapManager.GetTilemapObjectPosition
local MoveToPosition = MapManager.MoveToPosition
local StopMove = MapManager.StopMove

function moveToPositionNode:Start()
	self:SetSharedVar("playState", playStateEnum.eStart)
	local targetPos = self:GetSharedVar("targetPos")
	local entityPos = GetEntityPos(self.owner.guid)
	if targetPos == nil or IsPositionEqual(entityPos, targetPos) then
		self:SetSharedVar("playState", playStateEnum.eEnd)
		return eNodeState.failure
	else
		self:SetSharedVar("animState", animatorStateEnum.eWalk)
		MoveToPosition(self.owner.guid, targetPos, function()
			self:moveFinish()
		end)
		return eNodeState.running
	end
end

function moveToPositionNode:Abort()
	StopMove(self.owner.guid)
	self:moveFinish()
end

function moveToPositionNode:moveFinish()
	self:SetSharedVar("animState", animatorStateEnum.eIdle)
	self:SetSharedVar("playState", playStateEnum.eEnd)
	self.state = eNodeState.success
end