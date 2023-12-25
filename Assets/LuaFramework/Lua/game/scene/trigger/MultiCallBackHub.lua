---
--- Created by Hugo
--- DateTime: 2023/12/18 11:21
---

-- 用于绑定多个事件组件
---@class MultiCallBackHub : BaseClass
MultiCallBackHub = MultiCallBackHub or BaseClass()
MultiCallBackHub._token = 0

function MultiCallBackHub:__init()
    self.callbacks = {}
end

function MultiCallBackHub:AddCallBack(callback)
    if not callback then
        return
    end

    MultiCallBackHub._token = MultiCallBackHub._token + 1
    self.callbacks[MultiCallBackHub._token] = callback
    return MultiCallBackHub._token
end

function MultiCallBackHub:RemoveCallBack(token)
    if not token then
        return
    end
    if not self.callbacks[token] then
        return
    end
    self.callbacks[token] = nil
end

function MultiCallBackHub:Invoke(...)
    for _, callback in pairs(self.callbacks) do
        local result, error = pcall(callback, ...)
        if not result then
            print_error(error)
        end
    end
end

function MultiCallBackHub:Clear()
    for k, _ in pairs(self.callbacks) do
        self.callbacks[k] = nil
    end
end