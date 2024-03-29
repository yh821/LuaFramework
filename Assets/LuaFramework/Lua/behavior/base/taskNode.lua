---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuanhuan.
--- DateTime: 2020/10/26 10:12
---

---@class eNodeState
eNodeState = {
    Failure = 0,
    Success = 1,
    Running = 2,
}

---@class TaskNode : BaseClass
---@field owner BehaviorTree
---@field uid number
---@field data table
---@field _state eNodeState
TaskNode = BaseClass()

local _id = 0
local _openLog = false
local _format = string.format

---@param owner BehaviorTree
---@param data table
function TaskNode:__init(file, data, owner)
    _id = _id + 1
    self.uid = _id
    self:__Awake(file, data, owner)
end

function TaskNode:__Awake(file, data, owner)
    self.file = file
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
    if self:IsNotExecuted() then
        self:SetState(self:Start())
    end
    if self:IsNotExecuted() or self:IsRunning() then
        self:SetState(self:Update(delta_time))
    end
    return self:GetState()
end

---@return eNodeState
function TaskNode:Update(delta_time)
    return eNodeState.Running
end

---@return boolean
function TaskNode:IsExecuted()
    return self._state ~= nil
end

---@return boolean
function TaskNode:IsNotExecuted()
    return self._state == nil
end

---@return boolean
function TaskNode:IsRunning()
    return self._state == eNodeState.Running
end

---@return boolean
function TaskNode:IsSucceed()
    return self._state == eNodeState.Success
end

---@return boolean
function TaskNode:IsFailed()
    return self._state == eNodeState.Failure
end

---@return number
function TaskNode:GetState()
    return self._state
end

---@return boolean @是否发生改变, 变成非nil不算
function TaskNode:SetState(state)
    local is_change = self._state ~= nil and self._state ~= state
    self._state = state
    --self:print("SetState:" .. (self._state or "nil"))
    return is_change
end

function TaskNode:Reset()
    --override
end

function TaskNode:Abort()
    --override
end

function TaskNode:Clear()
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

---@param key string
---@param value any
function TaskNode:SetSharedVar(key, value)
    if IsNilOrEmpty(key) then
        return
    end
    local bb = self.owner:GetBlackboard()
    bb[key] = value
end

---@param key string
function TaskNode:GetSharedVar(key)
    if IsNilOrEmpty(key) then
        return
    end
    local bb = self.owner:GetBlackboard()
    return bb[key]
end

function TaskNode:print(msg)
    if _openLog then
        print_log(_format("[<color=yellow>%s</color>]", self.uid), msg)
    end
end