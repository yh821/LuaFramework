﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2023/4/26 14:06
---

---@class DrawObj
---@field part_list DrawPart[]
DrawObj = DrawObj or BaseClass()

local TypeMoveableObject = typeof(MoveableObject)

local function InitDrawObjPool()
    DrawObj.obj_list = {}
    DrawObj.obj_count = 0
    local root = GameObject.New("DrawObjPool")
    root.transform.position = Vector3Pool.GetTemp(0, 0, 0)
    DrawObj.obj_root = root
end
InitDrawObjPool()

function DrawObj:__init(parent_obj, parent_trans)
    self.parent_obj = parent_obj
    self.root = DrawObj.Pop()
    self.root_transform = self.root.transform
    if parent_trans then
        self.root_transform:SetParent(parent_trans, false)
    end
end

function DrawObj:__delete()
    DrawObj.Release(self.root)
end

local localPosition = Vector3(0, 0, 0)
local localRotation = Quaternion.Euler(0, 0, 0)
local localScale = Vector3(1, 1, 1)
local defaultLayer = UnityEngine.LayerMask.NameToLayer("Default")

function DrawObj.Pop()
    local draw_obj = Next(DrawObj.obj_list)
    if draw_obj then
        draw_obj.transform.localPosition = localPosition
        draw_obj.transform.localRotation = localRotation
        draw_obj.transform.localScale = localScale
        draw_obj.gameObject.layer = defaultLayer
        draw_obj.gameObject:SetActive(true)
        draw_obj.transform:DOKill()
        DrawObj.obj_list[draw_obj] = nil
        DrawObj.obj_count = DrawObj.obj_count - 1
    else
        draw_obj = U3DObject(GameObject.New("DrawObj"))
        draw_obj.gameObject:AddComponent(TypeMoveableObject)
    end
end