---
--- Created by Hugo
--- DateTime: 2023/5/9 13:37
---

local TypeGameObject = typeof(UnityEngine.GameObject)

---@class ResPoolMgr
ResPoolMgr = ResPoolMgr or BaseClass()

function ResPoolMgr:__init()
    self._res_pools = {}
    self._used_pools = {}
    self._game_obj_pools = {}
end

function ResPoolMgr:__delete()
    self._res_pools = nil
    self._used_pools = nil
    self._game_obj_pools = nil
end

function ResPoolMgr:Release(prefab)

end

function ResPoolMgr:GetPrefab(bundle, asset, callback, cb_data, priority, is_async)
    if IsNilOrEmpty(bundle) or IsNilOrEmpty(asset) then
        return
    end
    if string.find(asset, "%.prefab") == nil then
        asset = asset .. ".prefab"
    end
    asset = string.lower(asset)
    self:__GetRes(bundle, asset, TypeGameObject, callback, cb_data, priority, is_async)
end

function ResPoolMgr:TryGetPrefab(bundle, asset)
    if IsNilOrEmpty(bundle) or IsNilOrEmpty(asset) then
        return
    end
    if string.find(asset, "%.prefab") == nil then
        asset = asset .. ".prefab"
    end
    asset = string.lower(asset)
    local pool = self._res_pools[bundle]
    return pool and pool:GetRes(asset)
end

function ResPoolMgr:__TryGetGameObject(bundle, asset, parent)
    local pool = self:GetOrCreateGameObjectPool(bundle, asset)
    local go = pool:TryPop()
    if go then
        return go
    end
    local id = go:GetInstanceID()
    if self._used_pools[id] and self._used_pools[id] ~= pool then
        print_error("[ResPoolMgr] __TryGetGameObject error !!!")
    end
    self._used_pools[id] = pool
    if not IsNil(parent) then
        go.transform:SetParent(parent, false)
    end
    return go
end

function ResPoolMgr:GetOrCreateGameObjectPool(bundle, asset)
    local path = ResUtil.GetAssetFullPath(bundle, asset)
    local pool = self._game_obj_pools[path]
    if not pool then
        pool = GameObjectPool.New(self._root_transform, self._root_act_transform, path)
        self._game_obj_pools[path] = pool
    end
    return pool
end

function ResPoolMgr:__GetGameObject(bundle, asset, callback, cb_data, parent, priority, is_async)
    if string.find(asset, "%.prefab") == nil then
        asset = asset .. ".prefab"
    end
    asset = string.lower(asset)
    local go = self:__TryGetGameObject(bundle, asset, parent)
    if go then
        callback(go, cb_data)
        return true
    end
    self:__LoadGameObject(bundle, asset, callback, cb_data, parent, priority, is_async)
    return false
end

function ResPoolMgr:__GetDynamicObjAsync(bundle, asset, callback, cb_data, parent, priority)
    if priority == ResLoadPriority.low or priority == ResLoadPriority.mid then
        --TODO 11111111
    else
        self:__GetGameObject(bundle, asset, callback, cb_data, parent, priority, true)
    end
end

function ResPoolMgr:__GetDynamicObjSync(bundle, asset, callback, cb_data, parent)
    self:__GetGameObject(bundle, asset, callback, cb_data, parent, ResLoadPriority.sync, false)
end

local function LoadGameObjectCallback(go, cb_data)
    ---@type ResPoolMgr
    local self = cb_data[1]
    local bundle = cb_data[2]
    local asset = cb_data[3]
    local callback = cb_data[4]
    local cbd = cb_data[5]
    self:__ReleaseLoadGameObjectCallbackData(cb_data)

    if go == nil then
        callback(nil, cbd)
        return
    end

    local pool = self:GetOrCreateGameObjectPool(bundle, asset)
    local id = go:GetInstanceID()
    if self._used_pools[id] and self._used_pools[id] ~= pool then
        print_error("[ResPoolMgr] __LoadGameObject error !!!")
    end

    self._used_pools[id] = pool
    pool:CacheOriginalTransformInfo(ResManager:GetPrefab(id))
    callback(go, cbd)
end

function ResPoolMgr:__LoadGameObject(bundle, asset, callback, cb_data, parent, priority, is_async)
    local t = self:__GetLoadGameObjectCallbackData()
    t[1] = self
    t[2] = bundle
    t[3] = asset
    t[4] = callback
    t[5] = cb_data

    local load_func
    if is_async then
        load_func = ResManager.LoadGameObjectAsync
    else
        load_func = ResManager.LoadGameObjectSync
    end

    load_func(ResManager, bundle, asset, LoadGameObjectCallback, t, priority)
end

function ResPoolMgr:__GetLoadGameObjectCallbackData()

end

function ResPoolMgr:__ReleaseLoadGameObjectCallbackData(cb_data)

end

function ResPoolMgr:__GetRes(bundle, asset, asset_type, callback, cb_data, priority, is_async)
    local obj = self:__TryGetRes(bundle, asset)
    if obj then
        callback(obj, cb_data)
        return
    end
    self:__LoadRes(bundle, asset, asset_type, callback, cb_data, priority, is_async)
end

function ResPoolMgr:__TryGetRes(bundle, asset)
    local pool = self:GetOrCreateResPool(bundle)
    local obj = pool:GetRes(asset)
    if not obj then
        return
    end
    local id = obj:GetInstanceID()
    if self._used_pools[id] and self._used_pools[id] ~= pool then
        print_error("[ResPoolMgr] __TryGetRes error !!!")
    end
    self._used_pools[id] = pool
    return obj
end

local function LoadObjectCallback(obj, cb_data)
    ---@type ResPoolMgr
    local self = cb_data[1]
    local bundle = cb_data[2]
    local asset = cb_data[3]
    local callback = cb_data[4]
    local cbd = cb_data[5]
    self:__ReleaseLoadObjectCallbackData(cb_data)

    if obj == nil then
        callback(nil, cbd)
        return
    end

    local old_obj = self:__TryGetRes(bundle, asset)
    if old_obj then
        if old_obj ~= obj then
            print_error("[ResPoolMgr] __LoadRes error, old_obj is not same !!!")
        end
        callback(old_obj, cbd)
        return
    end

    local pool = self:GetOrCreateObjectPool(bundle)
    pool:CacheRes(asset, obj)
    callback(self:__TryGetRes(bundle, asset), cbd)
end

function ResPoolMgr:__LoadRes(bundle, asset, asset_type, callback, cb_data, priority, is_async)
    if UNITY_EDITOR and not EditorResourceMgr.IsExitsAsset(bundle, asset) then
        print_error("资源不存在，马上检测！！！")
        return
    end

    local t = self:__GetLoadObjectCallbackData()
    t[1] = self
    t[2] = bundle
    t[3] = asset
    t[4] = callback
    t[5] = cb_data

    local load_func
    if is_async then
        load_func = ResManager.__LoadObjectAsync
    else
        load_func = ResManager.__LoadObjectSync
    end

    load_func(ResManager, bundle, asset, asset_type, LoadGameObjectCallback, t, priority or ResLoadPriority.high)
end

function ResPoolMgr:__GetLoadObjectCallbackData()

end

function ResPoolMgr:__ReleaseLoadObjectCallbackData(cb_data)

end

function ResPoolMgr:GetOrCreateObjectPool(bundle, asset)

end