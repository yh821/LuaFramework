--[[
----------------------------------------------------
	created: 2020-10-26 10:12
	author : yuanhuan
	purpose:
----------------------------------------------------
]]

---@class BehaviorTree
---@field child TaskNode
---@field blackBoard table
---@field gameObject userdata
BehaviorTree = BaseClass()

local _id = 0

function BehaviorTree:__init(data, file)
    _id = _id + 1
    self.uid = _id
    self.data = data
    self.file = file
    self:Awake()
end

function BehaviorTree:__delete()
    self:Recycle()
    self.gameObject = nil
end

function BehaviorTree:Awake()
    self.child = nil
    self.blackBoard = nil
    self.child_count = 0
    self.restart = tonumber(self.data.restart) == 1
end

function BehaviorTree:Update(delta_time)
    if self.child.state == nil or self.child.state == eNodeState.Running then
        self.child:SetState(self.child:Tick(delta_time))
    elseif self.restart then
        self:Reset()
    end
end

---@param node TaskNode
function BehaviorTree:AddChild(node)
    node.parent = self
    self.child = node
end

---@return TaskNode
function BehaviorTree:GetChildren()
    return self.child
end

function BehaviorTree:IsParent()
    return true
end

---@type fun(parent:TaskNode)
local __ResetNode
__ResetNode = function(node)
    local children = node:GetChildren()
    if children then
        for _, v in ipairs(children) do
            __ResetNode(v)
        end
    end
    node:__Reset()
end

function BehaviorTree:Reset()
    __ResetNode(self.child)
end

---@type fun(node:TaskNode)
local __RecycleNode
__RecycleNode = function(node)
    local children = node:GetChildren()
    if children then
        for _, v in ipairs(children) do
            __RecycleNode(v)
        end
    end
    node:Reset()
    --TODO 回收节点, 这里临时Delete
    node:DeleteMe()
end

function BehaviorTree:Recycle()
    __RecycleNode(self.child)
end

---@return table
function BehaviorTree:GetBlackboard()
    if self.blackBoard == nil then
        self.blackBoard = {}
    end
    return self.blackBoard
end

---@param key string
---@param value any
function BehaviorTree:SetSharedVar(key, value)
    local bb = self:GetBlackboard()
    bb[key] = value
end

---@param key string
---@return any
function BehaviorTree:GetSharedVar(key)
    local bb = self:GetBlackboard()
    return bb[key]
end

---@param stateId number
function BehaviorTree:SetStateId(stateId)
    self:SetSharedVar("stateId", stateId)
end

---@return number
function BehaviorTree:GetStateId()
    return self:GetSharedVar("stateId")
end

function BehaviorTree:IsComposite()
    return false
end