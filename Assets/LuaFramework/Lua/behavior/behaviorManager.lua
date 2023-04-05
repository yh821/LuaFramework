--[[
----------------------------------------------------
	created: 2020-10-26 11:06
	author : yuanhuan
	purpose:
----------------------------------------------------
]]

require("behavior/behaviorConfig")

---@class BehaviorManager
BehaviorManager = {}

local _format = string.format
local _print = log
local _error = logError

local _behaviorNodeDict = {}
---@type behaviorTree[]
local _behaviorTreeDict = {}
local _globalVariables = {}

function BehaviorManager:SwitchTick()
	self.is_tick = not self.is_tick
	if self.is_tick then
		log("[behaviorManager] 开始心跳")
	else
		log("[behaviorManager] 停止心跳")
		self:CleanTree()
	end
end

function BehaviorManager:CleanTree()
	for _, bt in pairs(_behaviorTreeDict) do
		bt:Reset()
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
function BehaviorManager:__LoadBehaviorTree(file)
	local json = require(_format('config/behavior/%s', file))
	if json then
		local bt = behaviorTree.New(json.data, file)
		local root = json.children[1]
		__GenBehaviorTree(root, bt, bt)
		return bt
	end
end

---@param file string
---@return behaviorTree
function BehaviorManager:BindBehaviorTree(gameObject, file)
	local bt = _behaviorTreeDict[gameObject]
	if bt then
		logError("实体已经绑定了行为树: " .. bt.file)
		return
	end
	bt = self:__LoadBehaviorTree(file)
	if bt == nil then
		logError('找不到行为树: ' .. file)
		return
	end
	_behaviorTreeDict[gameObject] = bt
	return bt
end

function BehaviorManager:UnBindBehaviorTree(gameObject)
	local bt = _behaviorTreeDict[gameObject]
	if not bt then
		return
	end
	_behaviorTreeDict[gameObject] = nil
	log('已解绑行为树:', bt.file)
end

function BehaviorManager:GetBehaviorTree(gameObject)
	return _behaviorTreeDict[gameObject]
end

function BehaviorManager:Update(delta_time)
	if not self.is_tick then
		return
	end
	for _, bt in pairs(_behaviorTreeDict) do
		bt:Update(delta_time)
	end
end

function BehaviorManager:SetGlobalVar(key, value)
	_globalVariables[key] = value
end

function BehaviorManager:GetGlobalVar(key)
	return _globalVariables[key]
end