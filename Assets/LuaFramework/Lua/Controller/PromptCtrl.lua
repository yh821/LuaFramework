require("view/PromptPanel")

PromptCtrl = PromptCtrl or BaseClass()

--构建函数--
function PromptCtrl:__init()
    if PromptCtrl.Instance then
        print_error("[PromptCtrl] attempt to create singleton twice!")
        return
    end
    PromptCtrl.Instance = self
end

function PromptCtrl:__delete()
    self.gameObject = nil
    self.transform = nil
    self.panel = nil
    self.prompt = nil

    PromptCtrl.Instance=nil
end

function PromptCtrl:Open()
    PanelManager:CreatePanel("Prompt", BindTool.Bind(self.OnCreate, self))
end

--启动事件--
function PromptCtrl:OnCreate(obj)
    self.gameObject = obj
    self.transform = obj.transform

    self.panel = self.transform:GetComponent("UIPanel")
    self.prompt = self.transform:GetComponent("LuaBehaviour")

    self.prompt:AddClick(PromptPanel.btnOpen, BindTool.Bind(self.OnClick, self))
    ResourceManager:LoadPrefab("prompt", { "PromptItem" }, BindTool.Bind(self.InitPanel, self))
end

--初始化面板--
function PromptCtrl:InitPanel(objs)
    local count = 100
    local parent = PromptPanel.gridParent
    for i = 1, count do
        local go = Instantiate(objs[0])
        go.name = "Item" .. tostring(i)
        go.transform:SetParent(parent)
        go.transform.localScale = Vector3.one
        go.transform.localPosition = Vector3.zero
        self.prompt:AddClick(go, BindTool.Bind(self.OnItemClick, self))

        local label = go.transform:Find("Text")
        label:GetComponent("Text").text = tostring(i)
    end
end

--滚动项单击--
function PromptCtrl:OnItemClick(go)
    print_log(go.name)
end

--单击事件--
function PromptCtrl:OnClick(go)
    if TestProtoType == ProtocalType.BINARY then
        self.TestSendBinary()
    end
    if TestProtoType == ProtocalType.PB_LUA then
        self.TestSendPblua()
    end
    if TestProtoType == ProtocalType.PBC then
        self.TestSendPbc()
    end
    if TestProtoType == ProtocalType.SPROTO then
        self.TestSendSproto()
    end

    AiManager.Instance:BindBT(self.gameObject, "bt1")
    AiManager.Instance:SwitchTick()
end

--测试发送SPROTO--
function PromptCtrl:TestSendSproto()
    local sp = sproto.parse [[
    .Person {
        name 0 : string
        id 1 : integer
        email 2 : string

        .PhoneNumber {
            number 0 : string
            type 1 : integer
        }

        phone 3 : *PhoneNumber
    }

    .AddressBook {
        person 0 : *Person(id)
        others 1 : *Person
    }
    ]]

    local ab = {
        person = {
            [10000] = {
                name = "Alice",
                id = 10000,
                phone = {
                    { number = "123456789", type = 1 },
                    { number = "87654321", type = 2 },
                }
            },
            [20000] = {
                name = "Bob",
                id = 20000,
                phone = {
                    { number = "01234567890", type = 3 },
                }
            }
        },
        others = {
            {
                name = "Carol",
                id = 30000,
                phone = {
                    { number = "9876543210" },
                }
            },
        }
    }
    local code = sp:encode("AddressBook", ab)
    ----------------------------------------------------------------
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Message)
    buffer:WriteByte(ProtocalType.SPROTO)
    buffer:WriteBuffer(code)
    NetworkManager:SendMessage(buffer)
end

--测试发送PBC--
function PromptCtrl:TestSendPbc()
    local path = Util.DataPath .. "lua/3rd/pbc/addressbook.pb"

    local addr = io.open(path, "rb")
    local buffer = addr:read "*a"
    addr:close()
    protobuf.register(buffer)

    local addressbook = {
        name = "Alice",
        id = 12345,
        phone = {
            { number = "1301234567" },
            { number = "87654321", type = "WORK" },
        }
    }
    local code = protobuf.encode("tutorial.Person", addressbook)
    ----------------------------------------------------------------
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Message)
    buffer:WriteByte(ProtocalType.PBC)
    buffer:WriteBuffer(code)
    NetworkManager:SendMessage(buffer)
end

--测试发送PBLUA--
function PromptCtrl:TestSendPblua()
    local login = login_pb.LoginRequest()
    login.id = 2000
    login.name = "game"
    login.email = "jarjin@163.com"
    local msg = login:SerializeToString()
    ----------------------------------------------------------------
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Message)
    buffer:WriteByte(ProtocalType.PB_LUA)
    buffer:WriteBuffer(msg)
    NetworkManager:SendMessage(buffer)
end

--测试发送二进制--
function PromptCtrl:TestSendBinary()
    local buffer = ByteBuffer.New()
    buffer:WriteShort(Protocal.Message)
    buffer:WriteByte(ProtocalType.BINARY)
    buffer:WriteString("ffff我的ffffQ靈uuu")
    buffer:WriteInt(200)
    NetworkManager:SendMessage(buffer)
end

--关闭事件--
function PromptCtrl:Close()
    PanelManager:ClosePanel(CtrlNames.Prompt)
end