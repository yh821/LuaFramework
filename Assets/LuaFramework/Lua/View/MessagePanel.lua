local transform;
local gameObject;

MessagePanel = {};
local this = MessagePanel;

--启动事件--
function MessagePanel.Awake(obj)
    gameObject = obj;
    transform = obj.transform;

    this.InitPanel();
    print_warning("Awake lua--->>" .. gameObject.name);
end

--初始化面板--
function MessagePanel.InitPanel()
    this.btnClose = transform:FindChild("Button").gameObject;
end

--单击事件--
function MessagePanel.OnDestroy()
    print_warning("OnDestroy---->>>");
end

