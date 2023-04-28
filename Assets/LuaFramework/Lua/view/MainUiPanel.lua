local transform
local gameObject

---@class MainUiPanel
MainUiPanel = MainUiPanel or BaseClass()
local this = MainUiPanel

--启动事件--
function MainUiPanel.Awake(obj)
    gameObject = obj
    transform = obj.transform

    this.InitPanel()
end

--初始化面板--
function MainUiPanel.InitPanel()
    this.btn_open_ai = transform:FindChild("btn_open_ai").gameObject
end

--单击事件--
function MainUiPanel.OnDestroy()
end

