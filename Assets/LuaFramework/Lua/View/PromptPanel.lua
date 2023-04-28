local transform;
local gameObject;

PromptPanel = {};
local this = PromptPanel;

--启动事件--
function PromptPanel.Awake(obj)
    gameObject = obj;
    transform = obj.transform;

    this.InitPanel();
    print_warning("Awake lua--->>" .. gameObject.name);
end

--初始化面板--
function PromptPanel.InitPanel()
    this.btnOpen = transform:Find("Open").gameObject;
    this.label = transform:Find("Label").gameObject;
    this.gridParent = transform:Find('ScrollView/Grid');
end

--单击事件--
function PromptPanel.OnDestroy()
    print_warning("OnDestroy---->>>");
end