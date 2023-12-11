﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2023/4/26 14:08
---

SceneObjPart = {
    Main = 0,
    Weapon = 1,
    Weapon2 = 2,
    Wing = 3,
    Mount = 4,
    Tail = 5,
}

---@class DrawPart
---@field draw_obj DrawObj
---@field parent U3DObject
DrawPart = DrawPart or BaseClass()

---@type DrawPart[]
DrawPart._pool = {}
---@return DrawPart
function DrawPart.Pop()
    local draw_part = table.remove(DrawPart._pool)
    if not draw_part then
        draw_part = DrawPart.New()
    end
    return draw_part
end

---@param draw_part DrawPart
function DrawPart.Release(draw_part)
    if #DrawPart._pool < 1000 then
        draw_part:Clear()
        table.insert(DrawPart._pool, draw_part)
    else
        draw_part:DeleteMe()
    end
end

DrawPart._load_token = 0
DrawPart._cb_data_pool = {}
function DrawPart.CreateCbData(self, bundle, asset, token)
    local cb_data = table.remove(DrawPart._cb_data_pool)
    if not cb_data then
        cb_data = {}
    end
    cb_data[1] = self
    cb_data[2] = bundle
    cb_data[3] = asset
    cb_data[4] = token
    return cb_data
end

function DrawPart.ReleaseCbData(cb_data)
    for i, v in ipairs(cb_data) do
        cb_data[i] = false
    end
    table.insert(DrawPart._cb_data_pool, cb_data)
end

function DrawPart:__init()
    self.hide_mask = {}
end

function DrawPart:__delete()
    DrawPart.Release(self)
end

function DrawPart:SetDrawObj(draw_obj)
    self.draw_obj = draw_obj
end

function DrawPart:SetParent(parent)
    self.parent = parent
    if self.obj then
        self:__FlushParent(self.obj)
    end
end

function DrawPart:SetPart(part)
    self.part = part
end

function DrawPart:CancelLoadInQueue()
    self.load_token = nil
end

local localPosition = Vector3(0, 0, 0)
local localRotation = Quaternion.Euler(0, 0, 0)
local localScale = Vector3(1, 1, 1)

function DrawPart:ChangeModel(bundle, asset, callback)
    if IsNilOrEmpty(bundle) or IsNilOrEmpty(asset) then
        return
    end
    if self.bundle == bundle and self.asset == asset then
        if self.load_token then
            self.load_callback = callback
        else
            if callback then
                callback()
            end
        end
        return
    end
    self.bundle = bundle
    self.asset = asset
    self:CancelLoadInQueue()
    self.load_callback = callback
    self:LoadModel(self.bundle, self.asset)
end

function DrawPart:LoadModel(bundle, asset)
    --TODO 暂时用Editor同步加载
    local go
    if UNITY_EDITOR then
        go = ResManager.Instance:Instantiate(EditorResourceMgr.LoadGameObject(bundle, asset))
        go.name = self.part
        go.transform:SetParent(self.draw_obj.root_transform, true)
        go.transform.localPosition = localPosition
        go.transform.localRotation = localRotation
        go.transform.localScale = localScale
    else

    end

    DrawPart._load_token = DrawPart._load_token + 1
    self.load_token = DrawPart._load_token
    local cb_data = DrawPart.CreateCbData(self, bundle, asset, self.load_token)
    DrawPart.__OnLoadComplete(go, cb_data)
end

function DrawPart:Reset(obj)
    if self.part == SceneObjPart.Main then
        print_error("[DrawPart] Unexpected process!")
        return
    end
    self:__RemoveAttach()
end

--销毁当前self.obj, 保留数据
function DrawPart:DestroyObj()
    self:CancelLoadInQueue()
    self:__RemoveAttach()
    local obj = self.obj
    self.obj = nil
    self.obj_transform = nil
    if not obj or IsNil(obj.gameObject) then
        return
    end
    if self.remove_callback then
        local result, error = pcall(self.remove_callback, self.draw_obj, obj, self.part, self)
        if not result then
            print_error(error)
        end
    end
    local trans = obj.transform
    trans.localScale = Vector3Pool.one
    trans.localRotation = Vector3Pool.rotate
    --animator放回act池优化
    ResPoolMgr.Instance:Release(obj.gameObject)
end

function DrawPart.__OnLoadComplete(obj, cb_data)
    ---@type DrawPart
    local self = cb_data[1]
    local bundle = cb_data[2]
    local asset = cb_data[3]
    local token = cb_data[4]
    DrawPart.ReleaseCbData(cb_data)
    if self.load_token ~= token then
        if not IsNil(obj) then
            self:__ReleaseLoaded(obj)
        end
        return
    end
    self.load_token = nil
    self:DestroyObj()
    if IsNil(obj) then
        print_error(string.format("加载模型失败, bundle:%s, asset:%s", bundle, asset))
        return
    end
    if self.bundle ~= bundle or self.asset ~= asset then
        print_error("[DrawPart] Reload for bundle and asset not match!")
        self:__ReleaseLoaded(obj)
        if sel.bundle and self.asset then
            self:LoadModel(self.bundle, self.asset)
        end
        return
    end
    self.obj = U3DObject(obj)
    self.obj_transform = self.obj.transform
    self.part_scale = self.obj_transform.localScale
    self.part_rotate = self.obj_transform.localRotation
    self:__FlushParent(self.obj)
    self:__FlushClickListener(self.obj)
    self.obj_transform.localPosition = Vector3Pool.GetTemp(0, 0, 0)

    self:__InitRenderer()
    self:__InitAnimator()
end

function DrawPart:__InitRenderer()
end

function DrawPart:__InitAnimator()
    if not self.obj then
        return
    end

    self.obj:SetActive(true)
    local animator = self.obj.animator
    if not IsNil(animator) then

    end
    self:__TryInvokeComplete()
end

function DrawPart:__TryInvokeComplete()
end

function DrawPart:__FlushParent(obj)
    if self.parent then
        obj.transform:SetParent(self.parent.transform, false)
    else
        obj.transform:SetParent(nil)
    end
end

function DrawPart:__FlushClickListener(obj)
    local clickable = obj.clickable_obj
    if clickable == nil then
        return
    end
    if self.click_listener then
        clickable:SetClickListener(self.click_listener)
        clickable:SetClickable(true)
    else
        clickable:SetClickListener(nil)
        clickable:SetClickable(false)
    end
end

function DrawPart:__RemoveAttach()
    local obj = self.obj
    if obj and not IsNil(obj.gameObject) then
        obj.transform.localScale = self.part_scale
        obj.transform.localRotation = Quaternion.Euler(self.part_rotate.x, self.part_rotate.y, self.part_rotate.z)
    end
end

function DrawPart:__ReleaseLoaded(obj)
    ResPoolMgr.Instance:Release(obj)
end

function DrawPart:SetTrigger(key)
    self.cur_play_anim = nil
    if self.obj then
        if self.obj.animator and self.obj.animator.isActiveAndEnabled then
            self.obj.animator:SetTrigger(key)
        end
    elseif #self.hide_mask == 0 then
        if not self.animator_triggers then
            self.animator_triggers = {}
        end
        self.animator_triggers[key] = true
    end
end

function DrawPart:ResetTrigger(key)
    if self.obj then
        if self.obj.animator and self.obj.animator.isActiveAndEnabled then
            self.obj.animator:ResetTrigger(key)
        end
    elseif #self.hide_mask == 0 then
        if self.animator_triggers then
            self.animator_triggers[key] = nil
        end
    end
end

function DrawPart:SetBool(key, value)
    if not self.animator_booleans then
        self.animator_booleans = {}
    end
    self.animator_booleans[key] = value
    if self.obj and self.obj.animator and self.obj.animator.isActiveAndEnabled then
        self.obj.animator:SetBool(key, value)
    end
end

function DrawPart:SetFloat(key, value)
    if not self.animator_floats then
        self.animator_floats = {}
    end
    self.animator_floats[key] = value
    if self.obj and self.obj.animator and self.obj.animator.isActiveAndEnabled then
        self.obj.animator:SetFloat(key, value)
    end
end

function DrawPart:SetInteger(key, value)
    if not self.animator_integers then
        self.animator_integers = {}
    end
    self.animator_integers[key] = value
    if self.obj and self.obj.animator and self.obj.animator.isActiveAndEnabled then
        self.obj.animator:SetInteger(key, value)
    end
end

function DrawPart:RemoveModel()
    self.bundle = nil
    self.asset = nil
    self:DestroyObj()
end