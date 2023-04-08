--[[
----------------------------------------------------
	created: 2020-12-07 16:59
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class randomPositionNode : ActionNode
randomPositionNode = BaseClass(ActionNode)

local MapManager = CS.MapManagerInterface
local IsCanMove = MapManager.IsCanMove

function randomPositionNode:Start()
	local pos = self:getNextPos()
	if IsCanMove(pos) then
		self:SetSharedVar('targetPos', pos)
		return eNodeState.success
	else
		return eNodeState.failure
	end
end