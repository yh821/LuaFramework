---
--- Created by Hugo
--- DateTime: 2023/4/28 12:00
---

---@class TimerQuest : BaseClass
TimerQuest = TimerQuest or BaseClass()

function TimerQuest:__init()
    if TimerQuest.Instance then
        print_error("[TimerQuest] attempt to create singleton twice!")
        return
    end
    TimerQuest.Instance = self

    self.quest_list = {}
    self.scaled_quest_list = {}
    self.scaled_quest_token = 0
    self.check_callback_map = {}
    self.check_handle_map = {}
    self.execute_callback_list = {}

    Runner.Instance:AddRunObj(self, RunnerPriority.fast)
end

function TimerQuest:__delete()
    self.quest_list = {}
    self.scaled_quest_list = {}
    Runner.Instance:RemoveRunObj(self)

    TimerQuest.Instance = nil
end

function TimerQuest:Update(realtime, unscaledDeltaTime)
    local execute_num = 0
    for k, v in pairs(self.quest_list) do
        if v[4] <= 0 then
            self.quest_list[k] = nil
            self:DelCheckQuest(k)
        else
            if v[3] <= realtime then
                execute_num = execute_num + 1
                self.execute_callback_list[execute_num] = k
                v[3] = realtime + v[2]
                v[4] = v[4] - 1
            end
        end
    end
    for i = 1, execute_num do
        local quest = self.quest_list[self.execute_callback_list[i]]
        self.execute_callback_list[i] = nil
        if quest then
            TryCall(quest[1], quest[5])
        end
    end

    self:UpdateScaledTimer()
end

function TimerQuest:AddDelayTimer(callback, delay_time, cb_data)
    return self:AddTimesTimer(callback, delay_time, 1, cb_data)
end

function TimerQuest:AddTimesTimer(callback, delay_time, times, cb_data)
    local t = { callback, delay_time, Status.NowTime + delay_time, times, cb_data }
    self.quest_list[t] = t
    return t
end

function TimerQuest:AddRunQuest(callback, delay_time)
    local quest = self:AddTimesTimer(callback, delay_time, INF)
    self.check_callback_map[callback] = callback
    self.check_handle_map[quest] = callback
    return quest
end

function TimerQuest:InvokeRepeating(callback, start_time, delay_time, times, not_add_delay)
    local t
    t = self:AddTimesTimer(function()
        callback()
        if t then
            t[1] = callback
            t[2] = delay_time
            t[3] = Status.NowTime + (not not_add_delay and delay_time or 0)
            t[4] = times
        end
    end, start_time)
    return t
end

function TimerQuest:CancelQuest(quest)
    if quest == nil then
        return
    end
    self.quest_list[quest] = nil
    self:DelCheckQuest(quest)
end

function TimerQuest:EndQuest(quest)
    if quest == nil then
        return
    end
    local info = self.quest_list[quest]
    self.quest_list[quest] = nil
    if info then
        local callback = info[1]
        local cb_data = info[5]
        self:DelCheckQuest(quest)
        callback(cb_data)
    end
end

function TimerQuest:GetQuest(quest)
    if quest then
        return self.quest_list[quest]
    end
end

function TimerQuest:IsExistsListen(callback)
    return self.check_callback_map[callback] ~= nil
end

function TimerQuest:DelCheckQuest(quest)
    local handle = self.check_handle_map[quest]
    self.check_handle_map[quest] = nil
    if handle then
        self.check_callback_map[handle] = nil
    end
end

function TimerQuest:GetQuestCount(t)
    t.time_quest_count = 0
    for i, v in pairs(self.quest_list) do
        t.time_quest_count = t.time_quest_count + 1
    end
end

function TimerQuest:AddDelayCall(obj, callback, delay_time)
    obj.__delay_call_times = (obj.__delay_call_times or 0) + 1
    local key = "__delay_call_times_" .. obj.__delay_call_times % 1000
    self:ReDelayCall(obj, callback, delay_time, key)
end

function TimerQuest:ReDelayCall(obj, callback, delay_time, key)
    self:__DelayCall(obj, callback, delay_time, key, true)
end

function TimerQuest:TryDelayCall(obj, callback, delay_time, key)
    self:__DelayCall(obj, callback, delay_time, key, false)
end

function TimerQuest:__DelayCall(obj, callback, delay_time, key, is_recall)
    if "table" ~= type(obj) or obj.DeleteMe == nil then
        print_error("[DelayCall]参数错误，请指定正确的obj")
        return
    end
    if callback == nil then
        print_error("[DelayCall]参数错误，请指定正确的callback")
        return
    end
    if key == nil then
        print_error("[DelayCall]参数错误，请指定唯一key")
        return
    end

    if obj.__delay_call_map == nil then
        obj.__delay_call_map = {}
    end

    if obj.__delay_call_map[key] then
        if is_recall then
            self:CancelQuest(obj.__delay_call_map[key])
        else
            return
        end
    end

    local quest = self:AddDelayTimer(function()
        obj.__delay_call_map[key] = nil
        callback()
    end, delay_time)

    obj.__delay_call_map[key] = quest
end

function TimerQuest:CancelDelayCall(obj, key)
    if obj == nil or key == nil or obj.__delay_call_map then
        return
    end
    self:CancelQuest(obj.__delay_call_map[key])
    obj.__delay_call_map[key] = nil
end

function TimerQuest:CancelAllDelayCall(obj, key)
    if obj == nil or key == nil or obj.__delay_call_map then
        return
    end
    for i, v in pairs(obj.__delay_call_map) do
        self:CancelQuest(v)
    end
    obj.__delay_call_map = nil
    obj.__delay_call_times = 0
end



---@class ScaledTimerData 带缩放的Timer组
---@field next_time number
---@field interval number
---@field count number
---@field callback function
---@field data table

function TimerQuest:AddScaledDelayTimer(callback, delay, data)
    return self:AddScaledTimer(callback, delay, nil, 1, data)
end

function TimerQuest:AddScaledRepeatTimer(callback, interval, count, data)
    return self:AddScaledTimer(callback, nil, interval, count, data)
end

function TimerQuest:AddScaledTimer(callback, delay, interval, count, data)
    if not callback then
        print_error("Trying to add a timer without callback!")
        return
    end
    if not interval then
        interval = 0
    end
    if not delay then
        delay = interval
    end
    ---@type ScaledTimerData
    local t = {
        next_time = Status.NowScaleTime + delay,
        interval = interval,
        callback = callback,
        count = count,
        data = data
    }
    local token = self.scaled_quest_token
    self.scaled_quest_token = self.scaled_quest_token + 1
    self.scaled_quest_list[token] = t
    return token
end

---@return ScaledTimerData
function TimerQuest:CancelScaledQuest(token)
    local data = self.scaled_quest_list[token]
    self.scaled_quest_list[token] = nil
    return data
end

function TimerQuest:EndScaledQuest(token)
    local quest = self:CancelScaledQuest(token)
    if quest then
        if quest.callback then
            TryCall(quest.callback, quest.data)
        end
        return quest
    end
end

function TimerQuest:UpdateScaledTimer()
    for i, v in pairs(self.scaled_quest_list) do
        --至少等一帧，避开时序问题
        if v.next_time < Status.NowScaleTime then
            if v.count then
                v.count = v.count - 1
                if v.count < 1 then
                    self.scaled_quest_list[i] = nil
                end
            end
            if v.callback then
                TryCall(v.callback, v.data)
            else
                self.scaled_quest_list[i] = nil
            end
            v.next_time = v.next_time + v.interval
        end
    end
end






