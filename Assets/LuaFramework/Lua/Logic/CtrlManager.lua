require "Common/define"

---@class CtrlManager
CtrlManager = CtrlManager or BaseClass();

function CtrlManager:__init()
    if CtrlManager.Instance then
        print_error("[CtrlManager] attempt to create singleton twice!")
        return
    end
    CtrlManager.Instance = self

    self.push_list = {
        "Runner",
        "PromptCtrl",
        "MessageCtrl",
        "AiManager",
        "MainUiCtrl",
    }
    self.ctrl_list = {}

    self:InitAllCtrl()
end

function CtrlManager:__delete()
    self.push_list = nil
    for i, v in ipairs(self.ctrl_list) do
        v:DeleteMe()
    end
    self.ctrl_list = nil

    CtrlManager.Instance = nil
end

function CtrlManager:Update(deltaTime, unscaledDeltaTime)
    if Runner.Instance then
        Runner.Instance:Update(deltaTime, unscaledDeltaTime)
    end
end

function CtrlManager:InitAllCtrl()
    for i, v in ipairs(self.push_list) do
        require("Controller/" .. v)
        local class = _G[v]
        if class then
            table.insert(self.ctrl_list, class.New())
        else
            print_error("缺少类: " .. v)
        end
    end
end