require "common/define"

---@class CtrlManager : BaseClass
CtrlManager = CtrlManager or BaseClass();

function CtrlManager:__init()
    if CtrlManager.Instance then
        print_error("[CtrlManager] attempt to create singleton twice!")
        return
    end
    CtrlManager.Instance = self

    self.push_list = {
        "controller/Runner", --循环系统
        "controller/EventSystem", --事件系统
        "controller/TimerQuest", --定时器
        "controller/BaseController", --管理类基类

        "loader/ResMgr",
        "loader/ResPoolMgr",
        "loader/AssetBundleMgr",
        "loader/BundleCacheMgr",
        "loader/DownloadMgr",
        "loader/GameObjLoaderMgr",

        "controller/ViewManager", --界面管理器
        "controller/AiManager",

        "quality/ShieldMgr", --屏蔽管理器

        "game/scene/Scene",
        "game/mainui/MainUiCtrl",
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

    if Vector3Pool then
        Vector3Pool.Update(deltaTime, unscaledDeltaTime)
    end
end

function CtrlManager:InitAllCtrl()
    for i, v in ipairs(self.push_list) do
        require(v)
        local paths = Split(v, "/")
        local class_name = paths[#paths]
        if IsNilOrEmpty(class_name) then
            print_error("缺少管理类: " .. v)
        else
            local class = _G[class_name]
            if class then
                table.insert(self.ctrl_list, class.New())
            else
                print_error("缺少管理类: " .. v)
            end
        end
    end
end