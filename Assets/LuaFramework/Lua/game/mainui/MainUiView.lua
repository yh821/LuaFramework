---
--- Created by Hugo
--- DateTime: 2022/5/6 0:18
---

---@class MainUiView : BaseView
MainUiView = MainUiView or BaseClass(BaseView)

--启动事件--
function MainUiView:__init(view_name)
    self.view_name = view_name
end

function MainUiView:__delete()
end

function MainUiView:LoadCallback()
    self.node_list["btn_add_pet"].button:AddClickListener(BindTool.Bind(self.OnAddPet, self))
    self.node_list["btn_open_ai"].button:AddClickListener(BindTool.Bind(self.OnOpenAi, self))
    self.node_list["btn_clean_all"].button:AddClickListener(BindTool.Bind(self.OnCleanSceneObj, self))
    for i = 1, 4 do
        self.node_list["btn_add_monster" .. i].button:AddClickListener(BindTool.Bind(self.OnAddMonster, self, i))
    end

    self:JoystickLoadCallback()
end

function MainUiView:OnOpenAi()
    print_log("切换AI开关")
    AiManager.Instance:SwitchTick()
end

function MainUiView:OnAddMonster(index)
    local role = Scene.Instance:GetMainRole()
    local pos = role:GetDrawObj():GetPosition() or Vector3Pool.GetTemp(0, 0, 0)
    local monster = Scene.Instance:CreateMonster({ pos_x = pos.x, pos_y = pos.y, pos_z = pos.z, name = "Zombie" })
    local bt = AiManager.Instance:BindBT(monster, "monster" .. index)
    bt:SetSharedVar(BtConfig.TargetObjKey, role)
end

function MainUiView:OnAddPet()
    local role = Scene.Instance:GetMainRole()
    local pos = role:GetDrawObj():GetPosition() or Vector3Pool.GetTemp(0, 0, 0)
    local pet = Scene.Instance:CreatePet({ pos_x = pos.x, pos_y = pos.y, pos_z = pos.z, name = "Pig" })
    local bt = AiManager.Instance:BindBT(pet, "pet")
    bt:SetSharedVar(BtConfig.TargetObjKey, role)
end

function MainUiView:OnCleanSceneObj()
    print_log("删除除主角外的场景对象")
    Scene.Instance:DeleteObjListByType(SceneObjType.Monster)
    Scene.Instance:DeleteObjListByType(SceneObjType.Pet)
end

--关闭事件--
function MainUiView:Close()
    PanelManager:ClosePanel(CtrlNames.Message);
end

--------------------------------------------------Joystick Begin--------------------------------------------------------

local DISTANCE_TO_MOVE = 30 * 30
local DISTANCE_TO_END = 25 * 25

function MainUiView:JoystickLoadCallback()
    self.is_touched = false
    self.is_joystick = false
    self.joystick_finger_index = -1
    self.control_id = -1

    local joystick = self.node_list["Joystick"].joystick
    joystick:AddTouchedListener(BindTool.Bind(self.OnJoystickTouched, self))
    joystick:AddDragUpdateListener(BindTool.Bind(self.OnJoystickUpdate, self))
    joystick:AddDragEndListener(BindTool.Bind(self.OnJoystickEnd, self))
end

function MainUiView:OnJoystickTouched(is_touched, finger_index)
    self.joystick_finger_index = finger_index
    self.is_touched = is_touched
    if not is_touched then
        self.is_joystick = false
    end
end

function MainUiView:OnJoystickUpdate(x, y)
    local delta = x * x + y * y
    local is_move
    if delta >= DISTANCE_TO_MOVE then
        is_move = true
    elseif delta < DISTANCE_TO_END then
        is_move = false
    else
        is_move = self.control_id == 2
    end
    if is_move then
        if not self.control_id then
            self:__OnControllerBegin(0)
        end
        self:__OnControllerUpdate(0, x, y)
    else
        self:__OnControllerEnd(0)
    end
    EventSystem.Instance:Fire(TouchEventType.JOYSTICK_UPDATE)
end

function MainUiView:OnJoystickEnd(x, y)
    self:__OnControllerEnd(0, true)
    EventSystem.Instance:Fire(TouchEventType.JOYSTICK_END)
end

function MainUiView:IsJoystick()
    return self.is_joystick
end

function MainUiView:__OnControllerBegin(id)
    if self.control_id > 0 and self.control_id ~= id then
        return
    end
    local main_role = Scene.Instance:GetMainRole()
    if not main_role:CanDoMove() then
        return
    end
    self.control_id = id
    EventSystem.Instance:Fire(TouchEventType.TOUCH_BEGIN)
end

function MainUiView:__OnControllerUpdate(id, x, y)
    if self.control_id ~= id then
        return
    end
    local main_role = Scene.Instance:GetMainRole()
    if not main_role:CanDoMove() then
        self.control_id = -1
        return
    end
end

function MainUiView:__OnControllerEnd(id)
    if self.control_id ~= id then
        return
    end
    self.control_id = -1
    local main_role = Scene.Instance:GetMainRole()
    if not main_role:CanDoMove() then
        self.control_id = -1
        return
    end
    EventSystem.Instance:Fire(TouchEventType.TOUCH_END)
end

---------------------------------------------------Joystick End---------------------------------------------------------