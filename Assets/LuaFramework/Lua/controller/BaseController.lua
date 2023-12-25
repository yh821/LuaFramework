---
--- Created by Hugo
--- DateTime: 2023/12/21 15:06
---

---@class BaseController : BaseClass
BaseController = BaseController or BaseClass()

function BaseController:__init()
    self.event_map = {}
    self.msg_type_map = {}
end

function BaseController:__delete()
    for k, _ in pairs(self.event_map) do
        EventSystem.Instance:UnBind(k)
    end
    self.event_map = nil

    for k, v in pairs(self.msg_type_map) do
        ProtocolPool.Instance:UnRegister(v, k)
        GameNet.Instance:unRegisterMsgOperate(k)
    end
    self.msg_type_map = nil
end

---@param protocol table
---@param func_name function|string
function BaseController:RegisterProtocol(protocol, func_name)
    if protocol == nil then
        return
    end

    local msg_type = ProtocolPool.Instance:Register(protocol)
    if msg_type < 0 then
        return
    end

    self.msg_type_map[msg_type] = protocol

    if func_name then
        local callback
        local typo = type(func_name)
        if typo == "string" then
            callback = self[func_name]
        elseif typo == "function" then
            callback = func_name
        end
        if not callback then
            return
        end

        GameNet.Instance:RegisterMsgOperate(msg_type, BindTool.Bind1(callback, self))
    end
end

function BaseController:Fire(event_id, ...)
    EventSystem.Instance:Fire(event_id, ...)
end

function BaseController:FireNextFrame(event_id, ...)
    EventSystem.Instance:FireNextFrame(event_id, ...)
end

function BaseController:Bind(event_id, event_func)
    local handle = EventSystem.Instance:Bind(event_id, event_func)
    self.event_map[handle] = event_id
    return handle
end

function BaseController:UnBind(handle)
    if handle == nil then
        return
    end
    EventSystem.Instance:UnBind(handle)
    self.event_map[handle] = nil
end