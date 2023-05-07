---
--- Created by Hugo
--- DateTime: 2023/5/6 10:09
---

local UserDataKey = "__userdata__"

local TypeRawImage = typeof(UnityEngine.UI.RawImage)
local TypeImage = typeof(UnityEngine.UI.Image)

local function component_func_wrap(value)
    return function(self, ...)
        local com = rawget(self, "__meta__")
        return value(com, ...)
    end
end

local function handle_func_wrap(caches, table, key)
    local value = caches[key]
    if value then
        return value
    end
    local component = rawget(table, "__meta__")
    if IsNil(component) then
        return nil
    end
    value = component[key]
    if value and type(value) == "function" then
        value = component_func_wrap(value)
        caches[key] = value
    end
    return value
end

local RawImageFunctionCaches = {}
local ImageFunctionCaches = {}

local component_metatable = {
    [TypeRawImage] = function(table, key)
        if key == "LoadSprite" or key == "LoadUrlSprite" or key == "LoadSpriteAsync" then
            local base_view = rawget(table, UserDataKey)
            return base_view["LoadRawImage"]
        elseif key == "__metaself__" then
            return rawget(table, UserDataKey)
        else
            return handle_func_wrap(RawImageFunctionCaches, table, key)
        end
    end,

    [TypeImage] = function(table, key)
        if key == "LoadSprite" or key == "LoadSpriteAsync" then
            local base_view = rawget(table, UserDataKey)
            return base_view["LoadRawImage"]
        elseif key == "__metaself__" then
            return rawget(table, UserDataKey)
        else
            return handle_func_wrap(ImageFunctionCaches, table, key)
        end
    end
}

local function create_component_metatable(component, index, userdata)
    return setmetatable(
            {
                __meta__ = component,
                is_component = true,
                [UserDataKey] = userdata
            },
            {
                __index = index,
                __newindex = function(t, k, v)
                    component[k] = v
                end
            })
end

local component_table = {
    transform = typeof(UnityEngine.Transform),
    rect = typeof(UnityEngine.RectTransform),
    canvas = typeof(UnityEngine.Canvas),
    canvas_group = typeof(UnityEngine.CanvasGroup),
    image = TypeImage,
    raw_image = TypeRawImage,
    text = typeof(UnityEngine.UI.Text),
    button = typeof(UnityEngine.UI.Button),
    toggle = typeof(UnityEngine.UI.Toggle),

    animator = typeof(UnityEngine.Animator),
    move_obj = typeof(MovableObject),
}

---@class U3DObject
---@field gameObject GameObject
---@field transform Transform
local u3d_shortcut = {}
function u3d_shortcut:SetActive(active)
    self.gameObject:SetActive(active)
end

function u3d_shortcut:GetActive()
    return self.gameObject.activeInHierarchy
end

function u3d_shortcut:FindObj(path)
    local trans = self.transform:FindHard(path)
    if trans then
        return U3DObject(trans.gameObject, trans)
    end
end

function u3d_shortcut:GetComponent(type)
    self.gameObject:GetComponent(type)
end

function u3d_shortcut:GetOrAddComponent(type)
    self.gameObject:GetOrAddComponent(type)
end

function u3d_shortcut:GetComponentsInChildren(type)
    self.gameObject:GetComponentsInChildren(type)
end

function u3d_shortcut:SetLocalPosition(x, y, z)
    self.transform:SetLocalPosition(x, y, z)
end

local localPosition = Vector3(0, 0, 0)
local localRotation = Quaternion.Euler(0, 0, 0)
local localScale = Vector3(1, 1, 1)
function u3d_shortcut:ResetTransform()
    self.transform.localPosition = localPosition
    self.transform.localRotation = localRotation
    self.transform.localScale = localScale
end

function u3d_shortcut:SetText(text)
    local com = self.text
    if com then
        com.text = text
    end
end

local u3d_metatable = {
    __index = function(table, key)
        if IsNil(table.gameObject) then
            return
        end
        local key_type = component_table[key]
        if key_type then
            local component = table.gameObject:GetComponent(key_type)
            if component then
                local metatable = component_metatable[key_type]
                local data
                if metatable then
                    data = create_component_metatable(component, metatable, table[UserDataKey])
                else
                    data = component
                end
                table[key] = data
                return data
            end
        end
        return u3d_shortcut[key]
    end
}

---@return U3DObject
function U3DObject(go, transform, data)
    if go == nil then
        return
    end
    local obj = { gameObject = go, transform = transform, [UserDataKey] = data }
    setmetatable(obj, u3d_metatable)
    return obj
end

function U3DNodeList(name_table, data)
    local node_list = {}
    if name_table then
        local map = name_table.Lookup
        local iter = map:GetEnumerator()
        while iter:MoveNext() do
            local cur = iter.Current
            node_list[cur.Key] = U3DObject(cur.Value, nil, data)
        end
    end
    return node_list
end

---@class GameObject

---@class Transform