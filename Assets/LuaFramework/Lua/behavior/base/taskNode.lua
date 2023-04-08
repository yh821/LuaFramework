--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class eNodeState
---@field running number
---@field success number
---@field failure number
eNodeState = {
    running = 0,
    success = 1,
    failure = 2,
}

---@class TaskNode : BaseClass
---@field owner BehaviorTree
---@field uid number
---@field data table
---@field state eNodeState
TaskNode = BaseClass()

local _id = 0
local _openLog = true
local _format = string.format

---@param owner BehaviorTree
---@param data table
function TaskNode:__init(data, owner)
    _id = _id + 1
    self.uid = _id
    self.data = data
    self.owner = owner
    self:Awake()
end

function TaskNode:Awake()
    --override
end

---@return eNodeState
function TaskNode:Start()
    --override
end

---@return eNodeState
function TaskNode:Tick(delta_time)
    if self.state == nil then
        self.state = self:Start()
    end
    if self.state == nil or self.state == eNodeState.running then
        self.state = self:Update(delta_time)
    end
    return self.state
end

---@return eNodeState
function TaskNode:Update(delta_time)
    --override
end

function TaskNode:__Reset()
    if self.state == eNodeState.running then
        self:Abort()
    end
    self:Reset()
    self.state = nil
end

function TaskNode:Reset()
    --override
end

function TaskNode:Abort()
    --override
end

---@param node TaskNode
function TaskNode:AddChild(node)
    --override
end

function TaskNode:GetChildren()
    --override
end

---@param key string
---@param value any
function TaskNode:SetSharedVar(key, value)
	if key == nil or key == "" then
		return
	end
    local bb = self.owner:GetBlackboard()
    bb[key] = value
end

---@param key string
function TaskNode:GetSharedVar(key)
    if key == nil or key == "" then
        return
    end
    local bb = self.owner:GetBlackboard()
    return bb[key]
end

function TaskNode:IsAction()
    return false
end

function TaskNode:IsCondition()
    return false
end

function TaskNode:IsComposite()
    return false
end

function TaskNode:IsDecorator()
    return false
end

function TaskNode:IsParent()
    return false
end

function TaskNode:print(...)
    if _openLog then
        print(_format('[behavior][%s]', self.uid), ...)
    end
end