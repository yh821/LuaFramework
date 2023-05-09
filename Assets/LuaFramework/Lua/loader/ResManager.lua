---
--- Created by Hugo
--- DateTime: 2023/5/9 13:28
---

local wait_load_obj_queue = {}
local wait_load_game_obj_queue = {}

--测试专用, 模拟加载慢效果
local delay_load = 0

ResLoadPriority = {
    min = 0,
    steal = 1, --偷偷加载
    low = 2, --场景其他对象
    mid = 3,
    high = 4, --角色身体
    ui_low = 5, --ui特效
    ui_mid = 6, --ui小界面
    ui_high = 7, --ui大界面
    sync = 8, --同步加载
    max = 9
}

---@class ResManager
ResManager = ResManager or BaseClass()

function ResManager:__init()
    Runner.Instance:AddRunObj(self, 6)
end

function ResManager:__delete()
    Runner.Instance:RemoveRunObj(self)
end

function ResManager:Update()
    self:UpdateLoadQueue()
end

function ResManager:UpdateLoadQueue()
    if #wait_load_obj_queue > 0 then
        local count = 1 + math.ceil(#wait_load_obj_queue / 5)
        count = math.min(count, 1)
        while count > 0 do
            count = count - 1
            local t = wait_load_obj_queue[1]
            if t.time + delay_load > UnityEngine.Time.realtimeSinceStartup then
                break
            end
            t = table.remove(wait_load_obj_queue, 1)
            self:__InternalLoadObject(t.bundle, t.asset, t.callback, t.cb_data, t.asset_type)
        end
    end

    if #wait_load_game_obj_queue > 0 then
        local count = 1 + math.ceil(#wait_load_game_obj_queue / 5)
        count = math.min(count, 1)
        local last_bundle = ""
        local last_asset = ""
        while true do
            if #wait_load_game_obj_queue <= 0 then
                break
            end
            count = count - 1
            local t = wait_load_game_obj_queue[1]
            if count < 0 and t.bundle ~= last_bundle and t.asset ~= last_asset then
                break
            end
            if t.time + delay_load > UnityEngine.Time.realtimeSinceStartup then
                break
            end
            t = table.remove(wait_load_game_obj_queue, 1)
            last_bundle = t.bundle
            last_asset = t.asset
            self:__InternalLoadGameObj(t.bundle, t.asset, t.callback, t.cb_data, t.parent, true)
        end
    end
end

function ResManager:LoadGameObjectAsync(bundle, asset, callback, parent, cb_data, priority)
    if UNITY_EDITOR then
        if not EditorResourceMgr.IsExitsAsset(bundle, asset) then
            print_error("资源不存在，马上检测！！！")
            return
        end
        if priority == nil or priority <= 0 or priority >= 9 then
            print_error("加载优先度设置有误！！！")
            return
        end
    end

    local prefab = ResPoolMgr:TryGetPrefab(bundle, asset)
    if prefab then
        self:__InternalLoadGameObj(bundle, asset, callback, cb_data, parent, true)
        ResPoolMgr:Release(prefab)
    end

    table.insert(wait_load_game_obj_queue, {
        bundle = bundle,
        asset = asset,
        callback = callback,
        time = UnityEngine.Time.realtimeSinceStartup,
        cb_data = cb_data,
        parent = parent,
        priority = priority
    })
end

function ResManager:__InternalLoadGameObj(bundle, asset, callback, cb_data, parent, is_async)
    ResPoolMgr:GetPrefab(bundle, asset, function(prefab)
        if prefab == nil then
            print_error("[ResManager] load game object  error! " .. bundle .. ", " .. asset)
            callback(nil, cb_data)
            return
        end
        local go = self:Instantiate(prefab, true, parent)
        local id = go:GetInstanceID()
        self.go_id_go_map[id] = go
        self.go_id_prefab_map[id] = prefab
        callback(go, cb_data)
    end, nil, nil, is_async)
end

function ResManager:__InternalLoadObject(bundle, asset, callback, cb_data, asset_type)
end

function ResManager:LoadGameObjectSync(bundle, asset, callback, parent, cb_data)
    if UNITY_EDITOR then
        if not EditorResourceMgr.IsExitsAsset(bundle, asset) then
            print_error("资源不存在，马上检测！！！")
            return
        end
    end
    self:__InternalLoadGameObj(bundle, asset, callback, cb_data, parent, false)
end

local function LoadAssetCallback(obj, cb_data)
    local self = cb_data[1]
    local bundle = cb_data[3]
    local callback = cb_data[5]
    local cbd = cb_data[6]
    local need_loads = cb_data[7]
    self:__ReleaseDownLoadBundlesCallbackData(cb_data)

    BundleCache:UnLockBundles(need_loads)
    callback(obj, cbd, bundle)
end

local function LoadMultiBundlesCallback(is_success, cb_data)
    local self = cb_data[1]
    local asset_type = cb_data[2]
    local bundle = cb_data[3]
    local asset = cb_data[4]
    local callback = cb_data[5]
    local cbd = cb_data[6]
    local need_loads = cb_data[7]
    local priority = cb_data[8]
    local is_async = cb_data[9]

    if not is_success then
        BundleCache:UnLockBundles(need_loads)
        callback(nil, cbd, bundle)
        self:__ReleaseDownLoadBundlesCallbackData(cb_data)
        return
    end

    local load_func
    if is_async then
        load_func = AssetBundleMgr.LoadAssetAsync
    else
        load_func = AssetBundleMgr.LoadAssetSync
    end
    --加载asset
    load_func(AssetBundleMgr, bundle, asset, LoadAssetCallback, asset_type, priority, cb_data)
end

local function DownLoadBundlesCallback(is_success, cb_data)
    local self = cb_data[1]
    local bundle = cb_data[3]
    local callback = cb_data[5]
    local cbd = cb_data[6]
    local need_loads = cb_data[7]
    local priority = cb_data[8]

    if not is_success then
        callback(nil, cbd, bundle)
        self:__ReleaseDownLoadBundlesCallbackData(cb_data)
        return
    end

    BundleCache:LockBundles(need_loads)
    local load_func
    if priority >= ResLoadPriority.ui_low and priority <= ResLoadPriority.sync then
        load_func = AssetBundleMgr.LoadMultiBundlesSync
    else
        load_func = AssetBundleMgr.LoadMultiBundlesAsync
    end
    --加载bundle
    load_func(AssetBundleMgr, need_loads, LoadMultiBundlesCallback, priority, cb_data)
end

function ResManager.__LoadObjectAsync(bundle, asset, asset_type, callback, cb_data, priority)
    local need_downloads, need_loads = self:CalcLoadBundleDepends(bundle)
    if need_downloads == nil or need_loads == nil then
        callback(nil, cb_data, bundle)
        return
    end
    local cbd = self:__GetDownLoadBundlesCallbackData()
    cbd[1] = self
    cbd[2] = asset_type
    cbd[3] = bundle
    cbd[4] = asset
    cbd[5] = callback
    cbd[6] = cb_data
    cbd[7] = need_loads
    cbd[8] = priority
    cbd[9] = true

    --下载AB
    AssetBundleMgr:DownLoadBundles(need_downloads, DownLoadBundlesCallback, priority, cbd)
end

function ResManager:__GetDownLoadBundlesCallbackData()

end

function ResManager:CalcLoadBundleDepends(bundle)

end

function ResManager.__LoadObjectSync(bundle, asset, asset_type, callback, cb_data, priority)

end

function ResManager.LoadUnitySceneAsync(bundle, asset, load_mode, callback)

end

function ResManager.LoadUnitySceneSync(bundle, asset, load_mode, callback)

end

