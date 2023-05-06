---
--- Created by Hugo
--- DateTime: 2023/5/6 17:43
---

require("game/scene/SceneObj")
require("game/scene/Monster")

SceneObjType = {
    Unknown = 0,
    Role = 1,
    Monster = 2,
}

---@class Scene
Scene = Scene or BaseClass()

function Scene:__init()
    if Scene.Instance then
        print_error("[Scene] attempt to create singleton twice!")
        return
    end
    Scene.Instance = self

    self.obj_list = {}
end

function Scene:__delete()
    self:DeleteAllObj()

    Scene.Instance = nil
end

function Scene:DeleteAllObj()
    for k, v in pairs(self.obj_list) do
        self.obj_list[k] = nil
        v:DeleteMe()
    end
end

---@return Monster
function Scene:CreateMonster(vo)
    return self.CreateObj(vo, SceneObjType.Monster)
end

local client_obj_id = 0x10000
function Scene:GetSceneClientId()
    client_obj_id = client_obj_id + 1
    return client_obj_id
end

function Scene:CreateObj(vo, obj_type)
    if vo.obj_id < 0 then
        vo.obj_id = self:GetSceneClientId()
    end
    local old_obj = self.obj_list[vo.obj_id]
    if old_obj then
        print_error(string.format("[Scene] obj exits in obj_list, %s, %s, %s", old_obj:GetType(), vo.name, obj_type))
        return
    end
    ---@type SceneObj
    local obj
    if obj_type == SceneObjType.Role then
        obj = Role.New(vo)
    elseif obj_type == SceneObjType.Monster then
        obj = Monster.New(vo)
    end
    obj.draw_obj:SetObjType(obj_type)
    return obj
end