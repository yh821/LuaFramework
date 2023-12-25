---
--- Created by Hugo
--- DateTime: 2023/12/11 15:14
---

require("loader/LoaderBase")

---@class SimulationLoader : LoaderBase
SimulationLoader = BaseClass(LoaderBase)

local UnityGameObject = UnityEngine.GameObject
local UnityDestroy = UnityGameObject.Destroy
local TypeUnityGameObject = typeof(UnityGameObject)

local wait_load_obj_queue = {}
local wait_load_game_obj_queue = {}

function SimulationLoader:__init()
    self.v_goid_prefab_map = {}
    self.v_goid_go_monitors = {}
    self.v_goid_go_monitor_time = 0
    self.load_scene_t = nil
end

function SimulationLoader:Update(now_time, delta_time)
    SimulationLoader.super.Update(self, now_time, delta_time)
    EditorResourceMgr.SweepOriginalInstanceIdMap()
    self:UpdateQueueLoad()
    self:MonitorGameObjLive(now_time)
    self:UpdateSceneLoad()
end

function SimulationLoader:GetPrefab(instance_id)
    return self.v_goid_prefab_map[instance_id]
end

--监测obj是否被移除，逻辑层往往因为在父节点移除而没调用Destroy的方法
function SimulationLoader:MonitorGameObjLive(time)
    if time < self.v_goid_go_monitor_time then
        return
    end
    self.v_goid_go_monitor_time = time + 1

    local die_goids = {}
    local monitor_count = 0
    for k, v in pairs(self.v_goid_go_monitors) do
        monitor_count = monitor_count + 1
        if v:Equals(nil) then
            table.insert(die_goids, k)
        end
    end

    for _, v in ipairs(die_goids) do
        self:ReleaseInObjId(v)
    end

    if #die_goids > 0 then
        print_log("[SimulationLoader] monitor_count=" .. monitor_count .. ", die_game_obj count=" .. #die_goids)
    end
end

function SimulationLoader:Destroy(go)
    self:__Destroy(go)
end

function SimulationLoader:__Destroy(go)
    if IsNil(go) then
        return
    end
    self:ReleaseInObjId(go:GetInstanceID())
    UnityDestroy(go)
end

function SimulationLoader:ReleaseInObjId(instance_id)
    if self.v_goid_prefab_map[instance_id] then
        ResPoolMgr.Instance:Release(self.v_goid_prefab_map[instance_id])
        self.v_goid_go_monitors[instance_id] = nil
        self.v_goid_prefab_map[instance_id] = nil
    end
end

--模拟AB模式加载延迟
local delayLoad = 0

function SimulationLoader:UpdateQueueLoad()
    if #wait_load_obj_queue > 0 then
        local count = 1 + math.ceil(#wait_load_obj_queue / 5)
        count = math.min(count, 1)
        while count > 0 do
            count = count - 1
            local t = wait_load_obj_queue[1]
            if t[CbdIndex.time] + delayLoad > UnityEngine.Time.realtimeSinceStartup then
                break
            end
            table.remove(wait_load_obj_queue, 1)
            self:InternalLoadObject(t[CbdIndex.bundle], t[CbdIndex.asset], t[CbdIndex.type], t[CbdIndex.callback], t[CbdIndex.cb_data])
            CbdPool.ReleaseCbData(t)
        end
    end

    if #wait_load_game_obj_queue > 0 then
        local count = 1 + math.ceil(#wait_load_game_obj_queue / 5)
        count = math.min(count, 1)
        local bundle_name
        local asset_name
        local last_bundle_name
        local last_asset_name
        while true do
            if #wait_load_game_obj_queue <= 0 then
                break
            end
            count = count - 1
            local t = wait_load_game_obj_queue[1]
            bundle_name = t[CbdIndex.bundle]
            asset_name = t[CbdIndex.asset]
            if count < 0 and bundle_name ~= last_bundle_name and asset_name ~= last_asset_name then
                break
            end
            if t[CbdIndex.time] + delayLoad > UnityEngine.Time.realtimeSinceStartup then
                break
            end
            table.remove(wait_load_game_obj_queue, 1)
            last_bundle_name = bundle_name
            last_asset_name = asset_name
            self:__InternalLoadGameObj(bundle_name, asset_name, t[CbdIndex.parent], t[CbdIndex.callback], t[CbdIndex.cb_data], true)
            CbdPool.ReleaseCbData(t)
        end
    end
end

function SimulationLoader:LoadLocalLuaManifest(name)
end

function SimulationLoader:LoadRemoteLuaManifest(callback)
    callback()
end

function SimulationLoader:LoadLocalManifest(name)
end

function SimulationLoader:LoadRemoteManifest(name, callback)
    callback()
end

--异步加载资源(texture,prefab,material等)
function SimulationLoader:LoadObjectAsync(bundle_name, asset_name, asset_type, callback, cb_data, load_priority)
    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.bundle] = bundle_name
    cbd[CbdIndex.asset] = asset_name
    cbd[CbdIndex.type] = asset_type
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    cbd[CbdIndex.priority] = load_priority
    cbd[CbdIndex.time] = Status.NowTime
    table.insert(wait_load_obj_queue, cbd)
end

--同步加载资源(texture,prefab,material等)
function SimulationLoader:LoadObjectSync(bundle_name, asset_name, asset_type, callback, cb_data)
    self:InternalLoadObject(bundle_name, asset_name, asset_type, callback, cb_data)
end

function SimulationLoader:InternalLoadObject(bundle_name, asset_name, asset_type, callback, cb_data)
    asset_type = asset_type or TypeUnityGameObject
    local obj = EditorResourceMgr.LoadObject(bundle_name, asset_name, asset_type)
    if IsNil(obj) then
        print_error("[SimulationLoader] load object error", bundle_name, asset_name)
    else
        BundleCacheMgr.Instance:OnUseBundle(bundle_name)
    end

    callback(obj, cb_data)
end

--异步加载prefab并实例化GameObject
function SimulationLoader:LoadGameObjectAsync(bundle_name, asset_name, parent, callback, cb_data, load_priority)
    if UNITY_EDITOR then
        if not EditorResourceMgr.IsExitsAsset(bundle_name, asset_name) then
            print_error("资源不存在，马上检测！！！")
            return
        end
        if load_priority == nil or load_priority <= 0 or load_priority >= 9 then
            print_error("加载优先度设置有误！！！")
            return
        end
    end

    local prefab = ResPoolMgr.Instance:TryGetPrefab(bundle_name, asset_name)
    if prefab then
        self:__InternalLoadGameObj(bundle_name, asset_name, parent, callback, cb_data, true)
        ResPoolMgr.Instance:Release(prefab)
        return
    end

    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.bundle] = bundle_name
    cbd[CbdIndex.asset] = asset_name
    cbd[CbdIndex.parent] = parent
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    cbd[CbdIndex.priority] = load_priority
    cbd[CbdIndex.time] = Status.NowTime
    table.insert(wait_load_game_obj_queue, cbd)
end

--同步加载prefab并实例化GameObject
function SimulationLoader:LoadGameObjectSync(bundle_name, asset_name, parent, callback, cb_data)
    if UNITY_EDITOR then
        if not EditorResourceMgr.IsExitsAsset(bundle_name, asset_name) then
            print_error("资源不存在，马上检测！！！")
            return
        end
    end

    self:__InternalLoadGameObj(bundle_name, asset_name, parent, callback, cb_data, false)
end

function SimulationLoader:__InternalLoadGameObj(bundle_name, asset_name, parent, callback, cb_data, is_async)
    ResPoolMgr.Instance:GetPrefab(bundle_name, asset_name, function(prefab)
        if prefab == nil then
            print_error("[ResManager] load game object  error:", bundle_name, asset_name)
            callback(nil, cb_data)
            return
        end
        local go = self:Instantiate(prefab, true, parent)
        local id = go:GetInstanceID()
        self.v_goid_go_monitors[id] = go
        self.v_goid_prefab_map[id] = prefab
        callback(go, cb_data)
    end, nil, nil, is_async)
end

function SimulationLoader:UpdateBundle(bundle_name, update_callback, complete_callback, check_hash)
    complete_callback()
end

function SimulationLoader:GetBundlesWithoutCached(bundle_name)
    return nil
end

function SimulationLoader:Instantiate(res, dont_destroy, parent)
    local go = LoaderBase.Instantiate(self, res, dont_destroy, parent)
    EditorResourceMgr.CacheOriginalInstanceMapping(go, res)
    --local go
    --if IsNil(parent) then
    --    go = UnityInstantiate(uobj)
    --else
    --    go = UnityInstantiate(uobj, parent.transform, false)
    --end
    --go.name = uobj.name
    ----存在父节点时，设置DontDestroyOnLoad会报错
    --if dont_destroy and go.transform.parent then
    --    self:DontDestroyOnLoad(go)
    --end
    return go
end

function SimulationLoader:UpdateSceneLoad()
    if self.v_load_scene_t
            and self.v_load_scene_t.load_scene_op
            and self.v_load_scene_t.load_scene_op.isDone
    then
        self.v_load_scene_t.callback(true)
        self.v_load_scene_t = nil
    end
end

function SimulationLoader:LoadUnitySceneAsync(bundle_name, asset_name, load_mode, callback)
    local load_scene_op = EditorResourceMgr.LoadLevelAsync(bundle_name, asset_name, load_mode)
    if not load_scene_op then
        print_error("[SimulationLoader] load level async error:", bundle_name, asset_name)
    end

    if callback then
        callback(load_scene_op)
    end
end

function SimulationLoader:LoadUnitySceneSync(bundle_name, asset_name, load_mode, callback)
    local is_succ = EditorResourceMgr.LoadLevelSync(bundle_name, asset_name, load_mode)
    if not is_succ then
        print_error("[SimulationLoader] load level error:", bundle_name, asset_name)
    end

    if callback then
        callback(is_succ)
    end
end