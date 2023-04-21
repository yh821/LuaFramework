--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]
---@class eNodeState
eNodeState = {
    Failure = 0,
    Success = 1,
    Running = 2,
}

---@class TaskNode : BaseClass
---@field owner BehaviorTree
---@field parent TaskNode
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
    if self:GetState() == nil then
        self:SetState(self:Start())
    end
    if self:GetState() == nil or self:GetState() == eNodeState.Running then
        self:SetState(self:Update(delta_time))
    end
    return self:GetState()
end

---@return eNodeState
function TaskNode:Update(delta_time)
    --override
end

---@return number
function TaskNode:GetState()
    return self.state
end

---@return boolean @是否发生改变, 变成非nil不算
function TaskNode:SetState(state)
    local is_change = self.state ~= nil and self.state ~= state
    --if self.state ~= state then
    --    self:print("状态改变", self.state, state)
    --end
    self.state = state
    return is_change
end

function TaskNode:__Reset()
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

---@return TaskNode[]
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

function TaskNode:IsNeedReevaluate()
    return false
end

function TaskNode:print(msg)
    if _openLog then
        log(_format("[<color=yellow>%s</color>] %s\n%s", self.uid, msg, debug.traceback()))
    end
end