---
--- Created by Hugo
--- DateTime: 2023/6/10 14:37
---

---@class ActorTriggerBase : BaseClass
ActorTriggerBase = ActorTriggerBase or BaseClass()

function ActorTriggerBase:__init()
    self.enabled = true
    self.delay_timer_num = 0
end

function ActorTriggerBase:__delete()
    self:Reset()
end

function ActorTriggerBase:InitData(data)
    self.data = data
    self.anim_name = data.eventName
    self.delay = data.delay
end

function ActorTriggerBase:ResetDelay()
    if self.delay_timer_quest then
        for k, v in pairs(self.delay_timer_quest) do
            TimerQuest.Instance:CancelQuest(v)
            self.delay_timer_quest[k] = nil
        end
    end
    if self.scaled_timer_quest then
        for k, v in pairs(self.scaled_timer_quest) do
            TimerQuest.Instance:CancelScaledQuest(v)
            self.scaled_timer_quest[k] = nil
        end
    end
end

function ActorTriggerBase:Reset()
    self:ResetDelay()
    self.delay_timer_quest = nil
    self.scaled_timer_quest = nil
    self.delay_timer_num = 0
    self.data = nil
end

function ActorTriggerBase:Enabled(value)
    if value == nil then
        return self.enabled
    end
    self.enabled = value
end

--动画状态机事件
---@param state_info table @状态数据
function ActorTriggerBase:OnAnimatorEvent(params, state_info, source, target, anim_name)
    if not self.enabled then
        return
    end
    if self.delay then
        self:DelayTrigger(source, target, state_info)
    else
        self:__InvokeEventTrigger(source, target, state_info)
    end
end

---@param source GameObject @源
---@param target GameObject @目标
function ActorTriggerBase:__InvokeEventTrigger(source, target, state_info)
    if not self.enabled
            or not source
            or IsNil(source.gameObject)
            or not source.gameObject.activeInHierarchy then
        return
    end
    self:OnEventTriggered(source, target, state_info)
end

---@param source Transform
---@param target Transform
---@param state_info userdata @AnimatorStateInfo
function ActorTriggerBase:OnEventTriggered(source, target, state_info)
    -- override
end

local function DelayTriggerCallBack(cb_data)
    local self = cb_data[CbdIndex.self]
    local source = cb_data[CbdIndex.source]
    local target = cb_data[CbdIndex.target]
    local state_info = cb_data[CbdIndex.state_info]
    local token = cb_data[CbdIndex.token]
    CbdPool.ReleaseCbData(cb_data)
    if self.delay_timer_quest then
        self.delay_timer_quest[token] = nil
    end
    if self.scaled_timer_quest then
        self.scaled_timer_quest[token] = nil
    end
    self:__InvokeEventTrigger(source, target, state_info)
end

function ActorTriggerBase:DelayTrigger(source, target, state_info)
    local token = self.delay_timer_num
    self.delay_timer_num = self.delay_timer_num + 1
    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = self
    cbd[CbdIndex.source] = source
    cbd[CbdIndex.target] = target
    cbd[CbdIndex.state_info] = state_info
    cbd[CbdIndex.token] = token
    if self.data
            and self.data.unscaledDelay
            and self.data.unscaledDelay > 0 then
        if not self.delay_timer_quest then
            self.delay_timer_quest = {}
        end
        self.delay_timer_quest[token] = TimerQuest.Instance:AddDelayTimer(DelayTriggerCallBack, self.delay, cbd)
    else
        if not self.scaled_timer_quest then
            self.scaled_timer_quest = {}
        end
        self.scaled_timer_quest[token] = TimerQuest.Instance:AddScaledDelayTimer(DelayTriggerCallBack, self.delay, cbd)
    end
end

ActorTriggerBase._pool = {}

---@return ActorTriggerBase
function ActorTriggerBase.PopInstance(type)
    local list = ActorTriggerBase._pool[type]
    if not list or #list == 0 then
        local result = type.New()
        result.type = type
        return result
    end
    return table.remove(list)
end

function ActorTriggerBase.PushInstance(item)
    local type = item.type
    local list = ActorTriggerBase._pool[type]
    if not list then
        list = {}
        ActorTriggerBase._pool[type] = list
    end
    if #list < 100 then
        item:Reset()
        table.insert(list, item)
    else
        item:DeleteMe()
    end
end