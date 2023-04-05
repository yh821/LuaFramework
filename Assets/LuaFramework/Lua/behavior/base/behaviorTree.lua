--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class behaviorTree
---@field child taskNode
---@field blackBoard table
---@field guid number
---@field restart boolean
behaviorTree = BaseClass()

local _id = 0

function behaviorTree:__init(data, file)
	_id = _id + 1
	self.uid = _id
	self.data = data
	self.file = file
	self:awake()
end

function behaviorTree:awake()
	self.child = nil
	self.blackBoard = nil
	self.child_count = 0
	self.restart = tonumber(self.data.restart) == 1
end

---@param node
function behaviorTree:addChild(node)
	self.child = node
end

---@return taskNode
function behaviorTree:getChildren()
	return self.child
end

function behaviorTree:isParent()
	return true
end

---@type fun(parent:taskNode)
local __ResetAll
__ResetAll = function(parent)
	parent:_reset()
	local children = parent:getChildren()
	if children then
		for i, v in ipairs(children) do
			__ResetAll(v)
		end
	end
end

function behaviorTree:Reset()
	__ResetAll(self.child)
end

function behaviorTree:Update(delta_time)
	if self.restart and (self.child.state == eNodeState.success or self.child.state == eNodeState.failure) then
		self:Reset()
	end
	if self.child.state == nil or self.child.state == eNodeState.running then
		self.child.state = self.child:tick(delta_time)
	end
end

---@type fun(parent:taskNode)
local __AbortAll
__AbortAll = function(parent)
	if parent.state == eNodeState.running then
		parent:abort()
		parent.state = eNodeState.failure
	end
	local children = parent:getChildren()
	if children then
		for i, v in ipairs(children) do
			__AbortAll(v)
		end
	end
end

function behaviorTree:abort()
	__AbortAll(self.child)
end

---@return table
function behaviorTree:getBlackboard()
	if self.blackBoard == nil then
		self.blackBoard = {}
	end
	return self.blackBoard
end

---@param key string
---@param value any
function behaviorTree:setSharedVar(key, value)
	local bb = self:getBlackboard()
	bb[key] = value
end

---@param key string
---@return any
function behaviorTree:getSharedVar(key)
	local bb = self:getBlackboard()
	return bb[key]
end

---@param stateId number
function behaviorTree:setStateId(stateId)
	self:setSharedVar('stateId', stateId)
end

---@return number
function behaviorTree:getStateId()
	return self:getSharedVar('stateId')
end