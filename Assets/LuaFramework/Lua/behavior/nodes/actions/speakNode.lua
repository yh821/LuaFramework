--[[
----------------------------------------------------
	created: 2020-12-07 16:54
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class speakNode : ActionNode
speakNode = BaseClass(ActionNode)

function speakNode:Start()
	if self.hudId == nil then
		self.hudId = hudControl:addHUD(self.owner.guid)
	end
	local widget = hudControl:getHUDWidget(self.hudId)
	if widget and self.data and self.data.say then
		widget:setText(self.data.say)
		return eNodeState.success
	else
		return eNodeState.failure
	end
end

function speakNode:Reset()
	self:shutUp()
	self.state = nil
end

function speakNode:Abort()
	self:shutUp()
end

function speakNode:shutUp()
	if self.hudId then
		hudControl:removeHUD(self.hudId)
		self.hudId = nil
	end
end