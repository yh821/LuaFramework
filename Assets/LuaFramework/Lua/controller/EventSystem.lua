---
--- Created by Hugo
--- DateTime: 2023/4/28 14:58
---

require("common/EventConfig")
require("common/Event")

---@class EventSystem : BaseClass
---@field event_list Event[]
EventSystem = EventSystem or BaseClass()
EventSystem.delay_args_pool = {}

function EventSystem:__init()
    if EventSystem.Instance then
        print_error("[EventSystem] attempt to create singleton twice!")
        return
    end
    EventSystem.Instance = self

    self.is_deleted = false
    self.event_list = {}
    self.check_callback_map = {}
    self.check_handle_map = {}
    self.need_fire_events = {}
    self.event_warning_num_map = {}
end

function EventSystem:__delete()
    self.is_deleted = true

    EventSystem.Instance = nil
end

function EventSystem:Update()
    if #self.need_fire_events > 0 then
        local events = self.need_fire_events
        self.need_fire_events = {}
        for _, v in pairs(events) do
            v.event:Fire(v.arg_list)
            EventSystem.PushDelayArgs(v)
        end
    end
end

function EventSystem:IsExistsListen(callback)
    return self.check_callback_map[callback] ~= nil
end

function EventSystem:GetEventCount(t)
    for k, v in pairs(self.event_list) do
        t["global_event:" .. k] = v:GetBindCount()
    end
end

function EventSystem:Bind(event_id, event_func)
    if self.is_deleted then
        return
    end
    if event_id == nil then
        return
    end
    local event = self.event_list[event_id]
    if event == nil then
        event = Event.New(event_id)
        self.event_list[event_id] = event
    end

    if UNITY_EDITOR then
        local count = event:GetBindCount()
        if count >= 30 then
            print_error("[EventSystem]监听事件太多, 请检查:", event_id, count)
        end
    end

    local handle = event:Bind(event_func)
    self.check_callback_map[event_func] = handle
    self.check_handle_map[handle] = event_func

    return handle
end

function EventSystem:UnBind(handle)
    if self.is_deleted then
        return
    end
    if not handle or not handle.event_id then
        return
    end
    if self.check_handle_map[handle] then
        self.check_callback_map[self.check_handle_map[handle]] = nil
        self.check_handle_map[handle] = nil
    end

    local event = self.event_list[handle.event_id]
    if event then
        event:UnBind(handle)
    end
end

function EventSystem:Fire(event_id, ...)
    if self.is_deleted then
        return
    end
    if event_id == nil then
        return
    end
    local event = self.event_list[event_id]
    if event then
        event:Fire({ ... })
    end
end

function EventSystem:FireNextFrame(event_id, ...)
    if self.is_deleted then
        return
    end
    if event_id == nil then
        return
    end
    local event = self.event_list[event_id]
    if event then
        local args = EventSystem.PopDelayArgs()
        args.event = event
        args.arg_list = { ... }
        table.insert(self.need_fire_events, args)
    end
end

function EventSystem.PushDelayArgs(args)
    args.event = nil
    args.arg_list = nil
    table.insert(EventSystem.delay_args_pool, args)
end

function EventSystem.PopDelayArgs()
    local args
    if #EventSystem.delay_args_pool > 0 then
        args = table.remove(EventSystem.delay_args_pool)
    else
        args = {}
    end
    return args
end