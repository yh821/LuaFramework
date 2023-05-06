﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2023/4/26 21:23
---

---@class Event
Event = Event or BaseClass()

function Event:__init(id)
    self.event_id = id
    self.bind_id_count = 0
    self.bind_num = 0
    self.event_func_list = {}
end

function Event:Fire(args)
    if UNITY_EDITOR then
        for i, v in pairs(self.event_func_list) do
            v(unpack(args))
        end
    else
        for i, v in pairs(self.event_func_list) do
            local s, e = pcall(func, unpack(args))
            if not s then
                print_error("Event:" .. self.event_id .. ", Invoke Error:" .. e)
            end
        end
    end
end

function Event:unBind(obj)
    if obj.event_id == self.event_id then
        self.bind_num = self.bind_num - 1
        self.event_func_list[obj.bind_id] = nil
    end
end

function Event:Bind(func)
    self.bind_num = self.bind_num + 1
    self.bind_id_count = self.bind_id_count + 1
    local obj = { event_id = self.event_id, bind_id = self.bind_id_count }
    self.event_func_list[obj.bind_id] = func
    return obj
end

function Event:GetBindNum()
    return self.bind_num
end