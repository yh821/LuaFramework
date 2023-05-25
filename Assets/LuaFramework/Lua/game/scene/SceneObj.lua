---
--- Created by Hugo
--- DateTime: 2023/5/6 17:35
---

---@class SceneObj
---@field draw_obj DrawObj
SceneObj = SceneObj or BaseClass()

SceneObjLayer = GameObject.Find("GameRoot/SceneObjLayer")
SceneObj.wait_enter_scene_obj_count = 0

function SceneObj:__init(vo, parent_scene)
    self.vo = vo
    self.parent_scene = parent_scene

    self.draw_obj = self:CreateDrawObj()

    self.moving = false

    self.is_wait_enter_scene = true
    SceneObj.wait_enter_scene_obj_count = SceneObj.wait_enter_scene_obj_count + 1
    self.wait_enter_scene_num = math.ceil(SceneObj.wait_enter_scene_obj_count / 2)
end

function SceneObj:__delete()
    self.is_enter_scene = nil
    self.wait_enter_scene_num = 0

    self:RemoveModel(SceneObjPart.Main)
end

---@return DrawObj
function SceneObj:CreateDrawObj()
    ---@type DrawObj
    local draw_obj = DrawObj.New(self, SceneObjLayer.transform)
    local vo = self.vo
    draw_obj:SetPosition(Vector3Pool.GetTemp(vo.pos_x or 0, vo.pos_y or 0, vo.pos_z or 0))
    return draw_obj
end

function SceneObj:Update(realtime, unscaledDeltaTime)
    self.wait_enter_scene_num = self.wait_enter_scene_num - 1
    if not self.is_enter_scene and self.wait_enter_scene_num <= 0 then
        self:OnEnterScene()
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

function SceneObj:ChangeModel(part, bundle, asset, callback)
    if not self.draw_obj or self.draw_obj:IsDeleted() then
        return
    end
    local part_obj = self.draw_obj:GetPart(part)
    part_obj.load_priority = self.load_priority
    part_obj:ChangeModel(bundle, asset, callback)
end

---@return DrawObj
function SceneObj:GetDrawObj()
    return self.draw_obj
end

function SceneObj:RemoveModel(part)
    if self.draw_obj then
        self.draw_obj:RemoveModel(part)
    end
end
