require("view/MessagePanel")

---@class MessageCtrl : BaseClass
MessageCtrl = MessageCtrl or BaseClass();

function MessageCtrl:__init()
    if MessageCtrl.Instance then
        print_error("[PromptCtrl] attempt to create singleton twice!")
        return
    end
    MessageCtrl.Instance = self
end

function MessageCtrl:__delete()
    self.gameObject = nil
    self.transform = nil
    self.panel = nil
    self.prompt = nil

    MessageCtrl.Instance = nil
end

function MessageCtrl:Open()
    PanelManager:CreatePanel("Message", BindTool.Bind(self.OnCreate, self))
end

--启动事件--
function MessageCtrl:OnCreate(obj)
    self.gameObject = obj;

    self.message = self.gameObject:GetComponent('LuaBehaviour');
    self.message:AddClick(MessagePanel.btnClose, BindTool.Bind(self.OnClick, self))
end

--单击事件--
function MessageCtrl:OnClick(go)
    Destroy(self.gameObject);
end

--关闭事件--
function MessageCtrl:Close()
    PanelManager:ClosePanel(CtrlNames.Message);
end