---
--- Created by Hugo
--- DateTime: 2023/5/9 13:37
---

local TypeUnityTexture = typeof(UnityEngine.Texture)
local TypeUnitySprite = typeof(UnityEngine.Sprite)
local TypeUnityMaterial = typeof(UnityEngine.Material)
local TypeGameObject = typeof(UnityEngine.GameObject)
local TypeTextAsset = typeof(UnityEngine.TextAsset)
local TypeAudioItem = typeof(AudioItem)
local TypeAnimatorController = typeof(UnityEngine.RuntimeAnimatorController)

require("loader/ResPool")
require("loader/GameObjPool")

---@class ResPoolMgr : BaseClass
---@field v_used_pools ObjPool[]
---@field v_res_pools ResPool[]
---@field v_game_obj_pools GameObjPool[]
ResPoolMgr = ResPoolMgr or BaseClass()

function ResPoolMgr:__init()
    if ResPoolMgr.Instance then
        print_error("[ResPoolMgr] attempt to create singleton twice!")
        return
    end
    ResPoolMgr.Instance = self

    self.v_res_pools = {}
    self.v_used_pools = {}
    self.v_game_obj_pools = {}
    self.v_get_game_obj_token = 0
    self.v_priority_map = {}

    self.v_pools_root = ResMgr.Instance:CreateEmptyGameObj("Pools", true)
    self.v_pools_root_transform = self.v_pools_root.transform

    self.v_root = ResMgr.Instance:CreateEmptyGameObj("GameObjectPool", true)
    self.v_root_transform = self.v_root.transform
    self.v_root_transform:SetParent(self.v_pools_root_transform)
    self.v_root:SetActive(false)

    self.priority_type_list = { ResLoadPriority.mid, ResLoadPriority.low }
    for i, v in ipairs(self.priority_type_list) do
        local data = {}
        data.get_game_obj_map = {}
        data.get_game_obj_index = 1
        self.v_priority_map[v] = data
    end
    self.next_check_pool_release_time = 0

    Runner.Instance:AddRunObj(self)
end

function ResPoolMgr:__delete()
    Runner.Instance:RemoveRunObj(self)

    if self.v_pools_root then
        ResMgr.Instance:Destroy(self.v_pools_root)
        self.v_pools_root = nil
        self.v_root = nil
    end
    self.v_res_pools = nil
    self.v_used_pools = nil
    self.v_game_obj_pools = nil

    ResPoolMgr.Instance = nil
end

function ResPoolMgr:GetRoot()
    return self.v_root
end

function ResPoolMgr:Update(realtime, unscaledDeltaTime)
    self:QueueGetGameObject()
    self:UpdateAllPool(realtime)
end

function ResPoolMgr:GetSprite(bundle_name, asset_name, callback, cb_data, load_priority, is_async)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.png") then
        asset_name = asset_name .. ".png"
    end

    --TODO Sprite暂时同步
    self:__GetRes(bundle_name, asset_name, TypeUnitySprite, callback, cb_data, load_priority, false)
end

function ResPoolMgr:GetTexture(bundle_name, asset_name, callback, cb_data, load_priority, is_async)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.png") and not string.find(asset_name, "%.jpg") then
        print_error("[ResPoolMgr] asset_name is not with end .png or .jpg!")
        callback(nil, cb_data)
        return
    end

    self:__GetRes(bundle_name, asset_name, TypeUnityTexture, callback, cb_data, load_priority, is_async)
end

function ResPoolMgr:GetTextAsset(bundle_name, asset_name, callback, cb_data, load_priority, is_async)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.txt") then
        asset_name = asset_name .. ".txt"
    end

    self:__GetRes(bundle_name, asset_name, TypeTextAsset, callback, cb_data, load_priority, is_async)
end

function ResPoolMgr:GetAnimatorController(bundle_name, asset_name, callback, cb_data, load_priority, is_async)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.controller") then
        asset_name = asset_name .. ".controller"
    end

    self:__GetRes(bundle_name, asset_name, TypeAnimatorController, callback, cb_data, load_priority, is_async)
end

function ResPoolMgr:GetAudio(bundle_name, asset_name, callback, cb_data, is_async)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.asset") then
        asset_name = asset_name .. ".asset"
    end

    self:__GetRes(bundle_name, asset_name, TypeAudioItem, callback, cb_data, ResLoadPriority.high, is_async)
end

function ResPoolMgr:GetMaterial(bundle_name, asset_name, callback, cb_data, load_priority, is_async)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.mat") then
        asset_name = asset_name .. ".mat"
    end

    self:__GetRes(bundle_name, asset_name, TypeUnityMaterial, callback, cb_data, load_priority, is_async)
end

function ResPoolMgr:TryGetMaterial(bundle_name, asset_name)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.mat") then
        asset_name = asset_name .. ".mat"
    end

    local pool = self.v_res_pools[bundle_name]
    return pool and pool:GetRes(asset_name) or nil
end

function ResPoolMgr:GetPrefab(bundle_name, asset_name, callback, cb_data, load_priority, is_async)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end
    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.prefab") then
        asset_name = asset_name .. ".prefab"
    end
    self:__GetRes(bundle_name, asset_name, TypeGameObject, callback, cb_data, load_priority, is_async)
end

function ResPoolMgr:TryGetPrefab(bundle_name, asset_name)
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end
    asset_name = string.lower(asset_name)
    if not string.find(asset_name, "%.prefab") then
        asset_name = asset_name .. ".prefab"
    end
    local pool = self.v_res_pools[bundle_name]
    return pool and pool:GetRes(asset_name)
end

function ResPoolMgr:ScanRes(bundle_name, asset_name)
    if self.v_res_pools[bundle_name] then
        return self.v_res_pools[bundle_name]:ScanRes(asset_name)
    end
end

function ResPoolMgr:GetResPoolAssetCount(bundle_name)
    if self.v_res_pools[bundle_name] then
        return self.v_res_pools[bundle_name].v_asset_count
    end
    return 0
end

---@return ResPool
function ResPoolMgr:GetOrCreateResPool(bundle_name)
    local pool = self.v_res_pools[bundle_name]
    if not pool then
        pool = ResPool.New(bundle_name)
        self.v_res_pools[bundle_name] = pool
    end
    return pool
end

function ResPoolMgr:__GetRes(bundle_name, asset_name, asset_type, callback, cb_data, load_priority, is_async)
    local obj = self:__TryGetRes(bundle_name, asset_name)
    if obj then
        callback(obj, cb_data)
        return
    end
    self:__LoadRes(bundle_name, asset_name, asset_type, callback, cb_data, load_priority, is_async)
end

function ResPoolMgr:__TryGetRes(bundle_name, asset_name)
    local pool = self:GetOrCreateResPool(bundle_name)
    local obj = pool:GetRes(asset_name)
    if not obj then
        return
    end
    local id = obj:GetInstanceID()
    if self.v_used_pools[id] and self.v_used_pools[id] ~= pool then
        print_error("[ResPoolMgr]__TryGetRes error:", bundle_name, asset_name)
    end
    self.v_used_pools[id] = pool
    return obj
end

local function LoadObjectCallBack(asset, cb_data)
    ---@type ResPoolMgr
    local self = cb_data[CbdIndex.self]
    local bundle_name = cb_data[CbdIndex.bundle]
    local asset_name = cb_data[CbdIndex.asset]
    local callback = cb_data[CbdIndex.callback]
    local cbd = cb_data[CbdIndex.cb_data]
    CbdPool.ReleaseCbData(cb_data)

    if asset == nil then
        callback(nil, cbd)
        return
    end

    local old_asset = self:__TryGetRes(bundle_name, asset_name)
    if old_asset then
        if old_asset ~= asset then
            print_error("[ResPoolMgr]__LoadRes error, old_obj is not same:", bundle_name, asset_name)
        end
        callback(old_asset, cbd)
        return
    end

    local pool = self:GetOrCreateResPool(bundle_name)
    pool:CacheRes(asset_name, asset)
    callback(self:__TryGetRes(bundle_name, asset_name), cbd)
end

function ResPoolMgr:__LoadRes(bundle_name, asset_name, asset_type, callback, cb_data, load_priority, is_async)
    if UNITY_EDITOR and not EditorResourceMgr.IsExitsAsset(bundle_name, asset_name) then
        print_error("资源不存在，马上检测！！！")
        return
    end

    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = self
    cbd[CbdIndex.bundle] = bundle_name
    cbd[CbdIndex.asset] = asset_name
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data

    if is_async then
        ResMgr.Instance:LoadObjectAsync(bundle_name, asset_name, asset_type, LoadObjectCallBack, cbd, load_priority or ResLoadPriority.high)
    else
        ResMgr.Instance:LoadObjectSync(bundle_name, asset_name, asset_type, LoadObjectCallBack, cbd, load_priority or ResLoadPriority.high)
    end
end

function ResPoolMgr:QueueGetGameObject()
    local remain_get_count = 2--最多同事获取N个, 按照优先级
    for _, v in ipairs(self.priority_type_list) do
        if remain_get_count <= 0 then
            return
        end
        local priority_t = self.v_priority_map[v]
        for i = priority_t.get_game_obj_index, self.v_get_game_obj_token do
            local t = priority_t.get_game_obj_map[i]
            priority_t.get_game_obj_index = priority_t.get_game_obj_index + 1
            if t then
                priority_t.get_game_obj_map[i] = nil
                remain_get_count = remain_get_count - 1
                self:__GetGameObject(t[CbdIndex.bundle], t[CbdIndex.asset], t[CbdIndex.parent], t[CbdIndex.callback], t[CbdIndex.cb_data], t[CbdIndex.priority], t[CbdIndex.is_async])
                CbdPool.ReleaseCbData(t)
                if remain_get_count <= 0 then
                    break
                end
            end
        end
    end
end

---@return GameObjPool
function ResPoolMgr:GetOrCreateGameObjectPool(bundle_name, asset_name)
    local path = ResUtil.GetAssetFullPath(bundle_name, asset_name)
    local pool = self.v_game_obj_pools[path]
    if not pool then
        pool = GameObjPool.New(self.v_root_transform, path)
        self.v_game_obj_pools[path] = pool
    end
    return pool
end

function ResPoolMgr:__GetGameObject(bundle_name, asset_name, parent, callback, cb_data, load_priority, is_async)
    asset_name = string.lower(asset_name)
    if string.find(asset_name, "%.prefab") == nil then
        asset_name = asset_name .. ".prefab"
    end
    local go = self:__TryGetGameObject(bundle_name, asset_name, parent)
    if go then
        callback(go, cb_data)
        return true
    end
    self:__LoadGameObject(bundle_name, asset_name, parent, callback, cb_data, load_priority, is_async)
    return false
end

function ResPoolMgr:__TryGetGameObject(bundle_name, asset_name, parent)
    local pool = self:GetOrCreateGameObjectPool(bundle_name, asset_name)
    local go = pool:TryPop()
    if IsNil(go) then
        return
    end
    local id = go:GetInstanceID()
    if self.v_used_pools[id] and self.v_used_pools[id] ~= pool then
        print_error("[ResPoolMgr] __TryGetGameObject error !!!")
    end
    self.v_used_pools[id] = pool
    if not IsNil(parent) then
        go.transform:SetParent(parent, false)
    end
    return go
end

local function LoadGameObjectCallback(go, cb_data)
    ---@type ResPoolMgr
    local self = cb_data[CbdIndex.self]
    local bundle_name = cb_data[CbdIndex.bundle]
    local asset_name = cb_data[CbdIndex.asset]
    local callback = cb_data[CbdIndex.callback]
    local cbd = cb_data[CbdIndex.cb_data]
    CbdPool.ReleaseCbData(cb_data)

    if go == nil then
        callback(nil, cbd)
        return
    end

    local pool = self:GetOrCreateGameObjectPool(bundle_name, asset_name)
    local id = go:GetInstanceID()
    if self.v_used_pools[id] and self.v_used_pools[id] ~= pool then
        print_error("[ResPoolMgr]__LoadGameObject error:", bundle_name, asset_name)
    end

    self.v_used_pools[id] = pool
    pool:CacheOriginalTransformInfo(ResMgr.Instance:GetPrefab(id))
    callback(go, cbd)
end

function ResPoolMgr:__LoadGameObject(bundle_name, asset_name, parent, callback, cb_data, load_priority, is_async)
    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = self
    cbd[CbdIndex.bundle] = bundle_name
    cbd[CbdIndex.asset] = asset_name
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data

    if is_async then
        ResMgr.Instance:LoadGameObjectAsync(bundle_name, asset_name, parent, LoadGameObjectCallback, cbd, load_priority)
    else
        ResMgr.Instance:LoadGameObjectSync(bundle_name, asset_name, parent, LoadGameObjectCallback, cbd, load_priority)
    end
end

function ResPoolMgr:__GetGameObjectInPrefab(prefab, parent)
    if prefab == nil then
        return
    end
    local pool = self.v_game_obj_pools[prefab]
    if pool == nil then
        pool = GameObjPool.New(self.v_root_transform)
        self.v_game_obj_pools[prefab] = pool
    end

    local go = pool:TryPop()
    if go then
        local instance_id = go:GetInstanceID()
        if self.v_used_pools[instance_id] ~= nil and self.v_used_pools[instance_id] ~= pool then
            print_error("[ResPoolMgr]__GetGameObjectInPrefab, pool is not match:", prefab.name)
        end
        self.v_used_pools[instance_id] = pool
        if not IsNil(parent) then
            go.transform:SetParent(parent, false)
        end
        return go
    end

    go = ResMgr.Instance:Instantiate(prefab, false, parent)
    local instance_id = go:GetInstanceID()
    self.v_used_pools[instance_id] = pool
    pool:CacheOriginalTransformInfo(prefab)

    return go
end

--function ResPoolMgr:__GetEffectAsync(bundle_name, asset_name, parent, callback, cb_data)
--    if bundle_name == nil or asset_name == nil then
--        print_error("[ResPoolMgr]GetEffectAsync param is invalid:", bundle_name, asset_name)
--        return
--    end
--    self:__GetGameObject(bundle_name, asset_name, parent, callback, cb_data, ResLoadPriority.low, true)
--end

function ResPoolMgr:__GetDynamicObjAsync(bundle_name, asset_name, parent, callback, cb_data, load_priority)
    if bundle_name == nil or asset_name == nil then
        print_error("[ResPoolMgr]__GetDynamicObjAsync param is invalid:", bundle_name, asset_name)
        return
    end
    if load_priority == ResLoadPriority.low or load_priority == ResLoadPriority.mid then
        self.v_get_game_obj_token = self.v_get_game_obj_token + 1
        local cbd = CbdPool.CreateCbData()
        cbd[CbdIndex.bundle] = bundle_name
        cbd[CbdIndex.asset] = asset_name
        cbd[CbdIndex.callback] = callback
        cbd[CbdIndex.cb_data] = cb_data
        cbd[CbdIndex.parent] = parent
        cbd[CbdIndex.priority] = load_priority
        cbd[CbdIndex.is_async] = true
        local priority_t = self.v_priority_map[load_priority]
        priority_t.get_game_obj_map[self.v_get_game_obj_token] = cbd
        return self.v_get_game_obj_token
    else
        self:__GetGameObject(bundle_name, asset_name, parent, callback, cb_data, load_priority, true)
    end
end

function ResPoolMgr:__GetDynamicObjSync(bundle_name, asset_name, parent, callback, cb_data)
    self:__GetGameObject(bundle_name, asset_name, parent, callback, cb_data, ResLoadPriority.sync, false)
end

function ResPoolMgr:__CancelGetInQueue(session)
    for i, v in pairs(self.v_priority_map) do
        local t = v.get_game_obj_map[session]
        v.get_game_obj_map[session] = nil
        if t then
            CbdPool.ReleaseCbData(t)
        end
    end
end

function ResPoolMgr:TryGetGameObject(bundle_name, asset_name, parent)
    local prefab = self:TryGetPrefab(bundle_name, asset_name)
    return self:__GetGameObjectInPrefab(prefab, parent)
end

function ResPoolMgr:TryGetGameObjectInPrefab(prefab, parent)
    return self:__GetGameObjectInPrefab(prefab, parent)
end

function ResPoolMgr:IsPoolObj(uobj)
    if IsNil(uobj) then
        return false
    end
    return self.v_used_pools[uobj:GetInstanceID()] ~= nil
end

function ResPoolMgr:Release(uobj, release_policy)
    if IsNil(uobj) then
        return
    end
    local cid = uobj:GetInstanceID()
    local pool = self.v_used_pools[cid]
    if pool == nil then
        print_error("[[ResPoolMgr] 释放一个没有池的obj:", uobj.name, "id:", cid)
        return
    end
    if pool:Release(uobj, release_policy) then
        self.v_used_pools[cid] = nil
    end
end

function ResPoolMgr:ReleaseInObjId(cid)
    local pool = self.v_used_pools[cid]
    if pool == nil then
        print_error("[[ResPoolMgr] 释放一个没有池的obj, id:", cid)
        return
    end
    if pool:ReleaseInObjId(cid) then
        self.v_used_pools[cid] = nil
    end
end

function ResPoolMgr:OnGameObjIllegalDestroy(cid)
    self.v_used_pools[cid] = nil
end

function ResPoolMgr:IsInGameObjPool(cid, go)
    local pool = self.v_used_pools[cid]
    return pool and pool:GetGameObjIsCache(go)
end

function ResPoolMgr:Clear()
    self:ClearPools(self.v_game_obj_pools)
    self:ClearPools(self.v_res_pools)
end

function ResPoolMgr:ClearPools(pools)
    local del_pools = {}
    for k, pool in pairs(pools) do
        if pool:Clear() then
            table.insert(del_pools, k)
        end
    end
    for _, v in ipairs(del_pools) do
        pools[v] = nil
    end
end

function ResPoolMgr:UpdateAllPool(now_time)
    if now_time < self.next_check_pool_release_time then
        return
    end
    self.next_check_pool_release_time = now_time + 0.1
    self:UpdatePool(self.v_game_obj_pools, now_time)
    self:UpdatePool(self.v_res_pools, now_time)
end

function ResPoolMgr:UpdatePool(pools, now_time)
    for k, pool in pairs(pools) do
        if pool:Update(now_time) then
            pools[k] = nil
            break
        end
    end
end

--------------------------------------------------------debug-----------------------------------------------------------

function ResPoolMgr:GetPoolDebugInfo(t)
    t.res_count = 0
    t.res_pool_count = 0

    for i, v in pairs(self.v_res_pools) do
        t.res_pool_count = t.res_pool_count + 1
        t.res_count = t.res_count + v:GetAssetCount()
    end

    t.game_obj_pool_count = 0
    t.game_obj_cache_count = 0
    for i, v in pairs(self.v_game_obj_pools) do
        t.game_obj_pool_count = t.game_obj_pool_count + 1
        t.game_obj_cache_count = t.game_obj_cache_count + v:GetAssetCount()
    end
end