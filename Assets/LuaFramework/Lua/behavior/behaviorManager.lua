--[[
----------------------------------------------------
	created: 2020-10-26 11:06
	author : yuanhuan
	purpose:
----------------------------------------------------
]]

require("behavior/behaviorConfig")

---@class behaviorManager
behaviorManager = {}

local _format = string.format
local _print = log
local _error = logError

local _behaviorNodeDict = {}
---@type behaviorTree[]
local _behaviorTreeDict = {}
local _globalVariables = {}

---@param interval number
function behaviorManager:startTick(interval)
	self.interval = interval or 0.2
	if self.timer == nil then
		self.timer = timer.new()
		self.timer:start(self.interval, function()
			self:Update(interval)
		end)
		_print('[behavior] 开始心跳')
	end
end

function behaviorManager:stopTick()
	if self.timer then
		self.timer:cancel()
		self.timer = nil
		_print('[behavior] 停止心跳')
	end
	self:cleanTree()
end

function behaviorManager:switchTick(is_tick)
	self.is_tick = is_tick and true or false
	if self.is_tick then
		log("[behaviorManager] 开始心跳")
	else
		log("[behaviorManager] 停止心跳")
		self:cleanTree()
	end
end

function behaviorManager:cleanTree()
	for _, bt in pairs(_behaviorTreeDict) do
		bt:reset()
	end
	_behaviorTreeDict = {}
end

---@type fun(json:table, parent:taskNode, tree:behaviorTree)
local __GenBehaviorTree
__GenBehaviorTree = function(json, parent, tree)
	if _behaviorNodeDict[json.file] == nil then
		_behaviorNodeDict[json.file] = true
		require("behavior/nodes/" .. json.type)
	end
	---@type BaseClass
	local class = _G[json.file]
	if class then
		local node = class.New(json.data, tree)
		parent:addChild(node)
		if json.children then
			for _, v in ipairs(json.children) do
				__GenBehaviorTree(v, node, tree)
			end
		end
	end
end

---@param file string
function behaviorManager:__LoadBehaviorTree(file)
	local json = require(_format('config/behavior/%s', file))
	if json then
		local bt = behaviorTree.New(json.data, file)
		__GenBehaviorTree(json.children[1], bt, bt)
		return bt
	end
end

---@param file string
---@return behaviorTree
function behaviorManager:bindBehaviorTree(gameObject, file)
	local bt = _behaviorTreeDict[gameObject]
	if bt then
		_error("实体已经绑定了行为树: " .. bt.file)
		return
	end
	bt = self:__LoadBehaviorTree(file)
	if bt == nil then
		_error('找不到行为树: ' .. file)
		return
	end
	_behaviorTreeDict[gameObject] = bt
	return bt
end

function behaviorManager:unBindBehaviorTree(gameObject)
	local bt = _behaviorTreeDict[gameObject]
	if not bt then
		return
	end
	_behaviorTreeDict[gameObject] = nil
	_print('已解绑行为树:', bt.file)
end

function behaviorManager:getBehaviorTree(gameObject)
	return _behaviorTreeDict[gameObject]
end

function behaviorManager:Update(delta_time)
	if not self.is_tick then
		return
	end
	for _, bt in pairs(_behaviorTreeDict) do
		bt:Update(delta_time)
	end
end

function behaviorManager:setGlobalVar(key, value)
	_globalVariables[key] = value
end

function behaviorManager:getGlobalVar(key)
	return _globalVariables[key]
end