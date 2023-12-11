---
--- Created by Hugo
--- DateTime: 2023/5/6 17:43
---

require("game/core/DrawPart")
require("game/core/DrawObj")

require("game/scene/ResPath")
require("game/scene/StateMachine")

require("game/scene/sceneobj/SceneObj")
require("game/scene/sceneobj/Character")
require("game/scene/sceneobj/Role")
require("game/scene/sceneobj/Pet")
require("game/scene/sceneobj/Monster")

---@class Scene
---@field obj_list SceneObj[]
Scene = Scene or BaseClass()

function Scene:__init()
    if Scene.Instance then
        print_error("[Scene] attempt to create singleton twice!")
        return
    end
    Scene.Instance = self

    self.obj_list = {}

    Runner.Instance:AddRunObj(self, 6)
end

function Scene:__delete()
    Runner.Instance:RemoveRunObj(self)

    self:DeleteAllObj()

    Scene.Instance = nil
end

function Scene:GetSceneObj(obj_id)
    if obj_id and self.obj_list then
        return self.obj_list[obj_id]
    end
end

function Scene:DeleteAllObj()
    for k, v in pairs(self.obj_list) do
        self.obj_list[k] = nil
        v:DeleteMe()
    end
end

---@return Role
function Scene:CreateRole(vo)
    return self:CreateObj(vo, SceneObjType.Role)
end
---@return Pet
function Scene:CreatePet(vo)
    return self:CreateObj(vo, SceneObjType.Pet)
end

---@return Monster
function Scene:CreateMonster(vo)
    return self:CreateObj(vo, SceneObjType.Monster)
end

local client_obj_id = 0x10000
function Scene:GetSceneClientId()
    client_obj_id = client_obj_id + 1
    return client_obj_id
end

function Scene:CreateObj(vo, obj_type)
    if vo.obj_id == nil or vo.obj_id < 0 then
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
        obj = Role.New(vo, self)
    elseif obj_type == SceneObjType.Pet then
        obj = Pet.New(vo, self)
    elseif obj_type == SceneObjType.Monster then
        obj = Monster.New(vo, self)
    end
    self.obj_list[vo.obj_id] = obj
    obj.draw_obj:SetObjType(obj_type)
    return obj
end

function Scene:Update(realtime, unscaledDeltaTime)
    for _, v in pairs(self.obj_list) do
        v:Update(realtime, unscaledDeltaTime)
    end
end