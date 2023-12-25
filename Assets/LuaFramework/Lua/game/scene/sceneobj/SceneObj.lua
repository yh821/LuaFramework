---
--- Created by Hugo
--- DateTime: 2023/5/6 17:35
---

---@class SceneObj : VisibleObj
---@field draw_obj DrawObj
SceneObj = SceneObj or BaseClass(VisibleObj)

local GSceneObjLayer = GameObject.Find("GameRoot/SceneObjLayer").transform
local GUiObjLayer = GameObject.Find("GameRoot/UiObjLayer").transform
local GEffectLayer = GameObject.Find("GameRoot/EffectLayer").transform
SceneObj.wait_enter_scene_obj_count = 0

function SceneObj:__init(vo)
    self.obj_type = SceneObjType.Unknown
    self.shield_obj_type = ShieldObjType.SceneObj
    --self.follow_ui_class = FollowUI
    self.shadow_hide_when_self_hide = false
    self.follow_ui_hide_when_self_hide = false
    self.vo = vo

    self.draw_obj = self:CreateDrawObj()

    self.moving = false

    self.is_wait_enter_scene = true
    SceneObj.wait_enter_scene_obj_count = SceneObj.wait_enter_scene_obj_count + 1
    self.wait_enter_scene_num = math.ceil(SceneObj.wait_enter_scene_obj_count / 2)
end

function SceneObj:__delete()
    self.is_enter_scene = false
    self.wait_enter_scene_num = 0
    self.parent_scene = nil

    self:RemoveModel(SceneObjPart.Main)
    self:DeleteDrawObj()
end

function SceneObj:Init(scene)
    self.parent_scene = scene

    self.actor_trigger = ActorTrigger.New(self.obj_type, self.vo.name)
    self.actor_ctrl = ActorCtrl.New(self.actor_trigger)
    self:CreateShieldHandle()

    self.draw_obj:SetName(self.vo.name)

end

function SceneObj:CreateShieldHandle()
    --屏蔽规则
end

---@return DrawObj
function SceneObj:GetDrawObj()
    return self.draw_obj
end

---@return DrawObj
function SceneObj:CreateDrawObj()
    ---@type DrawObj
    local draw_obj = DrawObj.New(self, GSceneObjLayer)
    local vo = self.vo
    draw_obj:SetPosition(Vector3Pool.GetTemp(vo.pos_x or 0, vo.pos_y or 0, vo.pos_z or 0))
    return draw_obj
end

function SceneObj:DeleteDrawObj()
    if self.draw_obj then
        self.draw_obj:DeleteMe()
        self.draw_obj = nil
    end
end

function SceneObj:OnEnterScene()
    self.is_enter_scene = true
    if self.is_wait_enter_scene then
        SceneObj.wait_enter_scene_obj_count = math.max(0, SceneObj.wait_enter_scene_obj_count - 1)
    end
    self.is_wait_enter_scene = false
    self:InitAppearance()
end

function SceneObj:InitAppearance()
end

function SceneObj:Update(realtime, unscaledDeltaTime)
    self.wait_enter_scene_num = self.wait_enter_scene_num - 1
    if not self.is_enter_scene and self.wait_enter_scene_num <= 0 then
        self:OnEnterScene()
    end
end

function SceneObj:ChangeModel(part, bundle_name, asset_name, callback)
    if not self.draw_obj or self.draw_obj:IsDeleted() then
        return
    end
    local part_obj = self.draw_obj:GetPart(part)
    part_obj.load_priority = self.load_priority
    part_obj:ChangeModel(bundle_name, asset_name, callback)
end

function SceneObj:RemoveModel(part)
    if self.draw_obj then
        self.draw_obj:RemoveModel(part)
    end
end

function SceneObj:OnLoadSceneComplete()
    if self:IsDeleted() then
        return
    end

    self.draw_obj:SetPosition(self.real_pos.x, self.real_pos.y)
end

function SceneObj:GetObjId()
    return self.vo and self.vo.obj_id or 0
end

function SceneObj:GetType()
    return self.obj_type
end