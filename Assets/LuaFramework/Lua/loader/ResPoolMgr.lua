---
--- Created by Hugo
--- DateTime: 2023/5/9 13:37
---

local TypeGameObject = typeof(UnityEngine.GameObject)

---@class ResPoolMgr
---@field _used_pools ObjPool[]
---@field _res_pools ResPool[]
---@field _game_obj_pools GameObjectPool[]
ResPoolMgr = ResPoolMgr or BaseClass()

function ResPoolMgr:__init()
    if ResPoolMgr.Instance then
        print_error("[ResPoolMgr] attempt to create singleton twice!")
        return
    end
    ResPoolMgr.Instance = self

    self._res_pools = {}
    self._used_pools = {}
    self._game_obj_pools = {}
    self._get_game_obj_token = 0
    self._priority_map = {}

    self._pools_root = ResManager.Instance:CreateEmptyGameObj("Pools", true)
    self._pools_root_transform = self._pools_root.transform

    self._root = ResManager.Instance:CreateEmptyGameObj("GameObjectPool", true)
    self._root_transform = self._root.transform
    self._root_transform:SetParent(self._pools_root_transform)
    self._root:SetActive(false)

    self._root_act = ResManager.Instance:CreateEmptyGameObj("GameObjectPoolAct", true)
    self._root_act_transform = self._root_act.transform
    self._root_act_transform:SetParent(self._pools_root_transform)
    self._root_act_transform.localPosition = Vector3(-100000, -100000, -100000)

    self.priority_type_list = { ResLoadPriority.mid, ResLoadPriority.low }
    for i, v in ipairs(self.priority_type_list) do
        local data = {}
        data.get_game_obj_map = {}
        data.get_game_obj_index = 1
        self._priority_map[v] = data
    end
    self.next_check_pool_release_time = 0

    Runner.Instance:AddRunObj(self)
end

function ResPoolMgr:__delete()
    Runner.Instance:RemoveRunObj(self)

    self._res_pools = nil
    self._used_pools = nil
    self._game_obj_pools = nil

    ResPoolMgr.Instance = nil
end

function ResPoolMgr:Update(deltaTime, unscaledDeltaTime)
    self:QueueGetGameObject()
    self:UpdateAllPool()
end

local DynamicObjCallbackDataPool = {}
function ResPoolMgr:__GetDynamicObjCallbackData()
    local t = table.remove(DynamicObjCallbackDataPool)
    if t == nil then
        t = { true, true, true, true, true, true, true }
    end
    return t
end

function ResPoolMgr:__ReleaseDynamicObjCallbackData(t)
    t[3] = true
    t[6] = true
    t[7] = true
    table.insert(DynamicObjCallbackDataPool)
end

function ResPoolMgr:__GetEffectAsync(bundle, asset, callback, cb_data, parent)
    if bundle == nil or asset == nil then
        return
    end
    self:__GetGameObject(bundle, asset, callback, cb_data, parent, ResLoadPriority.low, true)
end

function ResPoolMgr:QueueGetGameObject()
    local remain_get_count = 2--最多同事获取N个, 按照优先级
    for _, v in ipairs(self.priority_type_list) do
        if remain_get_count <= 0 then
            return
        end
        local priority_t = self._priority_map[v]
        for i = priority_t.get_game_obj_index, self._get_game_obj_token do
            local t = priority_t.get_game_obj_map[i]
            priority_t.get_game_obj_index = priority_t.get_game_obj_index + 1
            if t then
                priority_t.get_game_obj_map[i] = nil
                remain_get_count = remain_get_count - 1
                self:__GetGameObject(t[1], t[2], t[3], t[4], t[5], t[6], t[7])
                self:__ReleaseDynamicObjCallbackData(t)
            end
        end
    end
end

function ResPoolMgr:UpdateAllPool()
    local now_time = Status.NowUnScaleTime
    if now_time < self.next_check_pool_release_time then
        return
    end
    self.next_check_pool_release_time = now_time + 0.1
    self:UpdatePool(self._game_obj_pools, now_time)
    self:UpdatePool(self._res_pools, now_time)
end

function ResPoolMgr:UpdatePool(pools, now_time)
    for k, pool in pairs(pools) do
        if pool:Update(now_time) then
            pools[k] = nil
            break
        end
    end
end

function ResPoolMgr:ReleaseInObjId(id)
    local pool = self._used_pools[id]
    if pool == nil then
        print_error("[[ResPoolMgr] 释放一个没有池的obj: " .. obj.name .. ", id: " .. id)
        return
    end
    if pool:ReleaseInObjId(id) then
        self._used_pools[id] = nil
    end
end

function ResPoolMgr:Release(go, policy)
    if IsNil(go) then
        return
    end
    local id = go:GetInstanceID()
    local pool = self._used_pools[id]
    if pool == nil then
        print_error("[[ResPoolMgr] 释放一个没有池的obj: " .. go.name .. ", id: " .. id)
        return
    end
    if pool:Release(go, policy) then
        self._used_pools[id] = nil
    end
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
    if bundle == nil or asset == nil then
        return
    end
    if priority == ResLoadPriority.low or priority == ResLoadPriority.mid then
        self._get_game_obj_token = self._get_game_obj_token + 1
        local t = self:__GetDynamicObjCallbackData()
        t[1] = bundle
        t[2] = asset
        t[3] = callback
        t[4] = cb_data
        t[5] = parent
        t[6] = priority
        t[7] = true
        local priority_t = self._priority_map[priority]
        priority_t.get_game_obj_map[self._get_game_obj_token] = t
        return self._get_game_obj_token
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
    pool:CacheOriginalTransformInfo(ResManager.Instance:GetPrefab(id))
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

    load_func(ResManager.Instance, bundle, asset, LoadGameObjectCallback, t, priority)
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

    local pool = self:GetOrCreateResPool(bundle)
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

    load_func(ResManager.Instance, bundle, asset, asset_type, LoadObjectCallback, t, priority or ResLoadPriority.high)
end

function ResPoolMgr:__GetLoadObjectCallbackData()

end

function ResPoolMgr:__ReleaseLoadObjectCallbackData(cb_data)

end

function ResPoolMgr:GetOrCreateResPool(bundle)
    local pool = self._res_pools[bundle]
    if not pool then
        pool = ResPool.New(bundle)
        self._res_pools[bundle] = pool
    end
    return pool
end