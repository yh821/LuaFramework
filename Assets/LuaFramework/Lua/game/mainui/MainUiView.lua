---
--- Created by Hugo
--- DateTime: 2022/5/6 0:18
---

---@class MainUiView : BaseView
MainUiView = MainUiView or BaseClass(BaseView)

--启动事件--
function MainUiView:__init(view_name)
    self.view_name = view_name

    self.monster_list = {}
    self.pet_list = {}
end

function MainUiView:__delete()
end

function MainUiView:LoadCallback()
    self.node_list.btn_open_ai.button:AddClickListener(BindTool.Bind(self.OnOpenAi, self))
    self.node_list.btn_add_monster.button:AddClickListener(BindTool.Bind(self.OnAddMonster, self))
    self.node_list.btn_add_pet.button:AddClickListener(BindTool.Bind(self.OnAddPet, self))
    self.node_list.btn_clear_scene_obj.button:AddClickListener(BindTool.Bind(self.OnClearSceneObj, self))
end

function MainUiView:OnOpenAi()
    AiManager.Instance:SwitchTick()
end

function MainUiView:OnAddMonster()
    local role = Scene.Instance:GetSceneObj(1)
    local pos = role:GetDrawObj():GetPosition() or Vector3Pool.GetTemp(0, 0, 0)
    local monster = Scene.Instance:CreateMonster({ pos_x = pos.x, pos_y = pos.y, pos_z = pos.z })
    table.insert(self.monster_list, monster)
    local bt = AiManager.Instance:BindBT(monster, "monster")
    bt:SetSharedVar(BtConfig.TargetObjKey, role)
end

function MainUiView:OnAddPet()
    local role = Scene.Instance:GetSceneObj(1)
    local pos = role:GetDrawObj():GetPosition() or Vector3Pool.GetTemp(0, 0, 0)
    local pet = Scene.Instance:CreatePet({ pos_x = pos.x, pos_y = pos.y, pos_z = pos.z })
    table.insert(self.pet_list, pet)
    local bt = AiManager.Instance:BindBT(pet, "pet")
    bt:SetSharedVar(BtConfig.TargetObjKey, role)
end

function MainUiView:OnClearSceneObj()
    for i, v in ipairs(self.monster_list) do
        v:DeleteMe()
    end
    self.monster_list = {}

    for i, v in ipairs(self.pet_list) do
        v:DeleteMe()
    end
    self.pet_list = {}
end

--关闭事件--
function MainUiView:Close()
    PanelMgr:ClosePanel(CtrlNames.Message);
end