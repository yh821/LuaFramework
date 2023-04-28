---
--- Created by Hugo
--- DateTime: 2023/4/28 14:58
---

require("common/Event")
---@class EventSystem
EventSystem = EventSystem or BaseClass()
EventSystem._delay_args_pool = {}

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